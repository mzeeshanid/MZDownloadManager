<b>For swift checkout the swift branch.</b>

<b>For objective-c checkout the master branch.</b>
<h4>MZDownloadManager</h4>

![mzdownload manager hero](https://cloud.githubusercontent.com/assets/2767152/3459842/0c40fe66-0211-11e4-90d8-d8942c8f8651.png)

If you find MZDownloadManager userful consider donating thanks ;)</br>
[![Donate button](https://www.paypalobjects.com/en_US/DE/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=BMKTVHYK6PUUG)

<h3> Features:</h3>

This download manager uses the iOS 7 NSURLSession api to download files.<ol><li>Can download large files if app is in background.</li><li>Can download files if app is in background.</li><li>Can download multiple files at a time.</li><li>It can resume interrupted downloads.</li><li>User can also pause the download.</li><li>User can retry any download if any error occurred during download.</li></ol>
<h3>Requirements:</h3>
<ol><li>Please note that for resuming downloads server must have resuming support.</li><li>Please note that by using this control your app minimum deployment target will be iOS 7.</li></ol>
<h3>Screencast:</h3>
http://screencast.com/t/Rzm0xoRjGF
<h3>Usage:</h3>
<i><strong>See the demo project it is very simple and straight forward.</i></strong>
<strong>Steps:</strong>
Copy all files from <strong><i>MZDownloadManager</i></strong> group from sample project.
<ol><li>Setup your available downloads view controller.</li><li>Initialize <strong><i>MZDownloadManagerViewController</i></strong> and set its <strong><i>delegate.<i></strong> Initialize its downloading array and setup <strong><i>background session configuration.</i></strong> Interrupted downloads can be restore by instance method.</li>
<pre><code>- (void)populateOtherDownloadTasks</code></pre>
All steps will look like the following:
<pre><code>UINavigationController *mzDownloadingNav = [self.tabBarController.viewControllers objectAtIndex:1];
mzDownloadingViewObj = [mzDownloadingNav.viewControllers objectAtIndex:0];
[mzDownloadingViewObj setDelegate:self];
    
mzDownloadingViewObj.downloadingArray = [[NSMutableArray alloc] init];
mzDownloadingViewObj.sessionManager = [mzDownloadingViewObj backgroundSession];
[mzDownloadingViewObj populateOtherDownloadTasks]; </code></pre>

<i><strong>Please note that i am using tab based application in sample project.</i></strong>
<li>To add new download task you can use the instance method of MZDownloadManagerViewController.
<pre><code>- (void)addDownloadTask:(NSString *)fileName fileURL:(NSString *)fileURL;</code></pre>
</li><li>Use 3 delegate methods<br>
<i>A delegate method called each time whenever new download task is start downloading.</i>
<pre><code>- (void)downloadRequestStarted:(NSURLSessionDownloadTask *)downloadTask;</code></pre>
<i>A delegate method called each time whenever any download task is cancelled by the user.</i>
<pre></code>- (void)downloadRequestCanceled:(NSURLSessionDownloadTask *)downloadTask;</code></pre>
<i>A delegate method called each time whenever any download task is finished successfully.</i>
<pre><code>- (void)downloadRequestFinished:(NSString *)fileName;</code></pre></li></ol>
