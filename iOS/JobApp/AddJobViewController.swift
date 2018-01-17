//
//  AddJobViewController.swift
//  JobApp
//
//  Created by JaonMicle on 16/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import MICountryPicker
import Alamofire
import SwiftyJSON
import Toaster
import NotificationCenter

class AddJobViewController: UIViewController {
    private var job: Job = Job();
    private var type: String = "ReferedJob"
    public var countryPicker = MICountryPicker()
    public var location = ""
    public var inviteUsers: [Int] = []
    public var hiddenUsers: [Int] = []
    private var jobType: String = "Freelancer Job";
    private var userSelectItem:String = "Invite"
    
    let defaultJobDetail = "Details of Job"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var employerNameText: PlaceHolderTextField!
    @IBOutlet weak var locationFlagImage: UIImageView!
    
    @IBOutlet weak var projectTitleText: PlaceHolderTextField!
    @IBOutlet weak var countryText: PlaceHolderTextField!
    @IBOutlet weak var stateText: PlaceHolderTextField!
    @IBOutlet weak var cityText: PlaceHolderTextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var skillsText: PlaceHolderTextField!
    @IBOutlet weak var freelacerJobIcon: UIImageView!
    @IBOutlet weak var fullTimeIcon: UIImageView!
    @IBOutlet weak var salaryText: PlaceHolderTextField!
    @IBOutlet weak var partTimeIcon: UIImageView!
    @IBOutlet weak var hrEmailorPhoneText: PlaceHolderTextField!
    @IBOutlet weak var proposedUserBtn: UIButton!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var inviteUsersText: PlaceHolderTextField!
    @IBOutlet weak var hiddenUsersText: PlaceHolderTextField!
    @IBOutlet weak var shareorapplyBtnView: EffectView!
    @IBOutlet weak var shareorapplyBtn: UIButton!
    
