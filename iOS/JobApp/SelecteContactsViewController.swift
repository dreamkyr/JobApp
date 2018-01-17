//
//  SelecteContactsViewController.swift
//  JobApp
//
//  Created by JaonMicle on 16/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import SwiftyJSON

class SelecteContactsViewController: UIViewController {

    public let cellId = "SelectContactsCell";
    public var selecteUsers: [Int] = []
    public var currentSendEmail: String = "";
    public var currentContacts: [Contact] = [];
    
    public var parentVc: UIViewController! = nil;
    
    @IBOutlet weak var contactsTable: UITableView!
    
    let kCloseCellHeight: CGFloat = 75
    let kOpenCellHeight: CGFloat = 148
    
    
    var cellHeights = [CGFloat]()
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        self.contactsTable.estimatedRowHeight = kCloseCellHeight
        self.contactsTable.rowHeight = UITableViewAutomaticDimension
        self.contactsTable.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        self.refreshData();
    }
    
    public func refreshData(){
        self.currentContacts = [];
        for contact in AppCommon.instance.contacts{
            if contact.status == 0{
                self.currentContacts.append(contact)
            }
        }
        self.createCellHeightsArray()
        self.contactsTable.reloadData();
    }
    
    // MARK: configure
    func createCellHeightsArray() {
        for _ in 0...AppCommon.instance.contacts.count {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    public func selectUser(_ id: Int)->Void{
        for i in 0 ..< self.selecteUsers.count{
            if self.selecteUsers[i] == id{
                self.selecteUsers.remove(at: i)
                return;
            }
        }
        self.selecteUsers.append(id);
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchAction(_ sender: PlaceHolderTextField) {
        self.currentContacts = []
        for contact in AppCommon.instance.contacts{
            if let name = contact.profile.full_name, let email = contact.profile.email, let phone = contact.profile.phone{
                if name != ""{
                    if name.index(of: sender.text!) != nil{
                        self.currentContacts.append(contact)
                        continue
                    }
                }
                if email !=  ""{
                    if email.index(of: sender.text!) != nil{
                        self.currentContacts.append(contact)
                        continue
                    }
                }
                if phone != ""{
                    if phone.index(of: sender.text!) != nil{
                        self.currentContacts.append(contact)
                        continue
                    }
                }
            }
        }
        self.contactsTable.reloadData();
    }
    
    
    @IBAction func okAction(_ sender: UIButton) {
        if self.parentVc != nil{
            var profiles: [Profile] = [];
            for id in self.selecteUsers{
                profiles.append(AppCommon.instance.getContact(id: id).profile)
            }
            if let toVc = self.parentVc as? ChatListViewController{
                var addChatListUserIds: [Int] = []
                for profile in profiles{
                    addChatListUserIds.append(profile.user_id)
                }
                if addChatListUserIds.count != 0{
                    toVc.addUsers = addChatListUserIds;
                }
            }
            if let toVc = self.parentVc as? AddJobViewController{
                toVc.setUsers(params: self.selecteUsers);
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func setData(params: Any!){
        self.selecteUsers = []
        if params != nil{
            if let userIds = params as? [Int]{
                self.selecteUsers = userIds
            }
        }
    }
    
    public func isExistSelectedUsers(_ id: Int)->Bool{
        for userid in self.selecteUsers{
            if userid == id{
                return true
            }
        }
        return false;
    }
    
}

extension SelecteContactsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentContacts.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! SelectContactsCell
        cell.setData(userdata: self.currentContacts[indexPath.row], selcallbackfunc: self.selectUser)
        if isExistSelectedUsers(self.currentContacts[indexPath.row].profile.user_id){
            cell.checkImageView.image = UIImage(named: "checkbtn")
        }else{
            cell.checkImageView.image = UIImage(named: "uncheckbtn")
        }
        cell.backgroundColor = UIColor.clear
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    // MARK: Table vie delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
        let cell = tableView.cellForRow(at: indexPath) as! SelectContactsCell
        
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
