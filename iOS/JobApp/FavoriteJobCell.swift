//
//  FavoriteJobCell.swift
//  JobApp
//
//  Created by JaonMicle on 26/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class FavoriteJobCell: UITableViewCell {

    @IBOutlet weak var jobTitleText: UILabel!
    @IBOutlet weak var jobSkillsText: UILabel!
    @IBOutlet weak var postedDateText: UILabel!
    @IBOutlet weak var countryFlageImage: UIImageView!
    @IBOutlet weak var employerNameText: UILabel!
    @IBOutlet weak var stateCityText: UILabel!
    
    private var job : Job! = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func setData(job: Job){
        self.job = job
        self.initCell();
    }
    
    public func initCell(){
        if self.job != nil{
            
            self.jobTitleText.text = CtrCommon.convertNiltoEmpty(string: self.job.title, defaultstr: "")
            
            if self.job.referrer.code != nil{
                self.countryFlageImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(self.job.referrer.code.lowercased())")
            }
            self.employerNameText.text = CtrCommon.convertNiltoEmpty(string: self.job.employer_name, defaultstr: "")
            var locationStr = CtrCommon.convertNiltoEmpty(string: self.job.country, defaultstr: "")
            if self.job.state != nil{
                locationStr += ", " + CtrCommon.convertNiltoEmpty(string: self.job.state, defaultstr: "")
            }
            if self.job.city != nil{
                locationStr += ", " + CtrCommon.convertNiltoEmpty(string: self.job.city, defaultstr: "")
            }
            self.stateCityText.text = locationStr
            var skillStr = "";
            for skill in self.job.skills{
                skillStr += ", " +  skill;
            }
            if skillStr != ""{
                self.jobSkillsText.text = skillStr.substring(from: 1)
            }
            self.postedDateText.text = CtrCommon.convertNiltoEmpty(string: self.job.posted_date, defaultstr: "")
            
        }
        
    }
    
    
}
