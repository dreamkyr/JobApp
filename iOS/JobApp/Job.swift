//
//  Job.swift
//  JobApp
//
//  Created by Admin on 02/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation


public class Job{
    public var id: Int!
    public var employer_name: String!
    public var title:String!
    public var description:String!
    public var referrer:Profile!
    public var type:String!
    public var skills:[String] = []
    public var country: String!
    public var state: String!
    public var city: String!
    public var status:Int!
    public var proposed_users:[ProposedUser] = []
    public var share_dates: [String] = []
    public var accepted_user:Profile!
    public var favorite_users: [Profile] = []
    public var shared_users: [Profile] = []
    public var posted_date: String!
    public var salary: String!
    public var hremailorphone: String!
    public var invited_users: [Int] = []
    public var hidden_users: [Int] = []
    
    init(){
        self.id = nil;
        self.employer_name = nil;
        self.title = nil;
        self.description = nil;
        self.referrer = nil;
        self.type = nil;
        self.skills = []
        self.country = nil;
        self.state = nil;
        self.city = nil;
        self.status = nil;
        self.proposed_users = []
        self.shared_users = []
        self.accepted_user = nil
        self.favorite_users = []
        self.posted_date = nil
        self.share_dates = []
        self.salary = nil;
        self.hremailorphone = nil;
        self.invited_users = []
        self.hidden_users = []
    }
    
    
    init(_ param:[String:Any]){
        self.update(param)
    }
    
    public func update(_ param: [String: Any]){
        if param["_id"] != nil{
            self.id = param["_id"] as! Int;
        }
        self.employer_name = CtrCommon.filterNull(value: param["employer_name"])
        self.title = CtrCommon.filterNull(value: param["title"]);
        self.description = CtrCommon.filterNull(value: param["description"]);
        
        if param["referrer"] != nil {
            self.referrer = Profile(param["referrer"] as! [String: Any])
        }
        self.type = CtrCommon.filterNull(value: param["type"])
        
        if param["skills"] != nil {
            self.skills = param["skills"] as! [String]
        }
        self.country = CtrCommon.filterNull(value: param["country"])
        self.state = CtrCommon.filterNull(value: param["state"])
        self.city = CtrCommon.filterNull(value: param["city"])
        if param["status"] != nil {
            self.status = param["status"] as! Int
        }
        if param["proposed_users"] != nil {
            for proposed_userdata in param["proposed_users"] as! [[String: Any]]{
                let proposted_user: ProposedUser = ProposedUser()
                proposted_user.contact_email = proposed_userdata["contact_email"] as! String
                proposted_user.contact_phone = proposed_userdata["contact_phone"] as! String
                proposted_user.profile = Profile(proposed_userdata["profile"] as! [String: Any])
                self.proposed_users.append(proposted_user)
            }
        }
        
        if param["share_users"] != nil {
            for shared_userdata in param["share_users"] as! [[String: Any]]{
                self.shared_users.append(Profile(shared_userdata))
            }
        }
        
        if param["share_dates"] != nil{
            self.share_dates = param["share_dates"] as! [String]
        }
        
        if param["salary"] != nil{
            self.salary = param["salary"] as! String
        }
        
        if param["favorited_users"] != nil {
            for favorited_userData in param["favorited_users"] as! [[String: Any]]{
                self.favorite_users.append(Profile(favorited_userData))
            }
        }
        if param["accepted_user"] != nil {
            self.accepted_user = Profile(param["accepted_user"] as! [String: Any])
        }
        if param["invited_users"] != nil{
            self.invited_users = param["invited_users"] as! [Int]
        }
        
        if param["hidden_users"] != nil{
            self.hidden_users = param["hidden_users"] as! [Int]
        }
        self.posted_date = CtrCommon.filterNull(value: param["posted_date"])
        
        self.hremailorphone = CtrCommon.filterNull(value: param["hrphone_email"])
    }
}

public class ProposedUser{
    public var contact_email: String = ""
    public var contact_phone: String = ""
    public var profile: Profile = Profile();
}
