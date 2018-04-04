//
//  MZUtility.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 22/10/2014.
//  Copyright (c) 2014 ideamakerz. All rights reserved.
//

import UIKit

open class MZUtility: NSObject {
    
    @objc open static let DownloadCompletedNotif: String = {
        return "com.MZDownloadManager.DownloadCompletedNotif"
    }()
    
    @objc open static let baseFilePath: String = {
        return (NSHomeDirectory() as NSString).appendingPathComponent("Documents") as String
    }()

    @objc open class func getUniqueFileNameWithPath(_ filePath : NSString) -> NSString {
        let fullFileName        : NSString = filePath.lastPathComponent as NSString
        let fileName            : NSString = fullFileName.deletingPathExtension as NSString
        let fileExtension       : NSString = fullFileName.pathExtension as NSString
        var suggestedFileName   : NSString = fileName
        
        var isUnique            : Bool = false
        var fileNumber          : Int = 0
        
        let fileManger          : FileManager = FileManager.default
        
        repeat {
            var fileDocDirectoryPath : NSString?
            
            if fileExtension.length > 0 {
                fileDocDirectoryPath = "\(filePath.deletingLastPathComponent)/\(suggestedFileName).\(fileExtension)" as NSString?
            } else {
                fileDocDirectoryPath = "\(filePath.deletingLastPathComponent)/\(suggestedFileName)" as NSString?
            }
            
            let isFileAlreadyExists : Bool = fileManger.fileExists(atPath: fileDocDirectoryPath! as String)
            
            if isFileAlreadyExists {
                fileNumber += 1
                suggestedFileName = "\(fileName)(\(fileNumber))" as NSString
            } else {
                isUnique = true
                if fileExtension.length > 0 {
                    suggestedFileName = "\(suggestedFileName).\(fileExtension)" as NSString
                }
            }
        
        } while isUnique == false
        
        return suggestedFileName
    }
    
    @objc open class func calculateFileSizeInUnit(_ contentLength : Int64) -> Float {
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
    
    @objc open class func calculateUnit(_ contentLength : Int64) -> NSString {
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
    
    @objc open class func addSkipBackupAttributeToItemAtURL(_ docDirectoryPath : NSString) -> Bool {
        let url : URL = URL(fileURLWithPath: docDirectoryPath as String)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            
            do {
                try (url as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
                return true
            } catch let error as NSError {
                print("Error excluding \(url.lastPathComponent) from backup \(error)")
                return false
            }

        } else {
            return false
        }
    }
    
    @objc open class func getFreeDiskspace() -> NSNumber? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let systemAttributes: AnyObject?
        do {
            systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: documentDirectoryPath.last!) as AnyObject?
            let freeSize = systemAttributes?[FileAttributeKey.systemFreeSize] as? NSNumber
            return freeSize
        } catch let error as NSError {
            print("Error Obtaining System Memory Info: Domain = \(error.domain), Code = \(error.code)")
            return nil;
        }
    }
    
    @objc open class func removeAllFiles() {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: MZUtility.baseFilePath)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
}
