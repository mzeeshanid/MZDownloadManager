//
//  DownloadCell.m
//  MyDownloadManager
//
//  Created by Muhammad Zeeshan on 11/8/12.
//  Copyright (c) 2012 FUUAST. All rights reserved.
//

#import "DownloadCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation DownloadCell

+ (id)downloadCell
{
    return [[self alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:15.0f];
        
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
        self.detailTextLabel.numberOfLines = 3;
        
        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:progressView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        self.textLabel.text = @"Download";
    }
    return self;
}
-(void)willMoveToSuperview:(UIView *)newSuperview
{
    CGRect rect = self.contentView.bounds;
	self.imageView.layer.cornerRadius = 7.5f;
	rect.size.width = rect.size.width - (self.imageView.frame.size.width + 20.0f);
	rect.size.height = kDownloadCellHeight;
	rect.origin.x = self.imageView.frame.size.width + 10.0f;
	rect.origin.y = kDownloadCellHeight - kDownloadCellProgressViewHeight;
	progressView.frame = rect;
}
-(float)progress
{
    return progressView.progress;
}
-(void)setProgress:(float)progress
{
    progressView.progress = progress;
}
@end
