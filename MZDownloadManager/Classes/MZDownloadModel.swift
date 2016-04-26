//
//  MZDownloadModel.swift
//  MZDownloadManager
//
//  Created by Hamid Ismail on 19/04/2016.
//  Copyright © 2016 ideamakerz. All rights reserved.
//

import UIKit

enum TaskStatus: Int {
    case Unknown, GettingInfo, Downloading, Paused, Failed
    
    func description() -> String {
        switch self {
        case .GettingInfo:
            return "GettingInfo"
        case .Downloading:
            return "Downloading"
        case .Paused:
            return "Paused"
        case .Failed:
            return "Failed"
        default:
            return "Unknown"
        }
    }
}

class MZDownloadModel: NSObject {
    
    var fileName: String!
    var fileURL: String!
    var status: String = TaskStatus.GettingInfo.description()
    
    var file: (size: Float, unit: String)?
    var downloadedFile: (size: Float, unit: String)?
    
    var remainingTime: (hours: Int, minutes: Int, seconds: Int)?
    
    var speed: (speed: Float, unit: String)?
    
    var progress: Float = 0
    
    var task: NSURLSessionDownloadTask?
    
    var startTime: NSDate?
    
    convenience init(fileName: String, fileURL: String) {
        self.init()
        
        self.fileName = fileName
        self.fileURL = fileURL
    }
}
