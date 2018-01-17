//
//  ChatListEndPoint.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 08/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Moya

let ChatlistProvider = MoyaProvider<Chatlist>(plugins: [
    NetworkLoggerPlugin(verbose: true),
    AppAccessTokenPlugin()
    ])

public enum Chatlist {
    case chatlistAdd(linked_users: [Int])
    case chatlistGet
    case chatlistRemove(delete_ids: [Int])
}

extension Chatlist: TargetType {
    
    public var baseURL: URL { return URL(string: "http://\(Constant.SERVER_ADDR):8080")! }
    
    public var path: String {
        switch self {
        case .chatlistAdd(_):
            return "/job_admin/api/chatlist/add"
        case .chatlistGet:
            return "/job_admin/api/chatlist/get"
        case .chatlistRemove(_):
            return "/job_admin/api/chatlist/remove"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .chatlistAdd(_):
            return .post
        case .chatlistGet:
            return .post
        case .chatlistRemove(_):
            return .post
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .chatlistAdd(let linked_users):
            return ["linked_users": linked_users]
        case .chatlistRemove(let delete_ids):
            return ["delete_ids": delete_ids]
        default:
            return nil
        }
    }
    
    
    public var sampleData: Data {
        switch self {
        case .chatlistAdd:
            return "{\"code\":200,\"data\":[{\"_id\":16,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:43\",\"last_message\":\"\",\"__v\":0},{\"_id\":17,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:43\",\"last_message\":\"\",\"__v\":0},{\"_id\":12,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":13,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":15,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":14,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":6,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":7,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":9,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":8,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":11,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":10,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":4,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:40\",\"last_message\":\"\",\"__v\":0},{\"_id\":5,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:40\",\"last_message\":\"\",\"__v\":0},{\"_id\":2,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:35\",\"last_message\":\"\",\"__v\":0},{\"_id\":3,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:35\",\"last_message\":\"\",\"__v\":0},{\"_id\":0,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:29\",\"last_message\":\"\",\"__v\":0},{\"_id\":1,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:29\",\"last_message\":\"\",\"__v\":0}]}".data(using: .utf8)!
        case .chatlistGet:
            return "{\"code\":200,\"data\":[{\"_id\":16,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:43\",\"last_message\":\"\",\"__v\":0},{\"_id\":17,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:43\",\"last_message\":\"\",\"__v\":0},{\"_id\":12,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":13,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":15,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":14,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":6,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":7,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":9,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":8,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":11,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":10,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:42\",\"last_message\":\"\",\"__v\":0},{\"_id\":4,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:40\",\"last_message\":\"\",\"__v\":0},{\"_id\":3,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:35\",\"last_message\":\"\",\"__v\":0},{\"_id\":0,\"user_id\":0,\"linked_user\":{\"_id\":2,\"verified\":false,\"updated_date\":\"2017-07-07T21:52:25.870Z\",\"created_date\":\"2017-07-07T21:52:25.870Z\",\"email\":\"juan4108@hotmail.com\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:29\",\"last_message\":\"\",\"__v\":0},{\"_id\":1,\"user_id\":0,\"linked_user\":{\"_id\":5,\"verified\":false,\"updated_date\":\"2017-07-07T21:58:20.901Z\",\"created_date\":\"2017-07-07T21:58:20.901Z\",\"email\":\"juan@ok.comt\",\"role_id\":2,\"skills\":[],\"orgnizations\":[],\"courses\":[],\"share\":false,\"__v\":0},\"last_time\":\"2017-07-08 07:29\",\"last_message\":\"\",\"__v\":0}]}".data(using: .utf8)!
        case .chatlistRemove:
            return "".data(using: .utf8)!
        }
    }
    
    public var task: Task {
        return .request
    }
    public var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    
}
