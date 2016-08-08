//
//  ViewController.swift
//  Demo
//
//  Created by Michael Gaylord on 2016/05/13.
//  Copyright © 2016 Storie. All rights reserved.
//

import UIKit
import StorieCloudSDK
import AVFoundation
import MediaPlayer
import MobileCoreServices
import AVKit

class ViewController: UIViewController {
    
    let chooseVideoButton = UIButton()
    let progressBar = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
    let progressLabel = UILabel()
    let storiePlatform: StoriePlatform
    let logView = UITextView()
    let pauseButton = UIButton()
    let cancelAllButton = UIButton()
    let getVideoInfoButton = UIButton()
    
    private var waitingTimers = [String: NSTimer]()
    
    init(storiePlatform: StoriePlatform) {
        self.storiePlatform = storiePlatform
        super.init(nibName: nil, bundle: nil)
        storiePlatform.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chooseVideoButton.addTarget(self, action: #selector(chooseVideo), forControlEvents: .TouchUpInside)
        cancelAllButton.addTarget(self, action: #selector(cancelAll), forControlEvents: .TouchUpInside)
        pauseButton.addTarget(self, action: #selector(togglePause), forControlEvents: .TouchUpInside)
        getVideoInfoButton.addTarget(self, action: #selector(requestVideoID), forControlEvents: .TouchUpInside)
        
        view.addSubview(chooseVideoButton)
        view.addSubview(progressBar)
        view.addSubview(progressLabel)
        view.addSubview(logView)
        view.addSubview(pauseButton)
        view.addSubview(cancelAllButton)
        view.addSubview(getVideoInfoButton)
        
        logView.backgroundColor = UIColor.lightGrayColor()
        logView.editable = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        chooseVideoButton.setTitle("Choose video", forState: .Normal)
        chooseVideoButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        chooseVideoButton.sizeToFit()
        
        progressLabel.text = "0%"
        progressLabel.textColor = UIColor.blackColor()
        progressLabel.sizeToFit()
        
        progressBar.progressTintColor = UIColor.blueColor()
        progressBar.trackTintColor = UIColor.lightGrayColor()
        
        let title = storiePlatform.uploadsSuspended ? "Resume" : "Pause"
        pauseButton.setTitle(title, forState: .Normal)
        pauseButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        
        cancelAllButton.setTitle("Cancel All", forState: .Normal)
        cancelAllButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        
        getVideoInfoButton.setTitle("Play Video", forState: .Normal)
        getVideoInfoButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        progressLabel.sizeToFit()
        pauseButton.sizeToFit()
        cancelAllButton.sizeToFit()
        getVideoInfoButton.sizeToFit()
        
        chooseVideoButton.center = CGPoint(x: CGRectGetMidX(view.bounds), y: 50)
        progressBar.frame.size = CGSize(width: view.frame.size.width - 50, height: 10)
        progressBar.center = CGPoint(x: chooseVideoButton.center.x, y: CGRectGetMaxY(chooseVideoButton.frame) + CGRectGetHeight(progressBar.bounds) + 20)
        progressLabel.center = CGPoint(x: chooseVideoButton.center.x, y: CGRectGetMaxY(progressBar.frame) + CGRectGetHeight(progressLabel.bounds) + 20)
        
        pauseButton.frame.origin = CGPoint(x: 20, y: CGRectGetMaxY(progressLabel.frame) + 10)
        cancelAllButton.frame.origin = CGPoint(x: CGRectGetWidth(self.view.bounds) - cancelAllButton.bounds.width - 20, y: pauseButton.frame.origin.y)
        
        logView.frame = CGRect(x: 10, y: CGRectGetMaxY(pauseButton.frame) + 10,
                               width: CGRectGetWidth(view.bounds) - 20,
                               height: CGRectGetHeight(view.bounds) - CGRectGetMaxY(pauseButton.frame) - 40 - getVideoInfoButton.bounds.size.height)
        
        getVideoInfoButton.frame = CGRect(origin: CGPoint(
            x:CGRectGetMidX(self.view.bounds) - CGRectGetMidX(getVideoInfoButton.bounds),
            y:CGRectGetMaxY(logView.frame) + 20),
                                          size:getVideoInfoButton.bounds.size)
    }
    
    //MARK: Actions
    
    final func chooseVideo() {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        pickerController.allowsEditing = true
        pickerController.videoQuality = UIImagePickerControllerQualityType.TypeHigh
        pickerController.mediaTypes = [kUTTypeVideo as String, kUTTypeMovie as String]
        pickerController.delegate = self
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    final func togglePause() {
        storiePlatform.uploadsSuspended ? storiePlatform.resumeUploads() : storiePlatform.suspendUploads()
        let title = storiePlatform.uploadsSuspended ? "Resume" : "Pause"
        pauseButton.setTitle(title, forState: .Normal)
        view.setNeedsLayout()
    }
    
    final func cancelAll() {
        storiePlatform.cancelAll()
    }

    final func upload(fileURL: NSURL) {
        storiePlatform.upload(fileURL, userInfo: ["storyID" : "12345566"], callbackData: [:], serviceName: "$DEFAULT") { [weak self] success in
            do {
                try success()
            } catch let error as UploadError {
                self?.handleError(error)
            } catch let error {
                print("Error uploading file: \(error)")
            }
        }
        view.setNeedsLayout()
    }
    
    private func handleError(error: UploadError) {
        var alertMessage = ""
        switch error {
        case UploadError.InvalidFilePath:
            alertMessage = "Invalid path to video file."
        case UploadError.UploadAlreadyUploaded:
            alertMessage = "File already uploaded"
        case UploadError.UploadAuthenticationError(let message, _):
            alertMessage = message
        case UploadError.UploadServerError(let message, _):
            alertMessage = message
        default:
            alertMessage = "\(error)"
        }
        let alert = UIAlertController(title: "Error uploading file", message: alertMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: {[weak self] _ in
            self?.dismissViewControllerAnimated(true, completion: nil)})
        )
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    final func requestVideoID() {
        let controller = UIAlertController(title: "Video Object ID",
                                           message: "Provide your video's objectID to start playing when it is ready.",
                                           preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Play Video", style: UIAlertActionStyle.Default) { [weak self] action in
            defer {
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
            guard let videoID = controller.textFields?.first?.text where videoID.isEmpty == false else {
                return
            }
            self?.playVideoWhenPublished(videoID)
        }
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Default) { [weak self] _ in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        controller.addAction(confirmAction)
        controller.addAction(cancelAction)
        
        controller.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Video Object ID"
        }
        
        presentViewController(controller, animated: true, completion: nil)
    }
}

//MARK: -
//MARK: UImagePickerControllerDelegate implementation
extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    final func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        defer {
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let videoURL: NSURL? = {
            guard let url = info[UIImagePickerControllerMediaURL] as? NSURL else {
                guard let assetURL = info[UIImagePickerControllerReferenceURL] as? NSURL else {
                    return nil
                }
                return assetURL
            }
            return url
        }()
        
        guard let url = videoURL else {
            return
        }
        print("URL to video: \(url)")
        upload(url)
    }
    
    final func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK: -
//MARK: Play video when/if published
extension ViewController {
    
    private func getVideoStatus(objectID: String, callback: (finished: Bool, url: NSURL?) -> Void) {
        do {
            try storiePlatform.videoInfo(objectID) { [weak self] video in
                guard let status = video.status else {
                    return
                }
                let time = NSDate()
                switch status {
                case .Draft:
                    self?.appendToLog("\(time) : Video \(objectID) still needs to complete uploading.")
                    callback(finished: false, url: nil)
                case .Processing:
                    self?.appendToLog("\(time) : Video \(objectID) processing")
                    callback(finished: false, url: nil)
                case .Published:
                    self?.appendToLog("\(time) : Video \(objectID) published. Attempting to play...")
                    self?.appendToLog("Video details: \(video.videoID)")
                    callback(finished: true, url: video.url)
                case .Error:
                    self?.appendToLog("\(time) : Video \(objectID) has an error: \(video.dictionary)")
                    self?.appendToLog("Video details: \(video.videoID)")
                    callback(finished: true, url: nil)
                case .Deleted:
                    self?.appendToLog("\(time) : Video \(objectID) deleted unable to play.")
                    self?.appendToLog("Video details: \(video.dictionary)")
                    callback(finished: true, url: nil)
                }
            }
        } catch let error {
            appendToLog("Error getting video: \(error)")
            callback(finished: true, url: nil)
        }
    }
    
    func playVideoWhenPublished(objectID: String) {
        getVideoStatus(objectID) { [weak self] finished, url in
            if !finished {
                if let _ = self?.waitingTimers[objectID] { //do nothing we already have a timer
                    return
                }
                self?.addTimer(objectID)
                return
            }
            self?.playVideo(url)
            self?.waitingTimers[objectID]?.invalidate()
            self?.waitingTimers[objectID] = nil
        }
    }
    
    func checkVideoStatus(timer: NSTimer) {
        guard let objectID = timer.userInfo?["objectID"] as? String else {
            print("Unable to check video status as userInfo does not include `objectID`")
            return
        }
        playVideoWhenPublished(objectID)
    }
    
    func addTimer(objectID: String) {
        let newTimer = NSTimer(timeInterval: 10, target: self,
                               selector: #selector(ViewController.checkVideoStatus(_:)),
                               userInfo: ["objectID" : objectID],
                               repeats: true)
        NSRunLoop.mainRunLoop().addTimer(newTimer, forMode: NSDefaultRunLoopMode)
        waitingTimers[objectID] = newTimer
    }
    
    func playVideo(url: NSURL?) {
        guard let url = url else {
            return
        }
        let viewController = AVPlayerViewController()
        let player = AVPlayer(URL: url)
        viewController.player = player
        presentViewController(viewController, animated: true, completion: {
            viewController.player?.play()
        })
    }
}

//MARK: -
//MARK: StoriePlatformDelegate implementation
extension ViewController : StoriePlatformDelegate {
    
    func uploadDidProgress(objectID: String, userInfo:[String: AnyObject]?, progress: NSProgress, totalProgress: NSProgress) {
        progressBar.setProgress(Float(totalProgress.fractionCompleted), animated: true)
        progressLabel.text = "\(round(totalProgress.fractionCompleted * 100)) %"
        
        let roundedProgress = round(progress.fractionCompleted * 100)
        if roundedProgress % 10 == 0 {
            appendToLog("\(objectID)  with metadata: \(userInfo ?? [:]) did progress: \(roundedProgress)")
        }
        
        progressLabel.sizeToFit()
        view.setNeedsLayout()
    }
    
    func uploadDidInitialize(objectID: String, userInfo:[String: AnyObject]?) {
        appendToLog("Upload \(objectID) initialized with metadata: \(userInfo ?? [:])")
    }
    func uploadDidStart(objectID: String, userInfo:[String: AnyObject]?) {
        appendToLog("Upload \(objectID) started with metadata: \(userInfo ?? [:])")
    }
    func uploadDidResume(objectID: String, userInfo:[String: AnyObject]?) {
        appendToLog("Upload \(objectID) resuming with metadata: \(userInfo ?? [:])")
    }
    func uploadDidFinish(objectID: String, userInfo:[String: AnyObject]?) {
        appendToLog("Upload \(objectID) complete with metadata: \(userInfo ?? [:])")
    }
    func uploadDidFail(objectID: String, userInfo:[String: AnyObject]?, withError error: NSError?) {
        guard let _error = error else {
            appendToLog("Upload \(objectID) with metadata: \(userInfo ?? [:]) failed: Unknown error")
            return
        }
        appendToLog("Upload \(objectID)  with metadata: \(userInfo ?? [:]) failed: \(_error)")
    }
    func uploadsCompleted(results: [UploadCompleteResult]) {
        appendToLog("\n\n******* Upload Summary *******\n")
        for result in results {
            appendToLog("Upload result for: \(result.objectID) - \(result.result.description()) - metadata: \(result.userInfo ?? [:]).")
        }
        appendToLog("\n************************************************")
    }
    
    private func appendToLog(logEntry: String) {
        logView.text = logView.text.stringByAppendingString("\n\(logEntry)")
        logView.scrollRectToVisible(CGRect(x: 0, y: logView.contentSize.height - 20, width: logView.contentSize.width, height: 20), animated: true)
    }
}

