//
//  AppDelegate.m
//  Demo
//
//  Created by Michael Gaylord on 2016/06/13.
//  Copyright © 2016 Storie. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@import StorieCloudSDK;

@interface AppDelegate ()

@property (nonatomic, strong) StoriePlatform *storiePlatform;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSLog(@"Application did finishing launching.");
    
    NSError *error;
    
    //TODO: Add your API KEY to this function call below
    self.storiePlatform = [[StoriePlatform alloc] initWithApiKey:@"" error:&error];
    if (error) {
        NSLog(@"%@ Unable to create distributor due to: %@", error.localizedDescription, error.localizedFailureReason);
    }
    
    [self.storiePlatform initializeUploads];
    
    ViewController *viewController = [[ViewController alloc] initWithStoriePlatform:self.storiePlatform];
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
   completionHandler:(void (^)())completionHandler {

    if (application.applicationState == UIApplicationStateActive) {
        return;
    }
    [self.storiePlatform handleEventsForBackgroundSession:identifier completionHandler:completionHandler];
}

@end
