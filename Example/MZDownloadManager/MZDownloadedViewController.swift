//
//  MZDownloadedViewController.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 23/10/2014.
//  Copyright (c) 2014 ideamakerz. All rights reserved.
//

import UIKit
import MZDownloadManager

class MZDownloadedViewController: UITableViewController {
    
    var downloadedFilesArray : [String] = []
    var selectedIndexPath    : NSIndexPath?
    var fileManger           : NSFileManager = NSFileManager.defaultManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        do {
            let contentOfDir: [String] = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(MZUtility.baseFilePath as String)
            downloadedFilesArray.appendContentsOf(contentOfDir)
            
            let index = downloadedFilesArray.indexOf(".DS_Store")
            if let index = index {
                downloadedFilesArray.removeAtIndex(index)
            }
            
        } catch let error as NSError {
            print("Error while getting directory content \(error)")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("downloadFinishedNotification:"), name: MZUtility.DownloadCompletedNotif as String, object: nil)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MZDownloadedViewController.downloadFinishedNotification(_:)), name: DownloadCompletedNotif as String, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - NSNotification Methods -
    
    func downloadFinishedNotification(notification : NSNotification) {
        let fileName : NSString = notification.object as! NSString
        downloadedFilesArray.append(fileName.lastPathComponent)
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
}

//MARK: UITableViewDataSource Handler Extension

extension MZDownloadedViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedFilesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier : NSString = "DownloadedFileCell"
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier as String, forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = downloadedFilesArray[indexPath.row]
        
        return cell
    }
}

//MARK: UITableViewDelegate Handler Extension

extension MZDownloadedViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedIndexPath = indexPath
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let fileName : NSString = downloadedFilesArray[indexPath.row] as NSString
        let fileURL  : NSURL = NSURL(fileURLWithPath: (MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(fileName as String))
        
        do {
            try fileManger.removeItemAtURL(fileURL)
            downloadedFilesArray.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        } catch let error as NSError {
            debugPrint("Error while deleting file: \(error)")
        }
    }
}
