//
//  CLFileDetailViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 23/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLFileDetailViewController.h"

@interface CLFileDetailViewController ()
{
    UIWebView *webView;
    UIProgressView *progressView;
    UILabel *progressLabel;
    LiveDownloadOperation *downloadOperation;
}
@end

@implementation CLFileDetailViewController
@synthesize viewType;
@synthesize file;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(id) initWithFile:(NSDictionary *) fileDictionary
    WithinViewType:(VIEW_TYPE) type
{
    if (self = [super init]) {
        self.viewType = type;
        self.file = fileDictionary;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    [webView release];
    
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self.view addSubview:progressView];
    [progressView release];
    
    progressLabel = [[UILabel alloc] init];
    [self.view addSubview:progressLabel];
    [progressLabel release];
    
    progressView.center = self.view.center;
    progressLabel.center = CGPointMake(self.view.center.x,
                                       progressView.center.y - 20.f);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    [webView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    [webView addGestureRecognizer:panGesture];
    [panGesture release];

    
    switch (viewType) {
        case DROPBOX:
            [self.appDelegate.restClient loadFile:[file objectForKey:@"path"]
                                            atRev:[file objectForKey:@"rev"]
                                         intoPath:[NSString stringWithFormat:@"%@%@",[CLCacheManager getTemporaryDirectory],[file objectForKey:@"name"]]];
            break;
        case SKYDRIVE:
            downloadOperation = [[self.appDelegate.liveClient downloadFromPath:[file objectForKey:@"source"]
                                                 delegate:self userState:[file objectForKey:@"name"]] retain] ;
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) dealloc
{
    [downloadOperation  cancel];
    
    [downloadOperation release];
    downloadOperation = nil;
    
    [file release];
    file = nil;
    
    [super dealloc];
}

#pragma mark - Gestures

-(void) panGesture:(UIGestureRecognizer *) gesture
{
    
}


-(void) tapGesture:(UIGestureRecognizer *) gesture
{
    if (self.navigationController.navigationBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        self.navigationController.navigationBarHidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }

}



#pragma mark - DBRestClientDelegate

-(void) restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:destPath]]];
    progressView.hidden = YES;
}


-(void) restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    
}

-(void) restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath
{
    progressView.progress = progress;
}


#pragma mark - LiveDownloadOperationDelegate


- (void) liveOperationSucceeded:(LiveDownloadOperation *)operation
{
    NSString *filePath = [NSString stringWithFormat:@"%@%@",[CLCacheManager getTemporaryDirectory],operation.userState];
    [operation.data writeToFile:filePath
                     atomically:YES];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    progressView.hidden = YES;

}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveDownloadOperation *)operation
{
    
}

// This is invoked when there is a download progress event raised.
- (void) liveDownloadOperationProgressed:(LiveOperationProgress *)progress
                                    data:(NSData *)receivedData
                               operation:(LiveDownloadOperation *)operation
{
    [progressLabel setText:[NSString stringWithFormat:@"%d MB of %d MB",(progress.bytesTransferred) / (1024 * 1024),(progress.totalBytes) / (1024 * 1024)]];
    [progressLabel sizeToFit];
    progressView.progress = progress.progressPercentage;
}


#pragma mark - UIWebViewDelegate


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}



#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}




@end
