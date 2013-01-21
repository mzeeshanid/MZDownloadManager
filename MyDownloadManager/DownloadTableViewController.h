//
//  DownloadTableViewController.h
//  MyDownloadManager
//
//  Created by Muhammad Zeeshan on 11/8/12.
//  Copyright (c) 2012 FUUAST. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DownloadCell.h"
#import "ASIHTTPRequest.h"

#define kDownloadKeyTitle @"key"
#define kDownloadKeyImage @"image"
#define kDownloadErrorDomain @"DownloadErrorDomain"
#define kDownloadErrorCodeCancelled (-1)

@class DownloadTableViewController;

@protocol DownloadTableViewControllerDelegate <NSObject>
@optional
-(void)downloadController:(DownloadTableViewController *)vc startedDownloadingRequest:(ASIHTTPRequest *)request;
-(void)downloadController:(DownloadTableViewController *)vc finishedDownloadingReqeust:(ASIHTTPRequest *)request;
-(void)downloadController:(DownloadTableViewController *)vc failedDownloadingReqeust:(ASIHTTPRequest *)request;
@end

@interface DownloadTableViewController : UITableViewController<ASIHTTPRequestDelegate,ASIProgressDelegate>
{
    NSMutableArray *downloadingArray;
    
    NSString *downloadDirectory;
    
    NSMutableDictionary *dict;
    
    NSOperationQueue *downloadingRequestsQueue;
    
    int objectAtIndex;

    id <DownloadTableViewControllerDelegate>__unsafe_unretained delegate;
}
-(void)setupCell:(DownloadCell *)cell withRequest:(ASIHTTPRequest *)request;
-(void)addDownloadRequest:(ASIHTTPRequest *)request;
-(void)getInterruptedDownloadsAndResume;
-(void)resumeDownloadRequest:(ASIHTTPRequest *)request;
-(void)removeRequestAtIndex:(NSInteger)index;
-(void)cancelDownloadingURLAtIndex:(NSInteger)index;
-(void)removeRequest:(ASIHTTPRequest *)request;
-(void)createDirectoryIfNotExistAtPath:(NSString *)path;

@property (nonatomic, copy)NSString *downloadDirectory;
@property (nonatomic, readonly) NSInteger numberOfDownloads;
@property (nonatomic, unsafe_unretained) id <DownloadTableViewControllerDelegate>delegate;
@end
