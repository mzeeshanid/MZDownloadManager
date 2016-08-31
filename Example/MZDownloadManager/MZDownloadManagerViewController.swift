//
//  MZDownloadManagerViewController.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 22/10/2014.
//  Copyright (c) 2014 ideamakerz. All rights reserved.
//

import UIKit
import MZDownloadManager

let alertControllerViewTag: Int = 500

class MZDownloadManagerViewController: UITableViewController {
    
    var selectedIndexPath : NSIndexPath!
    
    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.iosDevelopment.MZDownloadManager.BackgroundSession"
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshCellForIndex(downloadModel: MZDownloadModel, index: Int) {
        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        if let cell = cell {
            let downloadCell = cell as! MZDownloadingCell
            downloadCell.updateCellForRowAtIndexPath(indexPath, downloadModel: downloadModel)
        }
    }
}

// MARK: UITableViewDatasource Handler Extension

extension MZDownloadManagerViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadManager.downloadingArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier : NSString = "MZDownloadingCell"
        let cell : MZDownloadingCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier as String, forIndexPath: indexPath) as! MZDownloadingCell
        
        let downloadModel = downloadManager.downloadingArray[indexPath.row]
        cell.updateCellForRowAtIndexPath(indexPath, downloadModel: downloadModel)
        
        return cell
        
    }
}

// MARK: UITableViewDelegate Handler Extension

extension MZDownloadManagerViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        
        let downloadModel = downloadManager.downloadingArray[indexPath.row]
        self.showAppropriateActionController(downloadModel.status)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

// MARK: UIAlertController Handler Extension

extension MZDownloadManagerViewController {
    
    func showAppropriateActionController(requestStatus: String) {
        
        if requestStatus == TaskStatus.Downloading.description() {
            self.showAlertControllerForPause()
        } else if requestStatus == TaskStatus.Failed.description() {
            self.showAlertControllerForRetry()
        } else if requestStatus == TaskStatus.Paused.description() {
            self.showAlertControllerForStart()
        }
    }
    
    func showAlertControllerForPause() {
        
        let pauseAction = UIAlertAction(title: "Pause", style: .Default) { (alertAction: UIAlertAction) in
            self.downloadManager.pauseDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .Destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(pauseAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showAlertControllerForRetry() {
        
        let retryAction = UIAlertAction(title: "Retry", style: .Default) { (alertAction: UIAlertAction) in
            self.downloadManager.retryDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .Destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(retryAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showAlertControllerForStart() {
        
        let startAction = UIAlertAction(title: "Start", style: .Default) { (alertAction: UIAlertAction) in
            self.downloadManager.resumeDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .Destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(startAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func safelyDismissAlertController() {
        /***** Dismiss alert controller if and only if it exists and it belongs to MZDownloadManager *****/
        /***** E.g App will eventually crash if download is completed and user tap remove *****/
        /***** As it was already removed from the array *****/
        if let controller = self.presentedViewController {
            guard controller is UIAlertController && controller.view.tag == alertControllerViewTag else {
                return
            }
            controller.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension MZDownloadManagerViewController: MZDownloadManagerDelegate {
    
    func downloadRequestStarted(downloadModel: MZDownloadModel, index: Int) {
        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(downloadModels: [MZDownloadModel]) {
        tableView.reloadData()
    }
    
    func downloadRequestDidUpdateProgress(downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestDidPaused(downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestDidResumed(downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestCanceled(downloadModel: MZDownloadModel, index: Int) {
        
        self.safelyDismissAlertController()
        
        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func downloadRequestFinished(downloadModel: MZDownloadModel, index: Int) {
        
        self.safelyDismissAlertController()
        
        downloadManager.presentNotificationForDownload("Ok", notifBody: "Download did completed")
        
        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        
        let docDirectoryPath : NSString = (MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(downloadModel.fileName)
        NSNotificationCenter.defaultCenter().postNotificationName(MZUtility.DownloadCompletedNotif as String, object: docDirectoryPath)
    }
    
    func downloadRequestDidFailedWithError(error: NSError, downloadModel: MZDownloadModel, index: Int) {
        self.safelyDismissAlertController()
        self.refreshCellForIndex(downloadModel, index: index)
        
        debugPrint("Error while downloading file: \(downloadModel.fileName)  Error: \(error)")
    }
    
    //Oppotunity to handle destination does not exists error
    //This delegate will be called on the session queue so handle it appropriately
    func downloadRequestDestinationDoestNotExists(downloadModel: MZDownloadModel, index: Int, location: NSURL) {
        let myDownloadPath = MZUtility.baseFilePath + "/Default folder"
        if !NSFileManager.defaultManager().fileExistsAtPath(myDownloadPath) {
            try! NSFileManager.defaultManager().createDirectoryAtPath(myDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
        let fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).stringByAppendingPathComponent(downloadModel.fileName as String))
        let path =  myDownloadPath + "/" + (fileName as String)
        try! NSFileManager.defaultManager().moveItemAtURL(location, toURL: NSURL(fileURLWithPath: path))
        debugPrint("Default folder path: \(myDownloadPath)")
    }
}


