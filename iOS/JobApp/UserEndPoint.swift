//
//  UserEnpoint.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 07/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Moya

    let UserProvider = MoyaProvider<User>(plugins: [
        NetworkLoggerPlugin(verbose: true),
        AppAccessTokenPlugin()
        ])

public enum User {
    case login(email: String, password: String, phone_contacts: [[String: Any]])
    case signUp(email: String, password: String)
    case verification
    case verifyConfirm(code: Int)
    case facebookLogin(access_token: String, phone_contacts: [[String: Any]])
    case me(phone_contacts: [[String: Any]])
    case updateWithPhoto(image: Data, fields: Data)
    }

extension User: AccessTokenAuthorizable {
    public var shouldAuthorize: Bool {
        switch self{
        case .login,.signUp,.facebookLogin:
            return false
        default:
            return true
        }
    }
}

extension User: TargetType {
    
    public var baseURL: URL { return URL(string: "http://\(Constant.SERVER_ADDR):8080")! }
    
    public var path: String {
        switch self {
        case .login(_, _, _):
            return "/job_admin/api/user/login"
        case .signUp(_, _):
            return "/job_admin/api/user/signup"
        case .verification:
            return "/job_admin/api/verification"
        case .verifyConfirm(_):
            return "/job_admin/api/user/verifyconfirm"
        case .facebookLogin(_,_):
            return "/job_admin/api/user/auth/facebook"
        case .me:
            return "/job_admin/api/user/me"
        case .updateWithPhoto:
            return "/job_admin/api/user/updatewithphoto"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .login:
            return .post
        case .signUp(_, _):
            return .post
        case .verification:
            return .post
        case .verifyConfirm(_):
            return .post
        case .facebookLogin(_):
            return .post
        case .me:
            return .post
        case .updateWithPhoto:
            return .post
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .login(let email, let password, let phone_contacts):
            return ["email": email, "password": password, "phone_contacts": phone_contacts]
        case .signUp(let email, let password):
            return ["email": email, "password": password]
        case .verifyConfirm(let code):
            return ["code": code]
        case .facebookLogin(let access_token, let phone_contacts):
            return ["access_token": access_token, "phone_contacts": phone_contacts]
        case .me(let phone_contacts):
            return ["phone_contacts": phone_contacts]
        default:
            return nil
        }
    }
    
    
    public var sampleData: Data {
        switch self {
        case .login:
            return "{\"code\":200,\"data\":{\"profile\":{\"_id\":0,\"verified\":false,\"email\":\"juan4106@hotmail.com\",\"role_id\":2,\"skills\":[],\"courses\":[],\"share\":false},\"skills\":[],\"contacts\":[],\"chatlists\":[],\"token\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOjAsInZlcmlmaWVkIjpmYWxzZSwiZW1haWwiOiJqdWFuNDEwNkBob3RtYWlsLmNvbSIsInJvbGVfaWQiOjIsInNoYXJlIjpmYWxzZSwiaWF0IjoxNDk5NDA4NTY0LCJleHAiOjE0OTk5MzQxNjR9.1In730AjslgEoh-I05i_X6KBr_zNiiuCexQGJ58q9Fk\"}}".data(using: .utf8)!
        case .signUp:
            return "{\"code\":200,\"data\":{\"profile\":{\"_id\":0,\"verified\":false,\"email\":\"juan4106@hotmail.com\",\"role_id\":2,\"skills\":[],\"courses\":[],\"share\":false},\"skills\":[],\"contacts\":[],\"chatlists\":[],\"token\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOjAsInZlcmlmaWVkIjpmYWxzZSwiZW1haWwiOiJqdWFuNDEwNkBob3RtYWlsLmNvbSIsInJvbGVfaWQiOjIsInNoYXJlIjpmYWxzZSwiaWF0IjoxNDk5NDA4NTU4LCJleHAiOjE0OTk5MzQxNTh9.kMk8dPsPuJsTR05Tcmz7TKr_lPkCXTThpSK2GWqZXq0\"}}".data(using: .utf8)!
        case .verification:
            return "{\"code\":200,\"message\":\"Verification mail sent successfully.\"}".data(using: .utf8)!
        case .verifyConfirm:
            return "{\"code\":200,\"message\":\"Your account verified successfully.\"}".data(using: .utf8)!
        case .facebookLogin:
            return "{\"code\":200,\"data\":{\"profile\":{\"_id\":11,\"verified\":true,\"email\":\"juan4105@hotmail.com\",\"role_id\":2,\"skills\":[],\"courses\":[],\"share\":false},\"skills\":[],\"contacts\":[],\"chatlists\":[],\"token\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOjExLCJ2ZXJpZmllZCI6dHJ1ZSwiZW1haWwiOiJqdWFuNDEwNUBob3RtYWlsLmNvbSIsInJvbGVfaWQiOjIsInNoYXJlIjpmYWxzZSwiaWF0IjoxNDk5NDkzNjcyLCJleHAiOjE1MDAwMTkyNzJ9.uzoTx0_eD3s4PvptiAVTtlWfCrimk95lrIxVQFAuKXg\"}}".data(using: .utf8)!
        case .me:
            return "{\"code\":200,\"data\":{\"profile\":{\"_id\":0,\"verified\":true,\"email\":\"juan4106@hotmail.com\",\"role_id\":2,\"skills\":[],\"courses\":[],\"share\":false},\"skills\":[],\"contacts\":[],\"chatlists\":[],\"token\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOjAsInZlcmlmaWVkIjp0cnVlLCJlbWFpbCI6Imp1YW40MTA2QGhvdG1haWwuY29tIiwicm9sZV9pZCI6Miwic2hhcmUiOmZhbHNlLCJpYXQiOjE0OTk0OTY4NTcsImV4cCI6MTUwMDAyMjQ1N30.nDGI1Ah1uKewj4_JTkWf4rngKmr14Mf3_kSmrHgFWYE\"}}".data(using: .utf8)!
        case .updateWithPhoto:
            return "{\"code\":200,\"data\":\"http://localhost:8080/uploads/profile/11-1499549147368.jpeg\",\"message\":\"Successfully updated.\"}".data(using: .utf8)!
        }
    }
    
    public var task: Task {
        switch self{
        case .updateWithPhoto(let image,  let fields):
            return .upload(.multipart([MultipartFormData(provider: .data(fields), name: "fields"),MultipartFormData(provider: .data(image), name:"photo", fileName: "profilePhoto", mimeType: "image/jpg")]))
        default:
            return .request
        }
        
    }
    public var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    
}






