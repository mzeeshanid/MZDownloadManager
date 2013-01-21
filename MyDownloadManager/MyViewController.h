//
//  MyViewController.h
//  MyDownloadManager
//
//  Created by Muhammad Zeeshan on 1/20/13.
//  Copyright (c) 2013 FUUAST. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadTableViewController.h"
#import "ASIHTTPRequest.h"
@interface MyViewController : UIViewController<DownloadTableViewControllerDelegate>
{
    IBOutlet UITableView *myTableView;
    DownloadTableViewController *downloadTableViewObj;
    
    NSMutableArray *urlArray;
}
-(void)showManagerButtonTapped:(UIBarButtonItem *)sender;
-(void)checkForInterruptedDownload;
-(void)downloadButtonTapped:(UIButton *)sender;
@end
