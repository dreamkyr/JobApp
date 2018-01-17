//
//  AppAccessTokenPlugin.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 07/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation
import Moya

struct AppAccessTokenPlugin: PluginType {
    
    /// The access token to be applied in the header.
    public var token: String {
        get {
            return SharedKeycard.token ?? ""
        }
    }
    

    private var authVal: String {
        print("authval: \(token)")
        return "Bearer " + token
    }
    
    
    /**
     Prepare a request by adding an authorization header if necessary.
     
     - parameters:
     - request: The request to modify.
     - target: The target of the request.
     - returns: The modified `URLRequest`.
     */
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let authorizable = target as? AccessTokenAuthorizable, authorizable.shouldAuthorize == false {
            return request
        }
        
        var request = request
        request.addValue(authVal, forHTTPHeaderField: "Authorization")
        
        return request
    }

}
