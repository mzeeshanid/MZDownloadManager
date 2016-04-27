# MZDownloadManager

[![CI Status](http://img.shields.io/travis/mzeeshanid/MZDownloadManager.svg?style=flat)](https://travis-ci.org/mzeeshanid/MZDownloadManager)
[![Version](https://img.shields.io/cocoapods/v/MZDownloadManager.svg?style=flat)](http://cocoapods.org/pods/MZDownloadManager)
[![License](https://img.shields.io/cocoapods/l/MZDownloadManager.svg?style=flat)](http://cocoapods.org/pods/MZDownloadManager)
[![Platform](https://img.shields.io/cocoapods/p/MZDownloadManager.svg?style=flat)](http://cocoapods.org/pods/MZDownloadManager)

![mzdownload manager hero](https://cloud.githubusercontent.com/assets/2767152/3459842/0c40fe66-0211-11e4-90d8-d8942c8f8651.png)

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

+ Minimum deployment target is iOS 8.
+ For resuming downloads server must have resuming support.

## Installation

MZDownloadManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MZDownloadManager"
```

## Author

Muhammad Zeeshan, mzeeshanid@yahoo.com

If you find MZDownloadManager userful consider donating thanks ;)</br>
[![Donate button](https://www.paypalobjects.com/en_US/DE/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BMKTVHYK6PUUG)

## License

MZDownloadManager is available under the BSD license. See the LICENSE file for more info.
