//
//  ViewController.m
//  Demo
//
//  Created by Michael Gaylord on 2016/06/13.
//  Copyright © 2016 Storie. All rights reserved.
//

#import "ViewController.h"

@import MobileCoreServices;
@import AVKit;
@import distribute;
@import AVFoundation;

@interface ViewController () <DistributorDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) Distributor *distributor;

@property (nonatomic, strong) UIButton *chooseVideoButton;
@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UITextView *logView;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *cancelAllButton;
@property (nonatomic, strong) UIButton *getVideoInfoButton;

@property (nonnull, strong) NSMutableDictionary *waitingTimers;

@end

@implementation ViewController

- (instancetype) initWithDistributor: (Distributor *) distributor {
    self = [self init];
    if (self) {
        self.distributor = distributor;
        self.waitingTimers = [[NSMutableDictionary alloc] init];
        self.distributor.delegate = self;
        [self initializeViews];
    }
    return self;
}

- (void) initializeViews {
    self.chooseVideoButton = [UIButton new];
    self.progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressLabel = [UILabel new];
    self.logView = [UITextView new];
    self.pauseButton = [UIButton new];
    self.cancelAllButton = [UIButton new];
    self.getVideoInfoButton = [UIButton new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [_chooseVideoButton addTarget:self action:@selector(chooseVideo) forControlEvents:UIControlEventTouchUpInside];
    [_cancelAllButton addTarget:self action:@selector(cancelAll) forControlEvents:UIControlEventTouchUpInside];
    [_pauseButton addTarget:self action:@selector(togglePause) forControlEvents:UIControlEventTouchUpInside];
    [_getVideoInfoButton addTarget:self action:@selector(requestVideoID) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_chooseVideoButton];
    [self.view addSubview:_progressBar];
    [self.view addSubview:_progressLabel];
    [self.view addSubview:_logView];
    [self.view addSubview:_pauseButton];
    [self.view addSubview:_cancelAllButton];
    [self.view addSubview:_getVideoInfoButton];
    
    [_logView setBackgroundColor:[UIColor lightGrayColor]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_chooseVideoButton setTitle:@"Choose video" forState:UIControlStateNormal];
    [_chooseVideoButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_chooseVideoButton sizeToFit];
    
    _progressLabel.text = @"0%";
    _progressLabel.textColor = [UIColor blackColor];
    [_progressLabel sizeToFit];
    
    _progressBar.progressTintColor = [UIColor blueColor];
    _progressBar.trackTintColor = [UIColor lightGrayColor];
    
    NSString *title = _distributor.uploadsSuspended ? @"Resume" : @"Pause";
    [_pauseButton setTitle:title forState:UIControlStateNormal];
    [_pauseButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [_cancelAllButton setTitle:@"Cancel All" forState:UIControlStateNormal];
    [_cancelAllButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [_getVideoInfoButton setTitle:@"Play Video" forState:UIControlStateNormal];
    [_getVideoInfoButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_progressLabel sizeToFit];
    [_pauseButton sizeToFit];
    [_cancelAllButton sizeToFit];
    [_getVideoInfoButton sizeToFit];
    
    _chooseVideoButton.center = CGPointMake(CGRectGetMidX(self.view.bounds), 50);
    
    _progressBar.frame = CGRectMake(0, 0, self.view.frame.size.width - 50, 10);
    _progressBar.center = CGPointMake(_chooseVideoButton.center.x, CGRectGetMaxY(_chooseVideoButton.frame) + CGRectGetHeight(_progressBar.bounds) + 20);
    _progressLabel.center = CGPointMake(_chooseVideoButton.center.x, CGRectGetMaxY(_progressBar.frame) + CGRectGetHeight(_progressLabel.bounds) + 20);
    
    _pauseButton.frame = CGRectMake(20, CGRectGetMaxY(_progressLabel.frame) + 10, _pauseButton.bounds.size.width, _pauseButton.bounds.size.height);
    _cancelAllButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - CGRectGetWidth(_cancelAllButton.bounds) - 20,
                                        CGRectGetMinY(_pauseButton.frame), CGRectGetWidth(_cancelAllButton.bounds),
                                        CGRectGetHeight(_cancelAllButton.bounds));
    
    _logView.frame = CGRectMake(10, CGRectGetMaxY(_pauseButton.frame),
                                CGRectGetWidth(self.view.bounds) - 20,
                                CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(_pauseButton.frame) - 40 - CGRectGetHeight(_getVideoInfoButton.bounds));
    
    _getVideoInfoButton.frame = CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(_getVideoInfoButton.bounds),
                                                       CGRectGetMaxY(_logView.frame) + 20,
                                           CGRectGetWidth(_getVideoInfoButton.bounds), CGRectGetHeight(_getVideoInfoButton.bounds));
}

#pragma mark Actions

- (void) chooseVideo {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.allowsEditing = true;
    pickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    pickerController.mediaTypes = @[(NSString *)kUTTypeVideo, (NSString *)kUTTypeMovie];
    pickerController.delegate = self;
    pickerController.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:pickerController animated:true completion:nil];
}

