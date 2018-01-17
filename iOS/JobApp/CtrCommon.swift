//
//  CtrCommon.swift
//  shot_doctor
//
//  Created by Admin on 2017/05/06.
//  Copyright © 2017 BenzCruise. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import AVFoundation

public class CtrCommon{
    public static var  alertController: UIAlertController = UIAlertController();
    public static var isAnimate: Bool = false;
    public static let soundDirPath:String = "/System/Library/Audio/UISounds/Modern/"
    public static var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    // indicator process.
    public static func startRunProcess(viewController: UIViewController, completion: @escaping ()->Void){
        DispatchQueue.main.async {
            if !isAnimate{
                isAnimate = true;
                alertController = UIAlertController(title: nil, message: "Please wait\n\n", preferredStyle: .alert);
                let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
                spinnerIndicator.color = UIColor.black
                spinnerIndicator.startAnimating()
                alertController.view.addSubview(spinnerIndicator)
                viewController.present(alertController, animated: false, completion: {
                    completion();
                })
            }
        }
    }
    
    public static func stopRunProcess(){
        
        DispatchQueue.main.async {
            print("dismiss");
            alertController.dismiss(animated: true, completion: {
                alertController = UIAlertController();
                isAnimate = false;
            });
        }
    }

    
    public static func playNotiSound(){
        var notiBellName:String = ""
        if UserDefaults.standard.object(forKey: "notibellname") == nil{
            notiBellName = "airdrop_invite"
        }else{
            notiBellName = UserDefaults.standard.object(forKey: "notibellname") as! String;
        }
        let fileURL: URL = URL(fileURLWithPath: "\(CtrCommon.soundDirPath)\(notiBellName).caf")
        print(fileURL)
        do {
            CtrCommon.audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            CtrCommon.audioPlayer.play()
        } catch {
            debugPrint("\(error)")
        }
        
    }
    
    public static func isInputComplete(_ inputArray: [String:String]) -> String!{
        let keys = Array(inputArray.keys);
        for i in 0 ..< keys.count {
            let key = keys[i] as String;
            if inputArray[key] == ""{
                return keys[i]
            }
        }
        return nil;
    }
    
    public static func isExistNil(_ array: [String: Any?])->String{
        for (key, value) in array{
            if value is NSNull && key != "load_date"{
                return key;
            }
        }
        return "";
    }
    
    public static func filterNull(value: Any?)->String!{
        if value is NSNull || value == nil{
            return nil;
        }
        return value as! String;
    }
    
    public static func convertNiltoEmpty(string: String!, defaultstr: String)->String{
        if string == nil{
            return defaultstr;
        }
        return string;
    }
    
    
}
