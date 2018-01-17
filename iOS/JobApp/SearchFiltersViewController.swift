//
//  SearchFiltersViewController.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 23/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MICountryPicker
import SearchTextField

class SearchFiltersViewController: UIViewController {
    
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var stateTextField: PlaceHolderTextField!
    @IBOutlet weak var cityTextField: PlaceHolderTextField!
    @IBOutlet weak var countryImage: UIImageView!
    
    @IBOutlet weak var freelancerjobIcon: UIImageView!
    @IBOutlet weak var fullTimeicon: UIImageView!
    @IBOutlet weak var partTimeIcon: UIImageView!
    
    @IBOutlet weak var searchSkillView: SearchTextField!
    @IBOutlet weak var skillsTableView: UITableView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var backView: UIView!
    
    public let cellId = "SelectCell"
    public var allSkills: [String] = []
    public var selectedSkills: [String] = []
    
    let varA = Variable("ok")
    
    let disposeBag = DisposeBag()
    
    var delegate: FindJobViewController?
    
    public var countryPicker: MICountryPicker = MICountryPicker()
  
    @IBAction func countryTap(_ sender: Any) {
        
        self.countryPicker.delegate = self
        //self.countryPicker.showCallingCodes = true
        self.countryPicker.setSelectedCountry(country: (self.delegate?.countryText)!)
        self.present(self.countryPicker, animated: true, completion: nil)
       
    }
    
    @IBAction func freelancerJobselectActon(_ sender: Any) {
        print("free")
        if self.delegate?.jobType == "Freelancer Job"{
            self.delegate?.jobType = ""
        }else{
            self.delegate?.jobType = "Freelancer Job"
        }
        self.setJobType()
    }
    
    @IBAction func fullTimeSelectAction(_ sender: Any) {
        if self.delegate?.jobType == "Full time"{
            self.delegate?.jobType = ""
        }else{
            self.delegate?.jobType = "Full time"
        }
        self.setJobType()
    }
    
    @IBAction func partTimeSelectAction(_ sender: Any) {
        if self.delegate?.jobType == "Part time"{
            self.delegate?.jobType = ""
        }else{
            self.delegate?.jobType = "Part time"
        }
        self.setJobType()
    }
    
    
    public func setJobType(){
        self.freelancerjobIcon.image = UIImage(named: "option")
        self.partTimeIcon.image = UIImage(named: "option")
        self.fullTimeicon.image = UIImage(named: "option")
        
        if self.delegate?.jobType != ""{
            if self.delegate?.jobType == "Freelancer Job"{
                self.freelancerjobIcon.image = UIImage(named: "option_focus")
            }else if self.delegate?.jobType == "Full time"{
                self.fullTimeicon.image = UIImage(named: "option_focus")
            }else{
                self.partTimeIcon.image = UIImage(named: "option_focus")
            }
        }
    }
    
    
     override func viewDidLoad() {
        super.viewDidLoad()
     
        //if ((self.delegate?.countryText)!) != "" {
            //self.countryLabel.text =  (self.delegate?.countryText)!
       // }
        
      //_ = varA
        //    .asObservable()
          //  .bind(to: self.countryLabel.rx.text )
            //.addDisposableTo(disposeBag)
        
        self.stateTextField.rx.text
            .throttle(0.1, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                print($0!)
             self.delegate?.stateText = $0!
            })
            .addDisposableTo(disposeBag)
        
