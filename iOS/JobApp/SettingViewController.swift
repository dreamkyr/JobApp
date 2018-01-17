//
//  ViewController.swift
//  JobApp
//
//  Created by Admin on 5/20/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import SCLAlertView
import Kingfisher
import Alamofire
import Toaster
import SwiftyJSON
import Contacts
import ContactsUI

let myBlueBgcolor = UIColor(red:0, green: 0.51, blue:0.82, alpha:1.0)
let myWhiteBgColor = UIColor(red:1.0, green: 1.0, blue:1.0, alpha: 1.0)
let myGreyBgColor = UIColor(red:0.90, green: 0.90, blue:0.90, alpha: 1.0)
let myBlackBgColor = UIColor(red:0.0, green: 0.0, blue:0.0, alpha: 1.0)
let myPrimanryColor = UIColor(red: 0.0, green: 129/255, blue: 210/255, alpha: 1.0)
let myGreenBgColor = UIColor(red:0.0, green: 1.0, blue:0.0, alpha: 1.0)

class SettingViewController: UIViewController {

    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var jobText: UILabel!
    @IBOutlet weak var profilePhotoCt: UIView!
    
    let kDefaultAnimationDuration = 2.0
    public var flag: Bool = false;
    
    public var gotoUpdateProfile: Bool = false
 
    override func viewDidLoad() {
       // super.viewDidLoad()
        nameText.text = "";
        jobText.text = "";
        
        if AppCommon.instance.profile == nil{
            self.loadData()
        }else{
            (AppCommon.instance.rootVc as! RootTabViewController).initMqtt();
        }
        
        profilePhotoCt.backgroundColor = myBlueBgcolor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.initView();
        
        if self.gotoUpdateProfile {
            self.gotoUpdateProfile = false
            self.goto(to: Constant.PROFILESETTING_VC, params: nil)
        }
    }
    
    private func getContactFromServer(){
        
        
    }
    
