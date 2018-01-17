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

class NoContactsViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    public let cellId = "NoContactsCell";
    public var currentSendEmail: String = ""
    
    
    
    
    public var parentVc: UIViewController! = nil;
    public var phoneContactData: [Contact] = []
    
    @IBOutlet weak var noContactsTable: UITableView!
    
    let kCloseCellHeight: CGFloat = 74
    let kOpenCellHeight: CGFloat = 194
    
    
    let kRowsCount = 10
    
    public var cellHeights = [CGFloat]()
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noContactsTable.estimatedRowHeight = kCloseCellHeight
        self.noContactsTable.rowHeight = UITableViewAutomaticDimension
        self.noContactsTable.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        self.noContactsTable.tableFooterView = UIView()
        
        self.phoneContactData = AppCommon.instance.noContacts
//        self.phoneContactData = self.phoneContactData.sorted { (contact1, contact2) -> Bool in
//            return contact1.profile.full_name.compare(contact2.profile.full_name) == ComparisonResult.orderedAscending
//        }
        
        self.createCellHeightsArray();
        
        FlatUISetting()
    }
    
    func FlatUISetting() {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.createCellHeightsArray();
        self.noContactsTable.reloadData()
    }
    
    func createCellHeightsArray() {
        self.cellHeights = []
        for _ in 0...self.phoneContactData.count {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    public func setData(param: Any!)->Void{
        if param != nil{
            self.phoneContactData = param as! [Contact]
            if self.noContactsTable != nil{
                
                if self.phoneContactData.count > 0 {
                    self.noContactsTable.separatorStyle = .singleLine
                    self.noContactsTable.separatorColor = UIColor.gray
                } else {
                    self.noContactsTable.separatorStyle = .none
                }
                
                self.noContactsTable.reloadData();
            }
        }
    }
    
    public func callUser(_ phone: String)->Void{
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Find and Post jobs between people you trust. Download the app now: http://ww.joltmate.com"
            controller.recipients = [phone]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil);
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil);
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
}

extension NoContactsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.phoneContactData.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as NoContactsCell = cell else {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! NoContactsCell
        cell.setData(userdata: self.phoneContactData[indexPath.row], usercall: self.callUser, useremail: self.emailUser);
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NoContactsCell
        
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
