//
//  CourseOrgDetailViewController.swift
//  JobApp
//
//  Created by JaonMicle on 04/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Toaster

class CourseOrgDetailViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var universityTitleLabel: UILabel!
    @IBOutlet weak var majorTitlelabel: UILabel!
    
    @IBOutlet weak var universityText: PlaceHolderTextField!
    @IBOutlet weak var majorText: PlaceHolderTextField!
    @IBOutlet weak var startText: PlaceHolderTextField!
    @IBOutlet weak var endText: PlaceHolderTextField!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var presentSwitch: UISwitch!
    
    private var data: CourseOrg! = nil;
    private var flag: Bool = true;
    private var index: Int! = nil
    
    let PRESENT: String = "Present"
    
    func FlatUISetting() {
        
        self.mainScrollView.contentSize = CGSize(width: self.mainScrollView.frame.size.width, height: 550)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.flag{
            self.titleLabel.text = "Course"
            self.universityTitleLabel.text = "University/College"
            self.majorTitlelabel.text = "Major"
            self.universityText.placeholder = "Please enter university or college name"
            self.majorText.placeholder = "Please enter major"
        }else{
            self.titleLabel.text = "Organization"
            self.universityTitleLabel.text = "Company"
            self.majorTitlelabel.text = "Title"
            self.universityText.placeholder = "Please enter company name"
            self.majorText.placeholder = "Please enter title"
        }
        if self.data != nil{
            self.universityText.text = self.data.name
            self.majorText.text = self.data.major
            self.startText.text = self.data.start;
            self.endText.text = self.data.end;
            if self.data.end == PRESENT {
                self.presentSwitch.isOn = true
            } else {
                self.presentSwitch.isOn = false
            }
        }
        self.startDatePicker.setValue(UIColor.black, forKeyPath: "textColor")
        self.endDatePicker.setValue(UIColor.black, forKeyPath: "textColor")
        self.setDismissKeyboard()
        
        FlatUISetting()
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.goto(to: "Back")
    }
    
    @IBAction func startDateSelectAction(_ sender: UIDatePicker) {
        self.startText.text = String(date: sender.date, format: "yyyy.MM.dd")
    }
    
    @IBAction func endDateSelectAction(_ sender: UIDatePicker) {
        self.endText.text = String(date: sender.date, format: "yyyy.MM.dd")
    }

    @IBAction func courseOrgSaveAction(_ sender: UIButton) {
        
        var endDateString = ""
        if self.endText.text != PRESENT {
            if self.endText.text == "" {
                Toast(text: "Please enter end date").show()
                return;
            }
            endDateString = self.endText.text!
        } else {
            endDateString = PRESENT
        }
        
        if flag{
            let result = CtrCommon.isInputComplete(["University/College": self.universityText.text!, "Major": self.majorText.text!, "Start date": self.startText.text!])
            if result != nil{
                Toast(text: "Please enter " + result!).show()
                return;
            }
            let newCourse: CourseOrg = CourseOrg(data: ["name": self.universityText.text!, "major": self.majorText.text!, "start": self.startText.text!, "end": endDateString])
            if self.index == nil{
                AppCommon.instance.profile.courses.append(newCourse)
            }else{
                AppCommon.instance.profile.courses[self.index] = newCourse
            }
            
        }else{
            let result = CtrCommon.isInputComplete(["Company": self.universityText.text!, "Title": self.majorText.text!, "Start date": self.startText.text!])
            if result != nil{
                Toast(text: "Please enter " + result!).show()
                return;
            }
            let newOrg: CourseOrg = CourseOrg(data: ["name": self.universityText.text!, "major": self.majorText.text!, "start": self.startText.text!, "end": endDateString])
            if self.index == nil{
                AppCommon.instance.profile.orgnizations.append(newOrg)
            }else{
                AppCommon.instance.profile.orgnizations[self.index] = newOrg
            }
        }
        self.goto(to: "Back");
    }
    
    @IBAction func onTillPresent(_ sender: UISwitch) {
        if sender.isOn {
            self.endDatePicker.isHidden = true
            self.endText.text = PRESENT
        } else {
            self.endDatePicker.isHidden = false
            self.endText.text = String(date: endDatePicker.date, format: "yyyy.MM.dd")
        }
    }
    
    private func goto(to: String){
        if to == "Back"{
            self.dismiss(animated: false, completion: nil);
        }
    }


    public func setData(data: [String:Any?]){
        self.flag = data["flag"] as! Bool
        if data["data"] != nil{
            self.data = data["data"] as! CourseOrg;
        }
        if data["index"] != nil{
            self.index = data["index"] as! Int
        }
    }

}
