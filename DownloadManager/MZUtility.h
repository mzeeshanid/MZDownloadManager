//
//  MZUtility.h
//  DownloadManager
//
//  Created by Muhammad Zeeshan on 5/6/14.
//  Copyright (c) 2014 Ideamakerz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAlertTitle @"MZDownloadManager"
#define fileDest [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"]
#define DownloadCompletedNotif @"DownloadCompletedNotif"

@interface MZUtility : NSObject
{
    
}
/**A method to show any occurred error.
@param NSString* title for alertview
@param NSString* messages for alertview
*/
+ (void)showAlertViewWithTitle:(NSString *)titl msg:(NSString *)msg;
/**A method to for deleting all white space characters from provided a string.
 @param NSString* from which we need to remove white space characters.
 @return new string by deleting white space characters
 */
+ (NSString *)trimWhitespace:(NSString *)text;
/**A method for generating unique file names.
 @param NSString* required file name.
 @return new file name if file already exists with the provided name.
 */
+ (NSString *)getUniqueFileNameForName:(NSString *)fullFileName;
/**A method for getting unit filesize.
 @param (unsigned long long)contentLength size in bytes.
 @return size in units.
 */
+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength;
/**A method for getting unit.
 @param (unsigned long long)contentLength size in bytes.
 @return units of size e.g MB, KB, GB.
 */
+ (NSString *)calculateUnit:(unsigned long long)contentLength;

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)docDirectoryPath;
/**A method for getting free disk space.
 @return free disk space.
 */
+ (uint64_t)getFreeDiskspace;
@end
