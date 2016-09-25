//
//  MZDownloadingCell.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 22/10/2014.
//  Copyright (c) 2014 ideamakerz. All rights reserved.
//

import UIKit
import MZDownloadManager

class MZDownloadingCell: UITableViewCell {

    @IBOutlet var lblTitle : UILabel?
    @IBOutlet var lblDetails : UILabel?
    @IBOutlet var progressDownload : UIProgressView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCellForRowAtIndexPath(_ indexPath : IndexPath, downloadModel: MZDownloadModel) {
        
        self.lblTitle?.text = "File Title: \(downloadModel.fileName!)"
        self.progressDownload?.progress = downloadModel.progress
        
        var remainingTime: String = ""
        if downloadModel.progress == 1.0 {
            remainingTime = "Please wait..."
        } else if let _ = downloadModel.remainingTime {
            if (downloadModel.remainingTime?.hours)! > 0 {
                remainingTime = "\(downloadModel.remainingTime!.hours) Hours "
            }
            if (downloadModel.remainingTime?.minutes)! > 0 {
                remainingTime = remainingTime + "\(downloadModel.remainingTime!.minutes) Min "
            }
            if (downloadModel.remainingTime?.seconds)! > 0 {
                remainingTime = remainingTime + "\(downloadModel.remainingTime!.seconds) sec"
            }
        } else {
            remainingTime = "Calculating..."
        }
        
        var fileSize = "Getting information..."
        if let _ = downloadModel.file?.size {
            fileSize = String(format: "%.2f %@", (downloadModel.file?.size)!, (downloadModel.file?.unit)!)
        }

        var speed = "Calculating..."
        if let _ = downloadModel.speed?.speed {
            speed = String(format: "%.2f %@/sec", (downloadModel.speed?.speed)!, (downloadModel.speed?.unit)!)
        }
        
        var downloadedFileSize = "Calculating..."
        if let _ = downloadModel.downloadedFile?.size {
            downloadedFileSize = String(format: "%.2f %@", (downloadModel.downloadedFile?.size)!, (downloadModel.downloadedFile?.unit)!)
        }
        
        let detailLabelText = NSMutableString()
        detailLabelText.appendFormat("File Size: \(fileSize)\nDownloaded: \(downloadedFileSize) (%.2f%%)\nSpeed: \(speed)\nTime Left: \(remainingTime)\nStatus: \(downloadModel.status)" as NSString, downloadModel.progress * 100.0)
        lblDetails?.text = detailLabelText as String
    }
}
