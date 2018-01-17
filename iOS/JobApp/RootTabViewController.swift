//
//  RootTabViewController.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 15/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation

import AVFoundation
import UIKit
import AZTabBar
import CocoaMQTT
import SwiftyJSON
import Contacts


class RootTabViewController: UIViewController {
    
    private var settingVc: SettingViewController! = nil;
    private var contactsVc: ContactRootViewController! = nil;
    private var findJobsVc: FindJobViewController! = nil;
    private var myJobsVc: ReferedJobsViewController! = nil;
    private var chatVc: ChatListViewController! = nil;
    
    private var contactNotiLabel: UILabel!
    private var jobNotiLabel: UILabel!
    private var chatNotiLabel: UILabel!
    private var postedJobNotiLabel: UILabel!
    
    private var topNotificationView: UIView!
    private var topNotificationLabel: UILabel!
    
    var tabController:AZTabBarController!
    
    public var mqtt: CocoaMQTT? = nil
    public var currentVc: UIViewController! = nil
    public var flag: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppCommon.instance.rootVc = self;
        //The icons that will be displayed on the tabs that are not currently selected
        var icons = [String]()
        icons.append("network")
        icons.append("find_jobs")
        icons.append("post_jobs")
        icons.append("jolts")
        icons.append("settings_s")

        //The icons that will be displayed for each tab once they are selected.
        var selectedIcons = [String]()
        selectedIcons.append("network")
        selectedIcons.append("find_jobs")
        selectedIcons.append("post_jobs")
        selectedIcons.append("jolts")
        selectedIcons.append("settings_s")

        

        tabController = AZTabBarController.insert(into: self, withTabIconNames: icons, andSelectedIconNames: selectedIcons)
        
        tabController.delegate = self
        
       // let myChildViewController = UIStoryboard(name: "GetStarted", bundle: nil).instantiateViewController(withIdentifier: "GetStartedViewController")
        
