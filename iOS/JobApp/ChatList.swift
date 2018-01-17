//
//  ChatList.swift
//  JobApp
//
//  Created by JaonMicle on 17/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation

public class ChatList{
    public var id: Int! = nil
    public var linked_user: Profile! = nil;
    public var last_message: String! = nil;
    public var last_time: String! = nil;
    
    init(){
        self.id = nil;
        self.linked_user = nil;
        self.last_time = nil;
        self.last_message = nil;
    }
    
    init(_ data: [String: Any]){
        self.update(data);
    }
    
    public func update(_ data: [String: Any]){
        if data["_id"] != nil{
            self.id = data["_id"] as! Int;
        }
        self.last_message = CtrCommon.filterNull(value: data["last_message"])
        self.last_time = CtrCommon.filterNull(value: data["last_time"])
        if data["linked_user"] != nil{
            self.linked_user = Profile(data["linked_user"] as! [String: Any])
        }
    }
}
