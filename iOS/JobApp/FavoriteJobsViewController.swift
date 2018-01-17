//
//  FavoriteJobsViewController.swift
//  JobApp
//
//  Created by JaonMicle on 26/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toaster

class FavoriteJobsViewController: UIViewController {

    fileprivate var favoriteJobs: [Job] = []
    
    fileprivate let cellId: String = "FavoriteJobCell"
    
    @IBOutlet weak var favoriteTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadData();
    }
    
    
    private func loadData(){
        CtrCommon.startRunProcess(viewController: self, completion: {
            Alamofire.request(Constant.JOB_GETFAVORITE_URL, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON(completionHandler: { (response) in
                CtrCommon.stopRunProcess()
                switch response.result{
                case .success(let data):
                    let jsonData: JSON = JSON(data)
                    if jsonData["code"].intValue == 200{
                        if jsonData["data"] != JSON.null{
                            let jobDatas: [JSON] = jsonData["data"].arrayValue
                            self.favoriteJobs = []
                            for jobData in jobDatas{
                                self.favoriteJobs.append(Job(jobData.dictionaryObject!))
                            }
                            
                            DispatchQueue.main.async {
                                self.favoriteTable.reloadData();
                            }
                            
                        }
                    }else{
                        Toast(text: jsonData["message"].stringValue).show();
                    }
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    break;
                }
            })
        })
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func goto(to: String, param: Any?){
        if to == Constant.JOBDETAILS_VC{
            let toVc: JobDetailsViewController = UIStoryboard(name: "JobDetails" , bundle: nil).instantiateViewController(withIdentifier: to) as! JobDetailsViewController;
            toVc.setData(params: param)
            toVc.type = "FavoriteJob"
            self.present(toVc, animated: true, completion: nil)
        }
    }
}
extension FavoriteJobsViewController: UITableViewDataSource, UITableViewDelegate{
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40;
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let sectionView: UIView = UIView();
//        sectionView.backgroundColor = UIColor(white: 1, alpha: 0.5)
//        let contentRect: CGRect = CGRect(x:10, y:0, width: 150, height: 50);
//        let headerLabel: UILabel = UILabel(frame: contentRect);
//        headerLabel.text = self.sectionName[section];
//        headerLabel.textColor = UIColor.white;
//        sectionView.addSubview(headerLabel);
//        return sectionView;
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteJobs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.goto(to: Constant.JOBDETAILS_VC, param: self.favoriteJobs[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! FavoriteJobCell
        cell.backgroundColor = UIColor.clear
        cell.setData(job: self.favoriteJobs[indexPath.row])
        return cell;
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
