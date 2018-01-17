//
//  JobCell.swift
//  JobApp
//
//  Created by JaonMicle on 22/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class JobCell: UITableViewCell {
    
    @IBOutlet weak var jobTitleText: UILabel!
    @IBOutlet weak var jobSkillsText: UILabel!
    @IBOutlet weak var postedDateText: UILabel!
    @IBOutlet weak var countryFlageImage: UIImageView!
    @IBOutlet weak var employerNameText: UILabel!
    @IBOutlet weak var stateCityText: UILabel!
    @IBOutlet weak var applyImage: UIImageView!
    @IBOutlet weak var shareImage: UIImageView!
    @IBOutlet weak var backView: EffectView!
    @IBOutlet weak var notiView: EffectView!
    
    private var userId: Int! = nil;

    private var job : Job! = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setData(job: Job, user: Int){
        self.job = job
        self.userId = user;
        self.initCell();
    }
    
    public func getSharedUserIndex()->Int{
        for i in 0 ..< self.job.shared_users.count{
            if userId == self.job.shared_users[i].user_id{
                return i;
            }
        }
        return -1;
    }
    
    public func initCell(){
        if self.job != nil{
            
            self.jobTitleText.text = CtrCommon.convertNiltoEmpty(string: self.job.title, defaultstr: "")
            
            if self.job.referrer.code != nil{
                self.countryFlageImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(self.job.referrer.code.lowercased())")
            }
            self.employerNameText.text = CtrCommon.convertNiltoEmpty(string: self.job.employer_name, defaultstr: "")
            
            var locationStr = ""
            if self.job.city != nil{
                locationStr =  CtrCommon.convertNiltoEmpty(string: self.job.city, defaultstr: "")
            }
            
            if self.job.state != nil{
                if locationStr == "" {
                    locationStr = CtrCommon.convertNiltoEmpty(string: self.job.state, defaultstr: "")
                } else {
                    locationStr += ", " + CtrCommon.convertNiltoEmpty(string: self.job.state, defaultstr: "")
                }
            }
            
            locationStr += "\n"
            locationStr += CtrCommon.convertNiltoEmpty(string: self.job.country, defaultstr: "")
            self.stateCityText.text = locationStr
            
            var skillStr = "";
            for skill in self.job.skills{
                skillStr += ", " +  skill;
            }
            if skillStr != ""{
                self.jobSkillsText.text = skillStr.substring(from: 1)
            }
            
            if self.userId == self.job.referrer.user_id{
                self.postedDateText.text = CtrCommon.convertNiltoEmpty(string: self.job.posted_date, defaultstr: "")
                if job.posted_date.index(of: "hour") != nil || job.posted_date.index(of: "min") != nil{
                    //self.backView.backgroundColor = UIColor(red: 18.0/225.0, green: 114.0/255.0, blue: 72.0/225.0, alpha: 0.75)
                }else{
                    //self.backView.backgroundColor =  UIColor(red: 0.070, green: 0.464, blue: 0.506, alpha: 1.0)
                }
            }else{
                if self.getSharedUserIndex() != -1{
                    self.postedDateText.text = CtrCommon.convertNiltoEmpty(string: self.job.share_dates[self.getSharedUserIndex()], defaultstr: "")
                    let sharedDate = self.postedDateText.text!
                    if sharedDate.index(of: "hour") != nil || sharedDate.index(of: "min") != nil{
                      //  self.backView.backgroundColor = UIColor(red: 18.0/225.0, green: 114.0/255.0, blue: 72.0/225.0, alpha: 0.75)
                    }else{
                        //self.backView.backgroundColor =  UIColor(red: 0.070, green: 0.464, blue: 0.506, alpha: 1.0)
                    }
                }
            }
            
            if AppCommon.instance.isNotificationJob(jobId: String(self.job.id)){
                if UserDefaults.standard.bool(forKey: "shownoti_flag"){
                    self.notiView.isHidden = false;
                }
            }else{
                self.notiView.isHidden = true;
            }
            
            if AppCommon.instance.isApplied(job: self.job){
                self.applyImage.isHidden = false;
            } else {
                self.applyImage.isHidden = true;
            }
            
            if AppCommon.instance.isShared(job: self.job){
                self.shareImage.isHidden = false;
            } else {
                self.shareImage.isHidden = true;
            }
        }
        
    }
    
    

}
