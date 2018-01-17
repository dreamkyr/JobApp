//
//  RootViewController.swift
//  JobApp
//
//  Created by JaonMicle on 16/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import CocoaMQTT
import SwiftyJSON
import Alamofire

class RootViewController: UIViewController {
    
    private var settingVc: SettingViewController! = nil;
    private var contactsVc: ContactRootViewController! = nil;
    private var findJobsVc: FindJobViewController! = nil;
    private var myJobsVc: ReferedJobsViewController! = nil;
    private var chatVc: ChatListViewController! = nil;
    
    public var mqtt: CocoaMQTT? = nil
    
    @IBOutlet weak var contactNotiView: EffectView!
    @IBOutlet weak var contactNotiLabel: UILabel!
    @IBOutlet weak var jobNotiView: EffectView!
    @IBOutlet weak var jobNotiLabel: UILabel!
    @IBOutlet weak var chatNotiView: EffectView!    
    @IBOutlet weak var chatNotiLabel: UILabel!
    @IBOutlet weak var postedJobNotiView: EffectView!
    @IBOutlet weak var postedJobNotiLabel: UILabel!
    
    
    @IBOutlet weak var tabContactIcon: UIImageView!
    @IBOutlet weak var tabContactLabel: UILabel!
    
    @IBOutlet weak var tabFindJobsIcon: UIImageView!
    @IBOutlet weak var tabFindJobsLabel: UILabel!
    
    @IBOutlet weak var tabMyJobsIcon: UIImageView!
    @IBOutlet weak var tabMyJobsLabel: UILabel!
    
    @IBOutlet weak var tabChatIcon: UIImageView!
    @IBOutlet weak var tabChatLabel: UILabel!
    
    @IBOutlet weak var tabSettingIcon: UIImageView!
    @IBOutlet weak var tabSettingLabel: UILabel!
    
    @IBOutlet weak var tabmenuCtView: UIView!
    @IBOutlet weak var tabbarCtView: EffectView!
    
    public var currentVc: UIViewController! = nil
    
    public var flag: Bool = false;
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        AppCommon.instance.rootVc = self;
        
        self.settingVc = self.storyboard?.instantiateViewController(withIdentifier: Constant.SETTING_VC) as! SettingViewController
        self.contactsVc = self.storyboard?.instantiateViewController(withIdentifier: Constant.ROOTCONTACTS_VC) as! ContactRootViewController
        self.findJobsVc = self.storyboard?.instantiateViewController(withIdentifier: Constant.FINDJOB_VC) as! FindJobViewController
        self.myJobsVc = self.storyboard?.instantiateViewController(withIdentifier: Constant.REFEREDJOB_VC) as! ReferedJobsViewController
        self.chatVc = self.storyboard?.instantiateViewController(withIdentifier: Constant.CHATLIST_VC) as! ChatListViewController
        self.settingVc.flag = true;
        self.switchViewController(from: nil, to: self.settingVc)
        self.currentVc = self.settingVc;
        
