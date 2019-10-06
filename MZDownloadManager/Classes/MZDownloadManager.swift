//
//  MZDownloadManager.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 19/04/2016.
//  Copyright © 2016 ideamakerz. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc public protocol MZDownloadManagerDelegate: class {
    /**A delegate method called each time whenever any download task's progress is updated
     */
    @objc func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called when interrupted tasks are repopulated
     */
    @objc func downloadRequestDidPopulatedInterruptedTasks(_ downloadModel: [MZDownloadModel])
    /**A delegate method called each time whenever new download task is start downloading
     */
    @objc optional func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever running download task is paused. If task is already paused the action will be ignored
     */
    @objc optional func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    @objc optional func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    @objc optional func downloadRequestDidRetry(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is cancelled by the user
     */
    @objc optional func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is finished successfully
     */
    @objc optional func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is failed due to any reason
     */
    @objc optional func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever specified destination does not exists. It will be called on the session queue. It provides the opportunity to handle error appropriately
     */
    @objc optional func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL)
    
}

open class MZDownloadManager: NSObject {
    
    fileprivate var sessionManager: URLSession!
    
    fileprivate var backgroundSessionCompletionHandler: (() -> Void)?
    
    fileprivate let TaskDescFileNameIndex = 0
    fileprivate let TaskDescFileURLIndex = 1
    fileprivate let TaskDescFileDestinationIndex = 2
    
    fileprivate weak var delegate: MZDownloadManagerDelegate?
    
    open var downloadingArray: [MZDownloadModel] = []
    
    public convenience init(session sessionIdentifer: String, delegate: MZDownloadManagerDelegate, sessionConfiguration: URLSessionConfiguration? = nil, completion: (() -> Void)? = nil) {
        self.init()
        self.delegate = delegate
        self.sessionManager = backgroundSession(identifier: sessionIdentifer, configuration: sessionConfiguration)
        self.populateOtherDownloadTasks()
        self.backgroundSessionCompletionHandler = completion
    }
    
    public class func defaultSessionConfiguration(identifier: String) -> URLSessionConfiguration {
        return URLSessionConfiguration.background(withIdentifier: identifier)
    }
    
    fileprivate func backgroundSession(identifier: String, configuration: URLSessionConfiguration? = nil) -> URLSession {
        let sessionConfiguration = configuration ?? MZDownloadManager.defaultSessionConfiguration(identifier: identifier)
        assert(identifier == sessionConfiguration.identifier, "Configuration identifiers do not match")
        let session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        return session
    }
}

// MARK: Private Helper functions

extension MZDownloadManager {
    
    fileprivate func downloadTasks() -> [URLSessionDownloadTask] {
        var tasks: [URLSessionDownloadTask] = []
        let semaphore : DispatchSemaphore = DispatchSemaphore(value: 0)
        sessionManager.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            tasks = downloadTasks
            semaphore.signal()
        }
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        debugPrint("MZDownloadManager: pending tasks \(tasks)")
        
        return tasks
    }
    
    fileprivate func populateOtherDownloadTasks() {
        
        let downloadTasks = self.downloadTasks()
        
        for downloadTask in downloadTasks {
            let taskDescComponents: [String] = downloadTask.taskDescription!.components(separatedBy: ",")
            let fileName = taskDescComponents[TaskDescFileNameIndex]
            let fileURL = taskDescComponents[TaskDescFileURLIndex]
            let destinationPath = taskDescComponents[TaskDescFileDestinationIndex]
            
            let downloadModel = MZDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath)
            downloadModel.task = downloadTask
            downloadModel.startTime = Date()
            
            if downloadTask.state == .running {
                downloadModel.status = TaskStatus.downloading.description()
                downloadingArray.append(downloadModel)
            } else if(downloadTask.state == .suspended) {
                downloadModel.status = TaskStatus.paused.description()
                downloadingArray.append(downloadModel)
            } else {
                downloadModel.status = TaskStatus.failed.description()
            }
        }
    }
    
    fileprivate func isValidResumeData(_ resumeData: Data?) -> Bool {
        
        guard resumeData != nil || resumeData?.count > 0 else {
            return false
        }
        
        return true
        
    }
}

