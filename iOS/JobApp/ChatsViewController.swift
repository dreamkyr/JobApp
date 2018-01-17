//
//  ChatsViewController.swift
//  JobApp
//
//  Created by Admin on 5/24/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toaster
import JSQMessagesViewController
import  MobileCoreServices
import AVKit
import SDWebImage
import CocoaMQTT

class ChatsViewController: JSQMessagesViewController  {
    
    //topbar imagen and name( linked user)
    
    
    public let picker = UIImagePickerController();
    
    // chatting user
    public var chatUser: Profile! = nil
    public var currentUser: Profile! = nil;
    
    // chatting API object
    public var mqtt: CocoaMQTT! = nil;

    // chatting content datasource
    public var messages = [JSQMessage]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.initChatView();
        self.senderId = String(self.currentUser.user_id!)
        self.senderDisplayName = CtrCommon.convertNiltoEmpty(string: self.currentUser.full_name, defaultstr: "")
        self.initMQTT();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scrollToBottom(animated: false)
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {
            self.mqtt.unsubscribe(Constant.MQTTCHAT_TOPIC_PREFIX + self.senderId)
            self.mqtt.disconnect()
        })
    }
}

extension ChatsViewController{
    
    public func initChatView(){
        automaticallyScrollsToMostRecentMessage = true;
        
        //self.collectionView.backgroundColor = UIColor(red: 73.0/255.0, green: 151.0/255.0, blue: 165.0/255.0, alpha: 1)
        self.collectionView.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1)
        let navTitleView:ChatTitleView = ChatTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40));
        navTitleView.initView(photourl: self.chatUser.photo, name: CtrCommon.convertNiltoEmpty(string: self.chatUser.full_name, defaultstr: ""))
        self.navigationItem.titleView = navTitleView;
        
        self.inputToolbar.contentView.leftBarButtonItemWidth = 0
        
        self.picker.delegate = self;
        
        self.initMessage()
    }
    
    public func initMessage(){
        CtrCommon.startRunProcess(viewController: self, completion: {
            
            //
            ChattingProvider.request(.chattingGet(user_id: self.chatUser.user_id)) { result in
                CtrCommon.stopRunProcess();
                switch result {
                case .success(let response):
                    let jsonData = JSON(response.data)
                    switch response.statusCode {
                    case 200:
                        print("test debug: \(jsonData)")
                        for msgJsonData in jsonData["data"].arrayValue{
                            self.messageAdd(senderID: String(msgJsonData["sender"].intValue), name: "sender", type: msgJsonData["type"].stringValue, data: msgJsonData["content"].stringValue, flag: false)
                        }
                        DispatchQueue.main.async {
                            self.collectionView.reloadData();
                        }
                        
                    default:
                        Toast(text: jsonData["message"].stringValue).show()
                        return;
                    }
                case .failure(let error):
                   Toast(text: error.localizedDescription).show();
                }
            }
            //
            /*
           Alamofire.request(Constant.GETCHATHISTORY_URL, method: .post, parameters: ["user_id": self.chatUser.user_id], encoding: JSONEncoding.default).responseJSON { (response) in
                CtrCommon.stopRunProcess();
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data);
                    if jsonData["code"].intValue == 200{
                        for msgJsonData in jsonData["data"].arrayValue{
                            self.messageAdd(senderID: String(msgJsonData["sender"].intValue), name: "sender", type: msgJsonData["type"].stringValue, data: msgJsonData["content"].stringValue, flag: false)
                        }
                        DispatchQueue.main.async {
                            self.collectionView.reloadData();
                        }
                    }else{
                        Toast(text: jsonData["message"].stringValue).show()
                    }
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show();
                    break;
                }
            }*/
            
            
        })
    }
    
    public func initMQTT(){
        let clientID = AppCommon.instance.profile.user_id!
        self.mqtt = CocoaMQTT(clientID: String(describing: clientID), host: Constant.MQTTSERVER_ADDR, port: UInt16(Constant.MQTTSERVERCHAT_PORT))
        self.mqtt!.username = "eswara/jobapp/mqtt"
        self.mqtt!.password = "sOuBQvsIveEIi2dnhpRi"
        
        self.mqtt!.keepAlive = 60
        self.mqtt!.delegate = self
        self.mqtt!.connect()
    }
    
    public func setChatUsers(user: Profile!){
        if user != nil{
            self.chatUser = user
            self.currentUser = AppCommon.instance.profile
        }
    }
    
}

