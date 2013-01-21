//
//  DownloadCell.h
//  MyDownloadManager
//
//  Created by Muhammad Zeeshan on 11/8/12.
//  Copyright (c) 2012 FUUAST. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellID @"cell"
#define kDownloadCellProgressViewHeight 15.0f
#define kDownloadCellHeight 70.0f
#define kAvailableCellHeight 44.0
@interface DownloadCell : UITableViewCell
{
    UIProgressView *progressView;
}
+ (id)downloadCell;

@property (nonatomic, assign)float progress;
@end
