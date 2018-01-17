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


class NoContactsCell: FoldingCell {
    
    private var contact: Contact! = Contact(){
        didSet{
            // UI init.
        }
    }
    
    private var userCall: ((String)->Void)! = nil;
    private var userEmail: ((String)->Void)! = nil;
    @IBOutlet weak var contactNameOutLabel: UILabel!
    @IBOutlet weak var photoOutImage: ExtentionImageView!
    @IBOutlet weak var photoInImage: ExtentionImageView!
    @IBOutlet weak var contactNameInLabel: UILabel!
    @IBOutlet weak var countryStateLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var countryOutLabel: UILabel!
    @IBOutlet weak var stateCityOutLabel: UILabel!
    
   
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 0//10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func setData(userdata: Any?, usercall: @escaping ((String)->Void), useremail: @escaping ((String)->Void)){
        if userdata != nil{
            self.contact = userdata as! Contact;
            self.userCall = usercall;
            self.userEmail = useremail
            self.initCell();
        }
    }
    
    @IBAction func callAction(_ sender: UIButton) {
        if self.contact.profile.phone != nil{
            self.userCall(self.contact.profile.phone)
        }else{
            Toast(text: "Invalidate Phone number").show()
        }
    }
    
    @IBAction func emailSendAction(_ sender: UIButton) {
        if self.contact.profile.email != nil{
            self.userEmail(self.contact.profile.email)
        }else{
            Toast(text: "Invalidate Email").show()
        }
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    private func initCell(){
        self.contactNameOutLabel.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.first_name, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.contact.profile.last_name, defaultstr: "")
        self.contactNameInLabel.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.first_name, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.contact.profile.last_name, defaultstr: "")
        
        self.phoneLabel.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.phone, defaultstr: "")
        self.emailLabel.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.email, defaultstr: "")
        if self.contact.profile.photo != nil{
            if let url = URL(string: self.contact.profile.photo){
                self.photoOutImage.kf.setImage(with: url)
                self.photoInImage.kf.setImage(with: url)
            }
        }
        if self.contact.profile.code != nil{
            self.flagImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(self.contact.profile.code!.lowercased())")
        }
    }
}
