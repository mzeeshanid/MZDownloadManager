//
//  MZAvailableDownloadsViewController.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 23/10/2014.
//  Copyright (c) 2014 ideamakerz. All rights reserved.
//

import UIKit
import MZDownloadManager

class MZAvailableDownloadsViewController: UITableViewController {

    var mzDownloadingViewObj    : MZDownloadManagerViewController?
    var availableDownloadsArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        availableDownloadsArray.append("http://dl.dropbox.com/u/97700329/file1.mp4")
        availableDownloadsArray.append("http://dl.dropbox.com/u/97700329/file2.mp4")
        availableDownloadsArray.append("http://dl.dropbox.com/u/97700329/file3.mp4")
        availableDownloadsArray.append("http://dl.dropbox.com/u/97700329/FileZilla_3.6.0.2_i686-apple-darwin9.app.tar.bz2")
        availableDownloadsArray.append("http://dl.dropbox.com/u/97700329/GCDExample-master.zip")
        
        self.setUpDownloadingViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpDownloadingViewController() {
        let tabBarTabs : NSArray? = self.tabBarController?.viewControllers
        let mzDownloadingNav : UINavigationController = tabBarTabs?.objectAtIndex(1) as! UINavigationController
        
        mzDownloadingViewObj = mzDownloadingNav.viewControllers[0] as? MZDownloadManagerViewController
    }
}

//MARK: UITableViewDataSource Handler Extension

extension MZAvailableDownloadsViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableDownloadsArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier : NSString = "AvailableDownloadsCell"
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier as String, forIndexPath: indexPath) as UITableViewCell
        
        let fileURL  : NSString = availableDownloadsArray[indexPath.row] as NSString
        let fileName : NSString = fileURL.lastPathComponent
        
        cell.textLabel?.text = fileName as String
        
        return cell
    }
}

//MARK: UITableViewDelegate Handler Extension

extension MZAvailableDownloadsViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let fileURL  : NSString = availableDownloadsArray[indexPath.row] as NSString
        var fileName : NSString = fileURL.lastPathComponent
        fileName = MZUtility.getUniqueFileNameWithPath((MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(fileName as String))
        
        mzDownloadingViewObj?.downloadManager.addDownloadTask(fileName as String, fileURL: fileURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        availableDownloadsArray.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
    }
}
