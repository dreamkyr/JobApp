//
//  VerificationViewController.swift
//  JobApp
//
//  Created by JaonMicle on 11/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import SwiftyJSON
import ContactsUI
import Contacts
import SkyFloatingLabelTextField
import PMSuperButton


class VerificationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var verificationCode: SkyFloatingLabelTextField!
    
    @IBOutlet weak var resendcode: UIButton!
    @IBOutlet weak var underlineView1: UIView!
    @IBOutlet weak var underlineView2: UIView!
    @IBOutlet weak var verifyButton: PMSuperButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestVerificationCode()
        self.setDismissKeyboard();
        
        verifyButton.touchUpInside {
            self.verificationCode.errorMessage = nil
            self.verificationCode.isEnabled = false
            let code = Int(self.verificationCode.text!)
            
            if let code = code {
                //
                CtrCommon.startRunProcess(viewController: self, completion: {
                    
                    UserProvider.request(.verifyConfirm(code: code) ) { result in
                        CtrCommon.stopRunProcess();
                        switch result {
                        case .success(let response):
                            
                            let json = JSON(response.data)
                            switch response.statusCode {
                            case 200:
                                
                                
                                if json["code"].intValue == 200{
                                    SharedKeycard.verified = true
                                    DispatchQueue.main.async {
                                        Toast(text: json["message"].stringValue).show();
                                        self.loginProcess()
                                    }
                                }
                                
                            default:
                                Toast(text: json["message"].stringValue).show()
                                self.verificationCode.isEnabled = true
                                self.verificationCode.errorMessage = json["message"].stringValue
                            }
                        case .failure(let error):
                            self.verificationCode.isEnabled = true
                            Toast(text: error.localizedDescription).show()
                            
                        }
                    }
                    
                    
                })
                //
            }
            else {
                self.verificationCode.isEnabled = true
                self.verificationCode.errorMessage = "Enter Verification Code"
            }
        }
    }
    

    
    private func requestVerificationCode(){
    
        CtrCommon.startRunProcess(viewController: self, completion: {
            
            UserProvider.request(.verification) { result in
                CtrCommon.stopRunProcess();
                switch result {
                case .success(let response):
                    
                    let json = JSON(response.data)
                    switch response.statusCode {
                    case 200:
                        Toast(text: json["message"].stringValue).show()
                    default:
                        Toast(text: json["message"].stringValue).show()
                        return;
                    }
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    return;
                }
            }
            

            
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    
    private func loginProcess(){
        
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == CNAuthorizationStatus.denied {
            Toast(text: "Denied to access. please update your setting on your device.").show()
            return;
        }
        
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
                    myContactProfileData["email"] = "Not Avaliable"
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
                print("loginprocess")
                self.getContactFromServer()
            }
            if let error = error{
                print(error.localizedDescription)
            }
            
        })
    }
    
    private func getContactFromServer(){
        print("loginprocess init")
        var params: [[String: Any]] = []
        for phoneContact in AppCommon.instance.phoneContactData{
            let param: [String: Any] = phoneContact.getDicData()
            params.append(param)
        }
        print("loginprocess params")
        //CtrCommon.startRunProcess(viewController: self, completion: {
            print("loginprocess req")
            UserProvider.request(.me(phone_contacts: params)) { result in
          //      CtrCommon.stopRunProcess();
                switch result {
                case .success(let response):
                    
                    let json = JSON(response.data)
                     print("loginprocess req \(json)")
                    switch response.statusCode {
                    case 200:
                        
                        if AppCommon.instance.initApp(data: json["data"]){
                            self.goto(to: Constant.ROOT_TAB_VC, params: nil)
                        }
                        else {
                            SharedKeycard.token = json["data"]["token"].string!
                            self.goto(to: Constant.VERIFICATION_VC, params: nil);
                        }
                        
                    default:
                        Toast(text: json["message"].stringValue).show()
                        return;
                    }
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    print("loginprocess fail \(error.localizedDescription)")
                    return;
                }
            }
            
            

        //})
    }

    
    private func goto(to: String, params: Any!){
        DispatchQueue.main.async {
            if to == "Back"{
                self.dismiss(animated: true, completion: nil)
            }else if to == Constant.ROOT_TAB_VC{
                let toVc: RootTabViewController = UIStoryboard(name: "Root", bundle:nil).instantiateViewController(withIdentifier: to) as! RootTabViewController
                self.present(toVc, animated: true, completion: nil);
                
            }
        }
    }
    
    @IBAction func resendCodeAction(_ sender: UIButton) {
        self.requestVerificationCode()
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        SharedKeycard.verified = false
        SharedKeycard.removeToken()
        self.goto(to: "Back", params: nil)
    }
    
}
