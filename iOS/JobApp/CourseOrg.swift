//
//  File.swift
//  JobApp
//
//  Created by JaonMicle on 04/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import SwiftyJSON
public class CourseOrg{
    public var name: String!
    public var major: String!
    public var start: String!
    public var end: String!
    
    init(){
        self.name = "";
        self.major = "";
        self.start = ""
        self.end = ""
    }
    
    init(data: [String: Any]){
        self.name = CtrCommon.filterNull(value: data["name"]);
        self.major = CtrCommon.filterNull(value: data["major"]);
        self.start = CtrCommon.filterNull(value: data["start"]);
        self.end = CtrCommon.filterNull(value: data["end"]);
    }
    
    public func toDictionary()->[String: Any]{
        var dicData: [String: Any] = [:]
        dicData["name"] = self.name
        dicData["major"] = self.major
        dicData["start"] = self.start
        dicData["end"] = self.end
        return dicData;
    }
}
