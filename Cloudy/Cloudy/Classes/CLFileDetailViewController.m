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
    LiveDownloadOperation *downloadOperation;
    UIToolbar *progressToolBar;
}


-(void) createToolBarItems;

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
    webView.backgroundColor = [UIColor redColor];
    
    webView = [[UIWebView alloc] initWithFrame:self.appDelegate.window.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    webView.scalesPageToFit = YES;
    [webView release];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    [webView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
//    panGesture.delegate = self;
//    [webView.scrollView addGestureRecognizer:panGesture];
//    [panGesture release];

    progressToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                       webView.frame.size.height - TOOLBAR_HEIGHT,
                                         webView.frame.size.width,
                                                    TOOLBAR_HEIGHT)];
    progressToolBar.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:progressToolBar];
    [progressToolBar release];
    
    [self createToolBarItems];
    
    
    switch (viewType) {
        case DROPBOX:
            [self.appDelegate.restClient loadFile:[file objectForKey:@"path"]
                                            atRev:[file objectForKey:@"rev"]
                                         intoPath:[NSString stringWithFormat:@"%@%@",[CLCacheManager getTemporaryDirectory],[file objectForKey:@"filename"]]];
            break;
        case SKYDRIVE:
            downloadOperation = [[self.appDelegate.liveClient downloadFromPath:[file objectForKey:@"source"]
                                                 delegate:self userState:[file objectForKey:@"name"]] retain] ;
            break;
        default:
            break;
    }
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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


#pragma mark - Helper Methods

-(void) createToolBarItems
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    UIBarButtonItem *progressBarbuttonItem = [[UIBarButtonItem alloc] initWithCustomView:progressView];
    [progressView release ];
    [items addObject:progressBarbuttonItem];
    [progressBarbuttonItem release];

    
    flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    
    [progressToolBar setItems:items animated:YES];
    [items release];
    
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
        [progressToolBar setHidden:NO];
    } else {
        self.navigationController.navigationBarHidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [progressToolBar setHidden:YES];
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
    return YES;
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}




@end
