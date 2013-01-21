  



This download manager uses the ASIHTTPRequest classes to download files.
Can download files in back ground. 
Can download multiple files once at a time.
It can resume interrupted downloads.

USAGE:
You need ASIHTTPRequest classes get it <a href="https://github.com/pokeb/asi-http-request">https://github.com/pokeb/asi-http-request</a> and setup your project
Copy the downloadcell and downloadtableviewcontroller in your project.

Simply in your view controller viewdidload method do:

This will check for any interrupted download and resume it

    downloadTableViewObj = [[DownloadTableViewController alloc] init];
    [downloadTableViewObj setDelegate:self];
    [downloadTableViewObj getInterruptedDownloadsAndResume];

And populate url in an array like this:

    urlArray = [NSMutableArray arrayWithObjects:
    @"http://dl.dropbox.com/u/97700329/file1.mp4",
    @"http://dl.dropbox.com/u/97700329/file2.mp4",
    @"http://dl.dropbox.com/u/97700329/file3.mp4",nil];

Remove the urls from your array that was interrupted because
if you download one file multiple times it will cause problem

    NSMutableArray *interruptedRequests = [[NSUserDefaults standardUserDefaults] objectForKey:@"interruptedDownloads"];
    for(NSString *str in interruptedRequests)
    {
      if([urlArray containsObject:str])
      [urlArray removeObject:str];
    }
    [myTableView reloadData];

Set up table view in your view controller 

    -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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

Create a request and call the method "addDownloadRequest" of DownloadTableViewController
Set the file destination path

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

Use three delegate methods

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

That's it

