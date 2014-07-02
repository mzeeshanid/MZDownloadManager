//
//  MZUtility.m
//  DownloadManager
//
//  Created by Muhammad Zeeshan on 5/6/14.
//  Copyright (c) 2014 Ideamakerz. All rights reserved.
//

#import "MZUtility.h"

@implementation MZUtility
+ (void)showAlertViewWithTitle:(NSString *)titl msg:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titl message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}
+ (NSString *)trimWhitespace:(NSString *)text
{
    NSMutableString *str = [[NSMutableString alloc] initWithString:text];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
    return str;
}
+ (NSString *)getUniqueFileNameForName:(NSString *)fullFileName
{
    NSString *fileName = [fullFileName stringByDeletingPathExtension];
    NSString *fileExtension = [fullFileName pathExtension];
    NSString *suggestedFileName = [NSString stringWithFormat:@"%@",fileName];
    
    BOOL isUnique = FALSE;
    int fileNumber = 0;
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    
    do {
        
        NSString *fileDocDirectoryPath = [NSString stringWithFormat:@"%@/%@.%@",fileDest,suggestedFileName,fileExtension];
        BOOL isFileAlreadyExists = [fileManger fileExistsAtPath:fileDocDirectoryPath];
        
        if(isFileAlreadyExists)
        {
            fileNumber++;
            suggestedFileName = [NSString stringWithFormat:@"%@(%d)",fileName,fileNumber];
        }
        else
        {
            isUnique = TRUE;
            suggestedFileName = [NSString stringWithFormat:@"%@.%@",suggestedFileName,fileExtension];
        }
        
    } while (isUnique == FALSE);
    
    return suggestedFileName;
}
+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3))
        return (float) (contentLength / (float)pow(1024, 3));
    else if(contentLength >= pow(1024, 2))
        return (float) (contentLength / (float)pow(1024, 2));
    else if(contentLength >= 1024)
        return (float) (contentLength / (float)1024);
    else
        return (float) (contentLength);
}
+ (NSString *)calculateUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3))
        return @"GB";
    else if(contentLength >= pow(1024, 2))
        return @"MB";
    else if(contentLength >= 1024)
        return @"KB";
    else
        return @"Bytes";
}
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)docDirectoryPath
{
    NSURL *URL = [NSURL fileURLWithPath:docDirectoryPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:[URL path]])
    {
        NSError *error = nil;
        BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success)
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        return success;
    }
    return NO;
}
+ (uint64_t)getFreeDiskspace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %d", [error domain], [error code]);
    }
    
    return totalFreeSpace;
}
@end
