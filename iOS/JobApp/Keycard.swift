//
//  Keycard.swift
//  JobApp
//
//  Created by Juan Manuel Campos Olvera on 07/07/17.
//  Copyright © 2017 Admin. All rights reserved.
//
import Foundation
import KeychainSwift

let keychain = KeychainSwift()

func lookForTokenInKeychain() -> String? { return keychain.get("token") ?? "" }


public class Keycard : NSObject {
    public var token: String {
        get {
            return lookForTokenInKeychain()!
        }
        
        set(val) {
            keychain.set(val, forKey: "token")
        }
    
    }
    
    public var verified: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasVerified")
        }
        
        set(val){
            UserDefaults.standard.set(val, forKey: "hasVerified")
            UserDefaults.standard.synchronize()
        }
    
    }
    
    public func removeToken(){
        self.token = "";
        UserDefaults.standard.set(true, forKey: "shownoti_flag")
    }
    
    public override init() {
        super.init()
        
        //token = lookForTokenInKeychain()
    }
}

public let SharedKeycard = Keycard()
