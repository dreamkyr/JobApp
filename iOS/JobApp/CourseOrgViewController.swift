//
//  CourseOrgViewController.swift
//  JobApp
//
//  Created by JaonMicle on 28/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class CourseOrgViewController: UIViewController {

    fileprivate var profile:Profile = Profile()
    fileprivate var cellId: String = "CourseOrgViewCell"
    fileprivate var sectionName: [String] = ["Course", "Organization"]
    
    @IBOutlet weak var courseOrgTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    public func setProfile(profile: Profile){
        self.profile = profile
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension CourseOrgViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.profile.courses.count
        }else{
            return self.profile.orgnizations.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: UIView = UIView();
        sectionView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        let contentRect: CGRect = CGRect(x:10, y:0, width: 150, height: 50);
        let headerLabel: UILabel = UILabel(frame: contentRect);
        headerLabel.text = self.sectionName[section];
        headerLabel.textColor = UIColor.white;
        sectionView.addSubview(headerLabel);
        return sectionView;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseOrgViewCell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! CourseOrgViewCell
        if indexPath.section == 0{
            cell.couorgNameText.text = CtrCommon.convertNiltoEmpty(string: self.profile.courses[indexPath.row].name, defaultstr: "")
            cell.majorText.text = CtrCommon.convertNiltoEmpty(string: self.profile.courses[indexPath.row].major, defaultstr: "")
            cell.dateText.text = CtrCommon.convertNiltoEmpty(string: self.profile.courses[indexPath.row].start, defaultstr: "") + " - " + CtrCommon.convertNiltoEmpty(string: self.profile.courses[indexPath.row].end, defaultstr: "")
        }else{
            cell.couorgNameText.text = CtrCommon.convertNiltoEmpty(string: self.profile.orgnizations[indexPath.row].name, defaultstr: "")
            cell.majorText.text = CtrCommon.convertNiltoEmpty(string: self.profile.orgnizations[indexPath.row].major, defaultstr: "")
            cell.dateText.text = CtrCommon.convertNiltoEmpty(string: self.profile.orgnizations[indexPath.row].start, defaultstr: "") + " - " + CtrCommon.convertNiltoEmpty(string: self.profile.orgnizations[indexPath.row].end, defaultstr: "")
        }
        return cell;
    }
}
