//
//  InviteUserViewController.swift
//  JobApp
//
//  Created by JaonMicle on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import MessageUI


class InviteUserViewController: UIViewController,  MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    
    fileprivate var inviteUsers: [Contact] = []
    fileprivate var searchUsers: [Contact] = []
    fileprivate var cellId = "InviteUserCell"
    fileprivate var emailOrPhone: Bool = true;
    fileprivate var selectedUsers: [String] = []
    
    
    
    @IBOutlet weak var searchText: PlaceHolderTextField!
    @IBOutlet weak var inviteTable: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func searchTextChange(_ sender: PlaceHolderTextField) {
        self.searchUsers = []
        for user in self.inviteUsers{
            if user.profile.full_name != nil && user.profile.full_name != ""{
                if user.profile.full_name!.lowercased().index(of: sender.text!.lowercased()) != nil{
                    self.searchUsers.append(user)
                
                }
            }
        }
        self.inviteTable.reloadData();
    }
    
    @IBAction func searchAction(_ sender: UIButton) {
        
    }
    
    @IBAction func selectAllAction(_ sender: UIButton) {
        self.searchText.text = "";
        self.searchUsers = self.inviteUsers
        if self.selectedUsers.count != self.inviteUsers.count{
            self.selectedUsers = []
            sender.setTitle("Unselect All", for: .normal)
            for user in self.inviteUsers{
                if self.emailOrPhone{
                    self.selectedUsers.append(user.profile.email)
                }else{
                    self.selectedUsers.append(user.profile.phone)
                }
            }
        }else{
            sender.setTitle("Select All", for: .normal)
            self.selectedUsers = []
        }
        self.inviteTable.reloadData();
    }
    
    @IBAction func okAction(_ sender: UIButton) {
        if self.emailOrPhone{
            let mailComposeViewController = configureMailController()
            if MFMailComposeViewController.canSendMail(){
                self.present(mailComposeViewController, animated: true, completion: nil);
            }else{
                showMailError()
            }

        }else{
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = "Download it today from https://eswara.ltd.com."
                controller.recipients = self.selectedUsers
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil);
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil);
    }
    
    //**************** email process *************//
    
    private func configureMailController()->MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(self.selectedUsers)
        mailComposerVC.setSubject("Contact me via here.")
        mailComposerVC.setMessageBody("Download it today from https://eswara.ltd.com.", isHTML: false)
        
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

    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func setData(data: Any!){
        if data != nil{
            self.inviteUsers = (data as! [String: Any])["data"] as! [Contact]
            self.searchUsers = self.inviteUsers;
            self.emailOrPhone = (data as! [String: Any])["emailorphone"] as! Bool
        }
    }
    
    fileprivate func addSelectedUsers(_ user: String){
        for i in 0 ..< self.selectedUsers.count{
            if self.selectedUsers[i] == user{
                self.selectedUsers.remove(at: i)
                return;
            }
        }
        self.selectedUsers.append(user)
    }
    
    fileprivate func isSelectedUser(_ user:String)->Bool{
        for selectedUser in self.selectedUsers{
            if selectedUser == user{
                return true;
            }
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.searchText {
            self.searchText.resignFirstResponder()
        }
        
        return true
    }
}

extension InviteUserViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: InviteUserCell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! InviteUserCell
        cell.backgroundColor = UIColor.clear
        cell.setData(contact: self.searchUsers[indexPath.row], emailorphone: self.emailOrPhone)
        if self.emailOrPhone{
            if self.isSelectedUser(self.searchUsers[indexPath.row].profile.email){
                cell.selectSign(true)
            }else{
                cell.selectSign(false)
            }
        }else{
            if self.isSelectedUser(self.searchUsers[indexPath.row].profile.phone){
                cell.selectSign(true)
            }else{
                cell.selectSign(false)
            }
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell: InviteUserCell = tableView.cellForRow(at: indexPath) as! InviteUserCell
        if self.emailOrPhone{
            if self.isSelectedUser(self.searchUsers[indexPath.row].profile.email){
                cell.selectSign(false);
            }else{
                cell.selectSign(true);
            }
            self.addSelectedUsers(self.searchUsers[indexPath.row].profile.email)
        }else{
            if self.isSelectedUser(self.searchUsers[indexPath.row].profile.phone){
                cell.selectSign(false);
            }else{
                cell.selectSign(true);
            }
            self.addSelectedUsers(self.searchUsers[indexPath.row].profile.phone)
        }
        if self.searchText.text != ""{
            self.searchText.text = ""
            self.searchUsers = self.inviteUsers
            self.inviteTable.reloadData();
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.contentView.backgroundColor = UIColor(white: 1, alpha: 0.2)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.clear
    }
}