extension ChatsViewController{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        if self.messages[indexPath.row].senderId == self.senderId{
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(red: 206.0/255.0, green: 1.0, blue: 185.0/255.0, alpha: 1))
        }else{
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red: 125.0/255.0, green: 191.0/255.0, blue: 1.0, alpha: 1))
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil;
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let date = Date()
        let sendDate = String(date: date, format: "HH:mm")
        let text = text + "\r\n"+"\(sendDate)"
        let mqttmsgDic = ["type": "text", "content": text, "sender": String(self.currentUser.user_id!)]
        let mqttmsgStr = (JSON(mqttmsgDic)).rawString()
        self.mqtt?.publish(Constant.MQTTCHAT_TOPIC_PREFIX + String(chatUser.user_id!), withString: mqttmsgStr!, qos: .qos1)
        finishSendingMessage();
        self.messageAdd(senderID: self.senderId, name: self.senderDisplayName, type: "text", data: text, flag: true)
        
    }
    
    // attachment icon press action
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let alert = UIAlertController(title: "Media Messages", message: "Please Select A Media", preferredStyle: .actionSheet);
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        
        let photos = UIAlertAction(title: "Photos", style: .default, handler: {(alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeImage);
        })
        
        let videos = UIAlertAction(title: "Videos", style: .default, handler: {(alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeMovie);
        })
        
        alert.addAction(photos);
        alert.addAction(videos);
        alert.addAction(cancel);
        present(alert, animated: true, completion: nil);
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        if cell.textView != nil{
            cell.textView.textColor = UIColor.black
            cell.textView.font = UIFont.systemFont(ofSize: 14.0)
        }
        
        return cell;
    }
    
    public func messageAdd(senderID: String, name: String, type: String, data: String, flag: Bool){
        if type == "text"{
            self.messages.append(JSQMessage(senderId: senderID, displayName: senderDisplayName, text: data));
//            if flag{
                self.collectionView.reloadData();
                let lastItemIndex = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: lastItemIndex, at: .bottom, animated: true)
//            }
        }else if type == "image"{
            if let mediaURL: URL = URL(string: data){
                let mediaItem = JSQPhotoMediaItem(image: UIImage(named: "loadplaceholderimage"))
                let outGoing = senderID == self.senderId
                mediaItem?.appliesMediaViewMaskAsOutgoing = outGoing
                let _ = SDWebImageDownloader.shared().downloadImage(with: mediaURL, options: [], progress: nil, completed: {(image, data, error, finished) in
                    DispatchQueue.main.async {
                        mediaItem?.image = image;
                        self.collectionView.reloadData();
                    }
                })
                self.messages.append(JSQMessage(senderId: senderID, displayName: name, media: mediaItem));
                finishReceivingMessage(animated: true)
            }
        }else{
            if let mediaURL: URL = URL(string: data){
                let video = JSQVideoMediaItem(fileURL: mediaURL, isReadyToPlay: true);
                if senderID == self.senderId {
                    video?.appliesMediaViewMaskAsOutgoing = true;
                } else {
                    video?.appliesMediaViewMaskAsOutgoing = false;
                }
                messages.append(JSQMessage(senderId: senderID, displayName: name, media: video));
//                if flag{
                    self.collectionView.reloadData();
//                }
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let msg = messages[indexPath.item];
        if msg.isMediaMessage {
            if let mediaItem = msg.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL);
                let playerController = AVPlayerViewController();
                playerController.player = player;
                self.present(playerController, animated: true, completion: nil);
            }
        }
    }
    
}




