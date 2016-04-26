//
//  MZUtility.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 22/10/2014.
//  Copyright (c) 2014 ideamakerz. All rights reserved.
//

import UIKit

let fileDest               : NSString = (NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents")
let DownloadCompletedNotif : NSString = "DownloadCompletedNotif"
let kAlertTitle            : NSString = "Message"

class MZUtility: NSObject {
    
    class func showAlertViewWithTitle(titl : NSString, msg : NSString) {
        let alertview : UIAlertView = UIAlertView()
        alertview.title = titl as String
        alertview.message = msg as String
        alertview.addButtonWithTitle("Ok")
        alertview.cancelButtonIndex = 0
        alertview.show()
    }
    
    class func getUniqueFileNameWithPath(filePath : NSString) -> NSString {
        let fullFileName        : NSString = filePath.lastPathComponent
        let fileName            : NSString = fullFileName.stringByDeletingPathExtension
        let fileExtension       : NSString = fullFileName.pathExtension
        var suggestedFileName   : NSString = fileName
        
        var isUnique            : Bool = false
        var fileNumber          : Int = 0
        
        let fileManger          : NSFileManager = NSFileManager.defaultManager()
        
        repeat {
            var fileDocDirectoryPath : NSString?
            
            if fileExtension.length > 0 {
                fileDocDirectoryPath = "\(filePath.stringByDeletingLastPathComponent)/\(suggestedFileName).\(fileExtension)"
            } else {
                fileDocDirectoryPath = "\(filePath.stringByDeletingLastPathComponent)/\(suggestedFileName)"
            }
            
            let isFileAlreadyExists : Bool = fileManger.fileExistsAtPath(fileDocDirectoryPath! as String)
            
            if isFileAlreadyExists {
                fileNumber += 1
                suggestedFileName = "\(fileName)(\(fileNumber))"
            } else {
                isUnique = true
                if fileExtension.length > 0 {
                    suggestedFileName = "\(suggestedFileName).\(fileExtension)"
                }
            }
        
        } while isUnique == false
        
        return suggestedFileName
    }
    
    class func calculateFileSizeInUnit(contentLength : Int64) -> Float {
        let dataLength : Float64 = Float64(contentLength)
        if dataLength >= (1024.0*1024.0*1024.0) {
            return Float(dataLength/(1024.0*1024.0*1024.0))
        } else if dataLength >= 1024.0*1024.0 {
            return Float(dataLength/(1024.0*1024.0))
        } else if dataLength >= 1024.0 {
            return Float(dataLength/1024.0)
        } else {
            return Float(dataLength)
        }
    }
    
    class func calculateUnit(contentLength : Int64) -> NSString {
        if(contentLength >= (1024*1024*1024)) {
            return "GB"
        } else if contentLength >= (1024*1024) {
            return "MB"
        } else if contentLength >= 1024 {
            return "KB"
        } else {
            return "Bytes"
        }
    }
    
    class func addSkipBackupAttributeToItemAtURL(docDirectoryPath : NSString) -> Bool {
        let url : NSURL = NSURL(fileURLWithPath: docDirectoryPath as String)
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(url.path!) {
            
            do {
                try url.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
                return true
            } catch let error as NSError {
                print("Error excluding \(url.lastPathComponent) from backup \(error)")
                return false
            }

        } else {
            return false
        }
    }
    
    class func getFreeDiskspace() -> Int64? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let systemAttributes: AnyObject?
        do {
            systemAttributes = try NSFileManager.defaultManager().attributesOfFileSystemForPath(documentDirectoryPath.last!)
            let freeSize = systemAttributes?[NSFileSystemFreeSize] as? NSNumber
            return freeSize?.longLongValue
        } catch let error as NSError {
            print("Error Obtaining System Memory Info: Domain = \(error.domain), Code = \(error.code)")
            return nil;
        }
    }
}