extension MZDownloadManager: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        for (index, downloadModel) in self.downloadingArray.enumerated() {
            if downloadTask.isEqual(downloadModel.task) {
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let receivedBytesCount = Double(downloadTask.countOfBytesReceived)
                    let totalBytesCount = Double(downloadTask.countOfBytesExpectedToReceive)
                    let progress = Float(receivedBytesCount / totalBytesCount)
                    
                    let taskStartedDate = downloadModel.startTime ?? Date()
                    let timeInterval = taskStartedDate.timeIntervalSinceNow
                    let downloadTime = TimeInterval(-1 * timeInterval)
                    
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
                    
                    if self.downloadingArray.contains(downloadModel), let objectIndex = self.downloadingArray.firstIndex(of: downloadModel) {
                        self.downloadingArray[objectIndex] = downloadModel
                    }
                    
                    self.delegate?.downloadRequestDidUpdateProgress(downloadModel, index: index)
                })
                break
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        for (index, downloadModel) in downloadingArray.enumerated() {
            if downloadTask.isEqual(downloadModel.task) {
                let fileName = downloadModel.fileName as NSString
                let basePath = downloadModel.destinationPath == "" ? MZUtility.baseFilePath : downloadModel.destinationPath
                let destinationPath = (basePath as NSString).appendingPathComponent(fileName as String)
                
                let fileManager : FileManager = FileManager.default
                
                //If all set just move downloaded file to the destination
                if fileManager.fileExists(atPath: basePath) {
                    let fileURL = URL(fileURLWithPath: destinationPath as String)
                    debugPrint("directory path = \(destinationPath)")
                    
                    do {
                        try fileManager.moveItem(at: location, to: fileURL)
                    } catch let error as NSError {
                        debugPrint("Error while moving downloaded file to destination path:\(error)")
                        DispatchQueue.main.async(execute: { () -> Void in
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
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("task id: \(task.taskIdentifier)")
        /***** Any interrupted tasks due to any reason will be populated in failed state after init *****/
        
        DispatchQueue.main.async {
            
            let err = error as NSError?
            
            if (err?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? NSNumber)?.intValue == NSURLErrorCancelledReasonUserForceQuitApplication || (err?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? NSNumber)?.intValue == NSURLErrorCancelledReasonBackgroundUpdatesDisabled {
                
                let downloadTask = task as! URLSessionDownloadTask
                let taskDescComponents: [String] = downloadTask.taskDescription!.components(separatedBy: ",")
                let fileName = taskDescComponents[self.TaskDescFileNameIndex]
                let fileURL = taskDescComponents[self.TaskDescFileURLIndex]
                let destinationPath = taskDescComponents[self.TaskDescFileDestinationIndex]
                
                let downloadModel = MZDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath)
                downloadModel.status = TaskStatus.failed.description()
                downloadModel.task = downloadTask
                
                let resumeData = err?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
                
                var newTask = downloadTask
                if self.isValidResumeData(resumeData) == true {
                    newTask = self.sessionManager.downloadTask(withResumeData: resumeData!)
                } else {
                    newTask = self.sessionManager.downloadTask(with: URL(string: fileURL as String)!)
                }
                
                newTask.taskDescription = downloadTask.taskDescription
                downloadModel.task = newTask
                
                self.downloadingArray.append(downloadModel)
                
                self.delegate?.downloadRequestDidPopulatedInterruptedTasks(self.downloadingArray)
                
            } else {
                for(index, object) in self.downloadingArray.enumerated() {
                    let downloadModel = object
                    if task.isEqual(downloadModel.task) {
                        if err?.code == NSURLErrorCancelled || err == nil {
                            self.downloadingArray.remove(at: index)
                            
                            if err == nil {
                                self.delegate?.downloadRequestFinished?(downloadModel, index: index)
                            } else {
                                self.delegate?.downloadRequestCanceled?(downloadModel, index: index)
                            }
                            
                        } else {
                            let resumeData = err?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
                            var newTask = task
                            if self.isValidResumeData(resumeData) == true {
                                newTask = self.sessionManager.downloadTask(withResumeData: resumeData!)
                            } else {
                                newTask = self.sessionManager.downloadTask(with: URL(string: downloadModel.fileURL)!)
                            }
                            
                            newTask.taskDescription = task.taskDescription
                            downloadModel.status = TaskStatus.failed.description()
                            downloadModel.task = newTask as? URLSessionDownloadTask
                            
                            self.downloadingArray[index] = downloadModel
                            
                            if let error = err {
                                self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                            } else {
                                let error: NSError = NSError(domain: "MZDownloadManagerDomain", code: 1000, userInfo: [NSLocalizedDescriptionKey : "Unknown error occurred"])
                                
                                self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let backgroundCompletion = self.backgroundSessionCompletionHandler {
            DispatchQueue.main.async(execute: {
                backgroundCompletion()
            })
        }
        debugPrint("All tasks are finished")
    }
}

//MARK: Public Helper Functions

extension MZDownloadManager {
    
    @objc public func addDownloadTask(_ fileName: String, request: URLRequest, destinationPath: String) {
        
        let url = request.url!
        let fileURL = url.absoluteString
        
        let downloadTask = sessionManager.downloadTask(with: request)
        downloadTask.taskDescription = [fileName, fileURL, destinationPath].joined(separator: ",")
        downloadTask.resume()
        
        debugPrint("session manager:\(String(describing: sessionManager)) url:\(String(describing: url)) request:\(String(describing: request))")
        
        let downloadModel = MZDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath)
        downloadModel.startTime = Date()
        downloadModel.status = TaskStatus.downloading.description()
        downloadModel.task = downloadTask
        
        downloadingArray.append(downloadModel)
        delegate?.downloadRequestStarted?(downloadModel, index: downloadingArray.count - 1)
    }
    
    @objc public func addDownloadTask(_ fileName: String, fileURL: String, destinationPath: String) {
        
        let url = URL(string: fileURL)!
        let request = URLRequest(url: url)
        addDownloadTask(fileName, request: request, destinationPath: destinationPath)
        
    }
    
    @objc public func addDownloadTask(_ fileName: String, fileURL: String) {
        addDownloadTask(fileName, fileURL: fileURL, destinationPath: "")
    }
    
    @objc public func addDownloadTask(_ fileName: String, request: URLRequest) {
        addDownloadTask(fileName, request: request, destinationPath: "")
    }
    
    @objc public func pauseDownloadTaskAtIndex(_ index: Int) {
        
        let downloadModel = downloadingArray[index]
        
        guard downloadModel.status != TaskStatus.paused.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        downloadTask!.suspend()
        downloadModel.status = TaskStatus.paused.description()
        downloadModel.startTime = Date()
        
        downloadingArray[index] = downloadModel
        
        delegate?.downloadRequestDidPaused?(downloadModel, index: index)
    }
    
    @objc public func resumeDownloadTaskAtIndex(_ index: Int) {
        
        let downloadModel = downloadingArray[index]
        
        guard downloadModel.status != TaskStatus.downloading.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        downloadTask!.resume()
        downloadModel.status = TaskStatus.downloading.description()
        
        downloadingArray[index] = downloadModel
        
        delegate?.downloadRequestDidResumed?(downloadModel, index: index)
    }
    
    @objc public func retryDownloadTaskAtIndex(_ index: Int) {
        let downloadModel = downloadingArray[index]
        
        guard downloadModel.status != TaskStatus.downloading.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        
        downloadTask!.resume()
        downloadModel.status = TaskStatus.downloading.description()
        downloadModel.startTime = Date()
        downloadModel.task = downloadTask
        
        downloadingArray[index] = downloadModel
    }
    
    @objc public func cancelTaskAtIndex(_ index: Int) {
        let downloadInfo = downloadingArray[index]
        let downloadTask = downloadInfo.task
        downloadTask!.cancel()
    }
    
    @objc public func presentNotificationForDownload(_ notifAction: String, notifBody: String) {
        let application = UIApplication.shared
        let applicationState = application.applicationState
        
        if applicationState == UIApplication.State.background {
            let localNotification = UILocalNotification()
            localNotification.alertBody = notifBody
            localNotification.alertAction = notifAction
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.applicationIconBadgeNumber += 1
            application.presentLocalNotificationNow(localNotification)
        }
    }
}
