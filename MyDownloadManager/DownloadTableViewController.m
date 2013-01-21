//
//  DownloadTableViewController.m
//  MyDownloadManager
//
//  Created by Muhammad Zeeshan on 11/8/12.
//  Copyright (c) 2012 FUUAST. All rights reserved.
//

#import "DownloadTableViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kDownloadKeyURL @"URL"
#define kDownloadKeyStartTime @"startTime"
#define kDownloadKeyTotalSize @"totalSize"
#define kDownloadKeyConnection @"connection"
#define kDownloadKeyFileName @"fileName"
#define kDownloadKeyFileHandle @"fileHandle"
#define kDownloadKeyInterrupted @"interruptedDownloads"


#define temporaryFileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Temporary Files"]
#define fileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Downloaded Files"]

@interface DownloadTableViewController ()

@end

@implementation DownloadTableViewController

@synthesize downloadDirectory;
@synthesize delegate;

- (id)init
{
    return [self initWithStyle:UITableViewStyleGrouped];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        // Custom initialization
        downloadingArray = [[NSMutableArray alloc] init];
		self.downloadDirectory = @"/var/mobile/Downloads";
		self.title = NSLocalizedString(@"Downloading", nil);
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void) dealloc
{
//    [super dealloc];
    [self.tableView beginUpdates];
    
	while (downloadingArray.count > 0)
        [self removeRequestAtIndex:0];
    
	[self.tableView endUpdates];
    
	self.downloadDirectory = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (NSInteger)numberOfDownloads
{
	return downloadingArray.count;
}
- (void)close
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Tableview Datasource And Delegate -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return downloadingArray.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Downloading"];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if(cell == Nil)
    {
        cell = [DownloadCell downloadCell];
    }
    [self setupCell:cell withRequest:[downloadingArray objectAtIndex:indexPath.row]];
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.imageView.layer.cornerRadius = 8.0f;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        if(indexPath.section == 0)
        {
            [self cancelDownloadingURLAtIndex:indexPath.row];
        }
    }
}
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/
/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark - My Methods -
- (void)setupCell:(DownloadCell *)cell withRequest:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = [request userInfo];
	NSString *title =  [userInfo objectForKey:kDownloadKeyTitle];
    
	if (title == nil) title = [userInfo objectForKey:kDownloadKeyFileName];
	if (title == nil) title = NSLocalizedString(@"Downloading...", nil);
	cell.textLabel.text = title;
	cell.imageView.image = [userInfo objectForKey:kDownloadKeyImage];
    
    NSFileHandle *fileHandle = [userInfo objectForKey:kDownloadKeyFileHandle];
    
    if (fileHandle != nil)
	{
		unsigned long long downloaded = [fileHandle offsetInFile];
		NSDate *startTime = [userInfo objectForKey:kDownloadKeyStartTime];
        unsigned long long total = [[userInfo objectForKey:kDownloadKeyTotalSize] unsignedLongLongValue];
        
		NSTimeInterval dt = -1 * [startTime timeIntervalSinceNow];
		float speed = downloaded / dt;
		unsigned long long remaining = total - downloaded;
		int remainingTime = (int)(remaining / speed);
		int hours = remainingTime / 3600;
		int minutes = (remainingTime - hours * 3600) / 60;
		int seconds = remainingTime - hours * 3600 - minutes * 60;
        
		float downloadedF, totalF;
		char prefix;
		if (total >= 1024 * 1024 * 1024) 
        {
			downloadedF = (float)downloaded / (1024 * 1024 * 1024);
			totalF = (float)total / (1024 * 1024 * 1024);
			prefix = 'G';
		} 
        else if (total >= 1024 * 1024) 
        {
			downloadedF = (float)downloaded / (1024 * 1024);
			totalF = (float)total / (1024 * 1024);
			prefix = 'M';
		} 
        else if (total >= 1024) 
        {
			downloadedF = (float)downloaded / 1024;
			totalF = (float)total / 1024;
			prefix = 'k';
		} 
        else 
        {
			downloadedF = (float)downloaded;
			totalF = (float)total;
			prefix = '\0';
		}
        
		//float speedNorm = downloadedF / dt;
		NSString *subtitle = [[NSString alloc] initWithFormat:@"%.2f of %.2f %cB, %02d:%02d:%02d remaining\n \n",downloadedF, totalF, prefix, hours, minutes, seconds];
		cell.detailTextLabel.text = subtitle;
		cell.progress = downloadedF / totalF;
	}
    else
	{
		cell.detailTextLabel.text = Nil;
	}
}
-(void)addDownloadRequest:(ASIHTTPRequest *)request
{
    if(!downloadingArray)
        downloadingArray = [[NSMutableArray alloc] init];
    [self createDirectoryIfNotExistAtPath:temporaryFileDestination];
    [self createDirectoryIfNotExistAtPath:downloadDirectory];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:kDownloadKeyInterrupted])
    {
        NSArray *array = [[NSArray alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:kDownloadKeyInterrupted];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kDownloadKeyInterrupted]];
    if(![array containsObject:[NSString stringWithFormat:@"%@",request.url]])
    {
        [array addObject:[NSString stringWithFormat:@"%@",request.url]];
        NSArray *array2 = [NSArray arrayWithArray:array];
        [[NSUserDefaults standardUserDefaults] setObject:array2 forKey:kDownloadKeyInterrupted];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [request setDelegate:self];
    [request setDownloadProgressDelegate:self];
    [request setAllowResumeForFileDownloads:YES];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setNumberOfTimesToRetryOnTimeout:100];
    [request setTimeOutSeconds:20.0];
    
    [[request userInfo] setValue:request.url forKey:kDownloadKeyURL];
    [[request userInfo] setValue:request.connectionID forKey:kDownloadKeyConnection];
    
    NSString *fileName = [[request userInfo] objectForKey:kDownloadKeyFileName];
    if(!fileName)
    {
        fileName = [[[request url] absoluteString] lastPathComponent];
        [[request userInfo] setValue:fileName forKey:kDownloadKeyFileName];
    }
    NSString *temporaryDestinationPath = [NSString stringWithFormat:@"%@/%@.download",temporaryFileDestination,fileName];
    [request setTemporaryFileDownloadPath:temporaryDestinationPath];
    
    if(![request requestHeaders])
    {
        BOOL success = [[NSFileManager defaultManager] createFileAtPath:[request temporaryFileDownloadPath] contents:Nil attributes:Nil];
        if(!success)
            NSLog(@"Failed to create file");
    }
    
    NSLog(@"temp dest path %@",temporaryDestinationPath);
    
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@/%@",downloadDirectory,fileName]];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:downloadingArray.count inSection:0];
	[downloadingArray addObject:request];
    if(!downloadingRequestsQueue)
        downloadingRequestsQueue = [[NSOperationQueue alloc] init];
    [downloadingRequestsQueue addOperation:request];
    NSArray *paths = [NSArray arrayWithObject:indexPath];
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
}
-(void)getInterruptedDownloadsAndResume
{
    int countOfRequests = [[[NSUserDefaults standardUserDefaults] objectForKey:kDownloadKeyInterrupted] count];
    NSLog(@"nsuserdefaults request %@",[[NSUserDefaults standardUserDefaults] objectForKey:kDownloadKeyInterrupted]);
    for(int i=0;i<countOfRequests;i++)
    {
        if(countOfRequests >0)
        {
            NSString *urlFromUserDefaults = [[[NSUserDefaults standardUserDefaults] objectForKey:kDownloadKeyInterrupted] objectAtIndex:i];
            BOOL urlIsAlreadyDownloading = FALSE;
            for(ASIHTTPRequest *req in downloadingArray)
            {
                if([[req.url absoluteString] isEqualToString:urlFromUserDefaults])
                {
                    urlIsAlreadyDownloading = TRUE;
                    break;
                }
            }
            if(urlIsAlreadyDownloading == FALSE)
            {
                NSURL *url = [NSURL URLWithString:urlFromUserDefaults];
                ASIHTTPRequest *_request = [[ASIHTTPRequest alloc] initWithURL:url];
                __unsafe_unretained ASIHTTPRequest *request = _request;
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                [request setUserInfo:dictionary];
                objectAtIndex = -1;
                [self resumeDownloadRequest:request];
            }
        }
    }
}
-(void)resumeDownloadRequest:(ASIHTTPRequest *)request
{
    objectAtIndex++;
    NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[temporaryFileDestination stringByAppendingPathComponent:@""] error:Nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",[NSString stringWithFormat:@".download"]];
    allFiles = [allFiles filteredArrayUsingPredicate:predicate];
    unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:[temporaryFileDestination stringByAppendingPathComponent:[allFiles objectAtIndex:objectAtIndex]] error:Nil] fileSize];
    
    if(size != 0)
    {
        NSString* range = @"bytes=";
        range = [range stringByAppendingString:[[NSNumber numberWithInt:size] stringValue]];
        range = [range stringByAppendingString:@"-"];
        [request addRequestHeader:@"Range" value:range];
    }
    [self addDownloadRequest:request];
}
-(void)removeRequestAtIndex:(NSInteger)index
{
    NSDictionary *userInfo = [[downloadingArray objectAtIndex:index] userInfo];

    NSFileHandle *fileHandle = [userInfo objectForKey:kDownloadKeyFileHandle];
    [fileHandle closeFile];
    
    [downloadingArray removeObjectAtIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSArray *paths = [NSArray arrayWithObject:indexPath];
    
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationRight];
}
-(void)cancelDownloadingURLAtIndex:(NSInteger)index
{
    NSDictionary *userInfo = [[downloadingArray objectAtIndex:index] userInfo];
    NSFileHandle *fileHandle = [userInfo objectForKey:kDownloadKeyFileHandle];
    [fileHandle closeFile];
    [[NSFileManager defaultManager] removeItemAtPath:[[downloadingArray objectAtIndex:index] temporaryFileDownloadPath] error:Nil];
        
    [[downloadingArray objectAtIndex:index] cancel];
    [downloadingArray removeObjectAtIndex:index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSArray *paths = [NSArray arrayWithObject:indexPath];
    
    [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationRight];
}
- (void)removeRequest:(ASIHTTPRequest *)request
{
    NSInteger index = -1;
	for (ASIHTTPRequest *req in downloadingArray)
	{
		if ([req isEqual:request])
		{
			index = [downloadingArray indexOfObject:req];
			break;
		}
	}
    
	if (index != -1)
		[self removeRequestAtIndex:index];
}
-(void)createDirectoryIfNotExistAtPath:(NSString *)path
{
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    if(error)
        NSLog(@"Error while creating directory %@",[error localizedDescription]);
}
#pragma mark - ASIHTTPRequest Delegate -
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"response headers %@",responseHeaders);
    for(ASIHTTPRequest *req in downloadingArray)
    {
        if([req isEqual:request])
        {
            NSFileHandle *fileHandle = [[req userInfo] objectForKey:kDownloadKeyFileHandle];
            if(fileHandle == Nil)
            {
                if(![req requestHeaders])
                {
                    fileHandle = [NSFileHandle fileHandleForWritingAtPath:req.temporaryFileDownloadPath];
                    [[req userInfo] setValue:fileHandle forKey:kDownloadKeyFileHandle];
                }
            }
            long long length = [[[req userInfo] objectForKey:kDownloadKeyTotalSize] longLongValue];
            if(length == 0)
            {
                length = [req contentLength];
                if (length != NSURLResponseUnknownLength)
                {
                    NSNumber *totalSize = [NSNumber numberWithUnsignedLongLong:(unsigned long long)length];
                    [[req userInfo] setValue:totalSize forKey:kDownloadKeyTotalSize];
                }
                [[req userInfo] setValue:[NSDate date] forKey:kDownloadKeyStartTime];
            }
            if([request requestHeaders])
            {
                NSString *range = [[request requestHeaders] objectForKey:@"Range"];
                NSString *numbers = [range stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
                unsigned long long size = [numbers longLongValue];
                
                if(length != 0)
                {
                    length = length + size;
                    NSNumber *totalSize = [NSNumber numberWithUnsignedLongLong:(unsigned long long)length];
                    [[req userInfo] setValue:totalSize forKey:kDownloadKeyTotalSize];
                    
                    
                    fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:req.temporaryFileDownloadPath];
                    [[req userInfo] setValue:fileHandle forKey:kDownloadKeyFileHandle];
                    [fileHandle seekToFileOffset:size];
                }   
            }
            if([self.delegate respondsToSelector:@selector(downloadController:finishedDownloadingReqeust:)])
                [self.delegate downloadController:self startedDownloadingRequest:request];
            if(length != 0)
                [self.tableView reloadData];
			break;
        }
    }
}
-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    for(ASIHTTPRequest *req in downloadingArray)
    {
        if([req isEqual:request])
        {
            NSFileHandle *fileHandle = [[req userInfo] objectForKey:kDownloadKeyFileHandle];
			[fileHandle writeData:data];
            
			NSInteger row = [downloadingArray indexOfObject:req];
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
			DownloadCell *cell = (DownloadCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [self setupCell:cell withRequest:req];
			break;
        }
    }
}
- (void)requestDone:(ASIHTTPRequest *)request
{
    NSLog(@"request success: %@ userInfo: %@",[request responseString],request.userInfo);
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kDownloadKeyInterrupted]];
    if([array containsObject:[NSString stringWithFormat:@"%@",request.url]])
    {
        [array removeObject:[NSString stringWithFormat:@"%@",request.url]];
        NSArray *array2 = [NSArray arrayWithArray:array];
        [[NSUserDefaults standardUserDefaults] setObject:array2 forKey:kDownloadKeyInterrupted];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSInteger index = -1;
    NSMutableDictionary *userInfo = nil;
    for (ASIHTTPRequest *req in downloadingArray)
    {
        if ([req isEqual:request])
        {
            userInfo = [NSMutableDictionary dictionaryWithDictionary:[req userInfo]];
            index = [downloadingArray indexOfObject:req];
            break;
        }
    }
    if (index != -1)
    {
        [self removeRequestAtIndex:index];
        
        if([self.delegate respondsToSelector:@selector(downloadController:finishedDownloadingReqeust:)])
            [self.delegate downloadController:self finishedDownloadingReqeust:request];
    }
}
- (void)requestWentWrong:(ASIHTTPRequest *)request
{
//    NSLog(@"request failed: %@ userInfo: %@",[request.error localizedDescription],request.userInfo);
//    NSLog(@"status code %d and status message %@",[request responseStatusCode],[request responseStatusMessage]);
    
//    if([self.delegate respondsToSelector:@selector(downloadController:failedDownloadingReqeust:)])
//        [self.delegate downloadController:self failedDownloadingReqeust:request];
    
    NSMutableArray *userDefaultsURLs = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kDownloadKeyInterrupted]];
    [userDefaultsURLs removeObject:[NSString stringWithFormat:@"%@",request.url]];
    NSArray *remainingUrlArray = [NSArray arrayWithArray:userDefaultsURLs];
    [[NSUserDefaults standardUserDefaults] setObject:remainingUrlArray forKey:kDownloadKeyInterrupted];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
    
    NSInteger index = -1;
    NSMutableDictionary *userInfo = nil;
    for (ASIHTTPRequest *req in downloadingArray)
    {
        if ([req isEqual:request])
        {
            userInfo = [NSMutableDictionary dictionaryWithDictionary:[req userInfo]];
            index = [downloadingArray indexOfObject:req];
            break;
        }
    }
    if (index != -1)
    {
        [self removeRequestAtIndex:index];
        
        if([self.delegate respondsToSelector:@selector(downloadController:failedDownloadingReqeust:)])
            [self.delegate downloadController:self failedDownloadingReqeust:request];
    }
}
@end
