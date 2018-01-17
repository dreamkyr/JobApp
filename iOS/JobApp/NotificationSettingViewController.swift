//
//  NotificationSettingViewController.swift
//  JobApp
//
//  Created by Admin on 5/24/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import AVFoundation

class NotificationSettingViewController: UIViewController {
    
    fileprivate let cellIds: String = "SoundSelectCell"
    
    fileprivate var soundData: [String] = [ "airdrop_invite",
                                            "calendar_alert_chord",
                                            "camera_shutter_burst",
                                            "camera_shutter_burst_begin",
                                            "camera_shutter_burst_end",
                                            "sms_alert_aurora",
                                            "sms_alert_bamboo",
                                            "sms_alert_circles",
                                            "sms_alert_complete",
                                            "sms_alert_hello",
                                            "sms_alert_input",
                                            "sms_alert_keys",
                                            "sms_alert_note",
                                            "sms_alert_popcorn",
                                            "sms_alert_synth"]
    
    fileprivate var selectedBell: String = "airdrop_invite"

    
    fileprivate var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var soundNameText: UILabel!
    @IBOutlet weak var showNotiSwitch: UISwitch!
    @IBOutlet weak var showPreviewNotiSwitch: UISwitch!
    @IBOutlet weak var soundTable: UITableView!
    @IBOutlet weak var otherView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.showNotiSwitch.setOn(UserDefaults.standard.bool(forKey: "shownoti_flag"), animated: false)
        self.showPreviewNotiSwitch.setOn(UserDefaults.standard.bool(forKey: "showpreview_flag"), animated: false)
        
        self.otherView.frame = CGRect(x: self.otherView.frame.origin.x,
                                      y: self.soundTable.frame.origin.y,
                                      width: self.otherView.frame.size.width,
                                      height: self.otherView.frame.size.height)
        
        if UserDefaults.standard.object(forKey: "notibellname") != nil{
            self.selectedBell = UserDefaults.standard.object(forKey: "notibellname") as! String
            self.soundNameText.text = self.selectedBell
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
   
    @IBAction func showNotiAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "shownoti_flag")
    }

    @IBAction func showPreviewAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "showpreview_flag")
    }
    
    @IBAction func soundDropboxBtnAction(_ sender: UIButton) {
        if self.soundTable.frame.origin.y == self.otherView.frame.origin.y {
            self.otherView.frame = CGRect(x: self.otherView.frame.origin.x,
                                          y: self.soundTable.frame.origin.y + self.soundTable.frame.size.height,
                                          width: self.otherView.frame.size.width,
                                          height: self.otherView.frame.size.height)
        }else{
            self.otherView.frame = CGRect(x: self.otherView.frame.origin.x,
                                          y: self.soundTable.frame.origin.y,
                                          width: self.otherView.frame.size.width,
                                          height: self.otherView.frame.size.height)
        }
        self.soundTable.reloadData()
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        self.showNotiSwitch.isOn = true;
        UserDefaults.standard.set(true, forKey: "shownoti_flag")
        self.showPreviewNotiSwitch.isOn = true
        UserDefaults.standard.set(true, forKey: "showpreview_flag")
        self.selectedBell = "airdrop_invite"
        UserDefaults.standard.set(self.selectedBell, forKey: "notibellname")
        self.soundTable.reloadData();
        self.soundNameText.text = "airdrop_invite"
        
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

extension NotificationSettingViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SoundSelectCell = tableView.dequeueReusableCell(withIdentifier: self.cellIds, for: indexPath) as! SoundSelectCell
        cell.soundNameLabel.text = soundData[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.checkIconView.image = UIImage(named: "uncheckbtn");
        if soundData[indexPath.row] == self.selectedBell{
            cell.checkIconView.image = UIImage(named: "checkbtn");
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.soundData.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileURL: URL = URL(fileURLWithPath: "\(CtrCommon.soundDirPath)\(self.soundData[indexPath.row]).caf")
        print(fileURL)
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            self.audioPlayer.play()
        } catch {
            debugPrint("\(error)")
        }

    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell: SoundSelectCell = tableView.cellForRow(at: indexPath) as! SoundSelectCell
        cell.checkIconView.image = UIImage(named: "checkbtn")
        self.selectedBell = self.soundData[indexPath.row]
        UserDefaults.standard.set(self.selectedBell, forKey: "notibellname")
        self.soundNameText.text = self.selectedBell;
        self.soundTable.reloadData();
        return indexPath
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
