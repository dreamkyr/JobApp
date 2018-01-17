//
//  SelectContactsCellTableViewCell.swift
//  JobApp
//
//  Created by JaonMicle on 16/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

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

class SelectContactsCell: FoldingCell {
    
    private var profile: Profile! = Profile()
        
    private var selectCallbackFunc: ((Int)->Void)! = nil;
    
    @IBOutlet weak var contactNameOutLabel: UILabel!
    @IBOutlet weak var contactJobOutLabel: UILabel!
    @IBOutlet weak var photoOutImage: ExtentionImageView!
    @IBOutlet weak var photoInImage: ExtentionImageView!
    @IBOutlet weak var contactNameInLabel: UILabel!
    @IBOutlet weak var contactJobInLabel: UILabel!
    @IBOutlet weak var countryStateLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var flagImage: UIImageView!
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setData(userdata: Any?, selcallbackfunc: @escaping (Int)->Void){
        if userdata != nil{
            self.profile = (userdata as! Contact).profile;
            self.selectCallbackFunc = selcallbackfunc
            self.initCell();
        }
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    private func initCell(){
        self.contactNameOutLabel.text = CtrCommon.convertNiltoEmpty(string: self.profile.first_name, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.profile.last_name, defaultstr: "")
        self.contactNameInLabel.text = CtrCommon.convertNiltoEmpty(string: self.profile.first_name, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.profile.last_name, defaultstr: "")
        self.contactJobInLabel.text = CtrCommon.convertNiltoEmpty(string: self.profile.job_title, defaultstr: "")
        self.contactJobOutLabel.text = CtrCommon.convertNiltoEmpty(string: self.profile.job_title, defaultstr: "")
        
        self.countryStateLabel.text = CtrCommon.convertNiltoEmpty(string: self.profile.country, defaultstr: "") + " : " + CtrCommon.convertNiltoEmpty(string: self.profile.state, defaultstr: "")
        self.phoneLabel.text = CtrCommon.convertNiltoEmpty(string: self.profile.phone, defaultstr: "")
        self.emailLabel.text = CtrCommon.convertNiltoEmpty(string: self.profile.email, defaultstr: "")
        if self.profile.photo != nil{
            if let url = URL(string: self.profile.photo){
                self.photoOutImage.kf.setImage(with: url)
                self.photoInImage.kf.setImage(with: url)
            }
        }
        if self.profile.code != nil{
            self.flagImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(self.profile.code!.lowercased())")
        }
        
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        if self.checkImageView.image == UIImage(named: "checkbtn"){
           self.checkImageView.image = UIImage(named: "uncheckbtn")
        }else{
           self.checkImageView.image = UIImage(named: "checkbtn") 
        }
        self.selectCallbackFunc(self.profile.user_id)
    }
    
    
    
}
