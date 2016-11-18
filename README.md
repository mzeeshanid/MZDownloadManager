# MZDownloadManager

[![CI Status](http://img.shields.io/travis/mzeeshanid/MZDownloadManager.svg?style=flat)](https://travis-ci.org/mzeeshanid/MZDownloadManager)
[![Version](https://img.shields.io/cocoapods/v/MZDownloadManager.svg?style=flat)](http://cocoapods.org/pods/MZDownloadManager)
[![License](https://img.shields.io/cocoapods/l/MZDownloadManager.svg?style=flat)](http://cocoapods.org/pods/MZDownloadManager)
[![Platform](https://img.shields.io/cocoapods/p/MZDownloadManager.svg?style=flat)](http://cocoapods.org/pods/MZDownloadManager)

![mzdownload manager hero](https://cloud.githubusercontent.com/assets/2767152/18860606/655c21ea-8498-11e6-9bf9-05b5405d119a.jpg)

## Features

This download manager uses the iOS 7 NSURLSession api to download files.
+ Can download large files if app is in background.
+ Can download files if app is in background.
+ Can download multiple files at a time.
+ It can resume interrupted downloads.
+ User can also pause the download.
+ User can retry any download if any error occurred during download.

<h3>Screencast:</h3>
http://screencast.com/t/Rzm0xoRjGF

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

+ Xcode 8
+ Minimum deployment target is iOS 9.
+ For resuming downloads server must have resuming support.

## Installation

MZDownloadManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MZDownloadManager"
```

## Update

New helper functions added to support downloading at custom path. Example project is also updated about the usage.

To download file at custom path you can use the following instance method of MZDownloadManager:
    
```public func addDownloadTask(fileName: String, fileURL: String, destinationPath: String)```
      
#### When download completes:
    
* It will check if the destination folder still exists then it will move the downloaded file at the specified destination and call success delegate method.
* If destination folder does not exists, following delegate method will provide an opportunity to handle the downloaded file appropriately.

```optional func downloadRequestDestinationDoestNotExists(downloadModel: MZDownloadModel, index: Int, location: NSURL)```

* If the above delegate method is not implemented then it will just called the failure method.

> Important: This delegate method will be called on the session's queue.

## Author

Muhammad Zeeshan, mzeeshanid@yahoo.com

If you find MZDownloadManager userful consider donating thanks ;)</br>
[![Donate button](https://www.paypalobjects.com/en_US/DE/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BMKTVHYK6PUUG)

## License

MZDownloadManager is available under the BSD license. See the LICENSE file for more info.
