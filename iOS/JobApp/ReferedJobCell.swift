//
//  FindJobCell.swift
//  JobApp
//
//  Created by Admin on 5/21/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class ReferedJobCell: UITableViewCell {
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var bid_ct_out: UILabel!
    @IBOutlet weak var new_bid_ct_out: UILabel!
    @IBOutlet weak var posted_time: UILabel!
    @IBOutlet weak var skillText: UILabel!
    @IBOutlet weak var cellBackView: EffectView!
    @IBOutlet weak var bidIconImage: UIImageView!
    @IBOutlet weak var employerNameText: UILabel!
    @IBOutlet weak var stateCityText: UILabel!
    
    private var job: Job! = nil;
    
    public func setJob(job: Job){
        self.job = job;
        self.initCell()
    }
    
    public func getSharedUserIndex()->Int{
        for i in 0 ..< self.job.shared_users.count{
            if AppCommon.instance.profile.user_id == self.job.shared_users[i].user_id{
                return i;
            }
        }
        return -1;
    }
    
    private func initCell(){
        if self.job != nil{
            let applyCount:Int = self.job.proposed_users.count
            self.skillText.text = "";
            var skillstr = "";
            for skill in self.job.skills{
                skillstr += ", " + CtrCommon.convertNiltoEmpty(string: skill, defaultstr: "")
            }
            if skillstr != ""{
                self.skillText.text = skillstr.substring(from: 1)
            }
            self.titleText.text = CtrCommon.convertNiltoEmpty(string: self.job.title, defaultstr: "")
            self.bid_ct_out.text = String(applyCount)
            
            self.new_bid_ct_out.layer.cornerRadius = self.new_bid_ct_out.frame.size.width / 2
            self.new_bid_ct_out.clipsToBounds = true
            if job.referrer.user_id == AppCommon.instance.profile.user_id{
                let moreNewApples = self.storeAppliesCount(jobId: self.job.id, applies: applyCount)
                if moreNewApples < 1 {
                    self.new_bid_ct_out.isHidden = true
                } else {
                    self.new_bid_ct_out.text = "\(moreNewApples)"
                    self.new_bid_ct_out.isHidden = false
                }
            } else {
                self.new_bid_ct_out.isHidden = true
            }
            
            
            if AppCommon.instance.profile.user_id == self.job.referrer.user_id{
                self.posted_time.text = CtrCommon.convertNiltoEmpty(string: self.job.posted_date, defaultstr: "")
            }else{
                if self.getSharedUserIndex() != -1{
                    self.posted_time.text = CtrCommon.convertNiltoEmpty(string: self.job.share_dates[self.getSharedUserIndex()], defaultstr: "")
                }
            }
            
            self.employerNameText.text = CtrCommon.convertNiltoEmpty(string: self.job.employer_name, defaultstr: "")
            self.stateCityText.text = CtrCommon.convertNiltoEmpty(string: self.job.country, defaultstr: "")
            //            if self.job.referrer.user_id != AppCommon.instance.profile.user_id{
//                self.cellBackView.backgroundColor = UIColor(red: 206.0/255.0, green: 1.0, blue: 185.0/255.0, alpha: 0.5)
//                self.titleText.textColor = UIColor.black
//                self.bid_ct_out.textColor = UIColor.black
//                self.posted_time.textColor = UIColor.black
//                self.skillText.textColor = UIColor.black
//                self.bidIconImage.image = UIImage(named: "bidicon-b")
//            }else{
//                self.cellBackView.backgroundColor = UIColor(red: 18.0/255.0, green: 118.0/255.0, blue: 129.0/255.0, alpha: 1)
//                self.titleText.textColor = UIColor.white
//                self.bid_ct_out.textColor = UIColor.white
//                self.posted_time.textColor = UIColor.white
//                self.skillText.textColor = UIColor.white
//                self.bidIconImage.image = UIImage(named: "bidicon")
//            }
        }
    }
    
    func storeAppliesCount(jobId: Int, applies: Int) -> Int {
        var diffApplies = 0
        let jobIdString = "\(jobId)"
        let latestAppliesString = UserDefaults.standard.value(forKey: jobIdString) as? String
//        UserDefaults.standard.set("\(applies)", forKey: "\(jobId)")
//        UserDefaults.standard.synchronize()
        if latestAppliesString != nil {
            let latestApplies = Int(latestAppliesString!)
            diffApplies = applies - latestApplies!
        } else {
            diffApplies = applies
        }
        
        if diffApplies < 0 {
            diffApplies = 0
        }
        
        return diffApplies
    }
}
