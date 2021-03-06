# Storie Cloud SDK

The Storie Cloud SDK provides a simple interface to interact with the Storie Cloud API. For more info and developer access to the Storie Cloud visit https://developer.storie.com

## Features of the Storie Cloud API

### **Stream Video**:

In order to play to large video files over the Internet, Apple *strongly recommends* using HTTP Live Streaming (HLS). Setting up a fully fledged HLS transcoding service is costly and time consuming. Storie's Cloud API is designed to simplify this process, including delivery of your video object to our cloud storage service, fully customizable adaptive bit-rate streaming and support for true resumeable background uploads. _Never buffer again_ with only a few lines of code.

### **Upload Video**:

We've developed a propietary transfer mechanism for mobile video and added it to our SDK. Uploads are resumed automatically, can run in the background and are guaranteed delivery.

### **Transform Video**:

Storie Cloud supports multiple transformation tools for your videos. We provide conversion to a high-performance, *adaptive-bitrate video stream* (HLS & MPEG-DASH), or *animated GIFs* or video manipulation, all from our developer console. Take control of your videos, ready for analysis, distribution and storage.

### **Analyze Video**:

Extract keywords, locations, text and trademarks. Recognize faces, emotions and demographics. StorieCloud provides a powerful and highly accurate set of video analysis tools. Use our safe search analysis tool to notify you of explicit content.

### **Distribute Video**:

Our flexible callback architecture is designed to deliver feedback to your own server infrastructure, ready to be distributed to your users over a high performance Content Delivery Network.

### **Store Video**:

Running a fully-redundant, cloud storage infrastructure for video is complex. Based on Google Cloud Storage, we've put together a combination of both low access latency and full redundancy, so that your data is both safe and fully accessible at any time, all at a very low cost.

We built this infrastucture for our own app in the AppStore and its worked out so well (tested on over 100 000 videos), we wanted to make it available to other developers too.

For more information on our Cloud Video API, visit https://developer.storie.com or to see it in action visit: https://itunes.apple.com/us/app/storie-video-storytelling/id950300668?mt=8

## Prerequisites

The SDK is fully compatible with both Objective-C and Swift 2.2 and requires a minimum deployment target of iOS SDK 8.0. Please contact us for access to builds for Swift 2.3 and 3.0.

You will also need an API key. We are still busy polishing our Developer Console, so email us at support@storie.com for your API key and setup instructions.

## Documentation

Storie Cloud API Documentation can be found at: https://storie-developers.readme.io/docs and SDK documentation can be found at: https://developer.storie.com/docs/ios/index.html

You can also view our example apps in both Swift and Objective-C in this project in the `/Example/` folder.

If you would like to try out any of the Example projects, you can use the Cocoapods command: `pod try StorieCloudSDK`

## Getting Started:

#### With Cocoapods:

