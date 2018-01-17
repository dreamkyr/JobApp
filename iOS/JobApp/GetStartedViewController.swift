//
//  GetStartedViewController.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 14/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import PMSuperButton
import SwiftyJSON
import Toaster

import FacebookLogin

import ContactsUI
import Contacts

class GetStartedViewController: UIViewController{

    @IBOutlet weak var getStartedButton: PMSuperButton!
    @IBOutlet weak var signInButton: PMSuperButton!
    @IBOutlet weak var facebookButton: PMSuperButton!
    
    override func viewDidLoad() {
        
        
        getStartedButton.touchUpInside {
            // self.getStartedButton.showLoader(userInteraction: false)
            
            self.goto(to: Constant.SIGNUP_VC, params: nil)
            
            
        }
        
        signInButton.touchUpInside {
            self.goto(to: Constant.SIGNIN_VC, params: nil)
        }
        
        facebookButton.touchUpInside {
            
            let loginManager = LoginManager()
            loginManager.logIn([ .email ], viewController: self) { loginResult in
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("Logged in! \(accessToken)")
                    
                    
                    self.willLogin({self.requestVerificationCode(token: accessToken.authenticationToken)})
                    
                }
            }
        
        }
        
    }
    
    private func willLogin(_ callback: @escaping () -> Void){
        
        let contactStroe = CNContactStore()
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactEmailAddressesKey,
                           CNContactPhoneNumbersKey,
                           CNContactImageDataAvailableKey,
                           CNContactThumbnailImageDataKey] as [Any]
        contactStroe.requestAccess(for: .contacts, completionHandler: { (granted, error) -> Void in
            if granted {
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
                callback()
            }
        })
    
    }
    
    private func requestVerificationCode(token: String){
        
        var params: [[String: Any]] = []
        for phoneContact in AppCommon.instance.phoneContactData{
            let param: [String: Any] = phoneContact.getDicData()
            params.append(param)
        }
        
        CtrCommon.startRunProcess(viewController: self, completion: {
            
            UserProvider.request(.facebookLogin(access_token: token, phone_contacts: params)) { result in
                CtrCommon.stopRunProcess();
                switch result {
                case .success(let response):
                    
                    let json = JSON(response.data)
                    switch response.statusCode {
                    case 200:
                        //Toast(text: json["message"].stringValue).show()
                        if AppCommon.instance.initApp(data: json["data"]){
                            SharedKeycard.token = json["data"]["token"].string!
                            SharedKeycard.verified = true
                            self.goto(to: Constant.ROOT_TAB_VC, params: nil);
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
                let toVc: VerificationViewController = self.storyboard?.instantiateViewController(withIdentifier: to) as! VerificationViewController
                self.present(toVc, animated: true, completion: nil);
            }else if to == Constant.SIGNIN_VC{
                let toVc: SignInViewController = UIStoryboard(name: "SignIn", bundle:nil).instantiateViewController(withIdentifier: to) as! SignInViewController
                self.present(toVc, animated: true, completion: nil);
            }

        }
    }
    
}
