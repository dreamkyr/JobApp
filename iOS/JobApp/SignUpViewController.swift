//
//  SignUpViewController.swift
//  JobApp
//
//  Created by Admin on 01/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import Toaster
import PMSuperButton

class SignUpViewController: UIViewController{

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirm: UITextField!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var cancelButton: PMSuperButton!
    @IBOutlet weak var signUpButton: PMSuperButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDismissKeyboard()
        NotificationCenter.default.addObserver(self, selector:#selector(self.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        cancelButton.touchUpInside {
            self.dismiss(animated: true, completion: nil);
        }

        
        signUpButton.touchUpInside {
            self.onSignup()
        }
        
        // Do any additional setup after loading the view.

    }
    

    
    
    func keyboardWillAppear(_ notification: NSNotification){
        
    }
    
    func keyboardWillDisappear(_ notification: NSNotification){
    //    self.scrollview.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }


    
    @IBAction func backAction(_ sender: UIButton) {
        self.goto(to: Constant.LOGIN_VC, params: nil)
    }
    
    func onSignup() {
        let result = CtrCommon.isInputComplete(["Email": self.username.text!, "Password": self.password.text!, "Confirm password": self.confirm.text!])
        if result != nil{
            Toast(text: "Please enter " + result!).show()
            return;
        }
        
        let usernameStr:String = username.text!
        let passwordStr:String = password.text!
        let confirmStr:String = confirm.text!
        
        if !self.username.text!.isValidEmail(){
            Toast(text: "Email incorrect!").show()
            return;
        }
        
        if passwordStr != confirmStr {
            Toast(text: "Please confirm password.").show()
            return;
        }
     //   var params:[String:Any] = [:]
       // params["email"] = usernameStr
        //params["password"] = passwordStr
        
        CtrCommon.startRunProcess(viewController: self, completion: {
         
            
            UserProvider.request(.signUp(email: usernameStr, password: passwordStr)) { result in
                CtrCommon.stopRunProcess();
                switch result {
                case .success(let response):
                    
                    let json = JSON(response.data)
                    switch response.statusCode {
                    case 200:
                        SharedKeycard.token = json["data"]["token"].string!
                       self.goto(to: Constant.VERIFICATION_VC, params: nil);
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
            if to == Constant.VERIFICATION_VC{
                let toVc: VerificationViewController = UIStoryboard(name: "Verification", bundle:nil).instantiateViewController(withIdentifier: to) as! VerificationViewController
                self.present(toVc, animated: true, completion: nil)
            }else if to == Constant.LOGIN_VC{
                self.dismiss(animated: true, completion: nil);
            }
        }
    }
}

extension SignUpViewController: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.confirm{
            self.scrollview.setContentOffset(CGPoint(x: 0, y: 70 ), animated: true);
            
        }
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.scrollview.setContentOffset(CGPoint(x: 0, y: 0), animated: true);
        return true
    }

}