To use [CocoaPods](https://cocoapods.org) just add this to your Podfile:

``` Ruby
pod 'StorieCloudSDK'
```

Then run `pod install`

## Setup

### Swift:

Add this near the top of your `AppDelegate.swift` to be able to use Storie's Cloud SDK

``` Swift
import StorieCloudSDK
```

Then add a property to your `AppDelegate.swift` to store your `StoriePlatform` object:

``` Swift
var storiePlatform: StoriePlatform?
```

To initialize the `storiePlatform` property add the following to the beginning of your `AppDelegate:didFinishLaunchingWithOptions()`. Contact us now for an API key at support@storie.com.

``` Swift
self.storiePlatform = try? StoriePlatform(apiKey: "{API_KEY}")
```
For more visit the <a href="https://developer.storie.com/docs/ios/Classes/StoriePlatform.html">StoriePlatform documentation</a>.

### Objective-C:

Add this near the top of your `AppDelegate.m` to be able to use Storie's Cloud SDK

``` Objective-C
@import StorieCloudSDK;
```

Then add a property to your `AppDelegate.m` to store your `StoriePlatform` object as a property:

``` Objective-C
@property (nonatomic, strong) StoriePlatform *storiePlatform;
```

To initialize the `storiePlatform` property add the following to the beginning of your `[AppDelegate didFinishLaunchingWithOptions:]`. You will need to get your API_KEY from the Storie API developer's console:

``` Objective-C
NSError *error;
self.storiePlatform = [[StoriePlatform alloc] initWithApiKey:@"{API_KEY}" error:&error];
```

For more visit the <a href="https://developer.storie.com/docs/ios/Classes/StoriePlatform.html">StoriePlatform documentation</a>.

## Usage:


### Uploading a video file:

The Storie SDK supports both Quicktime and MPEG-4 video files only. The following will start a new upload to the Storie API:

In Swift:

``` Swift
let videoFileURL = = NSURL(fileURLWithPath: "file://path_to_my_file/to_upload.mp4")
do {
    try storiePlatform.upload(videoFileURL, userInfo: ["localObjectID" : "12345566"],
                                     callbackData: ["serverObjectID" : "1233454"]
                                      serviceName: @"DEFAULT")
} catch let error {
    NSLog("Error uploading video at URL: \(fileURL) : \(error)")
}
```

In Objective-C:

``` Objective-C
NSError *error;
NSURL *videoFileURL = [NSURL fileURLWithPath:@"file://path_to_my_file/to_upload.mp4"];
[storiePlatform upload:videoFileURL
            userInfo:@{@"localObjectID" : @"12345677"}
        callbackData:@{@"serverObjectID" : @"12345677"}
        serviceName: @"DEFAULT"
        thumbnailTime:0.3
              onError:^(NSError *error){
            NSLog(@"Error initializing upload: %@", error);
        }  onUploadInitialized: ^{
            NSLog(@"Upload initialized successfully.");
        }];
```

### Tracking upload progress

There are two ways to inspect the progress of an upload. The first is by implement the `StoriePlatformDelegate` protocol and assigning it to your `StoriePlatform` instance.


For more information about the callbacks you will receive via the `StoriePlatformDelegate` visit: https://developer.storie.com/docs/ios/Protocols/StoriePlatformDelegate.html

The second way is by registering `NSNotification` observers on `UploadNotifications`. For the available constants visit: https://developer.storie.com/docs/ios/Structs/UploadNotifications.html


In Objective-C, you will need to import:

``` Objective-C
#import <StorieCloudSDK/ObjcConstants.h>
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
    try storiePlatform.videoInfo(videoID) { video in
        NSLog("Video found: \(video.videoID) - status: \(video.status?.rawValue)")
    }
} catch let error {
    NSLog("Error getting video: \(error)")
}
```

In Objective-C:

```Objective-C
NSError *error;
[storiePlatform getVideoInfo: text error:&error success:^(NSDictionary<NSString *,id> *result) {
    NSLog(@"Video found: %@", result);
}];
```

### Enabling Resumable Background Upload Functionality

If you would like to automatically resume any failed or stopped downloads on startup, add the following to your `didFinishLaunchingWithOptions()` method after creating the `StoriePlatform` instance:

In Swift:

``` Swift
storiePlatform?.initializeUploads()
```

In Objective-C:

``` Objective-C
[self.storiePlatform initializeUploads];
```

Lastly, in order to manage your apps background upload sessions correctly you will need to implement the application delegate method: `application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: Void->())` So that it looks like this:

In Swift:

``` Swift
final func application(application: UIApplication,
  handleEventsForBackgroundURLSession identifier: String,
  completionHandler: Void->()) {
    if application.applicationState == UIApplicationState.Active { return }
    storiePlatform?.handleEventsForBackgroundSession(identifier, completionHandler: completionHandler)
}
```

In Objective-C:

``` Objective-C
- (void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
   completionHandler:(void (^)())completionHandler {
    if (application.applicationState == UIApplicationStateActive) { return;}
    [self.storiePlatform handleEventsForBackgroundSession:identifier completionHandler:completionHandler];
}
```

Then enable *Background Modes* in your Target's list of Capabilities and make sure *Background Fetch* is selected.

<img width="681" alt="capabilities-configuration" src="https://cloud.githubusercontent.com/assets/157073/15670541/5ebc9dee-2726-11e6-9777-6cb5857a8be7.png">

Run your app and ensure everything is working correctly by test uploading a file.

Note: About background uploads. While debugging an app, the app is never backgrounded, even if you switch to another app or return to the home screen. The only reliable way to test background uploading is to run the app detached from the debugger.