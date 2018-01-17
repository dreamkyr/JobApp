//
//  ProfileSettingViewController.swift
//  JobApp
//
//  Created by Admin on 5/23/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView
import Kingfisher
import Alamofire
import Toaster
import ALCameraViewController
import MICountryPicker
import NotificationCenter

class ProfileSettingViewController: UIViewController{
    
    @IBOutlet weak var profilePhoto: ExtentionImageView!
    @IBOutlet weak var firstName: PlaceHolderTextField!
    @IBOutlet weak var lastName: PlaceHolderTextField!
    @IBOutlet weak var phoneNumber: PlaceHolderTextField!
    @IBOutlet weak var email: PlaceHolderTextField!
    @IBOutlet weak var country: PlaceHolderTextField!
    @IBOutlet weak var state: PlaceHolderTextField!
    @IBOutlet weak var city: PlaceHolderTextField!
    @IBOutlet weak var language: PlaceHolderTextField!
    @IBOutlet weak var job: PlaceHolderTextField!
    @IBOutlet weak var share: UISwitch!
    @IBOutlet weak var skillCollectionView: UICollectionView!
    @IBOutlet weak var maleImage: UIImageView!
    @IBOutlet weak var famaleImage: UIImageView!
    @IBOutlet weak var myCountryFlagImage: UIImageView!
    
    @IBOutlet weak var theScrollView: UIScrollView!
    
    //Flat UI
    @IBOutlet weak var inputfieldView: UIView!
    
    @IBOutlet weak var titlebarCtView: UIView!
    @IBOutlet weak var photoCtView: UIView!
    
    @IBOutlet weak var firstnameCtView: UIView!
    @IBOutlet weak var lastnameCtView: UIView!
    @IBOutlet weak var genderCtView: UIView!
    @IBOutlet weak var phonenumberCtView: UIView!
    @IBOutlet weak var emailCtView: UIView!
    @IBOutlet weak var jobCtView: UIView!
    @IBOutlet weak var countryCtView: UIView!
    @IBOutlet weak var stateCtView: UIView!
    @IBOutlet weak var cityCtView: UIView!
    @IBOutlet weak var languageCtView: UIView!
    @IBOutlet weak var skillCtView: UIView!
    @IBOutlet weak var educationCtView: UIView!
    @IBOutlet weak var experienceCtView: UIView!
    @IBOutlet weak var privateCtView: UIView!
    
    @IBOutlet weak var firstnameView: UIView!
    @IBOutlet weak var lastnameView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var phonenumberView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var skillView: UIView!
    @IBOutlet weak var educationBtn: UIButton!
    @IBOutlet weak var experienceBtn: UIButton!
    

    //..
    public let picker = MICountryPicker()
    
    public var code: String = ""
    
    
    public var skillCollectionData:[String] = [];
    