        //Flat UI
        tabmenuCtView.backgroundColor = myGreenBgColor
        //tabbarCtView.backgroundColor = myBlueBgcolor
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshNotification()
    }
    
    public func refreshNotification(){
        self.viewChatNotification()
        self.viewContactNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if self.settingVc != nil && self.settingVc!.view.superview == nil {
            self.settingVc = nil
        }
        if self.contactsVc != nil && self.contactsVc!.view.superview == nil {
            self.contactsVc = nil
        }
        if self.findJobsVc != nil && self.findJobsVc!.view.superview == nil {
            self.findJobsVc = nil
        }
        if self.myJobsVc != nil && self.myJobsVc!.view.superview == nil {
            self.myJobsVc = nil
        }
        if self.chatVc != nil && self.chatVc!.view.superview == nil {
            self.chatVc = nil
        }
    }
    
    public func selectedTabInitView(){
//        self.tabContactIcon.image = UIImage(named: "tabcontacticon-w")
//        self.tabFindJobsIcon.image = UIImage(named: "tabfindjobicon-w")
//        self.tabMyJobsIcon.image = UIImage(named: "tabreferjobicon-w")
//        self.tabChatIcon.image = UIImage(named: "tabchaticon-w")
//        self.tabSettingIcon.image = UIImage(named: "tabsettingicon-w")
        
//        self.tabContactLabel.textColor = UIColor.white
//        self.tabFindJobsLabel.textColor = UIColor.white
//        self.tabMyJobsLabel.textColor = UIColor.white
//        self.tabChatLabel.textColor = UIColor.white
//        self.tabSettingLabel.textColor = UIColor.white
        
//        if self.currentVc == self.contactsVc{
//            self.tabContactIcon.image = UIImage(named: "tabcontacticon-b")
//            self.tabContactLabel.textColor = UIColor(red: 19.0/255.0, green: 71.0/255.0, blue: 78.0/255.0, alpha: 1)
//        }else if self.currentVc == self.findJobsVc{
//            self.tabFindJobsIcon.image = UIImage(named: "tabfindjobicon-b")
//            self.tabFindJobsLabel.textColor = UIColor(red: 19.0/255.0, green: 71.0/255.0, blue: 78.0/255.0, alpha: 1)
//        }else if self.currentVc == self.myJobsVc{
//            self.tabMyJobsIcon.image = UIImage(named: "tabreferjobicon-b")
//            self.tabMyJobsLabel.textColor = UIColor(red: 19.0/255.0, green: 71.0/255.0, blue: 78.0/255.0, alpha: 1)
//        }else if self.currentVc == self.chatVc{
//            self.tabChatIcon.image = UIImage(named: "tabchaticon-b")
//            self.tabChatLabel.textColor = UIColor(red: 19.0/255.0, green: 71.0/255.0, blue: 78.0/255.0, alpha: 1)
//        }else if self.settingVc == self.settingVc{
//            self.tabSettingIcon.image = UIImage(named: "tabsettingicon-b")
//            self.tabSettingLabel.textColor = UIColor(red: 19.0/255.0, green: 71.0/255.0, blue: 78.0/255.0, alpha: 1)
//        }
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
    
    @IBAction func selectSettingVc(_ sender: UIButton) {
        self.initToVc();
        if self.currentVc != nil
            && self.currentVc!.view.superview != nil {
            self.currentVc.view.frame = view.frame
            self.switchViewController(from: currentVc, to: settingVc)
            self.currentVc = self.settingVc
        }
        self.selectedTabInitView()
    }
    
    
    @IBAction func selectContactsAction(_ sender: UIButton) {
        
        self.initToVc();
        if self.currentVc != nil
            && self.currentVc!.view.superview != nil {
            self.currentVc.view.frame = view.frame
            self.switchViewController(from: self.currentVc, to: self.contactsVc)
            self.currentVc = self.contactsVc
            if AppCommon.instance.contactNotificationNumber != 0{
                self.contactsVc.setNotification()
            }
        }
        AppCommon.instance.contactNotificationNumber = 0;
        self.viewContactNotification();
        self.selectedTabInitView()
    }
    
    
    @IBAction func selectFindJobAction(_ sender: UIButton) {
        self.initToVc();
        if self.currentVc != nil
            && self.currentVc!.view.superview != nil {
            self.currentVc.view.frame = view.frame
            self.switchViewController(from: self.currentVc, to: self.findJobsVc)
            self.currentVc = self.findJobsVc
            if AppCommon.instance.getJobNotificationCount() != 0{
                self.findJobsVc.setNotification();
            }
        }
        self.selectedTabInitView()
    }
    
    
    @IBAction func selectMyJobsAction(_ sender: UIButton) {
        
        self.initToVc();
        if self.currentVc != nil
            && self.currentVc!.view.superview != nil {
            self.currentVc.view.frame = view.frame
            self.switchViewController(from: self.currentVc, to: self.myJobsVc)
            self.currentVc = self.myJobsVc
        }
        self.selectedTabInitView()
    }
    
    
    @IBAction func selectChatAction(_ sender: UIButton) {
        self.initToVc();
        if self.currentVc != nil
            && self.currentVc!.view.superview != nil {
            self.currentVc.view.frame = view.frame
            self.switchViewController(from: self.currentVc, to: self.chatVc)
            self.currentVc = self.chatVc
        }
        self.selectedTabInitView()
    }
    
    private func initToVc(){
        if self.settingVc?.view.superview == nil {
            if self.settingVc == nil {
                self.settingVc = self.storyboard?.instantiateViewController(withIdentifier: Constant.SETTING_VC) as! SettingViewController
            }
        }else if self.myJobsVc?.view.superview == nil{
            if self.myJobsVc == nil{
                self.myJobsVc = self.storyboard?.instantiateViewController(withIdentifier: Constant.REFEREDJOB_VC) as! ReferedJobsViewController
            }
        }else if self.contactsVc?.view.superview == nil{
            if self.contactsVc == nil{
                self.contactsVc = self.storyboard?.instantiateViewController(withIdentifier: Constant.ROOTCONTACTS_VC) as! ContactRootViewController
            }
        }else if self.findJobsVc?.view.superview == nil{
            if self.findJobsVc == nil{
                self.findJobsVc = self.storyboard?.instantiateViewController(withIdentifier: Constant.FINDJOB_VC) as! FindJobViewController
            }
        }else if self.chatVc?.view.superview == nil{
            if self.chatVc == nil{
                self.chatVc = self.storyboard?.instantiateViewController(withIdentifier: Constant.CHATS_VC) as! ChatListViewController
            }
        }
    }
    
    private func switchViewController(from fromVC:UIViewController?, to toVC:UIViewController?) {
        if fromVC != nil {
            fromVC!.willMove(toParentViewController: nil)
            fromVC!.view.removeFromSuperview()
            fromVC!.removeFromParentViewController()
        }
        
        if toVC != nil {
            self.addChildViewController(toVC!)
            self.view.insertSubview(toVC!.view, at: 0)
            toVC!.didMove(toParentViewController: self)
        }
    }
    
    public func viewContactNotification(){
        if AppCommon.instance.contactNotificationNumber + AppCommon.instance.getSharedNotificationCount() == 0{
            DispatchQueue.main.async {
                self.contactNotiView.isHidden = true
            }
        }else{
            if UserDefaults.standard.bool(forKey: "shownoti_flag"){
                DispatchQueue.main.async {
                    self.contactNotiView.isHidden = false
                    self.contactNotiLabel.text = String(AppCommon.instance.getSharedNotificationCount() + AppCommon.instance.contactNotificationNumber);
                }
            }
        }
    }
    
    public func viewJobPostNotification(){
        if AppCommon.instance.getJobNotificationCount() == 0{
            DispatchQueue.main.async {
                self.postedJobNotiView.isHidden = true
            }
        }else{
            if UserDefaults.standard.bool(forKey: "shownoti_flag"){
                DispatchQueue.main.async {
                    self.postedJobNotiView.isHidden = false
                    self.postedJobNotiLabel.text = String(AppCommon.instance.getJobNotificationCount());
                }
            }
        }
    }
    
    public func viewChatNotification(){
        if AppCommon.instance.chatNotification.count == 0{
            DispatchQueue.main.async {
                self.chatNotiView.isHidden = true
            }
        }else{
            if UserDefaults.standard.bool(forKey: "shownoti_flag"){
                DispatchQueue.main.async {
                    self.chatNotiView.isHidden = false
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

extension RootViewController: CocoaMQTTDelegate{
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
