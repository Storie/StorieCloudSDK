# Storie Distribution SDK

The Storie Distribution SDK provides a simple interface to interact with the Storie Cloud Video Processing API. In order to play to large video files over the Internet, Apple *strongly recommends* using HTTP Live Streaming (HLS). Setting up a fully fledged HLS transcoding service is costly and time consuming. Storie's Cloud API is designed to simplify this process, including delivery of your video object to our cloud storage service, fully customizable adaptive bit-rate streaming and support for true resumeable background uploads. _Never buffer again_ with only a few lines of code.

## Features

* **Simple:** The SDK is designed to be as simple as possible to integrate in your development infrastructure.
* **Mobile-focussed:** Designed from the ground up to be deployed in a mobile environment.
* **Scalable:** Our cloud processing API is designed to scale horizontally.
* **Flexible:** Our API is based on a flexible service architecture made up of processing tasks.

We built this infrastucture for our own app in the AppStore and its worked out so well (tested on over 100 000 videos), we wanted to make it available to other developers too.

For more information on our Cloud Video API, visit http://api.storie.com or to see it in action visit: http://www.storie.com

## Prerequisites

The SDK is fully compatible with both Objective-C and Swift 2.2 and requires a minimum deployment target of iOS SDK 8.0. Please contact us for access to builds for Swift 2.3 and 3.0.

You will also need an API key. We are still busy polishing our Developer Console, so email us at support@storie.com for your API key and setup instructions.

## Documentation

Full SDK documentation can be found here: http://api.storie.com/docs/ios-sdk/index.html

You can also view our example apps in both Swift and Objective-C in this project in the `/Example/` folder.

## Getting Started:

#### With Cocoapods:

