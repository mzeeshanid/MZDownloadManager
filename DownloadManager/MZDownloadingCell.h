//
//  MZDownloadingCell.h
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 1/11/14.
//  Copyright (c) 2014 Muhammad Zeeshan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MZDownloadingCell : UITableViewCell
{
    
}

@property(nonatomic, weak) IBOutlet UILabel *lblTitle;
@property(nonatomic, weak) IBOutlet UILabel *lblDetails;
@property(nonatomic, weak) IBOutlet UIProgressView *progressDownload;
@property(nonatomic, weak) IBOutlet UIButton *btnPause;
@property(nonatomic, weak) IBOutlet UIButton *btnCancel;
@end
