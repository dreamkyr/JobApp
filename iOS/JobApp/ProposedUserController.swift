//
//  ProposedUserController.swift
//  JobApp
//
//  Created by JaonMicle on 11/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Toaster
import Alamofire
import SwiftyJSON
import MessageUI

class ProposedUserController: UIViewController, MFMailComposeViewControllerDelegate{

    public let cellId: String = "ProposedCell";
    
    public var currentSendEmail:String = "";
    public var job: Job! = nil;
    
    @IBOutlet weak var proposedUserTable: UITableView!
    
    
    
    let kCloseCellHeight: CGFloat = 73
    let kOpenCellHeight: CGFloat = 228
    
    
    
    var cellHeights = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.proposedUserTable.estimatedRowHeight = kCloseCellHeight
        self.proposedUserTable.rowHeight = UITableViewAutomaticDimension
        self.createCellHeightsArray()
    }
    
    public func setData(param: Any?){
        self.job = param as! Job
    }
    
    public func getUserInPropostedUsers(id: Int)->Profile!{
        for proposeduser in self.job.proposed_users{
            if proposeduser.profile.user_id == id{
                return proposeduser.profile;
            }
        }
        return nil;
    }
    
    func createCellHeightsArray() {
        for _ in 0...self.job.proposed_users.count {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    public func viewProfile(_ profile: Profile)->Void{
        self.goto(to: Constant.PROFILE_VC, param: profile)
    }
    
    public func callUser(_ phone: String)->Void{
         UIApplication.shared.openURL(NSURL(string: "tel://" + phone)! as URL)
    }
    
    public func chatUser(_ id: Int)->Void{
        if AppCommon.instance.getChatList(id: id) != nil{
            self.goto(to: Constant.CHATS_VC, param: self.getUserInPropostedUsers(id: id))
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
                                self.goto(to: Constant.CHATS_VC, param: self.getUserInPropostedUsers(id: id))
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
                            let jsonData = JSON(data)
                            if jsonData["code"].intValue == 200{
                                AppCommon.instance.chatLinkUsers = [];
                                for chatlistdata in jsonData["data"].arrayValue{
                                    AppCommon.instance.chatLinkUsers.append(ChatList(chatlistdata.dictionaryObject!))
                                }
                                DispatchQueue.main.async {
                                    self.goto(to: Constant.CHATS_VC, param: self.getUserInPropostedUsers(id: id))
                                }
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
    
    @IBAction func backAction(_ sender: UIButton) {
        self.goto(to: "Back", param: nil);
    }
    
    
    
    private func goto(to: String, param: Any?){
        if to == "Back"{
            self.dismiss(animated: false, completion: nil)
        }else if to == Constant.CHATS_VC{
            let toVc: UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: to) as! UINavigationController
            let chatVc: ChatsViewController = toVc.viewControllers.first as! ChatsViewController
            chatVc.setChatUsers(user: (param as! Profile))
            self.present(toVc, animated: true, completion: nil)
        }else if to == Constant.PROFILE_VC{
            let toVc: ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: to) as! ProfileViewController
            toVc.setProfile(profile: param as! Profile)
            self.present(toVc, animated: true, completion: nil)
        }
    }
}

extension ProposedUserController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.job.proposed_users.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as ProposedCell = cell else {
            return
        }
        
        cell.backgroundColor = UIColor.clear
        
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProposedCell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! ProposedCell
        cell.setData(user: self.job.proposed_users[indexPath.row], viewprofile: self.viewProfile, usercall: self.callUser, userchat: self.chatUser, useremail: self.emailUser)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ProposedCell
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

