//
//  InviteUserCell.swift
//  JobApp
//
//  Created by JaonMicle on 24/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class InviteUserCell: UITableViewCell {
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var emailOrPhoneText: UILabel!
    @IBOutlet weak var selectImage: UIImageView!
    @IBOutlet weak var profilePhoto: ExtentionImageView!
    
    
    public var contact: Contact! = nil;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setData(contact: Contact!, emailorphone: Bool){
        if contact != nil{
            self.contact = contact
            self.initCell(emailorphone: emailorphone)
        }
    }
    
    private func initCell(emailorphone: Bool){
        self.nameText.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.full_name, defaultstr: "")
        if emailorphone{
            self.emailOrPhoneText.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.email, defaultstr: "")
        }else{
            self.emailOrPhoneText.text = CtrCommon.convertNiltoEmpty(string: self.contact.profile.phone, defaultstr: "")
        }
    }
    
    public func selectSign(_ flag: Bool){
        if flag{
            self.selectImage.image = UIImage(named: "checkbtn")
        }else{
            self.selectImage.image = UIImage(named: "uncheckbtn")
        }
    }
}