        self.settingVc = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: Constant.SETTING_VC) as! SettingViewController
        self.contactsVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constant.ROOTCONTACTS_VC) as! ContactRootViewController
        self.findJobsVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constant.FINDJOB_VC) as! FindJobViewController
        self.myJobsVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constant.REFEREDJOB_VC) as! ReferedJobsViewController
        self.chatVc = UIStoryboard(name: "ChatList", bundle: nil).instantiateViewController(withIdentifier: Constant.CHATLIST_VC) as! ChatListViewController

        self.settingVc.flag = true;
        
        tabController.setViewController(self.contactsVc, atIndex: 0)
        tabController.setViewController(self.findJobsVc, atIndex: 1)
        tabController.setViewController(self.myJobsVc, atIndex: 2)
        tabController.setViewController(self.chatVc, atIndex: 3)
        tabController.setViewController(self.settingVc, atIndex: 4)
        
        //customize
        
        tabController.selectedColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) //UIColor(colorLiteralRed: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0)
        
        tabController.highlightColor = .white
        
        //tabController.highlightedBackgroundColor
        
        tabController.defaultColor = #colorLiteral(red: 0.09048881881, green: 0.09048881881, blue: 0.09048881881, alpha: 1)
        
        tabController.buttonsBackgroundColor = .white//#colorLiteral(red: 0.2039215686, green: 0.2862745098, blue: 0.368627451, alpha: 1)
        
        tabController.selectionIndicatorHeight = 0
        
        tabController.selectionIndicatorColor = .white
        
        tabController.tabBarHeight = 62
        
        tabController.notificationBadgeAppearance.backgroundColor = .red
        tabController.notificationBadgeAppearance.textColor = .white
        tabController.notificationBadgeAppearance.borderColor = .red
        tabController.notificationBadgeAppearance.borderWidth = 0.2
        
        tabController.setIndex(0, animated: true)
        
        let frTabVC = tabController.view.frame
        let badgeSize: CGFloat = 12.0
        let interval: CGFloat = frTabVC.size.width / 5
        contactNotiLabel = UILabel(frame: CGRect(x: interval * 0.5 + 10, y: frTabVC.size.height - 50.0, width: badgeSize, height: badgeSize))
        contactNotiLabel.backgroundColor = UIColor.red
        contactNotiLabel.layer.cornerRadius = badgeSize / 2
        contactNotiLabel.clipsToBounds = true
        contactNotiLabel.textColor = UIColor.white
        contactNotiLabel.font = UIFont.systemFont(ofSize: 8)
        contactNotiLabel.text = "0"
        contactNotiLabel.textAlignment = .center
        tabController.view.addSubview(contactNotiLabel)
        contactNotiLabel.isHidden = true
        
        postedJobNotiLabel = UILabel(frame: CGRect(x: interval * 1.5 + 10, y: frTabVC.size.height - 50.0, width: badgeSize, height: badgeSize))
        postedJobNotiLabel.backgroundColor = UIColor.red
        postedJobNotiLabel.layer.cornerRadius = badgeSize / 2
        postedJobNotiLabel.clipsToBounds = true
        postedJobNotiLabel.textColor = UIColor.white
        postedJobNotiLabel.font = UIFont.systemFont(ofSize: 8)
        postedJobNotiLabel.text = "0"
        postedJobNotiLabel.textAlignment = .center
        tabController.view.addSubview(postedJobNotiLabel)
        postedJobNotiLabel.isHidden = true
        
        jobNotiLabel = UILabel(frame: CGRect(x: interval * 2.5 + 10, y: frTabVC.size.height - 50.0, width: badgeSize, height: badgeSize))
        jobNotiLabel.backgroundColor = UIColor.red
        jobNotiLabel.layer.cornerRadius = badgeSize / 2
        jobNotiLabel.clipsToBounds = true
        jobNotiLabel.textColor = UIColor.white
        jobNotiLabel.font = UIFont.systemFont(ofSize: 8)
        jobNotiLabel.text = "0"
        jobNotiLabel.textAlignment = .center
        tabController.view.addSubview(jobNotiLabel)
        jobNotiLabel.isHidden = true
        
        chatNotiLabel = UILabel(frame: CGRect(x: interval * 3.5 + 10, y: frTabVC.size.height - 50.0, width: badgeSize, height: badgeSize))
        chatNotiLabel.backgroundColor = UIColor.red
        chatNotiLabel.layer.cornerRadius = badgeSize / 2
        chatNotiLabel.clipsToBounds = true
        chatNotiLabel.textColor = UIColor.white
        chatNotiLabel.font = UIFont.systemFont(ofSize: 8)
        chatNotiLabel.text = "0"
        chatNotiLabel.textAlignment = .center
        tabController.view.addSubview(chatNotiLabel)
        chatNotiLabel.isHidden = true
        
        
        
        let heightNotificaiton: CGFloat = 70.0
        let heightCompleteProfileButton: CGFloat = 30.0
        
        topNotificationView = UIView(frame: CGRect(x: 0, y: -heightNotificaiton, width: tabController.view.frame.size.width, height: heightNotificaiton))
        topNotificationView.backgroundColor = UIColor.init(colorLiteralRed: 13.0 / 255.0, green: 109.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0)
        
        topNotificationLabel = UILabel(frame: CGRect(x: 10, y: 20, width: tabController.view.frame.size.width - 120, height: heightNotificaiton - 20))
        topNotificationLabel.backgroundColor = UIColor.clear
        topNotificationLabel.textColor = UIColor.white
        topNotificationLabel.font = UIFont.systemFont(ofSize: 12)
        topNotificationLabel.numberOfLines = 0
        topNotificationLabel.text = ""
        topNotificationLabel.textAlignment = .center
        topNotificationLabel.isUserInteractionEnabled = true
        topNotificationView.addSubview(topNotificationLabel)
        
        let completeButton = UIButton(frame: CGRect(x: tabController.view.frame.size.width - 110,
                                                    y: 20 + (heightNotificaiton - 20 - heightCompleteProfileButton) / 2,
                                                    width: 80,
                                                    height: heightCompleteProfileButton))
        completeButton.setTitle("Update Profile", for: .normal)
        completeButton.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
        completeButton.setTitleColor(UIColor.white, for: .normal)
        completeButton.layer.cornerRadius = 5
        completeButton.layer.borderColor = UIColor.white.cgColor
        completeButton.layer.borderWidth = 1
        completeButton.addTarget(self, action: #selector(tapNotification), for: .touchUpInside)
        topNotificationView.addSubview(completeButton)
        
        tabController.view.addSubview(topNotificationView)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapNotification))
        topNotificationLabel.addGestureRecognizer(tapGesture)
        
        if AppCommon.instance.profile == nil{
            self.loadData()
        }else{
            self.initMqtt()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshNotification()
    }
    
    public func showTopNotification(msg: String) {
        self.topNotificationLabel.text = "Please complete your profile before proceeding further. Thank You."//msg
        UIView.animate(withDuration: 0.3, animations: {
            self.topNotificationView.center = CGPoint(x: self.topNotificationView.center.x, y: self.topNotificationView.frame.size.height / 2)
        }) { (success) in
            self.perform(#selector(self.hideTopNotification), with: nil, afterDelay: 10.0)
        }
    }
    
    public func hideTopNotification() {
        UIView.animate(withDuration: 0.3, animations: {
            self.topNotificationView.center = CGPoint(x: self.topNotificationView.center.x, y: -self.topNotificationView.frame.size.height / 2)
        }) { (success) in
        }
    }
    
    public func tapNotification() {
        hideTopNotification()
        self.settingVc.gotoUpdateProfile = true
        tabController.setIndex(4, animated: true)
    }
    
    public func loadData(){
        
        let contactStroe = CNContactStore()
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactEmailAddressesKey,
                           CNContactPhoneNumbersKey,
                           CNContactImageDataAvailableKey,
                           CNContactThumbnailImageDataKey] as [Any]
        
            contactStroe.requestAccess(for: .contacts, completionHandler: { (granted, error) -> Void in
                if granted {
                    
                     AppCommon.instance.phoneContactData.removeAll()
                    
                    let predicate = CNContact.predicateForContactsInContainer(withIdentifier: contactStroe.defaultContainerIdentifier())
                    var contacts: [CNContact]! = []
                    do {
                        contacts = try contactStroe.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])// [CNContact]
                    }catch {
                        
                    }
                    for contact in contacts{
                        var myContactProfileData: [String: Any] = [:]
                        myContactProfileData["first_name"] = contact.givenName;
                        myContactProfileData["last_name"] = contact.familyName
                        if !contact.emailAddresses.isEmpty{
                            for email: CNLabeledValue in contact.emailAddresses{
                                let mailvalue = email.value
                                let mailvalueArray = mailvalue.components(separatedBy: "@")
                                if mailvalueArray.count > 1{
                                    myContactProfileData["email"] = mailvalueArray[0] + "@" + mailvalueArray[1]
                                }
                            }
                        }
                        if !contact.phoneNumbers.isEmpty{
                            for number: CNLabeledValue in contact.phoneNumbers{
                                let numbervalue = number.value
                                myContactProfileData["code"] = numbervalue.value(forKey: "countryCode") as? String
                                myContactProfileData["phone"] = numbervalue.value(forKey: "digits") as? String
                            }
                        }
                        
                        let myContactProfile: Profile = Profile(myContactProfileData)
                        let myContact = Contact()
                        myContact.profile = myContactProfile
                        AppCommon.instance.phoneContactData.append(myContact)
                    }
                    //var requestParams: [String: Any] = [:]
                    //requestParams["email"] = UserDefaults.standard.value(forKey: "useremail") as! String
                    //requestParams["password"] = UserDefaults.standard.value(forKey: "userpass") as! String
                    var params: [[String: Any]] = []
                    for phoneContact in AppCommon.instance.phoneContactData{
                        let param: [String: Any] = phoneContact.getDicData()
                        params.append(param)
                    }
                    
                    UserProvider.request(.me(phone_contacts: params)) { result in
                        switch result {
                        case .success(let response):
                            
                            let json = JSON(response.data)
                            switch response.statusCode {
                            case 200:
                                
                                print("test test")
                                if AppCommon.instance.initApp(data: json["data"]){
                                    (AppCommon.instance.rootVc as! RootTabViewController).initMqtt();
                                    
                                    NotificationsProvider.request(.notificationGet){ result in
                                        switch result {
                                        case .success(let response):
                                            let jsonData = JSON(response.data)
                                            if jsonData["code"].intValue == 200{
                                                for notiData in jsonData["data"].arrayValue{
                                                    (AppCommon.instance.rootVc as! RootTabViewController).notificationMsgProcess(notiData.rawString()!);
                                                }
                                            }
                                            break;
                                            
                                        case .failure(let error):
                                            print(error.localizedDescription);
                                            break;
                                        }
                                        
                                    }
                                    SharedKeycard.token = json["data"]["token"].string!
                                }
                                
                            default:
                                if json["message"].stringValue == "Account not exists." {
                                    print("me error 4")
                                    SharedKeycard.removeToken()
                                    SharedKeycard.verified = false
                                } else {
                                }
                            }
                        case .failure(let error):
                            break
                        }
                    }
                }else{
                }
            })
    }
    
    public func refreshNotification(){
        self.viewChatNotification()
        self.viewContactNotification()
        self.viewJobPostNotification()
        self.viewShareJobNotification()
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController?{
        return tabController
    }
    
    
    public func initMqtt(){
        let clientID = AppCommon.instance.profile.user_id!
        self.mqtt = CocoaMQTT(clientID: String(describing: clientID), host: Constant.MQTTSERVER_ADDR, port: UInt16(Constant.MQTTSERVERNOTI_PORT))
        self.mqtt?.username = "eswara/jobapp/mqtt"
        self.mqtt?.password = "sOuBQvsIveEIi2dnhpRi"
        
        self.mqtt?.keepAlive = 60
        self.mqtt?.delegate = self
        self.mqtt?.connect()
    }
    
    public func viewContactNotification(){
        if AppCommon.instance.contactNotificationNumber + AppCommon.instance.getSharedNotificationCount() == 0{
            DispatchQueue.main.async {
                self.contactNotiLabel.isHidden = true
            }
        }else{
            if UserDefaults.standard.bool(forKey: "shownoti_flag"){
                DispatchQueue.main.async {
                    self.contactNotiLabel.isHidden = false
                    self.contactNotiLabel.text = String(AppCommon.instance.getSharedNotificationCount() + AppCommon.instance.contactNotificationNumber);
                }
            }
        }
    }
    
    public func viewJobPostNotification(){
        if AppCommon.instance.getJobNotificationCount() == 0{
            DispatchQueue.main.async {
               self.postedJobNotiLabel.isHidden = true
            }
        }else{
            if UserDefaults.standard.bool(forKey: "shownoti_flag"){
                DispatchQueue.main.async {
                    self.postedJobNotiLabel.isHidden = false
                    self.postedJobNotiLabel.text = String(AppCommon.instance.getJobNotificationCount());
                }
            }
        }
    }
    
    public func viewShareJobNotification(){
        if AppCommon.instance.getSharedNotificationCount() == 0{
            DispatchQueue.main.async {
                self.jobNotiLabel.isHidden = true
            }
        }else{
            if UserDefaults.standard.bool(forKey: "shownoti_flag"){
                DispatchQueue.main.async {
                    self.jobNotiLabel.isHidden = false
                    self.jobNotiLabel.text = String(AppCommon.instance.getSharedNotificationCount());
                }
            }
        }
    }
    
    public func viewChatNotification(){
        if AppCommon.instance.chatNotification.count == 0{
            DispatchQueue.main.async {
                self.chatNotiLabel.isHidden = true
            }
        }else{
            if UserDefaults.standard.bool(forKey: "shownoti_flag"){
                DispatchQueue.main.async {
                    self.chatNotiLabel.isHidden = false
                    self.chatNotiLabel.text = String(AppCommon.instance.chatNotification.count);
                }
            }
        }
    }
    
    public static func viewChatNotification(){
        self.viewChatNotification();
    }
    
    public static func viewJobPostNotification(){
        self.viewJobPostNotification();
    }
    
    public static func viewContactNotification(){
        self.viewContactNotification()
    }
    
    public func setBackgroundNotification(msg: String){
        let notification = UILocalNotification()
        notification.alertTitle = "Job App"
        notification.alertBody = msg
        notification.fireDate = NSDate(timeIntervalSinceNow: 5) as Date
        UIApplication.shared.scheduledLocalNotifications = [notification]
    }
    
    public func notificationMsgProcess(_ message: String){
        if UserDefaults.standard.bool(forKey: "shownoti_flag"){
            CtrCommon.playNotiSound();
        }else{
            AppCommon.instance.removeAllNotification()
        }
        let notiJsonData = JSON(parseJSON: message);
        if notiJsonData["type"].stringValue == Constant.MQTTNOTI_CONTACT{
            if let _ = self.currentVc as? ContactRootViewController {
                (self.currentVc as! ContactRootViewController).setNotification();
            }else{
                AppCommon.instance.contactNotificationNumber += 1;
                self.viewContactNotification();
            }
        }else if notiJsonData["type"].stringValue == Constant.MQTTNOTI_JOBPOSTED{
            let notiContentData = JSON(parseJSON: notiJsonData["content"].stringValue)
            let currentNotiJobId: Int = notiContentData["job_id"].intValue
            let userId: Int = notiContentData["referrer"].intValue;
            if AppCommon.instance.jobNotification[String(userId)] == nil{
                AppCommon.instance.jobNotification[String(userId)] = []
            }
            AppCommon.instance.jobNotification[String(userId)]!.append("\(currentNotiJobId)")
            if let _ = self.currentVc as? FindJobViewController{
                (self.currentVc as! FindJobViewController).setNotification();
            }
            self.viewJobPostNotification();
        }else if notiJsonData["type"].stringValue == Constant.MQTTNOTI_JOBSHARED{
            let notiContentData = JSON(parseJSON: notiJsonData["content"].stringValue)
            let currentNotiJobId: Int = notiContentData["job_id"].intValue
            let userId: Int = notiContentData["referrer"].intValue;
            if AppCommon.instance.sharedNotification[String(userId)] == nil{
                AppCommon.instance.sharedNotification[String(userId)] = []
            }
            AppCommon.instance.sharedNotification[String(userId)]!.append("\(currentNotiJobId)")
            if let _ = self.currentVc as? ContactsViewController{
                (self.currentVc as! ContactsViewController).refreshData();
            }
            self.viewContactNotification();
        }else if notiJsonData["type"].stringValue == Constant.MQTTNOTI_CHAT{
            print(notiJsonData["content"])
            let notiContentData = JSON(parseJSON: notiJsonData["content"].stringValue)
            let chat_userid = notiContentData["chat_user"].intValue;
            for chatnoti_userid in AppCommon.instance.chatNotification{
                if chatnoti_userid == chat_userid{
                    return;
                }
            }
            AppCommon.instance.chatNotification.append(chat_userid)
            
            if let _ = self.currentVc as? ChatListViewController{
                (self.currentVc as! ChatListViewController).setNotification();
            }else{
                self.viewChatNotification();
            }
        }
    }

}


