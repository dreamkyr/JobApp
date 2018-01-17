//
//  AppDelegate.swift
//  JobApp
//
//  Created by Admin on 5/20/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Toaster
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        // Override point for customization after application launch.
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)){
            statusBar.backgroundColor = UIColor.clear
        }
        UIApplication.shared.statusBarStyle = .default
        
        
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasRunBefore") == false {
            // Remove Keychain token here
            
            SharedKeycard.removeToken();
            
            // Update the flag indicator
            userDefaults.set(true, forKey: "hasRunBefore")
            userDefaults.synchronize() // Forces the app to update UserDefaults
        }

        
        
       // if UserDefaults.standard.object(forKey: "useremail") != nil{
        if SharedKeycard.token != "" {
            
            if SharedKeycard.verified {
                let storyboard = UIStoryboard(name: "Root", bundle: nil)
                let initialViewController: RootTabViewController = storyboard.instantiateViewController(withIdentifier: Constant.ROOT_TAB_VC) as! RootTabViewController
                initialViewController.flag = true;
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
            else {
                
                let storyboard = UIStoryboard(name: "Verification", bundle: nil)
                let initialViewController: VerificationViewController = storyboard.instantiateViewController(withIdentifier: Constant.VERIFICATION_VC) as! VerificationViewController
                //initialViewController.flag = true;
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            
            }
            
            

        }
        
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return SDKApplicationDelegate.shared.application(application,
                                                         open: url,
                                                         sourceApplication: sourceApplication,
                                                         annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return SDKApplicationDelegate.shared.application(application, open: url, options: options)
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEventsLogger.activate(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