extension ChatsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    public func chooseMedia(type: CFString) {
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let data = UIImageJPEGRepresentation(pic, 0.001);
            Alamofire.upload(multipartFormData: { (MultipartFormData) in
                MultipartFormData.append(data!, withName: "file", fileName: "file", mimeType: "image/jpg")
            }, to: Constant.FILEUPLOAD_URL, encodingCompletion: { (result) in
                switch result{
                case .success(let upload, _, _):
                    upload.uploadProgress{(progress) in
                        
                    }
                    upload.responseJSON(completionHandler: { (response) in
                        switch response.result{
                        case .success(let data):
                            let jsonData = JSON(data)
                            if jsonData["code"].intValue == 200{
                                let fileURL = jsonData["data"].stringValue
                                let mqttmsgDic = ["type": "image", "content": fileURL, "sender": String(self.currentUser.user_id!)]
                                
                                let mqttmsgStr = (JSON(mqttmsgDic)).rawString()
                                
                                self.mqtt?.publish(Constant.MQTTCHAT_TOPIC_PREFIX + String(self.chatUser.user_id!), withString: mqttmsgStr!, qos: .qos1)
                                DispatchQueue.main.async {
                                    self.messageAdd(senderID: self.senderId, name: self.senderDisplayName, type: "image", data: fileURL, flag: true);
                                }
                            }
                            break;
                        case .failure(let error):
                            print(error.localizedDescription);
                            break;
                        }
                    })
                    break;
                case.failure(let error):
                    print(error.localizedDescription)
                    break;
                }
            })
           
        } else if let vidURL = info[UIImagePickerControllerMediaURL] as? URL {
            Alamofire.upload(multipartFormData: { (MultipartFormData) in
                MultipartFormData.append(vidURL, withName: "file")
            }, to: Constant.FILEUPLOAD_URL, encodingCompletion: { (result) in
                switch result{
                case .success(let upload, _, _):
                    upload.uploadProgress{(progress) in
                        print(progress)
                    }
                    upload.responseJSON(completionHandler: { (response) in
                        switch response.result{
                        case .success(let data):
                            let jsonData = JSON(data)
                            if jsonData["code"].intValue == 200{
                                let fileURL = jsonData["data"].stringValue
                                let mqttmsgDic = ["type": "video", "content": fileURL, "sender": String(self.currentUser.user_id!)]
                                let mqttmsgStr = (JSON(mqttmsgDic)).rawString()
                                self.mqtt?.publish(Constant.MQTTCHAT_TOPIC_PREFIX + String(self.chatUser.user_id!), withString: mqttmsgStr!, qos: .qos1)
                                DispatchQueue.main.async {
                                    self.messageAdd(senderID: self.senderId, name: self.senderDisplayName, type: "video", data: fileURL, flag: true);
                                }
                            }
                            break;
                        case .failure(let error):
                            print(error.localizedDescription);
                            break;
                        }
                    })
                    break;
                case.failure(let error):
                    print(error.localizedDescription)
                    break;
                }
            })
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                DispatchQueue.main.async {
                    self.collectionView.reloadData();
                }
            });
        }
    }
}

extension ChatsViewController:CocoaMQTTDelegate{
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        
    }
    
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        self.mqtt?.subscribe(Constant.MQTTCHAT_TOPIC_PREFIX + self.senderId, qos: CocoaMQTTQOS.qos1)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck _ id \(id)");
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        let notiJsonData = JSON(parseJSON: message.string!);
        let sender_id = notiJsonData["sender"].intValue;
        if sender_id == self.chatUser.user_id{
            let sender_name = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.getChatList(id: sender_id).linked_user.full_name, defaultstr: "")
            self.messageAdd(senderID: String(sender_id), name: sender_name, type: notiJsonData["type"].stringValue, data: notiJsonData["content"].stringValue, flag: true)
        }else{
            AppCommon.instance.chatNotification.append(sender_id);
            (AppCommon.instance.rootVc as! RootTabViewController).viewChatNotification()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        
    }
    
    func _console(_ info: String) {
        
    }
    
}