    @IBOutlet weak var theScrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initVc();
        self.setDismissKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.theScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.theScrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.theScrollView.contentInset = contentInset
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.job.id == nil {
            self.titleLabel.text = "Post New Job"
        }
    }
    
    private func initVc(){
        self.employerNameText.text = CtrCommon.convertNiltoEmpty(string: self.job.employer_name, defaultstr: "")
        self.projectTitleText.text = CtrCommon.convertNiltoEmpty(string: self.job.title, defaultstr: "")
        self.countryText.text = CtrCommon.convertNiltoEmpty(string: self.job.country, defaultstr: "")
        self.stateText.text = CtrCommon.convertNiltoEmpty(string: self.job.state, defaultstr: "")
        self.cityText.text = CtrCommon.convertNiltoEmpty(string: self.job.city, defaultstr: "")
        if self.job.description == nil{
            self.contentTextView.text = defaultJobDetail
            self.contentTextView.textColor = UIColor.init(white: 155.0 / 255.0, alpha: 1.0)
        } else {
            if self.job.description.characters.count == 0 {
                self.contentTextView.text = defaultJobDetail
            } else {
                self.contentTextView.text = CtrCommon.convertNiltoEmpty(string: self.job.description, defaultstr: defaultJobDetail)
            }
            self.contentTextView.textColor = UIColor.black
        }
        self.selectJobType(type: CtrCommon.convertNiltoEmpty(string: self.job.type, defaultstr: ""))
        self.salaryText.text = CtrCommon.convertNiltoEmpty(string: self.job.salary, defaultstr: "")
        self.hrEmailorPhoneText.text = CtrCommon.convertNiltoEmpty(string: self.job.hremailorphone, defaultstr: "")
        self.proposedUserBtn.setTitle("View Proposed Users (\(self.job.proposed_users.count))", for: .normal)
        var skillstr: String = "";
        for skill in self.job.skills{
            skillstr += "," + skill
        }
        if skillstr != ""{
            self.skillsText.text = skillstr.substring(from: 1);
        }
        if self.job.country != nil{
            if self.job.country != ""{
//                self.locationFlagImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(job.country!.components(separatedBy: "(")[1].components(separatedBy: ")")[0].lowercased())")
            }
        }
        
        if self.type == "SharedJob" || self.type == "AppliedJob"{
            self.employerNameText.isUserInteractionEnabled = false;
            self.projectTitleText.isUserInteractionEnabled = false;
            self.countryText.isUserInteractionEnabled = false;
            self.stateText.isUserInteractionEnabled = false;
            self.cityText.isUserInteractionEnabled = false;
            self.contentTextView.isUserInteractionEnabled = false;
            self.salaryText.isUserInteractionEnabled = false;
            self.hrEmailorPhoneText.isUserInteractionEnabled = false;
            self.skillsText.isUserInteractionEnabled = false;
            self.inviteUsersText.text = ""
            self.shareorapplyBtnView.isHidden = false
            if self.type == "SharedJob"{
                self.shareorapplyBtn.setTitle("Unshare a job", for: .normal)
                self.theScrollView.contentSize = CGSize(width: self.theScrollView.frame.size.width, height: 900)
            }else{
                self.shareorapplyBtn.isHidden = true
                self.shareorapplyBtn.setTitle("Unapply a job", for: .normal)
                self.theScrollView.contentSize = CGSize(width: self.theScrollView.frame.size.width, height: 820)
            }
        }else{
            self.userSelectItem = "Invite"
            self.setUsers(params: job.invited_users)
            self.userSelectItem = "Hidden"
            self.setUsers(params: job.hidden_users)
            
            self.theScrollView.contentSize = CGSize(width: self.theScrollView.frame.size.width, height: 900)
        }
    }
    
    public func selectJobType(type: String){
        self.freelacerJobIcon.image = UIImage(named: "option")
        self.fullTimeIcon.image = UIImage(named: "option")
        self.partTimeIcon.image = UIImage(named: "option")
        if type == "Freelancer Job"{
            self.freelacerJobIcon.image = UIImage(named: "option_focus");
        }else if type == "Full time"{
            self.fullTimeIcon.image = UIImage(named: "option_focus");
        }else{
            self.partTimeIcon.image = UIImage(named: "option_focus");
        }
    }
    
    @IBAction func skillSelectAction(_ sender: UIButton) {
        if self.type != "ReferedJob"{
            Toast(text: "You can't modify job.").show();
            return;
        }
        self.goto(to: Constant.SKILL_VC, params: self.job.skills)
    }
    
    @IBAction func locationSelectAction(_ sender: UIButton) {
        if self.type != "ReferedJob"{
            Toast(text: "You can't modify job.").show();
            return;
        }
        self.countryPicker.delegate = self
        //self.countryPicker.showCallingCodes = true
        self.countryPicker.setSelectedCountry(country: self.countryText.text!)
        self.present(self.countryPicker, animated: true, completion: nil)
        //there?
        
    }
    
    @IBAction func selectInviteUserfAction(_ sender: UIButton) {
        if self.type != "ReferedJob"{
            Toast(text: "You can't modify job.").show();
            return;
        }
        self.userSelectItem = "Invite"
        self.goto(to: Constant.SELECTCONTACTS_VC, params: nil)
    }
    
    @IBAction func selectHiddenUserAction(_ sender: UIButton) {
        if self.type != "ReferedJob"{
            Toast(text: "You can't modify job.").show();
            return;
        }
        self.userSelectItem = "Hidden"
        self.goto(to: Constant.SELECTCONTACTS_VC, params: nil)
    }
    
    
    @IBAction func postJob(_ sender: Any) {
        if self.type != "ReferedJob"{
            Toast(text: "You can't modify job.").show();
            return;
        }
        var params:[String: Any] = [:]
        params["referrer"] = AppCommon.instance.profile.user_id
        if self.employerNameText.text == ""{
            Toast(text: "Please enter Employer name.").show()
            return
        }
        if self.projectTitleText.text == ""{
            Toast(text: "Please enter Project title.").show()
            return
        }
        if self.job.skills.count == 0{
            Toast(text: "Please enter Skills required").show()
            return
        }
        if self.countryText.text == ""{
            Toast(text: "Please enter country.").show()
            return
        }
        if self.salaryText.text == ""{
            Toast(text: "Please enter Salary.").show()
            return
        }
        
        if self.contentTextView.text.trim() == defaultJobDetail {
            Toast(text: "Please enter Details of job.").show()
            return
        }
        
        if self.hrEmailorPhoneText.text == ""{
            Toast(text: "Please enter Email of HR").show()
            return
        }
        params["employer_name"] = self.employerNameText.text!
        params["title"] = self.projectTitleText.text!
        params["skills"] = self.job.skills
        params["description"] = self.contentTextView.text!
        params["country"] = self.countryText.text
        params["state"] = self.stateText.text
        params["city"] = self.cityText.text
        params["salary"] = self.salaryText.text!
        params["type"] = self.jobType
        params["hrphone_email"] = self.hrEmailorPhoneText.text!
        params["invited_users"] = self.inviteUsers
        params["hidden_users"] = self.hiddenUsers
        params["_id"] = self.job.id
        CtrCommon.startRunProcess(viewController: self, completion: {
            Alamofire.request(Constant.ADD_JOB_URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).validate().responseJSON { (response) in
                CtrCommon.stopRunProcess();
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data)
                    Toast(text: jsonData["message"].stringValue).show()
                    if jsonData["code"].intValue == 200{
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    break;
                }
            }
        })
    }

    @IBAction func deleteJobAction(_ sender: UIButton) {
        if self.job.id == nil{
            return;
        }
        if self.type == "ReferedJob"{
            let params: [String:Any] = ["job_id": self.job.id]
            CtrCommon.startRunProcess(viewController: self, completion: {
                Alamofire.request(Constant.JOB_REMOVE_URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                    CtrCommon.stopRunProcess();
                    switch response.result{
                    case .success(let data):
                        Toast(text: JSON(data)["message"].stringValue).show();
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                        break;
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show();
                        break;
                    }
                }
            })
        }
    }
    
    @IBAction func unShareApplyAction(_ sender: UIButton) {
        if self.job.id == nil{
            return;
        }
        if self.type == "SharedJob"{
            let params: [String:Any] = ["job_id": self.job.id]
            CtrCommon.startRunProcess(viewController: self, completion: {
                Alamofire.request(Constant.JOB_REMOVESHARE_URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                    CtrCommon.stopRunProcess();
                    switch response.result{
                    case .success(let data):
                        let jsonData = JSON(data)
                        if jsonData["code"].intValue == 200{
                            AppCommon.instance.removeSharedJob(job: self.job)
                        }
                        Toast(text: jsonData["message"].stringValue).show();
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                        break;
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show();
                        break;
                    }
                }
            })
        }
        if self.type == "AppliedJob"{
            let params: [String:Any] = ["job_id": self.job.id]
            CtrCommon.startRunProcess(viewController: self, completion: {
                Alamofire.request(Constant.JOB_REMOVEAPPLY_URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                    CtrCommon.stopRunProcess();
                    switch response.result{
                    case .success(let data):
                        let jsonData = JSON(data)
                        if jsonData["code"].intValue == 200{
                            AppCommon.instance.removeAppliedJob(job: self.job)
                        }
                        Toast(text: JSON(data)["message"].stringValue).show();
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                        break;
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show();
                        break;
                    }
                }
            })
        }
    }
    
    
    @IBAction func viewProposedUser(_ sender: UIButton) {
        if self.type != "ReferedJob"{
            Toast(text: "You can't modify job.").show();
            return;
        }
        if self.job.proposed_users.count == 0{
            Toast(text: "Proposed users don't exist.").show()
            return;
        }
        self.goto(to: Constant.PROPOSEUSERS_VC, params: self.job)
    }
    
    @IBAction func frelancerJobSelectAction(_ sender: UIButton) {
        if self.type != "ReferedJob"{
            Toast(text: "You can't modify job.").show();
            return;
        }
        self.jobType = "Freelancer Job"
        self.selectJobType(type: self.jobType)
    }
    
    @IBAction func fulTimeSelectAction(_ sender: UIButton) {
        
        if self.type != "ReferedJob"{
            Toast(text: "You can't modify job.").show();
            return;
        }
        self.jobType = "Full time"
        self.selectJobType(type: self.jobType)
    }
    
    @IBAction func pareTimeSelectAction(_ sender: UIButton) {
        
        if self.type != "ReferedJob"{
            Toast(text: "You can't modify job.").show();
            return;
        }
        self.jobType = "Part time"
        self.selectJobType(type: self.jobType)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil);
    }
    
    public func setData(job: Job, type: String){
        self.job = job
        self.type = type
    }
    
    public func setSkills(params: [String]){
        self.job.skills = params;
        var skillstr: String = "";
        for skill in self.job.skills{
            skillstr += "," + skill
        }
        if skillstr != ""{
            self.skillsText.text = skillstr.substring(from: 1);
        }
    }
    
    public func setUsers(params: [Int]){
        if self.userSelectItem == "Invite"{
            self.inviteUsers = params;
            var inviteUsersStr = ""
            for userid in self.inviteUsers{
                inviteUsersStr += "," + AppCommon.instance.getContact(id: userid).profile.full_name
            }
            if inviteUsersStr != ""{
                self.inviteUsersText.text = inviteUsersStr.substring(from: 1)
            } else {
                self.inviteUsersText.text = ""
            }
        }else{
            self.hiddenUsers = params;
            var hiddenUsersStr = ""
            for userid in self.hiddenUsers{
                hiddenUsersStr += "," + AppCommon.instance.getContact(id: userid).profile.full_name
            }
            if hiddenUsersStr != ""{
                self.hiddenUsersText.text = hiddenUsersStr.substring(from: 1)
            } else {
                self.hiddenUsersText.text = ""
            }
        }
    }
    
    private func goto(to: String, params: Any!){
        if to == Constant.SKILL_VC{
            let toVc: SkillViewController = UIStoryboard(name:"SkillView", bundle:nil).instantiateViewController(withIdentifier: to) as! SkillViewController
            toVc.parentVc = self;
            toVc.setData(params: params)
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.PROPOSEUSERS_VC{
            let toVc: ProposedUserController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: to) as! ProposedUserController
            toVc.setData(param: params)
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.SELECTCONTACTS_VC{
            let toVc: SelecteContactsViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: to) as! SelecteContactsViewController
            if self.userSelectItem == "Invite"{
                toVc.setData(params: self.inviteUsers)
            }else{
                toVc.setData(params: self.hiddenUsers)
            }
            toVc.parentVc = self
            self.present(toVc, animated: true, completion: nil);
        }
    }
}

extension AddJobViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
//        self.scrollview.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        return true;
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField == self.hrEmailorPhoneText || textField == self.inviteUsersText{
//            self.scrollview.setContentOffset(CGPoint(x: 0, y: 550), animated: true);
//        }
        return true;
    }
    
    
}

extension AddJobViewController: UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == defaultJobDetail {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        
        return true
    }
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        if textView.text.trim() == "" {
            textView.text = defaultJobDetail
            textView.textColor = UIColor.init(white: 155.0 / 255.0, alpha: 1.0)
        }
        
        return true
    }
}

extension AddJobViewController: MICountryPickerDelegate{
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String) {
        if name != "Back"{
            if name != ""{
                self.location = "\(name)(\(code))"
                self.countryText.text = self.location
                self.locationFlagImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(code.lowercased())")
            }else{
                self.location = ""
                self.countryText.text = self.location
                self.locationFlagImage.image = nil
            }
        }
        self.countryPicker.dismiss(animated: true, completion: nil)
    }
    
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        print(dialCode)
    }
}

