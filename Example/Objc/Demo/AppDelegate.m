//
//  AppDelegate.m
//  Demo
//
//  Created by Michael Gaylord on 2016/06/13.
//  Copyright © 2016 Storie. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@import distribute;

@interface AppDelegate ()

@property (nonatomic, strong) Distributor *distributor;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:true];
    
    DDLogInfo(@"Application did finishing launching.");
    
    NSError *error;
    
    //TODO: Add your API KEY to this function call below
    self.distributor = [[Distributor alloc] initWithApiKey:@"" error:&error];
    if (error) {
        DDLogError(@"%@ Unable to create distributor due to: %@", error.localizedDescription, error.localizedFailureReason);
    }
    
    [self.distributor initializeUploads];
    
    ViewController *viewController = [[ViewController alloc] initWithDistributor:self.distributor];
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
   completionHandler:(void (^)())completionHandler {
    
    DDLogInfo(@"Application did receive events about background URL session: %@", identifier);
    if (application.applicationState == UIApplicationStateActive) {
        DDLogInfo(@"Application is in the foreground so ignore.");
        return;
    }
    [self.distributor handleEventsForBackgroundSession:identifier completionHandler:completionHandler];
}

@end
