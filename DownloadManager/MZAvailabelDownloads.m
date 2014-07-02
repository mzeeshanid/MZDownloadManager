//
//  ViewController.m
//  DownloadManager
//
//  Created by Muhammad Zeeshan on 5/6/14.
//  Copyright (c) 2014 Ideamakerz. All rights reserved.
//

#import "MZAvailabelDownloads.h"
#import "MZDownloadManagerViewController.h"

@interface MZAvailabelDownloads () <MZDownloadDelegate>
{
    IBOutlet UITableView *availableDownloadTableView;
    
    NSMutableArray *availableDownloadsArray;
    
    MZDownloadManagerViewController *mzDownloadingViewObj;
}
@end

@implementation MZAvailabelDownloads

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    availableDownloadsArray = [NSMutableArray arrayWithObjects:
                               @"http://dl.dropbox.com/u/97700329/file1.mp4",
                               @"http://dl.dropbox.com/u/97700329/file2.mp4",
                               @"http://dl.dropbox.com/u/97700329/file3.mp4",
                               @"http://dl.dropbox.com/u/97700329/FileZilla_3.6.0.2_i686-apple-darwin9.app.tar.bz2",
                               @"http://dl.dropbox.com/u/97700329/GCDExample-master.zip", nil];
    
    UINavigationController *mzDownloadingNav = [self.tabBarController.viewControllers objectAtIndex:1];
    mzDownloadingViewObj = [mzDownloadingNav.viewControllers objectAtIndex:0];
    [mzDownloadingViewObj setDelegate:self];
    
    mzDownloadingViewObj.downloadingArray = [[NSMutableArray alloc] init];
    mzDownloadingViewObj.sessionManager = [mzDownloadingViewObj backgroundSession];
    [mzDownloadingViewObj populateOtherDownloadTasks];
    
    [self updateDownloadingTabBadge];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - My Methods -
- (void)updateDownloadingTabBadge
{
    UITabBarItem *downloadingTab = [self.tabBarController.tabBar.items objectAtIndex:1];
    int badgeCount = mzDownloadingViewObj.downloadingArray.count;
    if(badgeCount == 0)
        [downloadingTab setBadgeValue:nil];
    else
        [downloadingTab setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
}
#pragma mark - Tableview Delegate and Datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return availableDownloadsArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AvailableDownloadsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell.textLabel setText:[[[availableDownloadsArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"] lastObject]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *urlLastPathComponent = [[[availableDownloadsArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"] lastObject];
    NSString *fileName = [MZUtility getUniqueFileNameForName:urlLastPathComponent];
    [mzDownloadingViewObj addDownloadTask:fileName fileURL:[availableDownloadsArray objectAtIndex:indexPath.row]];
    
    [self updateDownloadingTabBadge];
    
    [availableDownloadsArray removeObjectAtIndex:indexPath.row];
    [availableDownloadTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
#pragma mark - MZDownloadManager Delegates -
-(void)downloadRequestStarted:(NSURLSessionDownloadTask *)downloadTask
{
    [self updateDownloadingTabBadge];
}
-(void)downloadRequestFinished:(NSString *)fileName
{
    [self updateDownloadingTabBadge];
    NSString *docDirectoryPath = [fileDest stringByAppendingPathComponent:fileName];
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadCompletedNotif object:docDirectoryPath];
}
-(void)downloadRequestCanceled:(NSURLSessionDownloadTask *)downloadTask
{
    [self updateDownloadingTabBadge];
}
@end
