//
//  ForgotPasswordViewController.swift
//  JobApp
//
//  Created by thanks on 8/6/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

import Alamofire
import Toaster
import SwiftyJSON
import SkyFloatingLabelTextField
import PMSuperButton

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var verificationCode: SkyFloatingLabelTextField!
    
    @IBOutlet weak var newPasswordText: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmPasswordText: SkyFloatingLabelTextField!
    
    public var email: String = ""
    var uid: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.requestVerificationCode()
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        self.back()
    }
    
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onResendCode(_ sender: UIButton) {
        self.requestVerificationCode()
    }
    
    @IBAction func onChangePwd(_ sender: UIButton) {
        
        if self.uid < 0 {
            Toast(text: "Your email address does not exist.").show()
            return
        }

        let code = self.verificationCode.text!.trim()
        let newPwd = self.newPasswordText.text!.trim()
        let confirmPwd = self.confirmPasswordText.text!.trim()
        
        if code == "" {
            Toast(text: "Input a valid code.").show()
            return
        }
        
        if newPwd == "" {
            Toast(text: "Input a valid password.").show()
            return
        }
        
        if newPwd != confirmPwd {
            Toast(text: "Confirm password does not match.").show()
            return
        }
        
        let params = ["user_id": "\(self.uid)",
                      "code": code,
                      "password": newPwd]
        
        CtrCommon.startRunProcess(viewController: self, completion: {
            Alamofire.request(Constant.RESETPASS_URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).validate().responseJSON { (response) in
                CtrCommon.stopRunProcess();
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data)
                    print(jsonData)
                    Toast(text: jsonData["message"].stringValue).show()
                    if jsonData["code"].intValue == 200{
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    break;
                }
            }
        })
    }
    
    func tapView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func requestVerificationCode(){
        CtrCommon.startRunProcess(viewController: self, completion: {
            Alamofire.request(Constant.FORGOTENPASS_URL, method: .post, parameters: ["email": self.email], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON(completionHandler: { (response) in
                CtrCommon.stopRunProcess()
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data).dictionaryValue
                    print(jsonData)
                    let userIdInfo = JSON(data)["message"].dictionaryObject
                    if userIdInfo != nil, userIdInfo!["user_id"] != nil {
                        self.uid = userIdInfo!["user_id"] as! Int
                    } else {
                        Toast(text: JSON(data)["message"].stringValue).show()
                    }
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    break;
                }
            })
        })
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
