//
//  Profile.swift
//  JobApp
//
//  Created by Admin on 01/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
public class Profile {
    
    public var user_id:Int!
    public var first_name: String!
    public var last_name: String!
    public var full_name: String!
    public var job_title: String!
    public var verified: Bool = false
    public var created_date: String!
    public var updated_date: String!
    public var email: String!
    public var phone: String!
    public var birthday: String!
    public var country: String!
    public var code: String!
    public var language: String!
    public var group: Int!
    public var gender: String!
    public var state: String!
    public var city:String!
    public var courses: [CourseOrg] = []
    public var orgnizations: [CourseOrg] = []
    public var skills: [String] = []
    public var share: Bool = false
    public var photo: String!
    public var role_id: Int!
    
    init(){
        self.user_id = nil
        self.first_name = nil
        self.last_name = nil
        self.full_name = nil;
        self.job_title = nil
        self.verified = false
        self.created_date = nil
        self.updated_date = nil
        self.email = nil
        self.phone = nil
        self.birthday = nil
        self.country = nil
        self.code = nil
        self.language = nil
        self.group = nil
        self.gender = nil
        self.state = nil
        self.city = nil;
        self.courses = []
        self.orgnizations = []
        self.skills = []
        self.share = false
        self.photo = nil
        self.role_id = nil
    }

    init(_ params:[String:Any]){
        update(params)
    }
    
    public func update(_ params:[String:Any]){
        if params["_id"] != nil{
            self.user_id = params["_id"] as! Int
        }
        self.first_name = CtrCommon.filterNull(value: params["first_name"])
        self.last_name = CtrCommon.filterNull(value: params["last_name"])
        self.full_name = CtrCommon.convertNiltoEmpty(string: first_name, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.last_name, defaultstr: "")
        self.job_title = CtrCommon.filterNull(value: params["job_title"])
        self.phone = CtrCommon.filterNull(value: params["phone"])
        self.birthday = CtrCommon.filterNull(value: params["birthday"])
        self.country = CtrCommon.filterNull(value: params["country"])
        self.code = CtrCommon.filterNull(value: params["code"])
        self.language = CtrCommon.filterNull(value: params["language"])
        self.photo = CtrCommon.filterNull(value: params["photo"])
        self.gender = CtrCommon.filterNull(value: params["gender"])
        self.state = CtrCommon.filterNull(value: params["state"])
        self.city = CtrCommon.filterNull(value: params["city"])
        self.email = CtrCommon.filterNull(value: params["email"])
        if params["verified"] != nil{
            self.verified = params["verified"] as! Bool
        }
        self.created_date = CtrCommon.filterNull(value: params["created_date"])
        self.updated_date = CtrCommon.filterNull(value: params["updated_date"])
        if params["role_id"] != nil{
            self.role_id = params["role_id"] as! Int
        }
        if params["group"] != nil{
            group = params["group"] as! Int
        }
        if params["skills"] != nil{
            skills = params["skills"] as! [String]
        }
        if params["share"] != nil{
            share = params["share"] as! Bool
        }
        if params["courses"] != nil{
            self.courses = []
            for courseData in params["courses"] as! [[String: Any]]{
                self.courses.append(CourseOrg(data: courseData))
            }
        }
        if params["orgnizations"] != nil{
            self.orgnizations = []
            for orgData in params["orgnizations"] as! [[String: Any]]{
                self.orgnizations.append(CourseOrg(data: orgData))
            }
        }
    }
    
    public func getDicData()->[String: Any]{
        var dicData:[String: Any] = [:]
        if self.first_name != nil{
            dicData["first_name"] = self.first_name
        }
        if self.last_name != nil{
            dicData["last_name"] = self.last_name
        }
        if self.phone != nil{
            dicData["phone"] = self.phone
        }
        if self.birthday != nil{
            dicData["birthday"] = self.birthday
        }
        if self.country != nil{
            dicData["country"] = self.country
        }
        if self.code != nil{
            dicData["code"] = self.code
        }
        if self.language != nil{
            dicData["language"] = self.language
        }
        if self.photo != nil{
            dicData["photo"] = self.photo
        }
        if self.gender != nil{
            dicData["gender"] = self.gender
        }
        if self.state != nil{
            dicData["state"] = self.state
        }
        if self.city != nil{
            dicData["city"] = self.city
        }
        if self.email != nil{
            dicData["email"] = self.email
        }
        if self.group != nil{
            dicData["group"] = self.group
        }
        if self.skills.count != 0{
            dicData["state"] = self.skills
        }
        if self.orgnizations.count != 0{
            dicData["orgnizations"] = self.orgnizations
        }
        if self.courses.count != 0{
            dicData["courses"] = self.courses
        }
        return dicData
    }
    
    public func isCompleted() -> Bool {
        
        if self.job_title != nil,  self.job_title.trim().characters.count == 0 {
            return false
        }
        
        if self.verified == false {
            return false
        }
        
        if self.email != nil, self.email.trim().characters.count == 0 {
            return false
        }
        
        if self.phone != nil, self.phone.trim().characters.count == 0 {
            return false
        }
        
        if self.birthday != nil, self.birthday.trim().characters.count == 0 {
            return false
        }

        if self.country != nil, self.country.trim().characters.count == 0 {
            return false
        }
        
        if self.code != nil, self.code.trim().characters.count == 0 {
            return false
        }
        
        if self.language != nil, self.language.trim().characters.count == 0 {
            return false
        }
        
        if self.gender != nil, self.gender.trim().characters.count == 0 {
            return false
        }

        if self.state != nil, self.state.trim().characters.count == 0 {
            return false
        }
        
        if self.city != nil, self.city.trim().characters.count == 0 {
            return false
        }

//        if self.courses.count == 0 {
//            return false
//        }
//        
//        if self.orgnizations.count == 0 {
//            return false
//        }
        
        if self.skills.count == 0 {
            return false
        }
        
        if self.share == false {
            return false
        }
        
        if self.photo == nil {
            return false
        }
        
        return true
    }
}
