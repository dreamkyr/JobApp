//
//  UserPostedJobsViewController.swift
//  JobApp
//
//  Created by JaonMicle on 22/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class UserPostedJobsViewController: UIViewController {

    @IBOutlet weak var jobTable: UITableView!
    
    
    public var myJob:FindJob! = nil;
    
    public var totalJobs: [Job] = []
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var postedJobDescriptionText: UILabel!
    @IBOutlet weak var postedUserPhoto: UIImageView!
    @IBOutlet weak var shareBtnIcon: UIImageView!
    @IBOutlet weak var appliedBtnIcon: UIImageView!
   
    
    @IBOutlet weak var test: EffectView!
    
    public let cellId: String = "JobCell";
    private var searchType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData();
        self.initView();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.jobTable.reloadData();
    }
    
    public func initView(){
        let userProfile: Profile = AppCommon.instance.getContact(id: self.myJob.user_id).profile
        self.nameText.text = CtrCommon.convertNiltoEmpty(string: userProfile.full_name, defaultstr: "")
        
        if userProfile.photo != nil{
            if let url = URL(string: userProfile.photo){
                self.postedUserPhoto.kf.setImage(with: url)
            }
        }
        
        self.postedJobDescriptionText.text = "Jobs Posted: " + String(self.myJob.postedCount) + " Recent: " + String(self.myJob.recentCount)
    }
    
    public func initData(){
        if self.myJob != nil{
            var postedJobs:[Job] = []
            var recentJobs:[Job] = []
            var sharedJobs:[Job] = []
            for job in self.totalJobs{
                if job.posted_date.index(of: "hour") != nil || job.posted_date.index(of: "min") != nil{
                    recentJobs.append(job)
                }else if job.referrer.user_id == self.myJob.user_id{
                    postedJobs.append(job)
                }else{
                    sharedJobs.append(job)
                }
            }
            self.totalJobs = []
            for job in recentJobs{
                self.totalJobs.append(job)
            }
            for job in postedJobs{
                self.totalJobs.append(job)
            }
            for job in sharedJobs{
                self.totalJobs.append(job)
            }
            self.myJob.jobs = self.totalJobs;
        }
    }
    
    @IBAction func appliedSearchAction(_ sender: UIButton) {
        self.shareBtnIcon.image = UIImage(named: "option")
        if self.searchType == "Applied"{
            self.searchType = ""
            self.appliedBtnIcon.image = UIImage(named: "option")
        }else{
            self.searchType = "Applied"
            self.appliedBtnIcon.image = UIImage(named: "option_focus")
        }
        self.search();
    }
    
    @IBAction func sharedSearchAction(_ sender: UIButton) {
        self.appliedBtnIcon.image = UIImage(named: "option")
        if self.searchType == "Shared"{
            self.searchType = ""
            self.shareBtnIcon.image = UIImage(named: "option")
        }else{
            self.searchType = "Shared"
            self.shareBtnIcon.image = UIImage(named: "option_focus")
        }
        self.search();
    }
    
    public func search(){
        self.totalJobs = []
        if self.searchType == "Applied"{
            for job in self.myJob.jobs{
                if AppCommon.instance.isApplied(job: job){
                    self.totalJobs.append(job)
                }
            }
        }else if self.searchType == "Shared"{
            for job in self.myJob.jobs{
                if AppCommon.instance.isShared(job: job){
                    self.totalJobs.append(job)
                }
            }
        }else{
            self.totalJobs = self.myJob.jobs
        }
        self.jobTable.reloadData();
    }
    
    public func setData(myjob: FindJob){
        self.myJob = myjob;
        self.totalJobs = self.myJob.jobs
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func goto(to: String, param: Any!){
        if to == Constant.SKILL_VC{
            let toVc: SkillViewController = UIStoryboard(name:"SkillView", bundle:nil).instantiateViewController(withIdentifier: to) as! SkillViewController
            toVc.parentVc = self
            toVc.setData(params: param)
            self.present(toVc, animated: true, completion: nil)
        }else if to == Constant.JOBDETAILS_VC{
            let toVc: JobDetailsViewController = UIStoryboard(name: "JobDetails" , bundle: nil).instantiateViewController(withIdentifier: to) as! JobDetailsViewController
            toVc.setData(params: param)
            self.present(toVc, animated: true, completion: nil)
        }
    }
}

extension UserPostedJobsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalJobs.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !AppCommon.instance.profile.isCompleted() {
            self.dismiss(animated: true, completion: nil)
            (AppCommon.instance.rootVc as! RootTabViewController).showTopNotification(msg: "Complete profile to view job.")
            return;
        }
        
        if AppCommon.instance.isNotificationJob(jobId: String(self.totalJobs[indexPath.row].id)){
            AppCommon.instance.removeJobNotification(userId: String(self.myJob.user_id), jobId: String(self.totalJobs[indexPath.row].id))
        }
        self.goto(to: Constant.JOBDETAILS_VC, param: self.totalJobs[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! JobCell
        cell.backgroundColor = UIColor.clear
        cell.setData(job: self.totalJobs[indexPath.row], user: self.myJob.user_id)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor(white: 1, alpha: 0.2)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.clear
    }
}
