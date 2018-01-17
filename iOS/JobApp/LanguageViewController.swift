//
//  LanguageViewController.swift
//  JobApp
//
//  Created by JaonMicle on 19/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    public var parentVc: UIViewController! = nil
    public var isLanguage: Bool = true
    
    public let cellId = "LanuguageCell"
    
    public var dataSource: [String] = []
    public var filteredDataSource: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDataSource();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isLanguage {
            self.titleLabel.text = "Select Language"
        } else {
            self.titleLabel.text = "Select Country"
        }
        
        filterDataSource()
    }
    
    public func initDataSource(){
        if self.isLanguage {
            for data in AppCommon.instance.languages{
                self.dataSource.append(data.stringValue);
            }
        } else {
            for data in AppCommon.instance.countries{
                self.dataSource.append(data.stringValue);
            }
        }
    }
    
    func filterDataSource() {
        filteredDataSource.removeAll()
        let keyword = self.searchBar.text?.trim()
        for data in dataSource {
            if passWithKeyword(data: data, keyword: keyword!) {
                filteredDataSource.append(data)
            }
        }
        self.tableView.reloadData()
    }
    
    func passWithKeyword(data: String, keyword: String) -> Bool {
        if keyword.characters.count == 0 {
            return true
        }
        
        let lowerkeyword = keyword.lowercased()
        let lowerdata = data.lowercased()
        
        return lowerdata.contains(lowerkeyword)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension LanguageViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterDataSource()
    }
}

extension LanguageViewController: UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellId)
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: self.cellId)
            
        }
        cell?.backgroundColor = UIColor.clear
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        cell?.textLabel?.text = self.filteredDataSource[indexPath.row]
        cell?.textLabel?.textColor = UIColor.black
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.parentVc != nil{
            if let toVc = self.parentVc as? ProfileSettingViewController{
                if self.isLanguage {
                    toVc.setLanguage(params: self.filteredDataSource[indexPath.row])
                } else {
                    toVc.setCountry(params: self.filteredDataSource[indexPath.row])
                }
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
        cell?.backgroundColor = UIColor(white: 1, alpha: 0.2)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.clear
    }
}
