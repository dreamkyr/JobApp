//
//  AppCommon.swift
//  BayleafTakeaway
//
//  Created by Admin on 2017/05/12.
//  Copyright © 2017 BenzCruise. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import CocoaMQTT
import UIKit
public class AppCommon{
    
    public static var instance:AppCommon = AppCommon();
    
    public static var backgroundThreadFlag = false;
    
    public var rootVc: UIViewController! = nil;
    
    public var profile: Profile! = nil;
    public var refferedJobs: [Job] = []
    public var sharedJobs: [Job] = []
    public var appliedJobs: [Job] = []
    public var chatLinkUsers: [ChatList] = []
    public var contactNotificationNumber: Int = 0;
    public var chatNotification: [Int] = [];
    public var phoneContactData: [Contact] = []
    
    public var jobNotification:[String: [String]] = [:]
    public var sharedNotification:[String: [String]] = [:]
    
    public var countries:[JSON] = []
    public var languages:[JSON] = []
    public var contacts: [Contact] = [];
    public var noContacts: [Contact] = [];
    public var categories:[String] = []
    public var skills:[String: [String]] = [:]
    
    init(){
        if let file = Bundle.main.path(forResource: "Arrays", ofType: "json"){
            let data = NSData(contentsOfFile: file) as Data?
            let json = JSON(data: data!, options: .mutableContainers, error: nil)
            self.countries = json["countries"].arrayValue
            self.languages = json["languages"].arrayValue
            
        } else {
            print("no file")
        }
    }
    
    public func initApp(data: JSON)->Bool{
        
        print("Token: \(data["token"])")
        
        let user = Profile(data["profile"].dictionaryObject!);
        if !user.verified{
            return false
        }
        self.profile = user
        
        
        let skillsData: [JSON] = data["skills"].arrayValue
        for skilldata in skillsData{
            self.categories.append(skilldata["category_name"].stringValue)
            self.skills[skilldata["category_name"].stringValue] = []
            for sdata in skilldata["skills"].arrayValue{
                self.skills[skilldata["category_name"].stringValue]?.append(sdata.stringValue);
            }
        }
        self.skills["other"] = []
        self.categories.append("other")
        
        
       
        AppCommon.instance.contacts = []
        for userData: JSON in data["contacts"].arrayValue{
            self.contacts.append(Contact(userData.dictionaryObject!))
        }
        for contactData in self.phoneContactData{
            var flag = false;
            for contact in self.contacts{
                if let phone1 = contact.profile.phone, let phone2 = contactData.profile.phone{
                    if phone1 == phone2{
                        flag = true;
                        break;
                    }
                }
                if let email1 = contact.profile.email, let email2 = contactData.profile.email{
                    if email1 == email2{
                        flag = true;
                        break;
                    }
                }
            }
            if !flag{
                self.noContacts.append(contactData)
            }
        }
        
        let chatlistsData: [JSON] = data["chatlists"].arrayValue
        for chatlistData in chatlistsData{
            self.chatLinkUsers.append(ChatList(chatlistData.dictionaryObject!))
        }
        
        return true;
    }
   
    
    public func isExistContact(refferer: Profile)->Bool{
        for contact in self.contacts{
            if contact.status == 0{
                if contact.profile.user_id == refferer.user_id{
                    return true;
                }
            }
        }
        return false;
    }
    
    
    public func deleteJob(of: String, id: Int){
        if of == "RefferedJobs"{
            for i in 0 ..< AppCommon.instance.refferedJobs.count{
                if AppCommon.instance.refferedJobs[i].id == id{
                    AppCommon.instance.refferedJobs.remove(at: i);
                    return;
                }
            }
        }
    }
    
    public func deletChatList(id: Int){
        for i in 0 ..< self.chatLinkUsers.count{
            if self.chatLinkUsers[i].id == id{
                self.chatLinkUsers.remove(at: i)
                return;
            }
        }
    }
    
    public func getJob(of: String, id: Int)->Job!{
        if of == "RefferedJobs"{
            for i in 0 ..< self.refferedJobs.count{
                if self.refferedJobs[i].id == id{
                    return self.refferedJobs[i]
                }
            }
        }
        return nil;
    }

