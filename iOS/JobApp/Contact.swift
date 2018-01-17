//
//  Contact.swift
//  JobApp
//
//  Created by JaonMicle on 12/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import SwiftyJSON
public class Contact {
    public var profile: Profile = Profile();
    public var status: Int = 2
    public var favorite: Bool = false
    public var display_setting: Bool = false;
    
    init(){
        self.profile = Profile();
        self.status = 2;
        self.favorite = false;
        self.display_setting = false;
    }
    
    init(_ data: [String: Any]){
        self.update(data);
    }
    
    public func update(_ data: [String: Any]){
        if data["contact_user"] != nil{
            let contactUser = data["contact_user"] as? [String: Any]
            if contactUser != nil {
                self.profile = Profile(contactUser!);
            }
        }
        if data["status"] != nil{
            self.status = data["status"] as! Int
        }
        if data["favorite"] != nil{
            self.favorite = data["favorite"] as! Bool
        }
        if data["isShared"] != nil{
            self.display_setting = data["isShared"] as! Bool
        }
    }
    
    
    public func getDicData()->[String: Any]{
        var dicData: [String: Any] = [:]
        dicData["contact_user"] = self.profile.getDicData()
        dicData["status"] = self.status
        dicData["favorite"] = self.favorite
        dicData["isShared"] = self.display_setting
        return dicData;
    }
}
