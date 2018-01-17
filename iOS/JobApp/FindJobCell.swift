//
//  FindJobContactCell.swift
//  JobApp
//
//  Created by Admin on 5/29/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import FoldingCell
import Alamofire
import SwiftyJSON
import Kingfisher

class FindJobCell: UITableViewCell{
    
    @IBOutlet weak var profilePhoto: ExtentionImageView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var postedText: UILabel!
    @IBOutlet weak var recentText: UILabel!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var notiView: EffectView!
    
    
    private var profile: Profile = Profile();
    private var recentJobsCount: Int = 0
    private var postedJobsCount: Int = 0;
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
    public func setData(profile: Profile, recentjobscount: Int, postedjobscount: Int){
        self.profile = profile
        self.recentJobsCount = recentjobscount
        self.postedJobsCount = postedjobscount
        self.initCell();
    }
    
    public func initCell(){
        self.nameText.text = CtrCommon.convertNiltoEmpty(string: self.profile.full_name, defaultstr: "")
 
        self.postedText.text = "Jobs Posted: " + String(self.postedJobsCount)
        self.recentText.text = "Recent: " + String(self.recentJobsCount)
       if self.profile.photo != nil{
            if let url = URL(string: self.profile.photo){
                self.profilePhoto.kf.setImage(with: url);
            }
        }
        
        if self.profile.code != nil{
            self.flagImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(self.profile.code!.lowercased())")
        } else {
            self.flagImage.image = UIImage(named: "profilemain")
        }
        
        if AppCommon.instance.getJobNotificationCount(userId: String(self.profile.user_id)) != 0{
            if UserDefaults.standard.bool(forKey: "shownoti_flag"){
                self.notiView.isHidden = false;
            }
        }else{
            self.notiView.isHidden = true;
        }
    }
    
    
}
