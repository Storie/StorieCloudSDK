//
//  AppDelegate.swift
//  Demo
//
//  Created by Michael Gaylord on 2016/05/13.
//  Copyright © 2016 Storie. All rights reserved.
//

import UIKit
import distribute
import CocoaLumberjack
import SwiftyBeaver

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow? = {
        return UIWindow(frame: UIScreen.mainScreen().bounds)
    }()
    
    private var distributor: Distributor?
    
    final func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        defaultDebugLevel = .Debug
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDTTYLogger.sharedInstance().colorsEnabled = true
        
        DDLogInfo("Application did finish launching")
        
        self.distributor = try? Distributor(apiKey: "uwa3jintauwui8f4zd27gr9q2595r2")
        distributor?.initializeUploads()

        let viewController = ViewController(distributor: distributor!)
        window?.rootViewController = viewController
        
        window?.backgroundColor = UIColor.whiteColor()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    final func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: Void->()) {
        DDLogInfo("**************** Application did receive receive events about background URL session: \(identifier) ****************")
        
        if application.applicationState == UIApplicationState.Active {
            DDLogInfo("Application is in the foreground, so ignore.")
            return
        }
        distributor?.handleEventsForBackgroundSession(identifier, completionHandler: completionHandler)
    }
}

