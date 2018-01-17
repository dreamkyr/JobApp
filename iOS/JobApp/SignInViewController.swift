//
//  SignInViewController.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 14/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import PMSuperButton
import Alamofire
import SwiftyJSON
import Toaster
import SkyFloatingLabelTextField
import ContactsUI
import Contacts

class SignInViewController : UIViewController {

    @IBOutlet weak var username: SkyFloatingLabelTextField!
    @IBOutlet weak var password: SkyFloatingLabelTextField!
    @IBOutlet weak var cancelButton: PMSuperButton!
    @IBOutlet weak var signInButton: PMSuperButton!
    @IBOutlet weak var forgotButton: PMSuperButton!
    

    override func viewDidLoad(){
        cancelButton.touchUpInside {
            self.dismiss(animated: true, completion: nil);
        }
        
        signInButton.touchUpInside {
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
                    
                    self.getContactFromServer()
                }
            })
        }
        
        cancelButton.touchUpInside {
            self.dismiss(animated: true, completion: nil);
        }
        
        forgotButton.touchUpInside { 
            let alert = UIAlertController(title: "Forgoten Password", message: "Please enter email", preferredStyle: .alert)
            let sendAction = UIAlertAction(title: "Send", style: .default, handler: {(alertAction: UIAlertAction) in
                let email: String = alert.textFields![0].text!
                self.goto(to: Constant.FORGOTPASSWORD_VC, params: email)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
            alert.addAction(sendAction)
            alert.addAction(cancelAction)
            alert.addTextField(configurationHandler: nil)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func getContactFromServer(){
        
        if !self.username.text!.isValidEmail(){
            Toast(text: "Email incorrect!").show()
            self.username.errorMessage = "Email incorrect!"
            return;
        }
        
        var params: [[String: Any]] = []
        for phoneContact in AppCommon.instance.phoneContactData{
            let param: [String: Any] = phoneContact.getDicData()
            params.append(param)
        }
    
        CtrCommon.startRunProcess(viewController: self, completion: {
            
            UserProvider.request(.login(email: self.username.text!, password: self.password.text!, phone_contacts: params)) { result in
                CtrCommon.stopRunProcess();
                switch result {
                case .success(let response):
                    
                    let json = JSON(response.data)
                    switch response.statusCode {
                    case 200:
                        
                        if AppCommon.instance.initApp(data: json["data"]){
                            SharedKeycard.token = json["data"]["token"].string!
                            SharedKeycard.verified = true
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
                    return;
                }
            }
            
            
        })
    }
    
    private func goto(to: String, params: Any!){
        DispatchQueue.main.async {
            if to == Constant.ROOT_TAB_VC{
                let toVc: RootTabViewController = UIStoryboard(name: "Root", bundle:nil).instantiateViewController(withIdentifier: to) as! RootTabViewController
                self.present(toVc, animated: true, completion: nil);
                
            }else if to == Constant.SIGNUP_VC{
                let toVc: SignUpViewController = UIStoryboard(name: "SignUp", bundle:nil).instantiateViewController(withIdentifier: to) as! SignUpViewController
                self.present(toVc, animated: true, completion: nil);
            }else if to == Constant.VERIFICATION_VC{
                let toVc: VerificationViewController = UIStoryboard(name: "Verification", bundle:nil).instantiateViewController(withIdentifier: to) as! VerificationViewController
                self.present(toVc, animated: true, completion: nil);
            }else if to == Constant.SIGNIN_VC{
                let toVc: SignInViewController = UIStoryboard(name: "SignIn", bundle:nil).instantiateViewController(withIdentifier: to) as! SignInViewController
                self.present(toVc, animated: true, completion: nil);
            }else if to == Constant.FORGOTPASSWORD_VC{
                let toVc: ForgotPasswordViewController = UIStoryboard(name: "ForgotPassword", bundle:nil).instantiateViewController(withIdentifier: to) as! ForgotPasswordViewController
                toVc.email = params as! String
                self.present(toVc, animated: true, completion: nil);
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
