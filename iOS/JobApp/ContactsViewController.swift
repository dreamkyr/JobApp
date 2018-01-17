//
//  ContactsViewController.swift
//  JobApp
//
//  Created by Admin on 5/22/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import SwiftyJSON
import MessageUI
import Contacts
import ContactsUI

class ContactsViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate{
    
    public let cellId = "ContactsCell";
    public let sectionName: [String] = ["Contacts", "Requested Contacts", "Unknown"]
    public var parentVc: UIViewController! = nil;
    
    
    public var emailContactData: [Contact] = []
    public var requestedContacts: [Contact] = []
    public var knownContacts: [Contact] = []
    public var unknownContacts: [Contact] = []
    public var currentSendEmail: String = "";
    
    //public var phoneContactData: [Contact] = []
    
    
    @IBOutlet weak var contactsTable: UITableView!
    
    
    let kCloseCellHeight: CGFloat = 74
    let kOpenCellHeight: CGFloat = 310
    
    
    let kRowsCount = 10
    
    var cellHeights = [CGFloat]()
    
    //flat UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactsTable.estimatedRowHeight = kCloseCellHeight
        self.contactsTable.rowHeight = UITableViewAutomaticDimension
        self.contactsTable.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        self.contactsTable.tableFooterView = UIView()
        
        self.emailContactData = AppCommon.instance.contacts
        
