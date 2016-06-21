//
//  distribute.h
//  distribute
//
//  Created by Michael Gaylord on 2016/05/13.
//  Copyright © 2016 Storie. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for distribute.
FOUNDATION_EXPORT double distributeVersionNumber;

//! Project version string for distribute.
FOUNDATION_EXPORT const unsigned char distributeVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <distribute/PublicHeader.h>
NSString* const UploadNotificationUploadFailed = @"com.storie.UploadFailedNotification";
NSString* const UploadNotificationUploadInitializing = @"com.storie.UploadInitializingNotification";
NSString* const UploadNotificationUploadProgress = @"com.storie.UploadProgressNotification";
NSString* const UploadNotificationUploadAllComplete = @"com.storie.AllUploadsCompleteNotification";
NSString* const UploadNotificationUploadComplete = @"com.storie.UploadCompleteNotification";
NSString* const UploadNotificationUploadStarted = @"com.storie.UploadsStartedNotification";
NSString* const UploadNotificationUploadResumed = @"com.storie.UploadsResumedNotification";
NSString* const UploadNotificationUploadProgressKey = @"com.storie.UploadProgressNotificationKey";
NSString* const UploadNotificationUploadTotalProgressKey = @"com.storie.TotalUploadProgressNotificationKey";
NSString* const UploadNotificationUploadErrorKey = @"com.storie.UploadsNotificationErrorKey";
NSString* const UploadNotificationUploadObjectKey = @"com.storie.UploadsNotificationObjectKey";
NSString* const UploadNotificationUploadCompletedResultsKey = @"com.storie.UploadsCompletedResultsKey";
NSString* const UploadNotificationUploadUserInfoKey = @"com.storie.UploadUserInfoKey";