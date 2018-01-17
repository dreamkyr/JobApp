//
//  FindJobViewController.swift
//  JobApp
//
//  Created by Admin on 5/21/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import SwiftyJSON
import MessageUI
import Presentr
import RxSwift

struct FindJob{
    public var user_id: Int! = nil;
    public var jobs:[Job] = []
    public var recentCount: Int = 0
    public var postedCount: Int = 0
}


class FindJobViewController: UIViewController{
    
    
    //@IBOutlet weak var countryText: PlaceHolderTextField!
    //@IBOutlet weak var stateText: PlaceHolderTextField!
    //@IBOutlet weak var cityText: PlaceHolderTextField!
    @IBOutlet weak var jobTable: UITableView!

    //@IBOutlet weak var countryImage: UIImageView!
    
    public var totalJob:[FindJob] = []
    public var jobType: String = ""
    public var countryText: String = ""
    public var searchCountry: String = ""
    public var searchSkills: [String] = []
    
    var donotRefresh: Bool = false
    
    // refactor
    public var stateText:String = ""
    public var cityText:String = ""
    
    public let cellId: String = "FindJobCell";
    
    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.transitionType = TransitionType.coverHorizontalFromRight
        presenter.dismissOnSwipe = true
        return presenter
    }()

    lazy var popupViewController: SearchFiltersViewController = {
        let popupViewController = UIStoryboard(name:"FindJob",bundle:nil).instantiateViewController(withIdentifier: "SearchFiltersViewController")
               return popupViewController as! SearchFiltersViewController
    }()
    
    @IBAction func searchButtonTap(_ sender: Any) {
        presenter.presentationType = .fullScreen
        presenter.transitionType = nil
        presenter.dismissTransitionType = nil
        presenter.dismissAnimated = true
        
        popupViewController.delegate = self
        
        customPresentViewController(presenter, viewController: popupViewController, animated: true, completion: nil)
    }
    //Flat UI
    @IBOutlet weak var searchCtView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchJobs()
        
        //FlatUISetting()
    }
    
    func FlatUISetting() {
        searchCtView.backgroundColor = myBlueBgcolor

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.refreshData()
        if self.donotRefresh {
            self.donotRefresh = false
        } else {
            self.searchJobs()
        }
    }
    
    public func refreshData(){
        
        self.totalJob = self.totalJob.sorted(by: { (user1, user2) -> Bool in
            
            let date1 = self.getLatestPostDate(user: user1)
            let date2 = self.getLatestPostDate(user: user2)
            
            if date1 == date2 {
                return user1.user_id < user2.user_id
            }
            
            return date1 < date2
        })
        
        self.jobTable.reloadData();
        (AppCommon.instance.rootVc as! RootTabViewController).viewJobPostNotification();
    }
    
    public func getLatestPostDate(user: FindJob) -> Int {
        var days: Int = 0
        
        for job in user.jobs {
            let days_string = job.posted_date.components(separatedBy: " ").first
            if days_string != nil {
                let days_number = Int(days_string!)
                if days == 0 {
                    days = days_number!
                } else {
                    if days_number! < days {
                        days = days_number!
                    }
                }
            }
        }
        
        return days
    }
    
    public func setNotification(){
        self.searchJobs()
    }
    
    public func searchJobs(){
        print("search jobs ok \(self.jobType)")
        
        var params: [String: Any] = [:]
        params["country"] = self.searchCountry
        params["state"] = self.stateText //self.stateText.text!
        params["city"] = self.cityText //self.cityText.text!
        params["skills"] = self.searchSkills
        params["type"] = self.jobType
        CtrCommon.startRunProcess(viewController: self, completion: {
            Alamofire.request(Constant.JOB_SEARCH_URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                CtrCommon.stopRunProcess();
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data);
                    print(jsonData);
                    if jsonData["code"].intValue == 200{
                        let findJobDatas: [JSON] = jsonData["data"].arrayValue
                        self.totalJob = []
                        for findJobData in findJobDatas{
                            var findJob: FindJob = FindJob()
                            findJob.user_id = findJobData["user_id"].intValue
                            let jobDatas: [JSON] = findJobData["jobs"].arrayValue
                            var jobs: [Job] = []
                            var recentCount = 0;
                            for jobdata in jobDatas{
                                let job: Job = Job(jobdata.dictionaryObject!)
                                if job.posted_date.index(of: "hour") != nil || job.posted_date.index(of: "min") != nil{
                                    recentCount += 1
                                }
                                jobs.append(job)
                            }
                            findJob.jobs = jobs;
                            findJob.recentCount = recentCount
                            findJob.postedCount = findJob.jobs.count
                            self.totalJob.append(findJob)
                        }
                        if AppCommon.instance.appliedJobs.count == 0{
                            self.getAppliedJobs();
                        }
                        if AppCommon.instance.sharedJobs.count == 0{
                            self.getSharedJobs();
                        }
                        DispatchQueue.main.async {
                            self.refreshData();
                        }
                        
                    }else{
                        Toast(text: jsonData["message"].stringValue).show()
                    }
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show();
                    break;
                }
            }
        })
    }
    
    public func getAppliedJobs(){
        AppCommon.instance.appliedJobs = []
        for findjob in self.totalJob{
            for job in findjob.jobs{
                if self.isApplied(job: job){
                    AppCommon.instance.appliedJobs.append(job)
                }
            }
        }
    }
    
    public func getSharedJobs(){
        AppCommon.instance.sharedJobs = []
        for findjob in self.totalJob{
            for job in findjob.jobs{
                if self.isShared(job: job){
                    AppCommon.instance.sharedJobs.append(job)
                }
            }
        }
    }
    
    
    public func isApplied(job: Job)->Bool{
        for proposeduser in job.proposed_users{
            let myuid = AppCommon.instance.profile.user_id
            if proposeduser.profile.user_id == myuid{
                return true;
            }
        }
        return false;
    }
    
    public func isShared(job: Job)->Bool{
        for user in job.shared_users{
            if user.user_id == AppCommon.instance.profile.user_id{
                return true;
            }
        }
        return false;
    }
    
    
    public func setSkills(params: [String]){
        self.searchSkills = params
    }
    

    
    @IBAction func searchAction(_ sender: UIButton) {
        self.searchJobs()
    }
    
    internal func skillSelect(){
        self.goto(to: Constant.SKILL_VC, param: self.searchSkills)
    }
    
    @IBAction func skillSelectAction(_ sender: UIButton) {
        self.goto(to: Constant.SKILL_VC, param: self.searchSkills)
    }
    
    public func goto(to: String, param: Any!){
        DispatchQueue.main.async {
            if to == Constant.SKILL_VC{
                let toVc: SkillViewController = UIStoryboard(name:"SkillView", bundle:nil).instantiateViewController(withIdentifier: to) as! SkillViewController
                toVc.parentVc = self
                toVc.setData(params: param)
                self.present(toVc, animated: true, completion: nil)
            }else if to == Constant.USERPOSTED_VC{
                self.donotRefresh = true
                let toVc: UserPostedJobsViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: to) as! UserPostedJobsViewController
                if param != nil{
                    toVc.setData(myjob: param as! FindJob)
                }
                self.present(toVc, animated: true, completion: nil)
            }
        }
    }
}

extension FindJobViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalJob.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FindJobCell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! FindJobCell
        cell.backgroundColor = UIColor.clear
        if self.totalJob[indexPath.row].user_id != nil{
            if AppCommon.instance.getContact(id: self.totalJob[indexPath.row].user_id!) != nil{
                cell.setData(profile: AppCommon.instance.getContact(id: self.totalJob[indexPath.row].user_id!).profile, recentjobscount: self.totalJob[indexPath.row].recentCount, postedjobscount: self.totalJob[indexPath.row].postedCount)
            }
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.goto(to: Constant.USERPOSTED_VC, param: self.totalJob[indexPath.row])
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
    }
}



extension FindJobViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}
