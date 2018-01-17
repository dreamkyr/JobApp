//
//  ContactsCell.swift
//  JobApp
//
//  Created by Admin on 5/20/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import FoldingCell
import Kingfisher
import Alamofire
import SwiftyJSON
import Toaster


class ContactsCell: FoldingCell {
    
    private var contact: Contact! = Contact(){
        didSet{
            // UI init.
        }
    }
    
    private var callbackFunc: ((Int)->Void)! = nil;
    private var viewProfile: ((Int)->Void)! = nil;
    private var userCall: ((String)->Void)! = nil;
    private var userChat: ((Int)->Void)! = nil;
    private var userEmail: ((String)->Void)! = nil;
    private var userAllow: ((Int)->Void)! = nil;
    private var userAdd: ((Int)->Void)! = nil;
    
    @IBOutlet weak var contactNameOutLabel: UILabel!
    @IBOutlet weak var contactJobOutLabel: UILabel!
    @IBOutlet weak var photoOutImage: ExtentionImageView!
    @IBOutlet weak var photoInImage: ExtentionImageView!
    @IBOutlet weak var contactNameInLabel: UILabel!
    @IBOutlet weak var contactJobInLabel: UILabel!
    @IBOutlet weak var countryStateLabel: UILabel!
    @IBOutlet weak var stateCityOutLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var statusAllowConstraint: NSLayoutConstraint!
    @IBOutlet weak var allowBtnView: UIView!
    @IBOutlet weak var addBtnView: UIView!
    @IBOutlet weak var displaySetting: UISwitch!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var notiView1: EffectView!
    @IBOutlet weak var notiView2: EffectView!
    @IBOutlet weak var coutuntryFlagView: UIView!
    
    

    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 0
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func setData(userdata: Any?, callbackfunc: @escaping (Int)->Void, viewprofile: @escaping ((Int)->Void), usercall: @escaping ((String)->Void), useremail: @escaping ((String)->Void),userchat: @escaping ((Int)->Void),  userallow: @escaping ((Int)->Void),  useradd: @escaping ((Int)->Void)){
        if userdata != nil{
            self.contact = userdata as! Contact;
            self.callbackFunc = callbackfunc;
            self.viewProfile = viewprofile
            self.userCall = usercall;
            self.userEmail = useremail
            self.userChat = userchat
            self.userAllow = userallow;
            self.userAdd = useradd;
            self.initCell();
        }
    }
    
    @IBAction func chatAction(_ sender: UIButton) {
        self.userChat(self.contact.profile.user_id)
    }
    
    @IBAction func callAction(_ sender: UIButton) {
        self.userCall(self.contact.profile.phone)
    }
   
    @IBAction func emailSendAction(_ sender: UIButton) {
        self.userEmail(self.contact.profile.email)
    }
    
    @IBAction func allowAction(_ sender: UIButton) {
        self.userAllow(self.contact.profile.user_id)
    }
    
    @IBAction func viewProfileAction(_ sender: UIButton) {
        if self.contact.profile.share{
            self.viewProfile(self.contact.profile.user_id)
        }else{
            Toast(text: "Privated Profile").show()
        }
    }
    
    
    @IBAction func viewPostedJobAction(_ sender: UIButton){
        self.callbackFunc(self.contact.profile.user_id);
    }
    
    @IBAction func displaySettingAction(_ sender: UISwitch) {
        Alamofire.request(Constant.DISPLAY_SETTING_URL, method: .post, parameters: ["user_id": self.contact.profile.user_id, "isShared": sender.isOn], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
            switch response.result{
            case .success(let data):
                let jsonData = JSON(data);
                if jsonData["code"].intValue == 200{
                    for i in 0 ..< AppCommon.instance.contacts.count{
                        if AppCommon.instance.contacts[i].profile.user_id == self.contact.profile.user_id{
                            AppCommon.instance.contacts[i].display_setting = sender.isOn
                        }
                    }
                }else{
                    sender.setOn(!sender.isOn, animated: false)
                }
                Toast(text: jsonData["message"].stringValue).show();
                break;
            case .failure(let error):
                Toast(text: error.localizedDescription).show();
                break;
            }
        }
    }
    
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    private func initCell(){
        self.contactNameOutLabel.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.full_name, defaultstr: "")
        self.contactNameInLabel.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.full_name, defaultstr: "")
    
        self.contactJobInLabel.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.job_title, defaultstr: "")
        self.contactJobOutLabel.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.job_title, defaultstr: "")
        
        self.countryLabel.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.country, defaultstr: "")
        
        var address = ""
        let city = CtrCommon.convertNiltoEmpty(string: self.contact.profile.city, defaultstr: "")
        if city != "" {
            address = city
        }
        let state = CtrCommon.convertNiltoEmpty(string: self.contact.profile.state, defaultstr: "")
        if state != "" {
            if address == "" {
                address = state
            } else {
                address = address + ", " + state
            }
        }
        self.stateCityOutLabel.text = address
        
        let country = CtrCommon.convertNiltoEmpty(string: self.contact.profile.country, defaultstr: "")
        if country != "" {
            if address == "" {
                address = country
            } else {
                address = address + ", " + country
            }
        }
        self.countryStateLabel.text = address
        
        self.phoneLabel.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.phone, defaultstr: "")
        self.emailLabel.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.email, defaultstr: "")
    
        if self.contact.profile.photo != nil{
            if let url = URL(string: self.contact.profile.photo){
                self.photoOutImage.kf.setImage(with: url)
                self.photoInImage.kf.setImage(with: url)
            }
        } else {
            self.photoOutImage.image = UIImage.init(named: "profilemain")
            self.photoInImage.image = UIImage.init(named: "profilemain")
        }
        
        self.displaySetting.setOn(self.contact.display_setting, animated: false)
        if self.contact.profile.code != nil{
            self.flagImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(self.contact.profile.code!.lowercased())")
        }
        
        if self.contact.status == 2{
            self.foregroundView.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
            self.coutuntryFlagView.backgroundColor = UIColor.clear
        }else if self.contact.status == 1{
            self.foregroundView.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
            self.coutuntryFlagView.backgroundColor = UIColor.clear
        }else{
            self.foregroundView.backgroundColor = myWhiteBgColor
            self.coutuntryFlagView.backgroundColor = UIColor.clear
        }
        
        if AppCommon.instance.getSharedNotificationCount(userId: String(self.contact.profile.user_id)) != 0{
            if UserDefaults.standard.bool(forKey: "shownoti_flag"){
                self.notiView1.isHidden = false;
                self.notiView2.isHidden = false;
            }
        }else{
            self.notiView1.isHidden = true;
            self.notiView2.isHidden = true;
        }
    }
    
    @IBAction func addContactAction(_ sender: UIButton) {
        self.userAdd(self.contact.profile.user_id);
    }
    
    

}
