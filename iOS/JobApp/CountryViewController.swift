//
//  CountryViewController.swift
//  JobApp
//
//  Created by JaonMicle on 19/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class CountryViewController: UIViewController {

    public var parentVc: UIViewController! = nil;
    
    public let cellId = "CountryCell"
    
    public var dataSource: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDataSource();
    }
    
    public func initDataSource(){
        for countryData in AppCommon.instance.countries{
            self.dataSource.append(countryData["name"].stringValue);
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension CountryViewController: UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellId)
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: self.cellId)
        }
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.text = self.dataSource[indexPath.row]
        cell?.textLabel?.textColor = UIColor.white
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        return cell!
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.parentVc != nil{
            if let toVc = self.parentVc as? ProfileSettingViewController{
                toVc.setCountry(params: self.dataSource[indexPath.row])
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
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
