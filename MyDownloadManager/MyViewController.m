//
//  MyViewController.m
//  MyDownloadManager
//
//  Created by Muhammad Zeeshan on 1/20/13.
//  Copyright (c) 2013 FUUAST. All rights reserved.
//

#import "MyViewController.h"

#define fileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Downloaded Files"]
@interface MyViewController ()

@end

@implementation MyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    downloadTableViewObj = [[DownloadTableViewController alloc] init];
    [downloadTableViewObj setDelegate:self];
    [downloadTableViewObj getInterruptedDownloadsAndResume];
    
    [self checkForInterruptedDownload];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - My Methods -
-(void)showManagerButtonTapped:(UIBarButtonItem *)sender
{
    [self.navigationController pushViewController:downloadTableViewObj animated:YES];
}
-(void)checkForInterruptedDownload
{
    urlArray = [NSMutableArray arrayWithObjects:
                @"http://dl.dropbox.com/u/97700329/file1.mp4",
                @"http://dl.dropbox.com/u/97700329/file2.mp4",
                @"http://dl.dropbox.com/u/97700329/file3.mp4",nil];
    NSMutableArray *interruptedRequests = [[NSUserDefaults standardUserDefaults] objectForKey:@"interruptedDownloads"];
    for(NSString *str in interruptedRequests)
    {
        if([urlArray containsObject:str])
            [urlArray removeObject:str];
    }
    [myTableView reloadData];
}
-(void)downloadButtonTapped:(UIButton *)sender
{
    NSURL *url = [NSURL URLWithString:[urlArray objectAtIndex:sender.tag]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [request setUserInfo:dictionary];
    [downloadTableViewObj setDownloadDirectory:fileDestination];
    [downloadTableViewObj addDownloadRequest:request];
    
    [urlArray removeObjectAtIndex:sender.tag];
    [myTableView reloadData];
}
#pragma mark - Tableview Delegate and Datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return urlArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell-%d-%d-%d",indexPath.section,indexPath.row,urlArray.count];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == Nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell.textLabel setText:[[[urlArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"/"] lastObject]];
        
        UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [downloadButton setFrame:CGRectMake(230, 5, 80, 35)];
        [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
        [downloadButton addTarget:self action:@selector(downloadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [downloadButton setTag:indexPath.row];
        [cell addSubview:downloadButton];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - DownloadTableViewControlle Delegate -
-(void)downloadController:(DownloadTableViewController *)vc startedDownloadingRequest:(ASIHTTPRequest *)request
{
    NSLog(@"download started %@",[request userInfo]);
}
-(void)downloadController:(DownloadTableViewController *)vc finishedDownloadingReqeust:(ASIHTTPRequest *)request
{
    NSLog(@"download finished %@",[request userInfo]);
}
-(void)downloadController:(DownloadTableViewController *)vc failedDownloadingReqeust:(ASIHTTPRequest *)request
{
    NSLog(@"Error %@",[request error]);
    [urlArray addObject:[request.url absoluteString]];
    [myTableView reloadData];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error" message:[[request error] localizedDescription] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}
@end