    public let skillCellId:[String] = ["SkillCollectionCell"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.theScrollView.contentSize = CGSize(width: self.theScrollView.frame.size.width, height: 1220)
        
        self.setDismissKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        loadData()
        
        //FlatUISetting()
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
    
    func FlatUISetting() {
        inputfieldView.backgroundColor = myGreenBgColor
        
        titlebarCtView.backgroundColor = myBlueBgcolor
        photoCtView.backgroundColor = myBlueBgcolor
        
        firstnameCtView.backgroundColor = myGreyBgColor
        lastnameCtView.backgroundColor = myGreyBgColor
        genderCtView.backgroundColor = myGreyBgColor
        phonenumberCtView.backgroundColor = myGreyBgColor
        emailCtView.backgroundColor = myGreyBgColor
        jobCtView.backgroundColor = myGreyBgColor
        countryCtView.backgroundColor = myGreyBgColor
        stateCtView.backgroundColor = myGreyBgColor
        cityCtView.backgroundColor = myGreyBgColor
        languageCtView.backgroundColor = myGreyBgColor
        skillCtView.backgroundColor = myGreyBgColor
        educationCtView.backgroundColor = myGreyBgColor
        experienceCtView.backgroundColor = myGreyBgColor
        //privateCtView.backgroundColor = myGreyBgColor
        
        firstnameView.backgroundColor = myWhiteBgColor
        lastnameView.backgroundColor = myWhiteBgColor
        genderView.backgroundColor = myWhiteBgColor
        phonenumberView.backgroundColor = myWhiteBgColor
        emailView.backgroundColor = myWhiteBgColor
        jobView.backgroundColor = myWhiteBgColor
        countryView.backgroundColor = myWhiteBgColor
        stateView.backgroundColor = myWhiteBgColor
        cityView.backgroundColor = myWhiteBgColor
        languageView.backgroundColor = myWhiteBgColor
        skillView.backgroundColor = myWhiteBgColor
        educationBtn.backgroundColor = myWhiteBgColor
        experienceBtn.backgroundColor = myWhiteBgColor
        privateCtView.backgroundColor = myWhiteBgColor
        
        share.onTintColor = UIColor.lightGray
        share.tintColor = UIColor.darkGray
    }

    func loadData(){
        self.firstName.text! = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.first_name, defaultstr: "");
        self.lastName.text! = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.last_name, defaultstr: "")
        self.job.text = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.job_title, defaultstr: "")
        if CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.gender, defaultstr: "") == "famale"{
            self.famaleImage.image = UIImage(named: "option_focus")
            self.maleImage.image = UIImage(named: "option")
        } else {
            self.maleImage.image = UIImage(named: "option_focus")
            self.famaleImage.image = UIImage(named: "option")
        }
        self.phoneNumber.text! = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.phone, defaultstr: "")
        self.email.text! = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.email, defaultstr: "")
        self.country.text! = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.country, defaultstr: "")
        self.state.text! = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.state, defaultstr: "")
        self.language.text! = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.language, defaultstr: "")
        self.city.text! = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.city, defaultstr: "")
        self.code = CtrCommon.convertNiltoEmpty(string: AppCommon.instance.profile.code, defaultstr: "")
        if let urlstr = AppCommon.instance.profile.photo, let url = URL(string: urlstr){
            self.profilePhoto.kf.setImage(with: url)
        } else {
            self.profilePhoto.image = UIImage(named: "profilemain")
        }
        self.share.setOn(AppCommon.instance.profile.share, animated: false)
        self.skillCollectionData = AppCommon.instance.profile.skills;
        if AppCommon.instance.profile.country != nil{
            self.myCountryFlagImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(AppCommon.instance.profile.code!.lowercased())")
        }
    }
    
    public func setSkills(params: [String]){
        self.skillCollectionData = params;
        self.skillCollectionView.reloadData();
    }
    
    public func setCountry(params: String){
        self.country.text = params;
    }
    
    public func setLanguage(params: String){
        self.language.text = params;
    }
    
    @IBAction func save(_ sender: Any) {
        var params:[String: Any] = [:]
        params["_id"] = AppCommon.instance.profile.user_id
        if self.firstName.text! == ""{
            Toast(text: "Please enter FirstName").show();
            return;
        }
        if self.lastName.text! == ""{
            Toast(text: "Please enter LastName").show();
            return;
        }
        if self.country.text! == ""{
            Toast(text: "Please enter Country").show();
            return;
        }
        if self.state.text! == ""{
            Toast(text: "Please enter State").show();
            return;
        }
        if self.city.text! == ""{
            Toast(text: "Please enter City").show();
            return;
        }
        if self.lastName.text! == ""{
            Toast(text: "Please enter LastName").show();
            return;
        }
        
        if self.email.text! == ""{
            Toast(text: "Please enter Email").show();
            return;
        }
        
        params["first_name"] = firstName.text!
        params["last_name"] = lastName.text!
        params["gender"] = (self.maleImage.image == UIImage(named: "option_focus")) ? "male" : "famale"
        params["phone"] = phoneNumber.text!
        params["email"] = email.text!
        params["country"] = country.text!
        params["state"] = state.text!
        params["city"] = city.text!
        params["code"] = self.code
        params["language"] = language.text!
        params["share"] = share.isOn
        params["job_title"] = self.job.text!
        
        
        //param: course
        var courses:[[String: Any]] = []
        for courseData in AppCommon.instance.profile.courses{
            courses.append(courseData.toDictionary())
        }
        params["courses"] = courses;
        //param: skill
        let skills: [String] = self.skillCollectionData;
        params["skills"] = skills
        //param: orgnization
        var orgnizations:[[String: Any]] = []
        for orgData in AppCommon.instance.profile.orgnizations{
            orgnizations.append(orgData.toDictionary())
        }
        params["orgnizations"] = orgnizations
        let jsonParma = JSON(params);
        let jsonstrParma = jsonParma.rawString();
        
       // let test = String(data: jsonstrParma!.data(using: String.Encoding.utf8)!, encoding: .utf8)
        
        
        
        
        CtrCommon.startRunProcess(viewController: self, completion: {
            
            UserProvider.request(.updateWithPhoto(image: UIImageJPEGRepresentation(self.profilePhoto.image!, 0.1)!, fields: jsonstrParma!.data(using: String.Encoding.utf8)!), queue: DispatchQueue.main,
                                 progress: { response in
                                    
                                            },
                                 completion: { result in
                                    CtrCommon.stopRunProcess();
                                    switch result {
                                    case .success(let response):
                                        
                                        let jsonData = JSON(response.data)
                                        if jsonData["code"] == 200{
                                            if jsonData["data"] != JSON.null{
                                                AppCommon.instance.profile.update(params);
                                                AppCommon.instance.profile.photo = jsonData["data"].stringValue
                                                self.goto(to: "Back", params: nil)
                                            }
                                        }else{
                                            Toast(text: jsonData["message"].stringValue).show()
                                        }
                                        
                                    case .failure(let error):
                                        Toast(text: error.localizedDescription).show()
                                    }
            
            
                                } )
            
        })
    }
    
    
    @IBAction func profilePhotoSelectAction(_ sender: UIButton) {
        let croppingEnabled = true
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
            if image != nil {
                self?.profilePhoto.image = image
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func famaleSelectAction(_ sender: UIButton) {
        self.famaleImage.image = UIImage(named: "option_focus")
        self.maleImage.image = UIImage(named: "option")
    }
    
    @IBAction func maleSelectAction(_ sender: UIButton) {
        self.famaleImage.image = UIImage(named: "option")
        self.maleImage.image = UIImage(named: "option_focus")
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.goto(to: "Back", params: nil)
    }
    
    @IBAction func skillAddAction(_ sender: UIButton) {
        self.goto(to: Constant.SKILL_VC, params: self.skillCollectionData)
    }
    
    
    @IBAction func countrySelectAction(_ sender: UIButton) {
//        self.goto(to: Constant.COUNTRY_VC, params: nil)
        
        self.picker.delegate = self
        //self.picker.showCallingCodes = true
        self.picker.setSelectedCountry(country: self.country.text!)
        self.present(self.picker, animated: true, completion: nil)
    }
    
    @IBAction func languageSelectAction(_ sender: UIButton) {
        self.goto(to: Constant.LANGUAGE_VC, params: nil)
    }
    
    
    @IBAction func courseOrgSelectActon(_ sender: UIButton) {
        self.goto(to: Constant.CORORGSETTING_VC, params: nil)
    }
    
    
    private func goto(to: String, params: Any!){
        DispatchQueue.main.async {
            if to == "Back"{
                self.dismiss(animated: true, completion: nil);
            }else if to == Constant.CORORGSETTING_VC{
                let toVc: CourseOrgSettingViewController = UIStoryboard(name:"CourseOrg", bundle:nil).instantiateViewController(withIdentifier: Constant.CORORGSETTING_VC) as! CourseOrgSettingViewController;
                self.present(toVc, animated: true, completion: nil);
            }else if to == Constant.SKILL_VC{
                let toVc: SkillViewController = UIStoryboard(name:"SkillView", bundle:nil).instantiateViewController(withIdentifier: to) as! SkillViewController
                toVc.parentVc = self;
                toVc.setData(params: params)
                self.present(toVc, animated: true, completion: nil);
            }else if to == Constant.LANGUAGE_VC{
                let toVc: LanguageViewController = UIStoryboard(name:"SelectLanguage", bundle:nil).instantiateViewController(withIdentifier: to) as! LanguageViewController
                toVc.parentVc = self
                toVc.isLanguage = true
                self.present(toVc, animated: true, completion: nil);
            }else if to == Constant.COUNTRY_VC{
                let toVc: LanguageViewController = UIStoryboard(name:"SelectLanguage", bundle:nil).instantiateViewController(withIdentifier: to) as! LanguageViewController
                toVc.parentVc = self
                toVc.isLanguage = false
                self.present(toVc, animated: true, completion: nil);
            }
        }
    }
}


extension ProfileSettingViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ProfileSettingViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.skillCollectionData.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell =  collectionView.dequeueReusableCell(withReuseIdentifier: self.skillCellId[0], for: indexPath);
        (cell.viewWithTag(1) as! UILabel).text = self.skillCollectionData[indexPath.row]
        return cell;
    }
}


extension ProfileSettingViewController: MICountryPickerDelegate{
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String) {
        if name != "Back"{
            if name != ""{
                self.country.text = name;
                self.code = code
                self.myCountryFlagImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(code.lowercased())")
            }else{
                self.country.text = "";
                self.code = ""
                self.myCountryFlagImage.image = nil;
            }
        }
        
        self.picker.dismiss(animated: true, completion: nil)
    }
    
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        print(dialCode)
    }
}

