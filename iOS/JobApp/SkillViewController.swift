//
//  SkillViewController.swift
//  JobApp
//
//  Created by JaonMicle on 16/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import SearchTextField

class SkillViewController: UIViewController {
    
    var parentVc: UIViewController! = nil;
    
    let cellId = "SelectCell"
    
    @IBOutlet weak var searchText: SearchTextField!
    @IBOutlet weak var skillTable: UITableView!
    
    var allSkills: [String] = []
    var selectedSkills: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchText.filterStrings(Skills.skills)
        self.searchText.theme.font = UIFont.systemFont(ofSize: 14)
        self.searchText.theme.bgColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        self.searchText.theme.borderColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        self.searchText.theme.separatorColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        self.searchText.theme.cellHeight = 40
    }
    
    
    @IBAction func skillAddAction(_ sender: UIButton) {
        let skill = self.searchText.text?.trim()
        if !self.isExistSkill(skill: skill!) {
            self.allSkills.append(skill!)
            self.addSelectedSkill(skill: skill!)
            self.skillTable.reloadData()
        }
        
        self.searchText.text = ""
    }
    
    
    func isExistSkill(skill:String)->Bool{
        for tempSkill in self.allSkills {
            if tempSkill == skill{
                return true
            }
        }
        return false
    }
    
    func isSelectedSkill(skill: String)->Bool{
        for skilldata in self.selectedSkills{
            if skilldata == skill{
                return true
            }
        }
        return false
    }
    
    func addSelectedSkill(skill:String) -> Bool {
        for i in 0 ..< self.selectedSkills.count{
            if self.selectedSkills[i] == skill{
                self.selectedSkills.remove(at: i)
                return false
            }
        }
        self.selectedSkills.append(skill)
        return true
    }
    
    @IBAction func saveSkillAction(_ sender: UIButton) {
        if self.parentVc != nil{
            if let toVc = self.parentVc as? AddJobViewController{
                toVc.setSkills(params: self.selectedSkills)
                self.dismiss(animated: true, completion: nil)
            }
            if let toVc = self.parentVc as? ProfileSettingViewController{
                toVc.setSkills(params: self.selectedSkills)
                self.dismiss(animated: true, completion: nil)
            }
            if let toVc = self.parentVc as? FindJobViewController{
                toVc.setSkills(params: self.selectedSkills)
                self.dismiss(animated: true, completion: nil);
            }
            
            
            if let toVc = self.parentVc as? SearchFiltersViewController{
                toVc.delegate?.setSkills(params: self.selectedSkills)
                self.dismiss(animated: true, completion: nil);
            }
        }
    }
    
    @IBAction func cancellAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func setData(params: Any!){
        if params != nil{
            self.allSkills = params as! [String]
            self.selectedSkills = params as! [String]
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SkillViewController: UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allSkills.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SelectCell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! SelectCell
        let skill = self.allSkills[indexPath.row]
        cell.selTitle.text = skill
        if self.isSelectedSkill(skill: skill){
            cell.selImg.image = UIImage(named: "option_focus")
        }else{
            cell.selImg.image = UIImage(named: "option")
        }
        
        cell.backgroundColor = UIColor.clear
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: SelectCell = tableView.cellForRow(at: indexPath) as! SelectCell
        if self.addSelectedSkill(skill: cell.selTitle.text!) {
            cell.selImg.image = UIImage(named: "option_focus")
        }else{
            cell.selImg.image = UIImage(named: "option")
        }
    }
}
