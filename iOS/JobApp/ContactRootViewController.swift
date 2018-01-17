//
//  ContactRootViewController.swift
//  JobApp
//
//  Created by JaonMicle on 21/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import Alamofire
import SwiftyJSON
import Toaster

class ContactRootViewController: UIViewController {

    private var contactVc: ContactsViewController! = nil;
    private var noContactVc: NoContactsViewController! = nil;
    
    public var contactDataSource: [Contact] = []
    
    public var searchContact: [Contact] = []
    
    private var currentVc: UIViewController! = nil
    
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var noContactBtn: UIButton!
    
    @IBOutlet weak var contactPageMenuView: UIView!
    @IBOutlet weak var noContactPageMenuView: UIView!
    
    @IBOutlet weak var searchText: PlaceHolderTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contactVc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: Constant.CONTACTS_VC) as! ContactsViewController
        self.noContactVc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: Constant.NOCONTACTS_VC) as! NoContactsViewController
        self.switchViewController(from: nil, to: self.contactVc)
        self.currentVc = self.contactVc;
        
        self.setPageMenuInit()
        
        self.searchContact = AppCommon.instance.noContacts;
        
        FlatUISeting()
    }
    
    func FlatUISeting() {
            contactBtn.setTitleColor(myBlueBgcolor, for: UIControlState.normal)
    }
    
    public func setPageMenuInit(){
        self.contactBtn.setTitleColor(UIColor(white: 155.0 / 255.0, alpha: 1.0), for: .normal)
        self.noContactBtn.setTitleColor(UIColor(white: 155.0 / 255.0, alpha: 1.0), for: .normal)
        
        self.contactPageMenuView.isHidden = true;
        self.noContactPageMenuView.isHidden = true;
        
        if self.currentVc == self.contactVc{
            self.contactBtn.setTitleColor(myBlueBgcolor, for: .normal)
            self.contactPageMenuView.isHidden = false
        }else if self.currentVc == self.noContactVc{
            self.noContactBtn.setTitleColor(myBlueBgcolor, for: .normal)
            self.noContactPageMenuView.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if self.contactVc != nil && self.contactVc!.view.superview == nil {
            self.contactVc = nil
        }
        if self.noContactVc != nil && self.noContactVc!.view.superview == nil {
            self.noContactVc = nil
        }
    }
    
    @IBAction func selectContactVc(_ sender: UIButton) {
        self.initToVc();
        if self.currentVc != nil
            && self.currentVc!.view.superview != nil {
            self.currentVc.view.frame = view.frame
            self.switchViewController(from: self.currentVc, to: self.contactVc)
            self.currentVc = self.contactVc
        }
        self.setPageMenuInit()
    }
    
    public func gotoContact(){
        if (self.currentVc as? ContactsViewController) == nil{
            self.initToVc();
            if self.currentVc != nil
                && self.currentVc!.view.superview != nil {
                self.currentVc.view.frame = view.frame
                self.switchViewController(from: self.currentVc, to: self.contactVc)
                self.currentVc = self.contactVc
                
            }
            self.setPageMenuInit()
        }
    }
    
    public func setNotification(){
        if let toVc = self.currentVc as? ContactsViewController{
            toVc.loadData();
        }else{
            self.gotoContact()
            (self.currentVc as! ContactsViewController).loadData();
        }
    }
    
    @IBAction func selectNoContactVc(_ sender: UIButton) {
        self.initToVc();
        if self.currentVc != nil
            && self.currentVc!.view.superview != nil {
            UIView.setAnimationTransition(.flipFromRight, for: view, cache: true)
            self.currentVc.view.frame = view.frame
            self.noContactVc.view.frame = view.frame
            self.switchViewController(from: self.currentVc, to: self.noContactVc)
            self.currentVc = self.noContactVc
        }
        self.setPageMenuInit()
    }
    
//    @IBAction func searchAction(_ sender: UIButton) {
//        self.gotoContact()
//        self.search()
//    }
    
    @IBAction func editingChangedSearchText(_ sender: PlaceHolderTextField) {
       self.search()
    }
    
    
    
    private func initToVc(){
        if self.contactVc?.view.superview == nil {
            if self.contactVc == nil {
                self.contactVc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: Constant.CONTACTS_VC) as! ContactsViewController
            }
        }else if self.noContactVc?.view.superview == nil{
            if self.noContactVc == nil{
                self.noContactVc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: Constant.NOCONTACTS_VC) as! NoContactsViewController
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
    
    
    private func search(){
        if let toVc = (self.currentVc as? ContactsViewController){
            self.searchContact = []
            for contact in AppCommon.instance.contacts{
                if contact.profile.full_name != nil && contact.profile.full_name != ""{
                    if (contact.profile.full_name!.lowercased().index(of: searchText.text!.lowercased()) != nil){
                        self.searchContact.append(contact)
                    }
                }
            }
            toVc.setData(param: self.searchContact)
        }else{
            self.searchContact = []
            for contact in AppCommon.instance.noContacts{
                if contact.profile.full_name != nil && contact.profile.full_name != ""{
                    if (contact.profile.full_name!.lowercased().index(of: searchText.text!.lowercased()) != nil){
                        self.searchContact.append(contact)
                    }
                }
            }
            if let toVc = (self.currentVc as? NoContactsViewController){
                toVc.setData(param: self.searchContact)
            }
        }
    }
    
    fileprivate func severSearch(){
        var params: [String: Any] = [:]
        params["search"] = self.searchText.text
        CtrCommon.startRunProcess(viewController: self, completion: {
            Alamofire.request(Constant.SEARCH_CONTACTS_URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                CtrCommon.stopRunProcess();
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data)
                    print(jsonData)
                    if jsonData["code"].intValue == 200{
                        let profileDatas: [JSON] = jsonData["data"].arrayValue
                        self.searchContact = []
                        for contactData in profileDatas{
                            let newcontact: Contact = Contact();
                            newcontact.profile = Profile(contactData.dictionaryObject!)
                            newcontact.status = 3;
                            newcontact.favorite = false;
                            if AppCommon.instance.getContact(id: newcontact.profile.user_id) == nil{
                                self.searchContact.append(newcontact)
                            }
                        }
                        (self.currentVc as! ContactsViewController).setData(param: self.searchContact)
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
}

extension ContactRootViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.searchContact.count == 0{
            self.severSearch()
        }
        return true;
    }
}

