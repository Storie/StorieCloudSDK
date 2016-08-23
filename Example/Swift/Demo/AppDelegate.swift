//
//  AppDelegate.swift
//  Demo
//
//  Created by Michael Gaylord on 2016/05/13.
//  Copyright © 2016 Storie. All rights reserved.
//

import UIKit
import StorieCloudSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow? = {
        return UIWindow(frame: UIScreen.mainScreen().bounds)
    }()
    
    private var storiePlatform: StoriePlatform?
    
    final func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        print("Application did finish launching")
        
        //TODO: ADD YOUR API KEY TO THIS LINE
        self.storiePlatform = try? StoriePlatform(apiKey: "1dh0ocknt47yd2jjtc0aux5u8dexao")
        storiePlatform?.initializeUploads()

        let viewController = ViewController(storiePlatform: storiePlatform!)
        window?.rootViewController = viewController
        
        window?.backgroundColor = UIColor.whiteColor()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    final func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: Void->()) {
        if application.applicationState == UIApplicationState.Active {
            print("Application is in the foreground, so ignore.")
            return
        }
        storiePlatform?.handleEventsForBackgroundSession(identifier, completionHandler: completionHandler)
    }
}

