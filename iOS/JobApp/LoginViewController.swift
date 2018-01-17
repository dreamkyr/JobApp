//
//  LoginViewController.swift
//  JobApp
//
//  Created by Admin on 01/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toaster
import ContactsUI
import Contacts

import FacebookLogin

class LoginViewController: UIViewController, UIViewControllerTransitioningDelegate{

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signBtn: TKTransitionSubmitButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var forgotenBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var emailView: EffectView!
    @IBOutlet weak var pwdView: EffectView!
    
    @IBOutlet weak var emailView1: UIView!
    @IBOutlet weak var pwdView2: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDismissKeyboard()
        NotificationCenter.default.addObserver(self, selector:#selector(self.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        FlatUISetting()
    }
    
    func FlatUISetting() {
        signBtn.backgroundColor = myPrimanryColor
        forgotenBtn.setTitleColor(myPrimanryColor, for: .normal)
        signupBtn.setTitleColor(myPrimanryColor, for: .normal)
        
//        emailView.backgroundColor = myGreyBgColor
//        pwdView.backgroundColor = myGreyBgColor
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
    
    func facebookLoginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn([ .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in! \(accessToken)")
                
                self.requestVerificationCode(token: accessToken.authenticationToken)
                
            }
        }
    }
    
    func keyboardWillAppear(_ notification: NSNotification){
        
    }
    
    func keyboardWillDisappear(_ notification: NSNotification){
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    @IBAction func forgottenPassAction(_ sender: UIButton) {
        self.goto(to: Constant.SIGNUP_VC, params: nil);
    }
    
    @IBAction func facebookLoginAction(_ sender: UIButton) {
        
        print("facebook")
        facebookLoginButtonClicked()
    }
    
    
    @IBAction func linkedInLoginAction(_ sender: UIButton) {
    }
    
    @IBAction func googleLoginAction(_ sender: UIButton) {
    }
    
    @IBAction func forgotenPassAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Forgoten Password", message: "Please enter email", preferredStyle: .alert)
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: {(alertAction: UIAlertAction) in
            CtrCommon.startRunProcess(viewController: self, completion: {
                let email: String = alert.textFields![0].text!
                Alamofire.request(Constant.FORGOTENPASS_URL, method: .post, parameters: ["email": email], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON(completionHandler: { (response) in
                    CtrCommon.stopRunProcess()
                    switch response.result{
                    case .success(let data):
                        Toast(text: JSON(data)["message"].stringValue).show()
                        break;
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show()
                        break;
                    }
                })
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        alert.addAction(sendAction)
        alert.addAction(cancelAction)
        alert.addTextField(configurationHandler: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    

    @IBAction func onLogin(_ sender: TKTransitionSubmitButton) {
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
                self.getContactFromServer()
            }
        })
    }
    
    
    private func getContactFromServer(){
        
//        var requestParams: [String: Any] = [:]
//        requestParams["email"] = self.username.text!
//        requestParams["password"] = self.password.text!
//        
        if !self.username.text!.isValidEmail(){
            Toast(text: "Email incorrect!").show()
            return;
        }
        
        var params: [[String: Any]] = []
        for phoneContact in AppCommon.instance.phoneContactData{
            let param: [String: Any] = phoneContact.getDicData()
            params.append(param)
        }
//        requestParams["phone_contacts"] = params;
        
        CtrCommon.startRunProcess(viewController: self, completion: {
            
            UserProvider.request(.login(email: self.username.text!, password: self.password.text!, phone_contacts: params)) { result in
                CtrCommon.stopRunProcess();
                switch result {
                case .success(let response):
                  
                    let json = JSON(response.data)
                    switch response.statusCode {
                    case 200:
                        
                        if AppCommon.instance.initApp(data: json["data"]){
                            UserDefaults.standard.set(self.username.text!, forKey: "useremail")
                            UserDefaults.standard.set(self.password.text!, forKey: "userpass")
                            SharedKeycard.token = json["data"]["token"].string!
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
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TKFadeInAnimator(transitionDuration: 2, startingAlpha: 0.8)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    private func goto(to: String, params: Any!){
        DispatchQueue.main.async {
            if to == Constant.ROOT_TAB_VC{
                let toVc: RootTabViewController = UIStoryboard(name: "Root", bundle:nil).instantiateViewController(withIdentifier: to) as! RootTabViewController
                self.present(toVc, animated: true, completion: nil);
                
            }else if to == Constant.SIGNUP_VC{
                let toVc: SignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: to) as! SignUpViewController
                self.present(toVc, animated: true, completion: nil);
            }else if to == Constant.VERIFICATION_VC{
                let toVc: VerificationViewController = self.storyboard?.instantiateViewController(withIdentifier: to) as! VerificationViewController
                self.present(toVc, animated: true, completion: nil);
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate{
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 50), animated: true);
        return true;
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true);
        return true
    }
}
