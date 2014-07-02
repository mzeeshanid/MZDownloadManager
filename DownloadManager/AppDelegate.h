//
//  AppDelegate.h
//  DownloadManager
//
//  Created by Muhammad Zeeshan on 5/6/14.
//  Copyright (c) 2014 Ideamakerz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy) void (^backgroundSessionCompletionHandler)();

@end
