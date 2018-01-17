//
//  ProposedCell.swift
//  JobApp
//
//  Created by JaonMicle on 11/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import FoldingCell
import Kingfisher
import Toaster
    
class ProposedCell: FoldingCell {
    
    @IBOutlet weak var userNameOutLabel: UILabel!
    @IBOutlet weak var jobOutLabel: UILabel!
    @IBOutlet weak var userNameInLabel: UILabel!
    @IBOutlet weak var jobInLabel: UILabel!
    @IBOutlet weak var countryStateLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userOutPhoto: ExtentionImageView!
    @IBOutlet weak var userInPhoto: ExtentionImageView!
    
    @IBOutlet weak var flagImage: UIImageView!
    
    private var user: ProposedUser! = nil;
    private var viewProfile: ((_ profile: Profile)->Void)! = nil;
    private var userCall: ((_ phone:String )->Void)! = nil;
    private var userChat: ((_ id: Int)->Void)! = nil;
    private var userEmail: ((_ email: String)->Void)! = nil;
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func jobCallAction(_ sender: UIButton) {
        self.userCall(self.user.contact_phone)
    }
    
    @IBAction func jobChatAction(_ sender: UIButton) {
        self.userChat(self.user.profile.user_id)
    }
    
    @IBAction func jobEmailAction(_ sender: UIButton) {
        self.userEmail(self.user.contact_email)
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    public func setData(user: ProposedUser, viewprofile: ((_ profile: Profile)->Void)!, usercall: ((_ phone: String)->Void)!, userchat: ((_ id: Int)->Void)!, useremail: ((_ email: String)->Void)!){
        self.user = user;
        self.viewProfile = viewprofile
        self.userCall = usercall;
        self.userChat = userchat;
        self.userEmail = useremail;
        self.initCell();
    }
    
    private func initCell(){
        self.userNameInLabel.text = CtrCommon.convertNiltoEmpty(string: self.user.profile.first_name, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.user.profile.last_name, defaultstr: "")
        self.userNameOutLabel.text = self.userNameInLabel.text
        self.jobInLabel.text = CtrCommon.convertNiltoEmpty(string: self.user.profile.job_title, defaultstr: "")
        self.jobOutLabel.text = self.jobInLabel.text
        
        self.countryStateLabel.text = CtrCommon.convertNiltoEmpty(string: self.user.profile.country, defaultstr: "")  + " " + CtrCommon.convertNiltoEmpty(string: self.user.profile.state, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.user.profile.city, defaultstr: "")
        self.phoneLabel.text = CtrCommon.convertNiltoEmpty(string: self.user.contact_phone, defaultstr: "")
        self.emailLabel.text = CtrCommon.convertNiltoEmpty(string: self.user.contact_email, defaultstr: "")
        if self.user.profile.photo != nil{
            if let url = URL(string: self.user.profile.photo){
                self.userInPhoto.kf.setImage(with: url)
                self.userOutPhoto.kf.setImage(with: url)
            }
        }
        if self.user.profile.code != nil{
            self.flagImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(self.user.profile.code!.lowercased())")
        }
    }
    
    @IBAction func viewProfileAction(_ sender: UIButton) {
        if self.user.profile.share{
            self.viewProfile(self.user.profile)
        }else{
            Toast(text: "Profile is privated").show();
        }
    }
    
    
    
}