        FlatUISetting()
    }
    
    func FlatUISetting() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadData();
        
    }
    
    public func setData(param: Any!){
        if param != nil{
            self.emailContactData = param as! [Contact]
            self.refreshData()
        }
    }
    
    public func loadData(){
        CtrCommon.startRunProcess(viewController: self, completion: {
            Alamofire.request(Constant.GET_CONTACTS_URL, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                CtrCommon.stopRunProcess();
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data)
                    if jsonData["code"].intValue == 200{
                        AppCommon.instance.contacts = []
                        for userData: JSON in jsonData["data"].arrayValue{
                            AppCommon.instance.contacts.append(Contact(userData.dictionaryObject!))
                        }
                        for contactData in AppCommon.instance.phoneContactData{
                            var flag = false;
                            for contact in AppCommon.instance.contacts{
                                if let phone1 = contact.profile.phone, let phone2 = contactData.profile.phone{
                                    if phone1.characters.count >= 10 && phone2.characters.count >= 10{
                                        if phone1.substring(from: phone1.characters.count - 10) == phone2.substring(from: phone2.characters.count - 10){
                                            flag = true;
                                        }
                                    }
                                }
                                if let email1 = contact.profile.email, let email2 = contactData.profile.email{
                                    if email1 == email2{
                                        flag = true;
                                    }
                                }
                            }
                            if !flag{
                                AppCommon.instance.noContacts.append(contactData)
                            }
                        }
                        self.emailContactData = AppCommon.instance.contacts
                        self.refreshData();
                    }else{
                        Toast(text: jsonData["message"].stringValue).show()
                    }
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    break;
                }
            }
        })
    }
    
    public func refreshData(){
        self.requestedContacts = []
        self.knownContacts = []
        self.unknownContacts = []
        for contact in self.emailContactData{
            if contact.status == 0{
                self.knownContacts.append(contact)
            }else if contact.status == 1 || contact.status == 2{
                self.requestedContacts.append(contact)
            }else{
                self.unknownContacts.append(contact)
            }
        }
        
        self.knownContacts = self.knownContacts.sorted { (contact1, contact2) -> Bool in
            let fullname1 = contact1.profile.full_name.trim()
            let fullname2 = contact2.profile.full_name.trim()
            if fullname1 == "" {
                return false
            }
            if fullname2 == "" {
                return true
            }
            return contact1.profile.full_name.compare(contact2.profile.full_name) == ComparisonResult.orderedAscending
        }
        
        self.requestedContacts = self.requestedContacts.sorted { (contact1, contact2) -> Bool in
            let fullname1 = contact1.profile.full_name.trim()
            let fullname2 = contact2.profile.full_name.trim()
            if fullname1 == "" {
                return false
            }
            if fullname2 == "" {
                return true
            }
            return contact1.profile.full_name.compare(contact2.profile.full_name) == ComparisonResult.orderedAscending
        }
        
        self.unknownContacts = self.unknownContacts.sorted { (contact1, contact2) -> Bool in
            let fullname1 = contact1.profile.full_name.trim()
            let fullname2 = contact2.profile.full_name.trim()
            if fullname1 == "" {
                return false
            }
            if fullname2 == "" {
                return true
            }
            return contact1.profile.full_name.compare(contact2.profile.full_name) == ComparisonResult.orderedAscending
        }
        
        self.createCellHeightsArray()
        if self.contactsTable != nil{
            
            if self.emailContactData.count > 0 {
                self.contactsTable.separatorStyle = .singleLine
                self.contactsTable.separatorColor = UIColor.gray
            } else {
                self.contactsTable.separatorStyle = .none
            }
            
            self.contactsTable.reloadData();
        }
        (AppCommon.instance.rootVc as! RootTabViewController).viewContactNotification();
    }
    
    
    
    // MARK: configure
    func createCellHeightsArray() {
        for _ in 0...self.emailContactData.count {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    // MARK: - Table view data source
    
    
    private func goto(to: String, param: Any?){
        DispatchQueue.main.async {
            if to == Constant.CHATS_VC{
                let toVc: UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: to) as! UINavigationController
                let chatVc: ChatsViewController = toVc.viewControllers.first as! ChatsViewController
                chatVc.setChatUsers(user: (param as! Contact).profile)
                self.present(toVc, animated: true, completion: nil)
            }else if to == Constant.USERPOSTED_VC{
                let toVc: UserPostedJobsViewController = self.storyboard?.instantiateViewController(withIdentifier: to) as! UserPostedJobsViewController
                if param != nil{
                    toVc.setData(myjob: param as! FindJob)
                }
                self.present(toVc, animated: true, completion: nil)
            }else if to == Constant.PROFILE_VC{
                let toVc: ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: to) as! ProfileViewController
                toVc.setProfile(profile: param as! Profile)
                self.present(toVc, animated: true, completion: nil)
            }
        }
    }
    
    public func viewProfile(_ userId: Int)->Void{
        if let contact = AppCommon.instance.getContact(id: userId){
            self.goto(to: Constant.PROFILE_VC, param: contact.profile)
        }
    }
    
    public func viewPostedJob(_ userId: Int)->Void{
        CtrCommon.startRunProcess(viewController: self, completion: {
            Alamofire.request(Constant.JOB_USERPOSTED_URL, method: .post, parameters: ["user_id": userId], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON(completionHandler: { (response) in
                CtrCommon.stopRunProcess()
                switch(response.result){
                case .success(let data):
                    let jsonData = JSON(data)
                    if jsonData["code"].intValue == 200{
                        var postedJob: FindJob = FindJob()
                        postedJob.user_id = userId
                        let jobDatas: [JSON] = jsonData["data"].arrayValue
                        var jobs: [Job] = []
                        var recentCount = 0;
                        for jobdata in jobDatas{
                            let job: Job = Job(jobdata.dictionaryObject!)
                            if job.posted_date.index(of: "hour") != nil || job.posted_date.index(of: "min") != nil{
                                recentCount += 1
                            }
                            jobs.append(job)
                        }
                        postedJob.jobs = jobs;
                        postedJob.recentCount = recentCount
                        postedJob.postedCount = postedJob.jobs.count
                        for job in postedJob.jobs{
                            if self.isShared(job: job){
                                AppCommon.instance.addSharedJob(job: job)
                            }
                            if self.isApplied(job: job){
                                AppCommon.instance.addAppliedJob(job: job)
                            }
                        }
                        if postedJob.postedCount > 0{
                            self.goto(to: Constant.USERPOSTED_VC, param: postedJob)
                        }else{
                            Toast(text: "Posted jobs don't exist.").show()
                        }
                    }else{
                        Toast(text: jsonData["message"].stringValue).show()
                    }
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    break;
                }
            })
        })
    }
    
    public func isApplied(job: Job)->Bool{
        for proposeduser in job.proposed_users{
            if proposeduser.profile.user_id == AppCommon.instance.profile.user_id{
                return true;
            }
        }
        return false;
    }
    
    public func isShared(job: Job)->Bool{
        for user in job.shared_users{
            if user.user_id == AppCommon.instance.profile.user_id{
                return true;
            }
        }
        return false;
    }
    
    
    
    
    public func callUser(_ phone: String)->Void{
        UIApplication.shared.openURL(NSURL(string: "tel://" + phone)! as URL)
    }
    
    
    
    public func chatUser(_ id: Int)->Void{
        if AppCommon.instance.getChatList(id: id) != nil{
            self.goto(to: Constant.CHATS_VC, param: AppCommon.instance.getContact(id: id))
        }else{
            CtrCommon.startRunProcess(viewController: self, completion: {
                
                //
                ChatlistProvider.request(.chatlistAdd(linked_users: [id])) { result in
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
                                self.goto(to: Constant.CHATS_VC, param: AppCommon.instance.getContact(id: id))
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
                Alamofire.request(Constant.ADDCHATLIST_URL, method: .post, parameters: ["linked_users": [id]], encoding: JSONEncoding.default).responseJSON { (response) in
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
                                self.goto(to: Constant.CHATS_VC, param: AppCommon.instance.getContact(id: id))
                            }
                        }
                        break;
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show()
                        break;
                    }
                }*/
                
                
                
            })
        }
    }
    
    public func emailUser(_ email: String)->Void{
        self.currentSendEmail = email
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail(){
            //self.present(mailComposeViewController, animated: true, completion: nil)
            self.present(mailComposeViewController, animated: false, completion: nil);
        }else{
            showMailError()
        }
    }
    
    
    
    //**************** email process *************//
    
    private func configureMailController()->MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([self.currentSendEmail])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    private func showMailError(){
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func allowUser(_ id: Int)->Void{
        if AppCommon.instance.getContact(id: id) == nil{
            return;
        }
        if AppCommon.instance.getContact(id: id).status == 2{
            let params: [String: Any] = ["contact_user": id];
            CtrCommon.startRunProcess(viewController: self, completion: {
                Alamofire.request(Constant.AGREE_CONTACTS_URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                    CtrCommon.stopRunProcess();
                    switch response.result{
                    case .success(let data):
                        let jsonData = JSON(data);
                        if jsonData["code"].intValue == 200{
                            if let user = AppCommon.instance.getContact(id: id){
                                user.status = 0;
                                AppCommon.instance.updateContact(updatecontact: user)
                                self.refreshData()
                            }
                        }
                        Toast(text: jsonData["message"].stringValue).show()
                        break;
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show();
                        break;
                    }
                }
            })
        }
    }
    
    public func addUser(_ id: Int)->Void{
        let params: [String: Any] = ["contact_user": id];
        CtrCommon.startRunProcess(viewController: self, completion: {
            Alamofire.request(Constant.ADD_CONTACT_URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                CtrCommon.stopRunProcess()
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data);
                    Toast(text: jsonData["message"].stringValue).show()
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show();
                    break;
                }
            }
        })
    }
    
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            if self.requestedContacts.count != 0{
                return 0;
            }else{
                return 0
            }
            
        }else if section == 1{
            return 0
        }else{
            if self.unknownContacts.count != 0{
                return 0;
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: UIView = UIView();
        sectionView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        let contentRect: CGRect = CGRect(x:10, y:0, width: 150, height: 50);
        let headerLabel: UILabel = UILabel(frame: contentRect);
        headerLabel.text = self.sectionName[section];
        headerLabel.textColor = UIColor.white;
        sectionView.addSubview(headerLabel);
        return sectionView;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.requestedContacts.count
        }else if section == 1{
            
            return self.knownContacts.count
        }else{
            return self.unknownContacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            guard case let cell as ContactsCell = cell else {
                return
            }
            
            cell.backgroundColor = UIColor.clear
            
            if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
                cell.selectedAnimation(false, animated: false, completion:nil)
            } else {
                cell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! ContactsCell
        if indexPath.section == 0{
            cell.setData(userdata: self.requestedContacts[indexPath.row], callbackfunc: self.viewPostedJob, viewprofile: self.viewProfile, usercall: self.callUser, useremail: self.emailUser, userchat: self.chatUser, userallow: allowUser, useradd: addUser);
            if self.requestedContacts[indexPath.row].status == 2{
                cell.statusAllowConstraint.constant = 50
                cell.addBtnView.isHidden = true;
                cell.allowBtnView.isHidden = false;
            }else{
                cell.statusAllowConstraint.constant = 10
                cell.addBtnView.isHidden = true;
                cell.allowBtnView.isHidden = true;
            }
            return cell
        }else if indexPath.section == 1{
            cell.setData(userdata: self.knownContacts[indexPath.row], callbackfunc: self.viewPostedJob, viewprofile: self.viewProfile, usercall: self.callUser, useremail: self.emailUser, userchat: self.chatUser, userallow: allowUser, useradd: addUser);
            cell.statusAllowConstraint.constant = 10
            cell.addBtnView.isHidden = true;
            cell.allowBtnView.isHidden = true;
            
            if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight { // open cell
                cell.selectedAnimation(false, animated: false, completion: nil)
            } else {// close cell
                cell.selectedAnimation(true, animated: false, completion: nil)
            }
            
            return cell
        }else{
            cell.setData(userdata: self.unknownContacts[indexPath.row], callbackfunc: self.viewPostedJob, viewprofile: self.viewProfile, usercall: self.callUser, useremail: self.emailUser, userchat: self.chatUser, userallow: allowUser, useradd: addUser);
            cell.statusAllowConstraint.constant = 50;
            cell.addBtnView.isHidden = false;
            cell.allowBtnView.isHidden = true;
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section==0){
            return 74;
        }else{
            
            return cellHeights[(indexPath as NSIndexPath).row]
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    // MARK: Table vie delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            let cell = tableView.cellForRow(at: indexPath) as! ContactsCell
            
            if cell.isAnimating() {
                return
            }
            
            var duration = 0.0
            if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight { // open cell
                cellHeights[(indexPath as NSIndexPath).row] = kOpenCellHeight
                cell.selectedAnimation(true, animated: true, completion: nil)
                duration = 0.5
            } else {// close cell
                cellHeights[(indexPath as NSIndexPath).row] = kCloseCellHeight
                cell.selectedAnimation(false, animated: true, completion: nil)
                duration = 0.8
            }
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                tableView.beginUpdates()
                tableView.endUpdates()
            }, completion: nil)
        }
    }
    
    
}
