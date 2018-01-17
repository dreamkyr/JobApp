//
//  NotificationEndPoint.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 08/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Moya


let NotificationsProvider = MoyaProvider<Notifications>(plugins: [
    NetworkLoggerPlugin(verbose: true),
    AppAccessTokenPlugin()
    ])

public enum Notifications {
    case notificationRead(type: Int)
    case notificationGet
}

extension Notifications: TargetType {
    
    public var baseURL: URL { return URL(string: "http://\(Constant.SERVER_ADDR):8080")! }
    
    public var path: String {
        switch self {
        case .notificationRead(_):
            return "/job_admin/api/notification/read"
        case .notificationGet:
            return "/job_admin/api/notification/get"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .notificationRead(_):
            return .post
        case .notificationGet:
            return .post

        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .notificationRead(let type):
            return ["type": type]
        default:
            return nil
        }
    }
    
    
    public var sampleData: Data {
        switch self {
        case .notificationRead:
            return "{\"code\":200,\"message\":\"Success\"}".data(using: .utf8)!
        case .notificationGet:
            return "{\"code\":200,\"data\":[]}".data(using: .utf8)!

        }
    }
    
    public var task: Task {
        return .request
    }
    public var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    
}




