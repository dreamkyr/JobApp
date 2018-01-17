//
//  JobEndPoint.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 10/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Moya

let JobsProvider = MoyaProvider<Jobs>(plugins: [
    NetworkLoggerPlugin(verbose: true),
    AppAccessTokenPlugin()
    ])

public enum Jobs {
    case jobProposeResume(job_id:Data, resume:Data?, filename: String?, type: String?)
}

extension Jobs: TargetType {
    
    public var baseURL: URL { return URL(string: "http://\(Constant.SERVER_ADDR):8080")! }
    
    public var path: String {
        switch self {
        case .jobProposeResume:
            return "/job_admin/api/job/addproposeresume"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .jobProposeResume:
            return .post
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        default:
            return nil
        }
    }
    
    
    public var sampleData: Data {
        switch self {
        case .jobProposeResume:
            return "{\"code\":200,\"message\":\"Successfully proposed.\"}".data(using: .utf8)!
        }
    }
    
    public var task: Task {
        switch self{
        case .jobProposeResume(let job_id,  let resume, let filename, let type):
            
            var multi = [MultipartFormData(provider: .data(job_id), name: "job_id")]
           
            if let cv = resume, let fn = filename, let tp = type {
                multi.append(MultipartFormData(provider: .data(cv), name:"resume", fileName: fn , mimeType: tp))
            }
        
            
            return .upload(.multipart(multi))
        default:
            return .request
        }
        
    }
    public var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    
}
