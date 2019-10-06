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
    
    let myDownloadPath = MZUtility.baseFilePath + "/My Downloads"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !FileManager.default.fileExists(atPath: myDownloadPath) {
            try! FileManager.default.createDirectory(atPath: myDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
        debugPrint("custom download path: \(myDownloadPath)")

        availableDownloadsArray.append("https://www.dropbox.com/s/6xlpner3s6q336f/file1.mp4?dl=1")
        availableDownloadsArray.append("https://www.dropbox.com/s/73ymbx6icoiqus9/file2.mp4?dl=1")
        availableDownloadsArray.append("https://www.dropbox.com/s/4pw4jwiju0eon6r/file3.mp4?dl=1")
        availableDownloadsArray.append("https://www.dropbox.com/s/2bmbk8id7nseirq/file4.mp4?dl=1")
        availableDownloadsArray.append("https://www.dropbox.com/s/cw7wfyaic9rtzwd/GCDExample-master.zip?dl=1")
        availableDownloadsArray.append("https://www.dropbox.com/s/y9kgs6caztxxjdh/AlecrimCoreData-master.zip?dl=1")
        
        self.setUpDownloadingViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpDownloadingViewController() {
        let tabBarTabs : NSArray? = self.tabBarController?.viewControllers as NSArray?
        let mzDownloadingNav : UINavigationController = tabBarTabs?.object(at: 1) as! UINavigationController
        
        mzDownloadingViewObj = mzDownloadingNav.viewControllers[0] as? MZDownloadManagerViewController
    }
}

//MARK: UITableViewDataSource Handler Extension

extension MZAvailableDownloadsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableDownloadsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier : NSString = "AvailableDownloadsCell"
        let cell : UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier as String, for: indexPath) as UITableViewCell
        
        let fileURL  : NSString = availableDownloadsArray[(indexPath as NSIndexPath).row] as NSString
        let fileName : NSString = fileURL.lastPathComponent as NSString
        
        cell.textLabel?.text = fileName as String
        
        return cell
    }
}

//MARK: UITableViewDelegate Handler Extension

extension MZAvailableDownloadsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let fileURL  : NSString = availableDownloadsArray[(indexPath as NSIndexPath).row] as NSString
        var fileName : NSString = fileURL.lastPathComponent as NSString
        fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(fileName as String) as NSString)
        
        //Use it download at default path i.e document directory
//        mzDownloadingViewObj?.downloadManager.addDownloadTask(fileName as String, fileURL: fileURL as String)
        
        mzDownloadingViewObj?.downloadManager.addDownloadTask(fileName as String, fileURL: fileURL as String, destinationPath: myDownloadPath)
        
        availableDownloadsArray.remove(at: (indexPath as NSIndexPath).row)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
    }
}
