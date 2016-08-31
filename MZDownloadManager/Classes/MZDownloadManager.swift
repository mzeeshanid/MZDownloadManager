//
//  MZDownloadManager.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 19/04/2016.
//  Copyright © 2016 ideamakerz. All rights reserved.
//

import UIKit

@objc public protocol MZDownloadManagerDelegate {
    /**A delegate method called each time whenever any download task's progress is updated
     */
    func downloadRequestDidUpdateProgress(downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called when interrupted tasks are repopulated
     */
    func downloadRequestDidPopulatedInterruptedTasks(downloadModel: [MZDownloadModel])
    /**A delegate method called each time whenever new download task is start downloading
     */
    optional func downloadRequestStarted(downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever running download task is paused. If task is already paused the action will be ignored
     */
    optional func downloadRequestDidPaused(downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    optional func downloadRequestDidResumed(downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    optional func downloadRequestDidRetry(downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is cancelled by the user
     */
    optional func downloadRequestCanceled(downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is finished successfully
     */
    optional func downloadRequestFinished(downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is failed due to any reason
     */
    optional func downloadRequestDidFailedWithError(error: NSError, downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever specified destination does not exists. It will be called on the session queue. It provides the opportunity to handle error appropriately
     */
    optional func downloadRequestDestinationDoestNotExists(downloadModel: MZDownloadModel, index: Int, location: NSURL)
    
}

public class MZDownloadManager: NSObject {
    
    private var sessionManager: NSURLSession!
    public var downloadingArray: [MZDownloadModel] = []
    private var delegate: MZDownloadManagerDelegate?
    
    private var backgroundSessionCompletionHandler: (() -> Void)?
    
    private let TaskDescFileNameIndex = 0
    private let TaskDescFileURLIndex = 0
    private let TaskDescFileDestinationIndex = 0
    
    public convenience init(session sessionIdentifer: String, delegate: MZDownloadManagerDelegate) {
        self.init()
        
        self.delegate = delegate
        self.sessionManager = self.backgroundSession(sessionIdentifer)
        self.populateOtherDownloadTasks()
    }
    
    public convenience init(session sessionIdentifer: String, delegate: MZDownloadManagerDelegate, completion: (() -> Void)?) {
        self.init(session: sessionIdentifer, delegate: delegate)
        self.backgroundSessionCompletionHandler = completion
    }
    
    private func backgroundSession(sessionIdentifer: String) -> NSURLSession {
        struct sessionStruct {
            static var onceToken : dispatch_once_t = 0;
            static var session   : NSURLSession? = nil
        }
        
        dispatch_once(&sessionStruct.onceToken, { () -> Void in
            let sessionConfiguration : NSURLSessionConfiguration
            
            sessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(sessionIdentifer)
            sessionStruct.session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        })
        return sessionStruct.session!
    }
}

// MARK: Private Helper functions

extension MZDownloadManager {
    
    private func downloadTasks() -> NSArray {
        return self.tasksForKeyPath("downloadTasks")
    }
    
    private func tasksForKeyPath(keyPath: NSString) -> NSArray {
        var tasks: NSArray = NSArray()
        let semaphore : dispatch_semaphore_t = dispatch_semaphore_create(0)
        sessionManager.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            if keyPath == "downloadTasks" {
                if let pendingTasks: NSArray = downloadTasks {
                    tasks = pendingTasks
                    debugPrint("pending tasks \(tasks)")
                }
            }
            
            dispatch_semaphore_signal(semaphore)
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return tasks
    }
    
    private func populateOtherDownloadTasks() {
        
        let downloadTasks = self.downloadTasks()
        
        for object in downloadTasks {
            let downloadTask = object as! NSURLSessionDownloadTask
            let taskDescComponents: [String] = downloadTask.taskDescription!.componentsSeparatedByString(",")
            let fileName = taskDescComponents[TaskDescFileNameIndex]
            let fileURL = taskDescComponents[TaskDescFileURLIndex]
            let destinationPath = taskDescComponents[TaskDescFileDestinationIndex]
            
            let downloadModel = MZDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath)
            downloadModel.task = downloadTask
            downloadModel.startTime = NSDate()
            
            if downloadTask.state == .Running {
                downloadModel.status = TaskStatus.Downloading.description()
                downloadingArray.append(downloadModel)
            } else if(downloadTask.state == .Suspended) {
                downloadModel.status = TaskStatus.Paused.description()
                downloadingArray.append(downloadModel)
            } else {
                downloadModel.status = TaskStatus.Failed.description()
            }
        }
    }
    
    private func isValidResumeData(resumeData: NSData?) -> Bool {
        
        guard resumeData != nil || resumeData?.length > 0 else {
            return false
        }
        
        do {
            var resumeDictionary : AnyObject!
            resumeDictionary = try NSPropertyListSerialization.propertyListWithData(resumeData!, options: .Immutable, format: nil)
            var localFilePath : NSString? = resumeDictionary?.objectForKey("NSURLSessionResumeInfoLocalPath") as? NSString
            
            if localFilePath == nil || localFilePath?.length < 1 {
                localFilePath = NSTemporaryDirectory() + (resumeDictionary["NSURLSessionResumeInfoTempFileName"] as! String)
            }
            
            let fileManager : NSFileManager! = NSFileManager.defaultManager()
            debugPrint("resume data file exists: \(fileManager.fileExistsAtPath(localFilePath! as String))")
            return fileManager.fileExistsAtPath(localFilePath! as String)
        } catch let error as NSError {
            debugPrint("resume data is nil: \(error)")
            return false
        }
    }
}

extension MZDownloadManager: NSURLSessionDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        for (index, downloadModel) in self.downloadingArray.enumerate() {
            if downloadTask.isEqual(downloadModel.task) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let receivedBytesCount = Double(downloadTask.countOfBytesReceived)
                    let totalBytesCount = Double(downloadTask.countOfBytesExpectedToReceive)
                    let progress = Float(receivedBytesCount / totalBytesCount)
                    
                    let taskStartedDate = downloadModel.startTime!
                    let timeInterval = taskStartedDate.timeIntervalSinceNow
                    let downloadTime = NSTimeInterval(-1 * timeInterval)
                    
                    let speed = Float(totalBytesWritten) / Float(downloadTime)
                    
                    let remainingContentLength = totalBytesExpectedToWrite - totalBytesWritten
                    
                    let remainingTime = remainingContentLength / Int64(speed)
                    let hours = Int(remainingTime) / 3600
                    let minutes = (Int(remainingTime) - hours * 3600) / 60
                    let seconds = Int(remainingTime) - hours * 3600 - minutes * 60
                    
                    let totalFileSize = MZUtility.calculateFileSizeInUnit(totalBytesExpectedToWrite)
                    let totalFileSizeUnit = MZUtility.calculateUnit(totalBytesExpectedToWrite)
                    
                    let downloadedFileSize = MZUtility.calculateFileSizeInUnit(totalBytesWritten)
                    let downloadedSizeUnit = MZUtility.calculateUnit(totalBytesWritten)
                    
                    let speedSize = MZUtility.calculateFileSizeInUnit(Int64(speed))
                    let speedUnit = MZUtility.calculateUnit(Int64(speed))
                    
                    downloadModel.remainingTime = (hours, minutes, seconds)
                    downloadModel.file = (totalFileSize, totalFileSizeUnit as String)
                    downloadModel.downloadedFile = (downloadedFileSize, downloadedSizeUnit as String)
                    downloadModel.speed = (speedSize, speedUnit as String)
                    downloadModel.progress = progress
                    
                    self.downloadingArray[index] = downloadModel
                    
                    self.delegate?.downloadRequestDidUpdateProgress(downloadModel, index: index)
                })
                break
            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        for (index, downloadModel) in downloadingArray.enumerate() {
            if downloadTask.isEqual(downloadModel.task) {
                let fileName = downloadModel.fileName as NSString
                let basePath = downloadModel.destinationPath == "" ? MZUtility.baseFilePath : downloadModel.destinationPath
                let destinationPath = (basePath as NSString).stringByAppendingPathComponent(fileName as String)
                
                let fileManager : NSFileManager = NSFileManager.defaultManager()
                
                //If all set just move downloaded file to the destination
                if fileManager.fileExistsAtPath(basePath) {
                    let fileURL = NSURL(fileURLWithPath: destinationPath as String)
                    debugPrint("directory path = \(destinationPath)")
                    
                    do {
                        try fileManager.moveItemAtURL(location, toURL: fileURL)
                    } catch let error as NSError {
                        debugPrint("Error while moving downloaded file to destination path:\(error)")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                        })
                    }
                } else {
                    //Opportunity to handle the folder doesnot exists error appropriately.
                    //Move downloaded file to destination
                    //Delegate will be called on the session queue
                    //Otherwise blindly give error Destination folder does not exists
                    
                    if let _ = self.delegate?.downloadRequestDestinationDoestNotExists {
                        self.delegate?.downloadRequestDestinationDoestNotExists?(downloadModel, index: index, location: location)
                    } else {
                        let error = NSError(domain: "FolderDoesNotExist", code: 404, userInfo: [NSLocalizedDescriptionKey : "Destination folder does not exists"])
                        self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                    }
                }
                
                break
            }
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        debugPrint("task id: \(task.taskIdentifier)")
        /***** Any interrupted tasks due to any reason will be populated in failed state after init *****/
        if error?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey]?.integerValue == NSURLErrorCancelledReasonUserForceQuitApplication || error?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey]?.integerValue == NSURLErrorCancelledReasonBackgroundUpdatesDisabled {
            
            let downloadTask = task as! NSURLSessionDownloadTask
            let taskDescComponents: [String] = downloadTask.taskDescription!.componentsSeparatedByString(",")
            let fileName = taskDescComponents[TaskDescFileNameIndex]
            let fileURL = taskDescComponents[TaskDescFileURLIndex]
            let destinationPath = taskDescComponents[TaskDescFileDestinationIndex]
            
            let downloadModel = MZDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath)
            downloadModel.status = TaskStatus.Failed.description()
            downloadModel.task = downloadTask
            
            let resumeData = error?.userInfo[NSURLSessionDownloadTaskResumeData] as? NSData
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                var newTask = task
                if self.isValidResumeData(resumeData) == true {
                    newTask = self.sessionManager.downloadTaskWithResumeData(resumeData!)
                } else {
                    newTask = self.sessionManager.downloadTaskWithURL(NSURL(string: fileURL as String)!)
                }
                
                newTask.taskDescription = task.taskDescription
                downloadModel.task = newTask as? NSURLSessionDownloadTask
                
                self.downloadingArray.append(downloadModel)
                
                self.delegate?.downloadRequestDidPopulatedInterruptedTasks(self.downloadingArray)
            })
            
        } else {
            for(index, object) in self.downloadingArray.enumerate() {
                let downloadModel = object
                if task.isEqual(downloadModel.task) {
                    if error?.code == NSURLErrorCancelled || error == nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.downloadingArray.removeAtIndex(index)
                            
                            if error == nil {
                                self.delegate?.downloadRequestFinished?(downloadModel, index: index)
                            } else {
                                self.delegate?.downloadRequestCanceled?(downloadModel, index: index)
                            }
                            
                        })
                    } else {
                        let resumeData = error?.userInfo[NSURLSessionDownloadTaskResumeData] as? NSData
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            var newTask = task
                            if self.isValidResumeData(resumeData) == true {
                                newTask = self.sessionManager.downloadTaskWithResumeData(resumeData!)
                            } else {
                                newTask = self.sessionManager.downloadTaskWithURL(NSURL(string: downloadModel.fileURL)!)
                            }
                            
                            newTask.taskDescription = task.taskDescription
                            downloadModel.status = TaskStatus.Failed.description()
                            downloadModel.task = newTask as? NSURLSessionDownloadTask
                            
                            self.downloadingArray[index] = downloadModel
                            
                            if let error = error {
                                self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                            } else {
                                let error: NSError = NSError(domain: "MZDownloadManagerDomain", code: 1000, userInfo: [NSLocalizedDescriptionKey : "Unknown error occurred"])
                                
                                self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                            }
                            
                        })
                    }
                    break;
                }
            }
        }
    }
    
    public func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        
        if let backgroundCompletion = self.backgroundSessionCompletionHandler {
            dispatch_async(dispatch_get_main_queue(), {
                backgroundCompletion()
            })
        }
        debugPrint("All tasks are finished")
        
    }
}