- (void) togglePause {
    _distributor.uploadsSuspended ? [_distributor resumeUploads] : [_distributor suspendUploads];
    NSString *title = _distributor.uploadsSuspended ? @"Resume" : @"Pause";
    [_pauseButton setTitle:title forState:UIControlStateNormal];
    [self.view setNeedsLayout];
}

- (void) cancelAll {
    [_distributor cancelAll];
}

- (void) upload:(NSURL *) fileURL {
    __weak typeof(self) weakSelf = self;
    [_distributor upload:fileURL
                userInfo:@{@"localVideoID" : @"12345677"}
            callbackData:@{@"serverID" : @"4lkj344"}
             serviceName: @"$DEFAULT"
           thumbnailTime:0.3
                 onError:^(NSError *error){
                     NSString *reason = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
                     UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Error uploading video"
                                                                                    message: reason
                                                                             preferredStyle: UIAlertControllerStyleAlert];
                     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Dismiss"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                                              [weakSelf dismissViewControllerAnimated:true completion:nil];
                                                                          }];
                     [alert addAction:cancelAction];
                     [weakSelf presentViewController:alert animated:true completion:nil];
                 } onUploadInitialized: ^{
                     NSLog(@"Upload initialized successfully.");
                 }];
}

- (void) requestVideoID {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Video Object ID" message:@"Provide your video's objectID to start playing when it is ready." preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Get Details" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *text = [[controller.textFields firstObject] text];
        if (text == nil || [text length] == 0) {
            [weakSelf dismissViewControllerAnimated:true completion:nil];
            return;
        }
        [weakSelf playVideoWhenPublished:text];
        [weakSelf dismissViewControllerAnimated:true completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:true completion:nil];
    }];
    
    [controller addAction:confirmAction];
    [controller addAction:cancelAction];
    
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Video Object ID";
    }];
    
    [self presentViewController:controller animated:true completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate implement

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    id urlObject = [info objectForKey:UIImagePickerControllerMediaURL];
    if (!urlObject || ![urlObject isKindOfClass:[NSURL class]]) {
        urlObject = [info objectForKey:UIImagePickerControllerReferenceURL];
        if (!urlObject || ![urlObject isKindOfClass:[NSURL class]]) {
            [self dismissViewControllerAnimated:true completion:nil];
            return;
        }
    }
    NSURL *url = (NSURL *)urlObject;
    NSLog(@"URL to video: %@", url);
    [self upload:url];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark -
#pragma mark Play Video When/If Published

- (void) getVideoStatus:(NSString *) objectID callback:(void (^)(BOOL finished,  NSURL * _Nullable url)) callback {
    NSError *error = nil;
    [self.distributor getVideoInfo:objectID error:&error success:^(NSDictionary<NSString *,id> *result) {
        NSString *status = [result objectForKey:@"status"];
        if ([status isEqualToString:@"draft"]) {
            [self appendToLog:[NSString stringWithFormat: @"%@ : Video %@ still needs to complete uploading.", [NSDate date], objectID]];
            callback(NO, nil);
            return;
        }
        
        if ([status isEqualToString:@"processing"]) {
            [self appendToLog:[NSString stringWithFormat: @"%@ : Video %@ processing.", [NSDate date], objectID]];
            callback(NO, nil);
            return;
        }
        
        if ([status isEqualToString:@"published"]) {
            [self appendToLog:[NSString stringWithFormat: @"%@ : Video %@ publishing. Attempting to play...", [NSDate date], objectID]];
            NSString *playbackURLString = [result objectForKey:@"url"];
            NSURL *playbackURL = [NSURL URLWithString:playbackURLString];
            callback(YES, playbackURL);
            return;
        }
        
        if ([status isEqualToString:@"error"]) {
            [self appendToLog:[NSString stringWithFormat: @"%@ : Video %@ has an error.", [NSDate date], objectID]];
            [self appendToLog:[NSString stringWithFormat: @"Video details: %@", result]];
            callback(YES, nil);
            return;
        }
        
        if ([status isEqualToString:@"deleted"]) {
            [self appendToLog:[NSString stringWithFormat: @"%@ : Video %@ still needs to complete uploading.", [NSDate date], objectID]];
            [self appendToLog:[NSString stringWithFormat: @"Video details: %@", result]];
            callback(YES, nil);
            return;
        }
    }];
}

- (void) playVideoWhenPublished:(NSString *) objectID {
     __weak typeof(self) weakSelf = self;
    [self getVideoStatus:objectID callback:^(BOOL finished, NSURL * _Nullable url) {
        if (!finished) {
            if ([self.waitingTimers objectForKey:objectID]) {
                return;
            }
            [weakSelf addTimer:objectID];
            return;
        }
        [self playVideo:url];
        [[self.waitingTimers objectForKey:objectID] invalidate];
        [self.waitingTimers removeObjectForKey:objectID];
    }];
}

- (void) checkVideoStatus:(NSTimer *) timer {
    NSString *objectID = [[timer userInfo] objectForKey:@"objectID"];
    if (!objectID) {
        return;
    }
    [self playVideoWhenPublished:objectID];
}

- (void) addTimer:(NSString *) objectID {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkVideoStatus:)
                                                    userInfo:@{@"objectID" : objectID}
                                                     repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [_waitingTimers setObject:timer forKey:objectID];
}