        self.cityTextField.rx.text
            .throttle(0.1, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                print($0!)
                self.delegate?.cityText = $0!
            })
            .addDisposableTo(disposeBag)
        
        self.searchSkillView.filterStrings(Skills.skills)
        self.searchSkillView.theme.font = UIFont.systemFont(ofSize: 14)
        self.searchSkillView.theme.bgColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        self.searchSkillView.theme.borderColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        self.searchSkillView.theme.separatorColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        self.searchSkillView.theme.cellHeight = 40
        
        //self.delegate?.stateText
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBack(_:)))
        self.backView.addGestureRecognizer(tap)
    }
    
    @IBAction func skillButton(_ sender: Any) {
        
       // self.delegate?.skillSelect()
        
//        let toVc: SkillViewController = UIStoryboard(name:"SkillView", bundle:nil).instantiateViewController(withIdentifier: "SkillViewController") as! SkillViewController
//        toVc.parentVc = self
//        toVc.setData(params: self.searchSkills)
//        self.present(toVc, animated: true, completion: nil)
        
        let skill = self.searchSkillView.text?.trim()
        if !self.isExistSkill(skill: skill!) {
            self.allSkills.append(skill!)
            self.addSelectedSkill(skill: skill!)
            self.skillsTableView.reloadData()
        }
        
        self.searchSkillView.text = ""
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil )
        
    }

    
    @IBAction func search(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.searchSkills = self.selectedSkills
            self.delegate?.searchJobs()
        })
    }
    
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        UIView.animate(withDuration: 0.3, animations: {
            let mainViewHeight = self.mainView.frame.size.height
            self.mainView.frame = CGRect(x: self.mainView.frame.origin.x,
                                         y: (self.view.frame.size.height - keyboardFrame.size.height - mainViewHeight),
                                         width: self.mainView.frame.size.width,
                                         height: mainViewHeight)
        }) { (success) in
            
        }
    }
    
    func keyboardWillHide(notification:NSNotification){
        UIView.animate(withDuration: 0.3, animations: {
            let mainViewHeight = self.mainView.frame.size.height
            self.mainView.frame = CGRect(x: self.mainView.frame.origin.x,
                                         y: (self.view.frame.size.height - mainViewHeight),
                                         width: self.mainView.frame.size.width,
                                         height: mainViewHeight)
        }) { (success) in
            
        }
    }
    
    func tapBack(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil )
    }
    
    public func isExistSkill(skill:String)->Bool{
        for tempSkill in self.allSkills {
            if tempSkill == skill{
                return true
            }
        }
        return false
    }
    
    public func isSelectedSkill(skill: String)->Bool{
        for skilldata in self.selectedSkills{
            if skilldata == skill{
                return true
            }
        }
        return false
    }
    
    public func addSelectedSkill(skill:String)->Bool{
        for i in 0 ..< self.selectedSkills.count{
            if self.selectedSkills[i] == skill{
                self.selectedSkills.remove(at: i)
                return false
            }
        }
        self.selectedSkills.append(skill)
        return true
    }
    
}

extension SearchFiltersViewController: MICountryPickerDelegate{
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String) {
        if name != "Back"{
            if name != ""{
                self.delegate?.countryText = name;
                self.countryLabel.text = name
                self.countryImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(code.lowercased())")
                self.delegate?.searchCountry = "\(name)(\(code))";
            }else{
                self.delegate?.countryText = name;
                self.countryLabel.text = name
                self.countryImage.image = nil
                self.delegate?.searchCountry = "";
            }
        }
        self.countryPicker.dismiss(animated: true, completion:nil)
    }
    
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        print(dialCode)
    }
}

extension SearchFiltersViewController: UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allSkills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SelectCell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! SelectCell
        cell.selTitle.text = self.allSkills[indexPath.row]
        if self.isSelectedSkill(skill: cell.selTitle.text!){
            cell.selImg.image = UIImage(named: "option_focus")
        }else{
            cell.selImg.image = UIImage(named: "option")
        }
        cell.backgroundColor = UIColor.clear
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell: SelectCell = tableView.cellForRow(at: indexPath) as! SelectCell
        if self.addSelectedSkill(skill: cell.selTitle.text!){
            cell.selImg.image = UIImage(named: "option_focus")
        }else{
            cell.selImg.image = UIImage(named: "option")
        }
        return indexPath
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

