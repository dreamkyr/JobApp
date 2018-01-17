//
//  ReferedJobsViewController.swift
//  JobApp
//
//  Created by Admin on 5/22/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import DateTimePicker
import Alamofire
import Toaster
import SwiftyJSON

class ReferedJobsViewController: UIViewController{

    public let cellId: String = "ReferedJobCell"
    @IBOutlet weak var referedJobsTable: UITableView!
    @IBOutlet weak var posteJobsSignView: UIView!
    @IBOutlet weak var sharedJobsSignView: UIView!
    @IBOutlet weak var appliedJobsSignView: UIView!
    @IBOutlet weak var postedJobsBtn: UIButton!
    @IBOutlet weak var sharedJobsBtn: UIButton!
    @IBOutlet weak var appliedJobsBtn: UIButton!
    
    public var currentJobs: [Job] = []
    public var currentJobsName: String = "ReferedJob"
    
    public var referedJobs: [Job] = []
    public var sharedJobs: [Job] = []
    public var appliedJobs: [Job] = []
    
    var cellHeights = [CGFloat]()
    
    //Flat UI
    @IBOutlet weak var titlebarCtView: UIView!
    @IBOutlet weak var referbtnCtView: UIView!
    @IBOutlet weak var threeTabView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        threeTabView.addBorder(side: .bottom, thickness: 1, color: UIColor.black)
        threeTabView.addBorder(side: .top, thickness: 1, color: UIColor.black)
        
        self.setJobsSign(selected: currentJobsName)
   
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadJobsData();
    }
    
    public func initJobData(){
        self.referedJobs = []
        self.sharedJobs = []
        for job in AppCommon.instance.refferedJobs{
            if job.referrer.user_id == AppCommon.instance.profile.user_id{
                self.referedJobs.append(job)
            }else{
                self.sharedJobs.append(job)
            }
        }
        AppCommon.instance.sharedJobs = self.sharedJobs
        if self.currentJobsName == "ReferedJob"{
            self.currentJobs = self.referedJobs
        }else if self.currentJobsName == "SharedJob"{
            self.currentJobs = self.sharedJobs
        }else{
            self.currentJobs = self.appliedJobs
        }
    }
    
    private func setJobsSign(selected: String){
        self.postedJobsBtn.setTitleColor(UIColor(white: 155.0 / 255.0, alpha: 1.0), for: .normal)
        self.sharedJobsBtn.setTitleColor(UIColor(white: 155.0 / 255.0, alpha: 1.0), for: .normal)
        self.appliedJobsBtn.setTitleColor(UIColor(white: 155.0 / 255.0, alpha: 1.0), for: .normal)

        if selected == "ReferedJob"{
            self.postedJobsBtn.setTitleColor(myBlueBgcolor, for: .normal)

        }else if selected == "SharedJob"{
            self.sharedJobsBtn.setTitleColor(myBlueBgcolor, for: .normal)
 
        }else{
            self.appliedJobsBtn.setTitleColor(myBlueBgcolor, for: .normal)

        }
    }
    
    @IBAction func posteJobsAction(_ sender: UIButton) {
        self.setJobsSign(selected: "ReferedJob")
        self.currentJobsName = "ReferedJob"
        self.currentJobs = self.referedJobs
        self.referedJobsTable.reloadData()
    }
    
    @IBAction func sharedJobsAction(_ sender: UIButton) {
        self.setJobsSign(selected: "SharedJob")
        self.currentJobsName = "SharedJob"
        self.currentJobs = self.sharedJobs
        self.referedJobsTable.reloadData()
    }
    
    @IBAction func appliedJobs(_ sender: UIButton) {
        self.setJobsSign(selected: "AppliedJob")
        self.currentJobsName = "AppliedJob"
        self.currentJobs = self.appliedJobs
        self.referedJobsTable.reloadData()
    }
    
    @IBAction func addJobAction(_ sender: UIButton) {
        if !AppCommon.instance.profile.isCompleted() {
            (AppCommon.instance.rootVc as! RootTabViewController).showTopNotification(msg: "Complete profile to add a new job.")
            return;
        }
        
        let toVc: AddJobViewController = UIStoryboard(name:"AddJob", bundle: nil).instantiateViewController(withIdentifier: Constant.ADDJOB_VC) as! AddJobViewController;
        self.present(toVc, animated: true, completion: nil)
    }
    
    func loadJobsData(){
        CtrCommon.startRunProcess(viewController: self, completion: {
            Alamofire.request(Constant.JOB_MY_POSTED, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).validate().responseJSON { (response) in
                Alamofire.request(Constant.JOB_PROPOSED_URL, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).validate().responseJSON(completionHandler: { (response) in
                    CtrCommon.stopRunProcess()
                    switch response.result{
                    case .success(let data):
                        let jsonData = JSON(data);
                        if jsonData["code"].intValue == 200{
                            let jobDatas:[JSON] = jsonData["data"].arrayValue
                            self.appliedJobs = [];
                            for jobData in jobDatas{
                                self.appliedJobs.append(Job(jobData.dictionaryObject!))
                            }
                            AppCommon.instance.appliedJobs = self.appliedJobs;
                            DispatchQueue.main.async {
                                self.referedJobsTable.reloadData()
                            }
                        }else{
                            Toast(text: jsonData["message"].stringValue).show()
                        }
                        break;
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show()
                        break;
                    }
                })
                
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data)
                    if jsonData["code"].intValue == 200{
                        let jobDatas:[JSON] = jsonData["data"].arrayValue
                        AppCommon.instance.refferedJobs = [];
                        for jobData in jobDatas{
                            AppCommon.instance.refferedJobs.append(Job(jobData.dictionaryObject!))
                        }
                        self.initJobData()
                        DispatchQueue.main.async {
                            self.referedJobsTable.reloadData()
                        }
                    }else{
                        Toast(text: jsonData["message"].stringValue).show()
                    }
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    break;
                }
            }
        })
        
    }
    
   

}

extension ReferedJobsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentJobs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let job = self.currentJobs[indexPath.row]
        if job.referrer.user_id == AppCommon.instance.profile.user_id{
            let applyCount:Int = job.proposed_users.count
            let jobIdString = String.init(job.id)
            UserDefaults.standard.setValue("\(applyCount)", forKey: jobIdString)
            UserDefaults.standard.synchronize()
        }
        
        let toVc: AddJobViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: Constant.ADDJOB_VC) as! AddJobViewController;
        toVc.setData(job: job, type: self.currentJobsName)
        self.present(toVc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! ReferedJobCell
        cell.backgroundColor = UIColor.clear
        cell.setJob(job: self.currentJobs[indexPath.row])
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