- (void) playVideo:(NSURL *) url {
    if (!url) {
        return;
    }
    AVPlayerViewController *viewController = [[AVPlayerViewController alloc] init];
    AVPlayer *player = [[AVPlayer alloc] initWithURL: url];
    viewController.player = player;
    [self presentViewController:viewController animated:true completion:^{
        [player play];
    }];
}

#pragma mark -
#pragma mark DistributorDelegate implementation


- (void) uploadDidProgress:(NSString *)objectID userInfo:(NSDictionary<NSString *,id> *)userInfo progress:(NSProgress *)progress totalProgress:(NSProgress *)totalProgress {
    [_progressBar setProgress:totalProgress.fractionCompleted animated:true];
    int roundedProgress = round(totalProgress.fractionCompleted * 100);
    _progressLabel.text = [NSString stringWithFormat:@"%d%%", roundedProgress];
    [_progressLabel sizeToFit];
    [self.view setNeedsLayout];
}

- (void) uploadDidInitialize:(NSString *)objectID userInfo:(NSDictionary<NSString *,id> *)userInfo {
    [self appendToLog:[NSString stringWithFormat:@"Upload %@ initialized with metadata: %@", objectID, userInfo]];
}

- (void) uploadDidStart:(NSString *)objectID userInfo:(NSDictionary<NSString *,id> *)userInfo {
    [self appendToLog:[NSString stringWithFormat:@"Upload %@ started with metadata: %@", objectID, userInfo]];
}

- (void) uploadDidResume:(NSString *)objectID userInfo:(NSDictionary<NSString *,id> *)userInfo {
    [self appendToLog:[NSString stringWithFormat:@"Upload %@ resumed with metadata: %@", objectID, userInfo]];
}

- (void) uploadDidFinish:(NSString *)objectID userInfo:(NSDictionary<NSString *,id> *)userInfo {
    [self appendToLog:[NSString stringWithFormat:@"Upload %@ complete with metadata: %@", objectID, userInfo]];
}

- (void) uploadDidFail:(NSString *)objectID userInfo:(NSDictionary<NSString *,id> *)userInfo withError:(NSError *)error {
    [self appendToLog:[NSString stringWithFormat:@"Upload %@ initialized with metadata: %@ failed: %@",
                       objectID, userInfo, error.localizedDescription]];
}

- (void) uploadsCompleted:(NSArray<UploadCompleteResult *> *)results {
    [self appendToLog:@"\n\n******* Upload Summary *******\n"];
    for (UploadCompleteResult *result in results) {
        [self appendToLog:[NSString stringWithFormat:@"Upload result for: %@ - %ld - metadata: %@",
                           result.objectID, (long)result.result, result.userInfo]];
    }
    [self appendToLog: @"\n************************************************"];
}

- (void) appendToLog:(NSString *) logEntry {
    _logView.text = [_logView.text stringByAppendingString: [NSString stringWithFormat: @"\n%@", logEntry]];
    [_logView scrollRectToVisible: CGRectMake(0, _logView.contentSize.height - 20, _logView.contentSize.width, 20) animated: true];
}


@end
