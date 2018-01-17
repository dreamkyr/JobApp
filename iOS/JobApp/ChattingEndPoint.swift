//
//  ChattingEndPoint.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 09/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Moya

let ChattingProvider = MoyaProvider<Chatting>(plugins: [
    NetworkLoggerPlugin(verbose: true),
    AppAccessTokenPlugin()
    ])

public enum Chatting {
    case chattingGet(user_id: Int)
}

extension Chatting: TargetType {
    
    public var baseURL: URL { return URL(string: "http://\(Constant.SERVER_ADDR):8080")! }
    
    public var path: String {
        switch self {
        case .chattingGet(_):
            return "/job_admin/api/chatting/get"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .chattingGet(_):
            return .post
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .chattingGet(let user_id):
            return ["user_id": user_id]
        }
    }
    
    
    public var sampleData: Data {
        switch self {
        case .chattingGet:
            return "{\"code\":200,\"data\":[{\"_id\":0,\"send_date\":\"2017-07-10T01:53:19.654Z\",\"sender\":11,\"content\":\"Hi. Are you interested my project?\\n please reply.\",\"reciever\":1,\"isRead\":false,\"type\":\"text\",\"__v\":0},{\"_id\":1,\"send_date\":\"2017-07-10T01:54:22.225Z\",\"sender\":11,\"content\":\"Hi. Are you interested my project?\\n please reply.\",\"reciever\":1,\"isRead\":false,\"type\":\"text\",\"__v\":0}]}".data(using: .utf8)!
        }
    }
    
    public var task: Task {
        return .request
    }
    public var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    
}
