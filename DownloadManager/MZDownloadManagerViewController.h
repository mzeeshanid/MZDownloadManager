//
//  MZDownloaderViewController.h
//  VDownloader
//
//  Created by Muhammad Zeeshan on 2/13/14.
//  Copyright (c) 2014 Muhammad Zeeshan. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kMZDownloadKeyURL;
extern NSString * const kMZDownloadKeyStartTime;
extern NSString * const kMZDownloadKeyFileName;
extern NSString * const kMZDownloadKeyProgress;
extern NSString * const kMZDownloadKeyTask;
extern NSString * const kMZDownloadKeyStatus;
extern NSString * const kMZDownloadKeyDetails;
extern NSString * const kMZDownloadKeyResumeData;

extern NSString * const RequestStatusDownloading;
extern NSString * const RequestStatusPaused;
extern NSString * const RequestStatusFailed;

@protocol MZDownloadDelegate <NSObject>
@optional
/**A delegate method called each time whenever new download task is start downloading
 */
- (void)downloadRequestStarted:(NSURLSessionDownloadTask *)downloadTask;
/**A delegate method called each time whenever any download task is cancelled by the user
 */
- (void)downloadRequestCanceled:(NSURLSessionDownloadTask *)downloadTask;
/**A delegate method called each time whenever any download task is finished successfully
 */
- (void)downloadRequestFinished:(NSString *)fileName;
@end

@interface MZDownloadManagerViewController : UIViewController
{
    
}
/**An array that holds the information about all downloading tasks.
 */
@property(nonatomic, strong) NSMutableArray *downloadingArray;
/**A table view for displaying details of on going download tasks.
 */
@property(nonatomic, weak) IBOutlet UITableView *bgDownloadTableView;
/**A session manager for background downloading.
 */
@property(nonatomic, strong) NSURLSession *sessionManager;
@property (nonatomic, weak) id<MZDownloadDelegate> delegate;

- (NSURLSession *)backgroundSession;
/**A method for adding new download task.
 @param NSString* file name
 @param NSString* file url
 */
- (void)addDownloadTask:(NSString *)fileName fileURL:(NSString *)fileURL;
/**A method for restoring any interrupted download tasks e.g user force quits the app or any network error occurred.
 */
- (void)populateOtherDownloadTasks;
@end