To use [CocoaPods](https://cocoapods.org) just add this to your Podfile:

``` Ruby
pod "distribute"
```

Then run `pod install`

## Setup

### Swift:

Add this near the top of your `AppDelegate.swift` to be able to use Storie's Distribute SDK

``` Swift
import distribute
```

Then add a property to your `AppDelegate.swift` to store your `Distributor` object:

``` Swift
var distributor: Distributor?
```

To initialize the `distributor` property add the following to the beginning of your `AppDelegate:didFinishLaunchingWithOptions()`. Contact us now for an API key at support@storie.com.

``` Swift
self.distributor = try? Distributor(apiKey: "{API_KEY}")
```
For more visit the <a href="http://api.storie.com/docs/ios-sdk/Classes/Distributor.html">Distributor documentation</a>.

### Objective-C:

Add this near the top of your `AppDelegate.m` to be able to use Storie's Distribute SDK

``` Objective-C
@import distribute;
```

Then add a property to your `AppDelegate.m` to store your `Distributor` object as a property:

``` Objective-C
@property (nonatomic, strong) Distributor *distributor;
```

To initialize the `distributor` property add the following to the beginning of your `[AppDelegate didFinishLaunchingWithOptions:]`. You will need to get your API_KEY from the Storie API developer's console:

``` Objective-C
NSError *error;
self.distributor = [[Distributor alloc] initWithApiKey:@"{API_KEY}" error:&error];
```

For more visit the <a href="http://api.storie.com/docs/ios-sdk/Classes/Distributor.html">Distributor documentation</a>.

## Usage:


### Uploading a video file:

The Storie SDK supports both Quicktime and MPEG-4 video files. The following will start a new upload to the Storie API:

In Swift:

``` Swift
let videoFileURL = = NSURL(fileURLWithPath: "file://path_to_my_file/to_upload.mp4")
do {
    try distributor.upload(videoFileURL, userInfo: ["localObjectID" : "12345566"],
                                      callbackData: ["serverObjectID" : "1233454"])
} catch let error {
    NSLog("Error uploading video at URL: \(fileURL) : \(error)")
}
```

In Objective-C:

``` Objective-C
NSError *error;
NSURL *videoFileURL = [NSURL fileURLWithPath:@"file://path_to_my_file/to_upload.mp4"];
[distributor upload:videoFileURL
            userInfo:@{@"localObjectID" : @"12345677"}
        callbackData:@{@"serverObjectID" : @"12345677"}
        pipelineName: @"DEFAULT"
        thumbnailTime:0.3
               error:&error];
```

### Tracking upload progress

There are two ways to inspect the progress of an upload. The first is by implement the `DistributorDelegate` protocol and assigning it to your `Distributor` instance.


For more information about the callbacks you will receive via the `DistributorDelegate` visit: http://api.storie.com/docs/ios-sdk/Protocols/DistributorDelegate.html

The second way is by registering `NSNotification` observers on `UploadNotifications`. For the available constants visit: http://api.storie.com/docs/ios-sdk/Structs/UploadNotifications.html


In Objective-C, you will need to import:

``` Objective-C
#import <distribute/ObjcConstants.h>
```

You will then have access to the following notification names and constants, they are identical in functionality to those specified in the `UploadNotifications` struct in Swift:

``` Objective-C
extern NSString* const UploadNotificationUploadFailed;
extern NSString* const UploadNotificationUploadInitializing;
extern NSString* const UploadNotificationUploadProgress;
extern NSString* const UploadNotificationUploadAllComplete;
extern NSString* const UploadNotificationUploadComplete;
extern NSString* const UploadNotificationUploadStarted;
extern NSString* const UploadNotificationUploadResumed;
extern NSString* const UploadNotificationUploadProgressKey;
extern NSString* const UploadNotificationUploadTotalProgressKey;
extern NSString* const UploadNotificationUploadErrorKey;
extern NSString* const UploadNotificationUploadObjectKey;
extern NSString* const UploadNotificationUploadCompletedResultsKey;
extern NSString* const UploadNotificationUploadUserInfoKey;
```

### Retrieving video file info:

If you would like to investigate the properties of a video you have already uploaded, including its current status you can use the `videoInfo` function.

In Swift:

```Swift
do {
    try distributor.videoInfo(videoID) { video in
        NSLog("Video found: \(video.videoID) - status: \(video.status?.rawValue)")
    }
} catch let error {
    NSLog("Error getting video: \(error)")
}
```

In Objective-C:

```Objective-C
NSError *error;
[distributor getVideoInfo: text error:&error success:^(NSDictionary<NSString *,id> *result) {
    NSLog(@"Video found: %@", result);
}];
```

### Enabling Resumable Background Upload Functionality

If you would like to automatically resume any failed or stopped downloads on startup, add the following to your `didFinishLaunchingWithOptions()` method after creating your distributor:

In Swift:

``` Swift
distributor?.initializeUploads()
```

In Objective-C:

``` Objective-C
[self.distributor initializeUploads];
```

Lastly, in order to manage your apps background upload sessions correctly you will need to implement the application delegate method: `application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: Void->())` So that it looks like this:

In Swift:

``` Swift
final func application(application: UIApplication,
  handleEventsForBackgroundURLSession identifier: String,
  completionHandler: Void->()) {
    if application.applicationState == UIApplicationState.Active { return }
    distributor?.handleEventsForBackgroundSession(identifier, completionHandler: completionHandler)
}
```

In Objective-C:

``` Objective-C
- (void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
   completionHandler:(void (^)())completionHandler {
    if (application.applicationState == UIApplicationStateActive) { return;}
    [self.distributor handleEventsForBackgroundSession:identifier completionHandler:completionHandler];
}
```

Then enable *Background Modes* in your Target's list of Capabilities and make sure *Background Fetch* is selected.

<img width="681" alt="capabilities-configuration" src="https://cloud.githubusercontent.com/assets/157073/15670541/5ebc9dee-2726-11e6-9777-6cb5857a8be7.png">

Run your app and ensure everything is working correctly by test uploading a file.

Note: About background uploads. While debugging an app, the app is never backgrounded, even if you switch to another app or return to the home screen. The only reliable way to test background uploading is to run the app detached from the debugger.
