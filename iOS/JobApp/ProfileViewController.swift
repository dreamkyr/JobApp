//
//  ProfileViewController.swift
//  JobApp
//
//  Created by JaonMicle on 28/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import SDWebImage


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var genderText: UILabel!
    @IBOutlet weak var jobText: UILabel!
    @IBOutlet weak var phoneText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var locationText: UILabel!
    @IBOutlet weak var skillCollectionView: UICollectionView!
    @IBOutlet weak var profilePhoto: ExtentionImageView!
    @IBOutlet weak var countryFlagImage: UIImageView!
    
    fileprivate var skillData: [String] = []
    fileprivate var cellId: String = "SkillCollectionCell"
    private var profile: Profile = Profile();

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }

    public func setProfile(profile: Profile){
        self.profile = profile
    }
    
    public func initView(){
        self.nameText.text = CtrCommon.convertNiltoEmpty(string: self.profile.full_name, defaultstr: "")
        self.genderText.text = CtrCommon.convertNiltoEmpty(string: self.profile.gender, defaultstr: "")
        self.jobText.text = CtrCommon.convertNiltoEmpty(string: self.profile.job_title, defaultstr: "")
        self.phoneText.text = CtrCommon.convertNiltoEmpty(string: self.profile.phone, defaultstr: "")
        self.emailText.text = CtrCommon.convertNiltoEmpty(string: self.profile.email, defaultstr: "")
        self.locationText.text = CtrCommon.convertNiltoEmpty(string: self.profile.country, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.profile.state, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.profile.city, defaultstr: "")
        self.skillData = self.profile.skills
        if self.profile.code != nil{
            self.countryFlagImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(self.profile.code!.lowercased())")
        }
        if self.profile.photo != nil{
            if let url = URL(string: self.profile.photo){
                self.profilePhoto.sd_setImage(with: url, placeholderImage: UIImage(named: "profilemain"))
            }
        }
    }
    
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func educationAction(_ sender: UIButton) {
        let toVc: CourseOrgViewController = UIStoryboard(name:"EducationExperience", bundle:nil).instantiateViewController(withIdentifier: Constant.COROUGVIEW_VC) as! CourseOrgViewController
        toVc.setProfile(profile: self.profile);
        self.present(toVc, animated: true, completion: nil)
    }
    
    @IBAction func experienceAction(_ sender: UIButton) {
        let toVc: CourseOrgViewController = UIStoryboard(name:"EducationExperience", bundle:nil).instantiateViewController(withIdentifier: Constant.COROUGVIEW_VC) as! CourseOrgViewController
        toVc.setProfile(profile: self.profile);
        self.present(toVc, animated: true, completion: nil)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.skillData.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell =  collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath);
        (cell.viewWithTag(1) as! UILabel).text = self.skillData[indexPath.row]
        return cell;
    }

}
