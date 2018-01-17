//
//  HelpViewController.swift
//  JobApp
//
//  Created by Admin on 5/24/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.goto(to: "Back")
    }
    
    private func goto(to: String){
        if to == "Back"{
            self.dismiss(animated: false, completion: nil);
        }
    }
}