extension RootTabViewController: AZTabBarDelegate{
    func tabBar(_ tabBar: AZTabBarController, statusBarStyleForIndex index: Int) -> UIStatusBarStyle {
        return (index % 2) == 0 ? .default : .lightContent
    }
    
    func tabBar(_ tabBar: AZTabBarController, shouldLongClickForIndex index: Int) -> Bool {
        return false//index != 2 && index != 3
    }
    
    func tabBar(_ tabBar: AZTabBarController, shouldAnimateButtonInteractionAtIndex index: Int) -> Bool {
        return !(index == 3 || index == 2)
    }
    
    func tabBar(_ tabBar: AZTabBarController, didMoveToTabAtIndex index: Int) {
        print("didMoveToTabAtIndex \(index)")
    }
    
    func tabBar(_ tabBar: AZTabBarController, didSelectTabAtIndex index: Int) {
        print("didSelectTabAtIndex \(index)")
    }
    
    func tabBar(_ tabBar: AZTabBarController, willMoveToTabAtIndex index: Int) {
        print("willMoveToTabAtIndex \(index)")
    }
    
    func tabBar(_ tabBar: AZTabBarController, didLongClickTabAtIndex index: Int) {
        print("didLongClickTabAtIndex \(index)")
    }
    
    
}

extension RootTabViewController: CocoaMQTTDelegate{
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        
    }
    
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            self.mqtt?.subscribe(Constant.MQTTNOTI_TOPIC_PREFIX + String(AppCommon.instance.profile.user_id!))
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck _ id \(id)");
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        self.notificationMsgProcess(message.string!);
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
