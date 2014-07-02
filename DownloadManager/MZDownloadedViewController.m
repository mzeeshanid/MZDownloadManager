//
//  DownloadedViewController.m
//  VDownloader
//
//  Created by Muhammad Zeeshan on 1/21/14.
//  Copyright (c) 2014 Muhammad Zeeshan. All rights reserved.
//

#import "MZDownloadedViewController.h"

@interface MZDownloadedViewController () <UIActionSheetDelegate, UITableViewDelegate, UIAlertViewDelegate>
{
    IBOutlet UITableView *tblViewDownloaded;
    
    NSMutableArray *downloadedFilesArray;
    
    NSIndexPath *selectedIndexPath;
    
    NSFileManager *fileManger;
}
@end

@implementation MZDownloadedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    downloadedFilesArray = [[NSMutableArray alloc] init];
    
    fileManger = [NSFileManager defaultManager];
    NSError *error;
    downloadedFilesArray = [[fileManger contentsOfDirectoryAtPath:fileDest error:&error] mutableCopy];
    
    if([downloadedFilesArray containsObject:@".DS_Store"])
        [downloadedFilesArray removeObject:@".DS_Store"];
    
    if(error && error.code != NSFileReadNoSuchFileError)
        [MZUtility showAlertViewWithTitle:kAlertTitle msg:error.localizedDescription];
    else
        [tblViewDownloaded reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinishedNotification:) name:DownloadCompletedNotif object:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadCompletedNotif object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - My Methods -
- (void)deleteItemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = [downloadedFilesArray objectAtIndex:indexPath.row];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",fileDest,fileName]];
    NSError *error;
    BOOL isDeletedSucces = [fileManger removeItemAtURL:fileURL error:&error];
    if(isDeletedSucces)
    {
        [downloadedFilesArray removeObject:fileName];
        [tblViewDownloaded deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        NSString *errorMsg = [NSString stringWithFormat:@"Error occured while deleting file:\n%@",error.localizedDescription];
        [MZUtility showAlertViewWithTitle:kAlertTitle msg:errorMsg];
    }
}
- (void)renameFileTo:(NSString *)fileName
{
    NSString *oldFilePath = [NSString stringWithFormat:@"%@/%@",fileDest,[downloadedFilesArray objectAtIndex:selectedIndexPath.row]];
    NSString *newFilePath = [NSString stringWithFormat:@"%@/%@.%@",fileDest,fileName,oldFilePath.pathExtension];
    
    NSError *error;
    BOOL isRenamedSuccess = [fileManger moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
    
    if(isRenamedSuccess)
    {
        NSString *newFileName = [NSString stringWithFormat:@"%@.%@",fileName,newFilePath.pathExtension];
        [downloadedFilesArray replaceObjectAtIndex:selectedIndexPath.row withObject:newFileName];
        [tblViewDownloaded reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        NSString *errorMsg = [NSString stringWithFormat:@"Error occured while renaming file:\n%@",error.localizedDescription];
        
        if(error.code == NSFileWriteFileExistsError)
            [MZUtility showAlertViewWithTitle:kAlertTitle msg:@"File already exists with the same name"];
        else
            [MZUtility showAlertViewWithTitle:kAlertTitle msg:errorMsg];
    }
}
#pragma mark - My IBActions -
- (IBAction)editBarButtonTapped:(UIBarButtonItem *)sender
{
    if(tblViewDownloaded.isEditing)
    {
        [sender setTitle:@"Edit"];
        [sender setStyle:UIBarButtonItemStylePlain];
        [tblViewDownloaded setEditing:NO animated:YES];
    }
    else
    {
        [sender setTitle:@"Done"];
        [sender setStyle:UIBarButtonItemStyleDone];
        [tblViewDownloaded setEditing:YES animated:YES];
    }
}
#pragma mark - UITableView Delegate and Datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return downloadedFilesArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DownloadedFileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell.textLabel setText:[downloadedFilesArray objectAtIndex:indexPath.row]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectedIndexPath = [indexPath copy];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Rename", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self deleteItemForRowAtIndexPath:indexPath];
}
#pragma mark - UIActionSheet Delegate -
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSString *fileName = [downloadedFilesArray objectAtIndex:selectedIndexPath.row];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rename File" message:@"Please enter file name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
        [[alertView textFieldAtIndex:0] setText:[fileName stringByDeletingPathExtension]];
        [alertView setTag:1000];
        [alertView show];
    }
    else
    {
        
    }
}
#pragma mark - UIAlertView Delegate -
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if(alertView.tag == 1000)
    {
        NSString *textfieldText = [[alertView textFieldAtIndex:0] text];
        if(textfieldText.length == 0)
            textfieldText = @"";
        return ([[MZUtility trimWhitespace:textfieldText] length]>0)?YES:NO;
    }
    return YES;
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1000)
    {
        if(buttonIndex == 1)
        {
            UITextField *textfield = [alertView textFieldAtIndex:0];
            [self renameFileTo:textfield.text];
        }
    }
}
#pragma mark - NSNotification Methods -
- (void)downloadFinishedNotification:(NSNotification *)notification
{
    NSString *fileName = notification.object;
    [downloadedFilesArray addObject:fileName.lastPathComponent];
    [tblViewDownloaded reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end