    public func updateJob(of: String, updatejob: Job){
        if of == "RefferedJobs"{
            for i in 0 ..< self.refferedJobs.count{
                if self.refferedJobs[i].id == updatejob.id{
                    self.refferedJobs[i] = updatejob;
                    return;
                }
            }
        }
    }
    
    public func updateContact(updatecontact: Contact){
        for i in 0 ..< self.contacts.count{
            if self.contacts[i].profile.user_id == updatecontact.profile.user_id{
                self.contacts[i] = updatecontact;
                return;
            }
        }
    }
    
    public func getContact(id: Int)->Contact!{
        for contact in self.contacts{
            if contact.profile.user_id == id{
                return contact;
            }
        }
        return nil;
    }
    
    public func getChatList(id: Int)->ChatList!{
        for chatlist in self.chatLinkUsers{
            if chatlist.linked_user.user_id == id{
                return chatlist;
            }
        }
        return nil;
    }
    
    public func isApplied(job: Job)->Bool{
        for appliedjob in self.appliedJobs{
            if job.id == appliedjob.id{
                return true;
            }
        }
        return false;
    }
    
    public func isShared(job: Job)->Bool{
        for sharedjob in self.sharedJobs{
            if job.id == sharedjob.id{
                return true;
            }
        }
        return false;
    }
    
    public func addAppliedJob(job: Job){
        for appliedJob in self.appliedJobs{
            if job.id == appliedJob.id{
                return;
            }
        }
        self.appliedJobs.append(job)
    }
    
    public func addSharedJob(job: Job){
        for sharedJob in self.sharedJobs{
            if job.id == sharedJob.id{
                return;
            }
        }
        self.sharedJobs.append(job)
    }
    
    public func removeAppliedJob(job: Job){
        for i in 0 ..< self.appliedJobs.count{
            if self.appliedJobs[i].id == job.id{
                self.appliedJobs.remove(at: i)
                return;
            }
        }
    }

    public func removeSharedJob(job: Job){
        for i in 0 ..< self.sharedJobs.count{
            if self.sharedJobs[i].id == job.id{
                self.sharedJobs.remove(at: i)
                return;
            }
        }
    }
    
    
    /**** job post noti *******/
    public func removeJobNotification(userId: String, jobId: String){
        for i in 0 ..< self.jobNotification[userId]!.count{
            if self.jobNotification[userId]?[i] == jobId{
                self.jobNotification[userId]?.remove(at: i)
                return;
            }
        }
    }
    
    public func getJobNotificationCount()->Int{
        var count = 0;
        for (_, value) in self.jobNotification{
            count += value.count;
        }
        return count;
    }
    
    public func getJobNotificationCount(userId: String)->Int{
        for (key, value) in self.jobNotification{
            if key == userId{
                return value.count
            }
        }
        return 0;
    }
    
    public func isNotificationJob(jobId: String)->Bool{
        for (_, value) in self.jobNotification{
            for id in value{
                if id == jobId{
                    return true;
                }
            }
        }
        return false;
    }



    /******** shared noti *****/
    
    public func removeSharedNotification(userId: String, jobId: String){
        for i in 0 ..< self.sharedNotification[userId]!.count{
            if self.sharedNotification[userId]?[i] == jobId{
                self.sharedNotification[userId]?.remove(at: i)
            }
        }
    }
    
    public func getSharedNotificationCount()->Int{
        var count = 0;
        for (_, value) in self.sharedNotification{
            count += value.count;
        }
        return count;
    }
    
    public func getSharedNotificationCount(userId: String)->Int{
        for (key, value) in self.sharedNotification{
            if key == userId{
                return value.count
            }
        }
        return 0;
    }
    
    public func isSharedNotificationJob(jobId: String)->Bool{
        for (_, value) in self.sharedNotification{
            for id in value{
                if id == jobId{
                    return true;
                }
            }
        }
        return false;
    }
    
    public func removeAllNotification(){
        self.contactNotificationNumber = 0;
        self.chatNotification = [];
        self.jobNotification = [:]
        self.sharedNotification = [:]
    }
}
