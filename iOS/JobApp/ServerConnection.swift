//
//  ServerConnection.swift
//  BayleafTakeaway
//
//  Created by Admin on 2017/05/12.
//  Copyright © 2017 BenzCruise. All rights reserved.
//


import Foundation
import MobileCoreServices


public class ServerConnection{
    
    public static var instance:ServerConnection = ServerConnection();
    public static func getInstance()->ServerConnection{
        return instance;
    }
    
    public func getRequest(url:String, params: [String: Any?], complete: @escaping ([String:Any])->Void ) -> Void {
        let parameterString = params.stringFromHttpParameters()
        let url = URL(string:"\(url)?\(parameterString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            print(response ?? "aaa");
            var responseData: [String: Any] = [:]
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                responseData["error"] = NSLocalizedString("Server connection error!", comment: "");
                complete(responseData)
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [[String: Any]] {
                responseData["code"] = 200;
                responseData["data"] = responseJSON;
                complete(responseData)
            }else{
                responseData["error"] = NSLocalizedString("Server connection error!", comment: "");
                complete(responseData)
            }
        }.resume()
    }
    
    public func postRequest(_ url:String, params: [String:Any], complete: @escaping ([String:Any])->Void ){
        let newParams = params;
        
        // if need token
//        if url == Constant.URL_LOGIN || url == Constant.URL_FB_LOGIN || url == Constant.URL_REGISTER{
//            newParams["token"] = self.getTokenID();
//        }
        
        //convert param into json data
        let jsonData = try? JSONSerialization.data(withJSONObject: newParams);
        
        // create post request
        let url = URL(string: url)!;
        var request = URLRequest(url: url);
        
        // make header data of request.
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        // insert json data to body data of request
        request.httpBody = jsonData
        
        // send request
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                complete(["error": NSLocalizedString("Server connection error!", comment: "")])
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                complete(responseJSON)
            }else{
                complete(["error": NSLocalizedString("Server connection error!", comment: "")])
            }
        }.resume()
    }
    
    public func postMultipartRequest(_ url: String, _ param: [String: String], _ filename: String,  _ imageData: Data, complete: @escaping ([String:Any])->Void)
    {
        
        let url = URL(string: url)!;
        let request = NSMutableURLRequest(url:url);
        request.httpMethod = "POST";
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "img", filename: filename, imageDataKey: imageData as NSData, boundary: boundary) as Data
        
        
        URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                complete(["error": NSLocalizedString("Server connection error!", comment: "")])
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                complete(responseJSON)
            }else{
                complete(["error": NSLocalizedString("Server connection error!", comment: "")])
            }
            }.resume()
        
        
    }
    
    
    private func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, filename: String, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        let mimetype = "image/jpg"
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    private func getTokenID()->String{
//        //return "JNJ127RUJ225JYM831KUM54";
//        let instanceId = FIRInstanceID.instanceID()
//        let token = instanceId.token()
//        if let token = token{
//            print(token)
//            return token
//        }
        return "No Token"
    }

}
