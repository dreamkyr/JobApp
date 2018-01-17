//
//  CourseOrgViewController.swift
//  JobApp
//
//  Created by JaonMicle on 03/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class CourseOrgSettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    private let cellId: [String] = ["CourseOrgCell", "AddCourseCell"]
    @IBOutlet weak var courseOrgSettingTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FlatUISetting()
    }
    
    func FlatUISetting() {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.courseOrgSettingTable.reloadData();
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: UIView = UIView();
        sectionView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        let contentRect: CGRect = CGRect(x:0, y:0, width: UIScreen.main.applicationFrame.size.width, height: 40);
        let headerLabel: UILabel = UILabel(frame: contentRect);
        headerLabel.backgroundColor = myGreyBgColor
        headerLabel.textAlignment = .center
        if section == 0{
            headerLabel.text = "Course";
        }else{
            headerLabel.text = "Organization";
        }
        headerLabel.textColor = UIColor.black;
        sectionView.addSubview(headerLabel);
        return sectionView;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return AppCommon.instance.profile.courses.count + 1;
        }else{
            return AppCommon.instance.profile.orgnizations.count + 1;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            if indexPath.row == AppCommon.instance.profile.courses.count{
                let cell: AddCourseCell = tableView.dequeueReusableCell(withIdentifier: self.cellId[1], for: indexPath) as! AddCourseCell
                cell.labelname.text = "Add Education"
                cell.accessoryType = .detailButton
                return cell
            }else{
                let cell:CourseOrgCell = tableView.dequeueReusableCell(withIdentifier: self.cellId[0], for: indexPath) as! CourseOrgCell
                cell.courseTitleLabel.text = AppCommon.instance.profile.courses[indexPath.row].name
                cell.dateLabel.text = AppCommon.instance.profile.courses[indexPath.row].start + " - " + AppCommon.instance.profile.courses[indexPath.row].end
                cell.indexnum = [indexPath.section, indexPath.row]
                cell.removeCallBack = self.removeCourseOrg
                cell.accessoryType = .detailButton
                return cell;
            }
        }else{
            if indexPath.row == AppCommon.instance.profile.orgnizations.count{
                let cell: AddCourseCell = tableView.dequeueReusableCell(withIdentifier: self.cellId[1], for: indexPath) as! AddCourseCell
                cell.labelname.text = "Add Experience"
                cell.accessoryType = .detailButton
                return cell
            }else{
                let cell:CourseOrgCell = tableView.dequeueReusableCell(withIdentifier: self.cellId[0], for: indexPath) as! CourseOrgCell
                cell.courseTitleLabel.text = AppCommon.instance.profile.orgnizations[indexPath.row].name
                cell.dateLabel.text = AppCommon.instance.profile.orgnizations[indexPath.row].start + " - " + AppCommon.instance.profile.orgnizations[indexPath.row].end
                cell.indexnum = [indexPath.section, indexPath.row]
                cell.removeCallBack = self.removeCourseOrg
                cell.accessoryType = .detailButton
                return cell;
            }
        }
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var param: [String:Any?] = [:]
        if indexPath.section == 0{
            param["flag"] = true;
            if indexPath.row == AppCommon.instance.profile.courses.count{
                param["data"] = nil
            }else{
                param["data"] = AppCommon.instance.profile.courses[indexPath.row]
                param["index"] = indexPath.row
            }
        }else{
            param["flag"] = false;
            if indexPath.row == AppCommon.instance.profile.orgnizations.count{
                param["data"] = nil
            }else{
                param["data"] = AppCommon.instance.profile.orgnizations[indexPath.row]
                param["index"] = indexPath.row
            }
        }
        DispatchQueue.main.async {
            self.goto(to: Constant.CORORGDETAIL_VC, params: param)
            
        }
        return indexPath

    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.goto(to: "Back", params: nil)
    }
    
    private func removeCourseOrg(_ index: [Int])->Void{
        if index[0] == 0{
            AppCommon.instance.profile.courses.remove(at: index[1])
        }else{
            AppCommon.instance.profile.orgnizations.remove(at: index[1])
        }
        self.courseOrgSettingTable.reloadData();
    }
    
    private func goto(to: String, params: Any!){
        if to == "Back"{
            self.dismiss(animated: false, completion: nil);
        }else if to == Constant.CORORGDETAIL_VC{
            let toVc: CourseOrgDetailViewController = UIStoryboard(name:"CourseOrgDetail", bundle:nil).instantiateViewController(withIdentifier: Constant.CORORGDETAIL_VC) as! CourseOrgDetailViewController;
            
            toVc.setData(data: params as! [String : Any?])
            self.present(toVc, animated: true, completion: nil);
        }
        
    }
}
