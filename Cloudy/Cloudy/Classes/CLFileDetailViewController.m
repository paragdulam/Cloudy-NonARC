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
    UIProgressView *progressView;
    LiveDownloadOperation *downloadOperation;
    UIToolbar *progressToolBar;
    NSURL *fileURL;
    UIBarButtonItem *exportBarButton;
    UIDocumentInteractionController *interactionController;
}


-(void) createToolBarItems;
-(void) downloadFile;


@property(nonatomic,retain) NSURL *fileURL;
@property(nonatomic,retain) UIDocumentInteractionController *interactionController;


@end

@implementation CLFileDetailViewController
@synthesize fileURL;
@synthesize interactionController;
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

    progressToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                       self.view.frame.size.height - TOOLBAR_HEIGHT + [[UIApplication sharedApplication] statusBarFrame].size.height,
                                         self.view.frame.size.width,
                                                    TOOLBAR_HEIGHT)];
    progressToolBar.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:progressToolBar];
    [progressToolBar release];
    
    [self createToolBarItems];
    [self downloadFile];
}



-(void) downloadFile
{
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [exportBarButton setEnabled:NO];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) dealloc
{
    [interactionController release];
    interactionController = nil;
    
    [fileURL release];
    fileURL = nil;
    
    [downloadOperation  cancel];
    
    [downloadOperation release];
    downloadOperation = nil;
    
    [super dealloc];
}


#pragma mark - IBActions

-(void) exportButtonClicked:(UIButton *) btn
{
    self.interactionController =[UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = self;
    [interactionController presentOpenInMenuFromBarButtonItem:exportBarButton animated:YES];
}

#pragma mark - Helper Methods

-(void) createToolBarItems
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    UIBarButtonItem *progressBarbuttonItem = [[UIBarButtonItem alloc] initWithCustomView:progressView];
    [progressView release ];
    [items addObject:progressBarbuttonItem];
    [progressBarbuttonItem release];

    
    flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    exportBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                         target:self
                                                                                         action:@selector(exportButtonClicked:)];

    [items addObject:exportBarButton];
    [exportBarButton release];

    [progressToolBar setItems:items animated:YES];
    [items release];
    
}



-(void) loadInWebViewURL:(NSURL *) url
{
    self.fileURL = url;
    [webView loadRequest:[NSURLRequest requestWithURL:fileURL]];
    progressView.hidden = YES;
    exportBarButton.enabled = YES;
}

#pragma mark - Gestures



-(void) tapGesture:(UIGestureRecognizer *) gesture
{
    [super tapGesture:gesture];
    if (self.navigationController.navigationBarHidden) {
        [progressToolBar setHidden:YES];
    } else {
        [progressToolBar setHidden:NO];
    }
}


#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}



// Open in menu presented/dismissed on document.  Use to set up any HI underneath.
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller
{
    
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    
}

// Synchronous.  May be called when inside preview.  Usually followed by app termination.  Can use willBegin... to set annotation.
- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    
}
// bundle ID

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    
}


#pragma mark - DBRestClientDelegate

-(void) restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    [self loadInWebViewURL:[NSURL fileURLWithPath:destPath]];
}


-(void) restClient:(DBRestClient *)client loadedFile:(NSString *)destPath
{
    [self loadInWebViewURL:[NSURL fileURLWithPath:destPath]];
}



-(void) restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    [AppDelegate showError:error alertOnView:self.view];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
    [self loadInWebViewURL:[NSURL fileURLWithPath:filePath]];
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveDownloadOperation *)operation
{
    [AppDelegate showError:error alertOnView:self.view];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

// This is invoked when there is a download progress event raised.
- (void) liveDownloadOperationProgressed:(LiveOperationProgress *)progress
                                    data:(NSData *)receivedData
                               operation:(LiveDownloadOperation *)operation
{
    progressView.progress = progress.progressPercentage;
}






@end
