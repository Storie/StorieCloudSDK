//
//  AppDelegate.swift
//  Demo
//
//  Created by Michael Gaylord on 2016/05/13.
//  Copyright © 2016 Storie. All rights reserved.
//

import UIKit
import distribute

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow? = {
        return UIWindow(frame: UIScreen.mainScreen().bounds)
    }()
    
    private var distributor: Distributor?
    
    final func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        print("Application did finish launching")
        
        //TODO: ADD YOUR API KEY TO THIS LINE
        self.distributor = try? Distributor(apiKey: "")
        distributor?.initializeUploads()

        let viewController = ViewController(distributor: distributor!)
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
        distributor?.handleEventsForBackgroundSession(identifier, completionHandler: completionHandler)
    }
}