    public func loadData(){
        
        let contactStroe = CNContactStore()
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactEmailAddressesKey,
                           CNContactPhoneNumbersKey,
                           CNContactImageDataAvailableKey,
                           CNContactThumbnailImageDataKey] as [Any]
        CtrCommon.startRunProcess(viewController: self, completion: {
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
                    //var requestParams: [String: Any] = [:]
                    //requestParams["email"] = UserDefaults.standard.value(forKey: "useremail") as! String
                    //requestParams["password"] = UserDefaults.standard.value(forKey: "userpass") as! String
                    var params: [[String: Any]] = []
                    for phoneContact in AppCommon.instance.phoneContactData{
                        let param: [String: Any] = phoneContact.getDicData()
                        params.append(param)
                    }
                    
                    UserProvider.request(.me(phone_contacts: params)) { result in
                        CtrCommon.stopRunProcess();
                        switch result {
                        case .success(let response):
                            
                            let json = JSON(response.data)
                            switch response.statusCode {
                            case 200:
    
                                print("test test")
                                if AppCommon.instance.initApp(data: json["data"]){
                                    (AppCommon.instance.rootVc as! RootTabViewController).initMqtt();
                                    
                                    NotificationsProvider.request(.notificationGet){ result in
                                        CtrCommon.stopRunProcess()
                                        switch result {
                                        case .success(let response):
                                            let jsonData = JSON(response.data)
                                            if jsonData["code"].intValue == 200{
                                                for notiData in jsonData["data"].arrayValue{
                                                    (AppCommon.instance.rootVc as! RootTabViewController).notificationMsgProcess(notiData.rawString()!);
                                                }
                                            }
                                            break;
                                        
                                        case .failure(let error):
                                            print(error.localizedDescription);
                                            break;
                                        }

                                    }
                                    
                                    
                                    DispatchQueue.main.async {
                                        self.initView();
                                    }
                                    SharedKeycard.token = json["data"]["token"].string!
                                }
                                
                            default:
                                
                                
                                if json["message"].stringValue == "Account not exists." {
                                    print("me error 4")
                                    Toast(text: json["message"].stringValue).show()
                                    SharedKeycard.removeToken()
                                    SharedKeycard.verified = false
                                    self.goto(to: Constant.GET_STARTED_VC, params: nil)
                                } else {
                                    Toast(text: json["data"].stringValue).show()
                                }
                                CtrCommon.stopRunProcess();
                                
                                
                                
                            }
                        case .failure(let error):
                           
                            CtrCommon.stopRunProcess();
                           
                            Toast(text: error.localizedDescription).show()
                           
                        }
                    }
                    
                    
                }else{
                    CtrCommon.stopRunProcess();
                }
            })
        })
        
        
    }
    
    private func initView(){
        if AppCommon.instance.profile != nil{
            if let urlstr = AppCommon.instance.profile.photo, let url = URL(string: urlstr){
                self.profilePhoto.kf.setImage(with: url);
            }
            self.nameText.text = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.first_name, defaultstr: "") + " "
                + CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.last_name, defaultstr: "");
            self.jobText.text = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.job_title, defaultstr: "")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.	
    }
    
    
    @IBAction func profileSettingBtnAction(_ sender: UIButton){
        self.goto(to: Constant.PROFILESETTING_VC, params: nil)
    }
    
    @IBAction func notificationSettingBtnAction(_ sender: UIButton) {
        self.goto(to: Constant.NOTISETTING_VC, params: nil)
    }
    
    @IBAction func favoriteJobsAction(_ sender: UIButton) {
        self.goto(to: Constant.FAVORITEJOBS_VC, params: nil)
    }
    
    @IBAction func helpBtnAction(_ sender: UIButton) {
        self.goto(to: Constant.HELP_VC, params: nil);
    }
    
    
    @IBAction func inviteFriendBtnAction(_ sender: UIButton) {
        let alert = SCLAlertView()
        _ = alert.addButton("Mail"){
            let params: [String: Any] = ["data": self.getUserByEmail(), "emailorphone": true]
            self.goto(to: Constant.INVITEUSER_VC, params: params);
        }
        _ = alert.addButton("Message") {
            let params: [String: Any] = ["data": self.getUserByPhone(), "emailorphone": false]
            self.goto(to: Constant.INVITEUSER_VC, params: params)
        }
        //_ = alert.showSuccess(kSuccessTitle, subTitle: kSubtitle)
        let icon = UIImage(named: "inviteicon")
        let color = myBlackBgColor//UIColor(red: 19/255, green: 71/255, blue: 78/255, alpha: 1)
        
        _ = alert.showCustom("Tell a Friend/Invite", subTitle: "Please Choose Item", color: color, icon: icon!)

    }
    
    private func getUserByEmail()->[Contact]{
        var emailUsers: [Contact] = []
        for user in AppCommon.instance.noContacts{
            if user.profile.email != nil && user.profile.email.isValidEmail(){
                emailUsers.append(user)
            }
        }
        return emailUsers;
    }
    
    private func getUserByPhone()->[Contact]{
        var phoneUsers: [Contact] = []
        for user in AppCommon.instance.noContacts{
//            if user.profile.phone != nil && user.profile.phone.isValidatePhone(){
            if user.profile.phone != nil{
                phoneUsers.append(user)
            }
        }
        return phoneUsers;
    }
    
    public func loadData(flag: Bool){
        self.flag = flag;
    }
    
    private func goto(to: String, params: Any!){
       if to == Constant.PROFILESETTING_VC{
            let toVc: ProfileSettingViewController = UIStoryboard(name: "ProfileSetting", bundle: nil).instantiateViewController(withIdentifier: to) as! ProfileSettingViewController;
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.NOTISETTING_VC{
            let toVc: NotificationSettingViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: to) as! NotificationSettingViewController;
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.HELP_VC{
            let toVc: HelpViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: to) as! HelpViewController;
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.LOGIN_VC{
            let toVc: LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: to) as! LoginViewController;
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.INVITEUSER_VC{
            let toVc: InviteUserViewController = self.storyboard?.instantiateViewController(withIdentifier: to) as! InviteUserViewController;
            toVc.setData(data: params);
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.FAVORITEJOBS_VC{
            let toVc: FavoriteJobsViewController = self.storyboard?.instantiateViewController(withIdentifier: to) as! FavoriteJobsViewController;
            self.present(toVc, animated: true, completion: nil);
       } else if to == Constant.GET_STARTED_VC{
        //let toVc: GetStartedViewController =  UIStoryboard(name:"GetStarted", bundle: nil).instantiateViewController(withIdentifier: to) as! GetStartedViewController;
        //self.present(toVc, animated: true, completion: nil);
        self.dismiss(animated: true, completion: nil)

        }
    }


}

