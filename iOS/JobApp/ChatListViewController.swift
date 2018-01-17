//
//  ChatListViewController.swift
//  JobApp
//
//  Created by Admin on 5/25/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toaster


class ChatListViewController: UIViewController{

    public let cellId: String = "ChatListCell"
    public var selectAvaliable:Bool = false;
    public var selectedDeleteChatList: [Int] = []
    
    @IBOutlet weak var chatListTable: UITableView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    public var addUsers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.doneBtn.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.addUsers += AppCommon.instance.chatNotification
        self.chatListAddUsers(params: self.addUsers)
        self.addUsers = []
    }
    
    public func setNotification(){
        if AppCommon.instance.chatNotification.count != 0{
            self.addUsers += AppCommon.instance.chatNotification
            self.chatListAddUsers(params: self.addUsers)
            self.addUsers = [];
        }
    }
    
    public func chatListAddUsers(params: [Int]){
        CtrCommon.startRunProcess(viewController: self, completion: {
            
            //
            ChatlistProvider.request(.chatlistAdd(linked_users: params)) { result in
                CtrCommon.stopRunProcess();
                switch result {
                case .success(let response):
                    let jsonData = JSON(response.data)
                    switch response.statusCode {
                    case 200:
                        
                        AppCommon.instance.chatLinkUsers = [];
                        for chatlistdata in jsonData["data"].arrayValue{
                            AppCommon.instance.chatLinkUsers.append(ChatList(chatlistdata.dictionaryObject!))
                        }
                        DispatchQueue.main.async {
                            self.chatListTable.reloadData();
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
            Alamofire.request(Constant.ADDCHATLIST_URL, method: .post, parameters: ["linked_users": params], encoding: JSONEncoding.default).responseJSON { (response) in
                CtrCommon.stopRunProcess();
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data)
                    if jsonData["code"].intValue == 200{
                        AppCommon.instance.chatLinkUsers = [];
                        for chatlistdata in jsonData["data"].arrayValue{
                            AppCommon.instance.chatLinkUsers.append(ChatList(chatlistdata.dictionaryObject!))
                        }
                        DispatchQueue.main.async {
                            self.chatListTable.reloadData();
                        }
                    }else{
                        Toast(text: jsonData["message"].stringValue).show()
                    }
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    break;
                }
            }*/
            
            
        })
    }
    
    @IBAction func deleteBtnAction(_ sender: UIButton) {
        if self.selectAvaliable{
            self.selectAvaliable = false;
            self.deleteBtn.setTitle("Delete", for: .normal)
            self.doneBtn.isHidden = true
        }else{
            self.selectAvaliable = true;
            self.deleteBtn.setTitle("Cancel", for: .normal)
            self.doneBtn.isHidden = false
        }
        self.chatListTable.reloadData();
    }
    
    @IBAction func doneBtnAction(_ sender: UIButton){
        self.deleteBtn.setTitle("Delete", for: .normal)
        self.selectAvaliable = false;
        if self.selectedDeleteChatList.count == 0{
            self.doneBtn.isHidden = true
            self.chatListTable.reloadData();
            return;
        }
        CtrCommon.startRunProcess(viewController: self, completion: {
            Alamofire.request(Constant.REMOVECHATLIST_URL, method: .post, parameters: ["delete_ids": self.selectedDeleteChatList], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                CtrCommon.stopRunProcess();
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data)
                    if jsonData["code"].intValue == 200{
                        for delId in self.selectedDeleteChatList{
                            AppCommon.instance.deletChatList(id: delId)
                        }
                    }
                    Toast(text: jsonData["message"].stringValue).show()
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    break;
                }
                DispatchQueue.main.async {
                    self.chatListTable.reloadData();
                }
            }
        })
    }

    @IBAction func addBtnAction(_ sender: UIButton) {
        self.goto(to: Constant.SELECTCONTACTS_VC, params: nil)
    }
    
    public func selectDeleteChatLists(_ id: Int){
        for i in 0 ..< self.selectedDeleteChatList.count{
            if self.selectedDeleteChatList[i] == id{
                self.selectedDeleteChatList.remove(at: i)
                return;
            }
        }
        self.selectedDeleteChatList.append(id);
    }
    
    public func goto(to:String, params: Any!){
        if to == Constant.CHATS_VC{
            let toVc: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: to) as! UINavigationController
            let chatVc: ChatsViewController = toVc.viewControllers.first as! ChatsViewController
            chatVc.setChatUsers(user: (params as! ChatList).linked_user)
            self.present(toVc, animated: true, completion: nil)
        }else if to == Constant.SELECTCONTACTS_VC{
            let toVc: SelecteContactsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: to) as! SelecteContactsViewController
            toVc.parentVc = self;
            self.present(toVc, animated: true, completion: nil);
        }
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppCommon.instance.chatLinkUsers.count
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell: ChatListCell = tableView.cellForRow(at: indexPath) as! ChatListCell;
        if self.selectAvaliable{
            if cell.checkIconImage.image == UIImage(named: "option"){
                cell.checkIconImage.image = UIImage(named: "option_focus");
            }else{
                cell.checkIconImage.image = UIImage(named: "option");
            }
            self.selectDeleteChatLists(AppCommon.instance.chatLinkUsers[indexPath.row].id)
        }else{
            cell.checkIconImage.image = nil;
        }
        return indexPath;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatListCell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! ChatListCell
        cell.contentView.backgroundColor = UIColor.clear
        cell.setData(params: AppCommon.instance.chatLinkUsers[indexPath.row]);
        cell.unSetNotification()
        for notiuser_id in AppCommon.instance.chatNotification{
            if notiuser_id == AppCommon.instance.chatLinkUsers[indexPath.row].linked_user.user_id{
                cell.setNotification();
            }
        }
        if self.selectAvaliable{
            cell.checkIconImage.image = UIImage(named: "option");
        }else{
            cell.checkIconImage.image = nil;
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.selectAvaliable{
            for i in 0 ..< AppCommon.instance.chatNotification.count{
                if AppCommon.instance.chatNotification[i] == AppCommon.instance.chatLinkUsers[indexPath.row].linked_user.user_id{
                    AppCommon.instance.chatNotification.remove(at: i)
                }
            }
            self.goto(to: Constant.CHATS_VC, params: AppCommon.instance.chatLinkUsers[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChatListCell
        cell.contentView.backgroundColor = UIColor(white: 1, alpha: 0.2)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChatListCell
        cell.contentView.backgroundColor = UIColor.clear
    }
}
