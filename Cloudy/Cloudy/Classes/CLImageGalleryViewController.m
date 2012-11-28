//
//  CLImageGalleryViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 22/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLImageGalleryViewController.h"

@interface CLImageGalleryViewController ()
{
    UIImageView *mainImageView;
    NSMutableArray *liveOperations;
    CGRect originalViewRect;
    int currentIndex;
    UIToolbar *progressToolBar;
    UILabel *currentFileLabel;
    CLUploadProgressButton *downloadProgressButton;
}

-(void) downloadImageAtIndex:(int) index;
-(void) createToolBarItems;

@end

@implementation CLImageGalleryViewController
@synthesize images;
@synthesize currentImage;
@synthesize viewType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(id) initWithViewType:(VIEW_TYPE) type
           ImagesArray:(NSArray *)imagesArray
          CurrentImage:(NSDictionary *) imageDictionary
{
    if (self = [super init]) {
        self.viewType = type;
        self.images = imagesArray;
        self.currentImage = imageDictionary;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    mainImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    mainImageView.userInteractionEnabled = YES;
    mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:mainImageView];
    [mainImageView release];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc ] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    [mainImageView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    [mainImageView addGestureRecognizer:panGesture];
    [panGesture release];
    
    progressToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width, TOOLBAR_HEIGHT)];
    progressToolBar.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:progressToolBar];
    [progressToolBar release];
    
    [self createToolBarItems];
    
    liveOperations = [[NSMutableArray alloc] init];
    if ([images count]) {
        currentIndex = [images indexOfObject:currentImage];
        [self downloadImageAtIndex:currentIndex];
    }
    [self showImage];
    
	// Do any additional setup after loading the view.
}



-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.appDelegate.restClient.delegate = self;
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
    self.appDelegate.restClient.delegate = nil;
    for (LiveOperation *operation in liveOperations) {
        [operation cancel];
    }
    
    [liveOperations release];
    liveOperations = nil;
    
    [images release];
    images = nil;
    
    [currentImage release];
    currentImage = nil;
    [super dealloc];
}


#pragma Helper Methods

-(void) createToolBarItems
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    currentFileLabel = [[UILabel alloc] init];
    currentFileLabel.backgroundColor = [UIColor clearColor];
    currentFileLabel.textColor = [UIColor whiteColor];
    UIBarButtonItem *labelBarItem = [[UIBarButtonItem alloc] initWithCustomView:currentFileLabel];
    [currentFileLabel release];
    [items addObject:labelBarItem];
    [labelBarItem release];
    
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];

    downloadProgressButton = [[CLUploadProgressButton alloc] init];
    [downloadProgressButton setFrame:CGRectMake(0, 0, 30, 30)];
//    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    UIBarButtonItem *progressBarbuttonItem = [[UIBarButtonItem alloc] initWithCustomView:downloadProgressButton];
//    [progressView release ];
    [items addObject:progressBarbuttonItem];
    [progressBarbuttonItem release];
    
    [progressToolBar setItems:items animated:YES];
    [items release];
    
}



#pragma mark - DBRestClientDelegate

-(void) restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath
{
    downloadProgressButton.progress = progress;
}

-(void) restClient:(DBRestClient *)client
        loadedFile:(NSString *)destPath
       contentType:(NSString *)contentType
          metadata:(DBMetadata *)metadata
{
}


-(void) restClient:(DBRestClient *)client loadedFile:(NSString *)destPath
{
    currentIndex ++;
    if (currentIndex < [images count]) {
        [self downloadImageAtIndex:currentIndex];
    }
}


-(void) restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    [AppDelegate showError:error alertOnView:self.view];
}

#pragma mark - LiveDownloadOperationDelegate

- (void) liveOperationSucceeded:(LiveDownloadOperation *)operation
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CLCacheManager getTemporaryDirectory],operation.userState];
    [operation.data writeToFile:filePath atomically:YES];
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveDownloadOperation *)operation
{
    
}

- (void) liveDownloadOperationProgressed:(LiveOperationProgress *)progress
                                    data:(NSData *)receivedData
                               operation:(LiveDownloadOperation *)operation
{
    if ([operation.userState isEqualToString:[currentImage objectForKey:@"name"]]) {
        downloadProgressButton.progress = progress.progressPercentage;
    }
}

#pragma mark - Helper methods



-(void) downloadImageAtIndex:(int) index
{
    NSDictionary *data = [images objectAtIndex:index];
    [downloadProgressButton setImage:[UIImage imageWithData:[data objectForKey:THUMBNAIL_DATA]] forState:UIControlStateNormal];
    switch (viewType) {
        case DROPBOX:
        {
            NSString *fileName = [data objectForKey:@"filename"];
            currentFileLabel.text = fileName;
            [currentFileLabel sizeToFit];
            NSString *filePath = [NSString stringWithFormat:@"%@%@",[CLCacheManager getTemporaryDirectory],fileName];
            [self.appDelegate.restClient loadFile:[data objectForKey:@"path"]
                                            atRev:[data objectForKey:@"rev"]
                                         intoPath:filePath];
        }
            break;
        case SKYDRIVE:
        {
            currentFileLabel.text = [data objectForKey:@"name"];
            [currentFileLabel sizeToFit];

            NSArray *imagesArray = [data objectForKey:@"images"];
            if ([imagesArray count]) {
                NSDictionary *image = [imagesArray objectAtIndex:0];
                LiveDownloadOperation *downloadOperation = [self.appDelegate.liveClient downloadFromPath:[image objectForKey:@"source"] delegate:self userState:[data objectForKey:@"name"]];
                [liveOperations addObject:downloadOperation];
            }
        }
            break;
            
        default:
            break;
    }
}


-(void) downloadImages
{
    for (int i = 0; i < [images count]; i++) {
        [self downloadImageAtIndex:i];
    }
}



-(void) showImage
{
    NSString *fileName = nil;
    switch (viewType) {
        case DROPBOX:
            fileName = [currentImage objectForKey:@"filename"];
            break;
        case SKYDRIVE:
            fileName = [currentImage objectForKey:@"name"];
            break;
        default:
            break;
    }
    [self setTitle:fileName];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CLCacheManager getTemporaryDirectory],fileName];
    UIImage *imageToBeShown = [UIImage imageWithContentsOfFile:filePath];
    downloadProgressButton.hidden = YES;
    if (!imageToBeShown) {
        imageToBeShown = [UIImage imageWithData:[currentImage objectForKey:THUMBNAIL_DATA]];
        downloadProgressButton.hidden = NO;
    }
    [mainImageView setImage:imageToBeShown];
}


#pragma mark - Gestures


-(void) panGesture:(UIGestureRecognizer *) gesture
{
    UIView *view = [gesture view];
    float width = view.frame.size.width;
    float ratio = width / [images count];
    CGPoint touchPoint = [gesture locationInView:view];
    int index = touchPoint.x / ratio;
    self.currentImage = [images objectAtIndex:index];
    [self showImage];
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
