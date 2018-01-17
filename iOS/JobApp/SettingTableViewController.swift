//
//  SettingTableViewController.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 16/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import SCLAlertView

class SettingTableViewController : UITableViewController{

    @IBOutlet var settingTable: UITableView!
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        if let cell = tableView.cellForRow(at: indexPath)?.reuseIdentifier {
        
            switch cell {
            case "update":
                self.goto(to: Constant.PROFILESETTING_VC, params: nil)
            case "favorite":
                self.goto(to: Constant.FAVORITEJOBS_VC, params: nil)
            case "notifications":
                self.goto(to: Constant.NOTISETTING_VC, params: nil)
            case "data":
                print("ok d")
            case "help":
                self.goto(to: Constant.HELP_VC, params: nil)
            case "tellafriend":
                self.inviteFriend()
            default:
                print("no ")
                break
                
            }
        
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func inviteFriend(){
    
        let alert = SCLAlertView()
        _ = alert.addButton("Mail"){
            let params: [String: Any] = ["data": self.getUserByEmail(), "emailorphone": true]
            self.goto(to: Constant.INVITEUSER_VC, params: params);
        }
        _ = alert.addButton("Message") {
            let params: [String: Any] = ["data": self.getUserByPhone(), "emailorphone": false]
            self.goto(to: Constant.INVITEUSER_VC, params: params)
        }
        //_ = alert.showSuccess(kSuccessTitle, subTitle: kSubtitle)
        let icon = UIImage(named: "inviteicon")
        let color = myBlackBgColor//UIColor(red: 19/255, green: 71/255, blue: 78/255, alpha: 1)
        
        _ = alert.showCustom("Tell a Friend/Invite", subTitle: "Please Choose Item", color: color, icon: icon!)
    
    }
    
    private func getUserByEmail()->[Contact]{
        var emailUsers: [Contact] = []
        for user in AppCommon.instance.noContacts{
            if user.profile.email != nil && user.profile.email.isValidEmail(){
                emailUsers.append(user)
            }
        }
        return emailUsers;
    }
    
    private func getUserByPhone()->[Contact]{
        var phoneUsers: [Contact] = []
        for user in AppCommon.instance.noContacts{
            //            if user.profile.phone != nil && user.profile.phone.isValidatePhone(){
            if user.profile.phone != nil{
                phoneUsers.append(user)
            }
        }
        return phoneUsers;
    }
    
    private func goto(to: String, params: Any!){
        if to == Constant.PROFILESETTING_VC{
            let toVc: ProfileSettingViewController = UIStoryboard(name: "ProfileSetting", bundle: nil).instantiateViewController(withIdentifier: to) as! ProfileSettingViewController;
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.NOTISETTING_VC{
            let toVc: NotificationSettingViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: to) as! NotificationSettingViewController;
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.HELP_VC{
            let toVc: HelpViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: to) as! HelpViewController;
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.LOGIN_VC{
            let toVc: LoginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: to) as! LoginViewController;
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.INVITEUSER_VC{
            let toVc: InviteUserViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: to) as! InviteUserViewController;
            toVc.setData(data: params);
            self.present(toVc, animated: true, completion: nil);
        }else if to == Constant.FAVORITEJOBS_VC{
            let toVc: FavoriteJobsViewController = UIStoryboard(name: "Favorite", bundle: nil).instantiateViewController(withIdentifier: to) as! FavoriteJobsViewController;
            self.present(toVc, animated: true, completion: nil);
        }
    }
    
}