//MARK: Public Helper Functions

extension MZDownloadManager {
    
    public func addDownloadTask(fileName: String, fileURL: String, destinationPath: String) {
        
        let url = NSURL(string: fileURL as String)!
        let request = NSURLRequest(URL: url)
        
        let downloadTask = sessionManager.downloadTaskWithRequest(request)
        downloadTask.taskDescription = [fileName, fileURL, destinationPath].joinWithSeparator(",")
        downloadTask.resume()
        
        debugPrint("session manager:\(sessionManager) url:\(url) request:\(request)")
        
        let downloadModel = MZDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath)
        downloadModel.startTime = NSDate()
        downloadModel.status = TaskStatus.Downloading.description()
        downloadModel.task = downloadTask
        
        downloadingArray.append(downloadModel)
        delegate?.downloadRequestStarted?(downloadModel, index: downloadingArray.count - 1)
    }
    
    public func addDownloadTask(fileName: String, fileURL: String) {
        addDownloadTask(fileName, fileURL: fileURL, destinationPath: "")
    }
    
    public func pauseDownloadTaskAtIndex(index: Int) {
        
        let downloadModel = downloadingArray[index]
        
        guard downloadModel.status != TaskStatus.Paused.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        downloadTask!.suspend()
        downloadModel.status = TaskStatus.Paused.description()
        downloadModel.startTime = NSDate()
        
        downloadingArray[index] = downloadModel
        
        delegate?.downloadRequestDidPaused?(downloadModel, index: index)
    }
    
    public func resumeDownloadTaskAtIndex(index: Int) {
        
        let downloadModel = downloadingArray[index]
        
        guard downloadModel.status != TaskStatus.Downloading.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        downloadTask!.resume()
        downloadModel.status = TaskStatus.Downloading.description()
        
        downloadingArray[index] = downloadModel
        
        delegate?.downloadRequestDidResumed?(downloadModel, index: index)
    }
    
    public func retryDownloadTaskAtIndex(index: Int) {
        let downloadModel = downloadingArray[index]
        
        guard downloadModel.status != TaskStatus.Downloading.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        
        downloadTask!.resume()
        downloadModel.status = TaskStatus.Downloading.description()
        downloadModel.startTime = NSDate()
        downloadModel.task = downloadTask
        
        downloadingArray[index] = downloadModel
    }
    
    public func cancelTaskAtIndex(index: Int) {
        
        let downloadInfo = downloadingArray[index]
        let downloadTask = downloadInfo.task
        downloadTask!.cancel()
    }
    
    public func presentNotificationForDownload(notifAction: String, notifBody: String) {
        let application = UIApplication.sharedApplication()
        let applicationState = application.applicationState
        
        if applicationState == UIApplicationState.Background {
            let localNotification = UILocalNotification()
            localNotification.alertBody = notifBody
            localNotification.alertAction = notifAction
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.applicationIconBadgeNumber += 1
            application.presentLocalNotificationNow(localNotification)
        }
    }
}
