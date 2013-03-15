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
    int currentDownloadIndex;
    UIToolbar *progressToolBar;
    UIButton *saveButton;
    CLUploadProgressButton *downloadProgressButton;
    UILabel *currentImageIndexLabel;
    UIScrollView *zoomImageScrollView;
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
    
    zoomImageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    zoomImageScrollView.delegate = self;
    zoomImageScrollView.minimumZoomScale = 1.0;
    zoomImageScrollView.maximumZoomScale = 2.0;
    mainImageView = [[UIImageView alloc] initWithFrame:zoomImageScrollView.bounds];
    mainImageView.userInteractionEnabled = YES;
    mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    [zoomImageScrollView addSubview:mainImageView];
    [mainImageView release];

    [self.view addSubview:zoomImageScrollView];
    [zoomImageScrollView release];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc ] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    [mainImageView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    [mainImageView addGestureRecognizer:panGesture];
    [panGesture release];
    
    progressToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.appDelegate.window.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width, TOOLBAR_HEIGHT)];
    progressToolBar.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:progressToolBar];
    [progressToolBar release];
    
    [self createToolBarItems];
    
    liveOperations = [[NSMutableArray alloc] init];
    if ([images count]) {
        currentDownloadIndex = [images indexOfObject:currentImage];
        [self downloadImageAtIndex:currentDownloadIndex];
    }
    [self showImage:currentImage];
    
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(thumbnailLoadedFromNotification:)
                                                 name:@"thumbnail.loaded"
                                               object:nil];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"thumbnail.loaded"
                                                  object:nil];
    
    
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







#pragma mark - IBActions

-(void) saveButtonClicked:(UIButton *) btn
{
    UIImage *imageToBeSaved = [UIImage imageWithContentsOfFile:[self getImagePath:currentImage]];
    UIImageWriteToSavedPhotosAlbum(imageToBeSaved,
                                   nil,
                                   nil,
                                   NULL);
    [self imageDidSave];
}


-(void) downloadProgressButtonClicked:(UIButton *) btn
{
    if ([downloadProgressButton progressViewHidden]) {
        currentDownloadIndex = [images indexOfObject:currentImage];
        [self downloadImageAtIndex:currentDownloadIndex];
    }
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
    [downloadProgressButton setProgress:0];
    [downloadProgressButton setProgressViewHidden:YES];
    [self showImage:currentImage];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


-(void) restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    [downloadProgressButton setProgress:0];
    [downloadProgressButton setProgressViewHidden:YES];
    [AppDelegate showMessage:[error.userInfo objectForKey:@"error"]
                   withColor:[UIColor redColor]
                 alertOnView:self.view];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - LiveDownloadOperationDelegate

- (void) liveOperationSucceeded:(LiveDownloadOperation *)operation
{
    NSString *filePath = [self getImagePath:currentImage];
    [operation.data writeToFile:filePath atomically:YES];
    [downloadProgressButton setProgress:0];
    [downloadProgressButton setProgressViewHidden:YES];
    [self showImage:currentImage];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveDownloadOperation *)operation
{
    [downloadProgressButton setProgress:0];
    [downloadProgressButton setProgressViewHidden:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [AppDelegate showError:error alertOnView:self.view];
}

- (void) liveDownloadOperationProgressed:(LiveOperationProgress *)progress
                                    data:(NSData *)receivedData
                               operation:(LiveDownloadOperation *)operation
{
    if ([operation.userState isEqualToString:[currentImage objectForKey:FILE_NAME]]) {
        downloadProgressButton.progress = progress.progressPercentage;
    }
}

#pragma mark - Helper methods


-(void) thumbnailLoadedFromNotification:(NSNotification *) notification
{
    NSDictionary *data = [notification object];
    if ([images indexOfObject:data] == currentDownloadIndex) {
        [self updateDownloadProgressButtonImage:data];
        [self showImage:data];
    }
}


-(void) animationDidFinish:(id) obj
                  finished:(BOOL) finish
                   context:(void *) cont
{
    if ([(NSString *)obj isEqualToString:@"imageView.scale"]) {
        [(UIImageView *)cont removeFromSuperview];
    }
}

-(void)imageDidSave
{
    UIImageView *anImageView = [[UIImageView alloc] initWithFrame:mainImageView.bounds];
    anImageView.contentMode = UIViewContentModeScaleAspectFit;
    [mainImageView addSubview:anImageView];
    [anImageView release];
    [anImageView setImage:mainImageView.image];
    
    [UIView beginAnimations:@"imageView.scale" context:anImageView];
    [UIView setAnimationDuration:1.f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidFinish:finished:context:)];
    anImageView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    anImageView.center = CGPointMake(saveButton.center.x, self.view.frame.size.height - TOOLBAR_HEIGHT + saveButton.center.y);
    [UIView commitAnimations];
}


-(void) updateDownloadProgressButtonImage:(NSDictionary *) image
{
    UIImage *imageToBeShown = [UIImage imageWithContentsOfFile:[self getImageThumbnailPath:image]];
    if (!imageToBeShown) {
        NSString *fileExtention = [[[[image objectForKey:FILE_NAME] componentsSeparatedByString:@"."] lastObject] lowercaseString];
        imageToBeShown = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",fileExtention]];
    }
    [downloadProgressButton setImage:imageToBeShown forState:UIControlStateNormal];
}

-(void) downloadImageAtIndex:(int) index
{
    NSDictionary *data = [images objectAtIndex:index];
    [self updateDownloadProgressButtonImage:data];
    [downloadProgressButton setProgressViewHidden:NO];
    [currentImageIndexLabel setTextColor:NAVBAR_COLOR];
    switch (viewType) {
        case DROPBOX:
        {
            NSString *filePath = [self getImagePath:data];
            [self.appDelegate.restClient loadFile:[data objectForKey:FILE_PATH]
                                            atRev:nil
                                         intoPath:filePath];
        }
            break;
        case SKYDRIVE:
        {
            LiveDownloadOperation *downloadOperation = [self.appDelegate.liveClient downloadFromPath:[data objectForKey:FILE_URL] delegate:self userState:[data objectForKey:FILE_NAME]];
            [liveOperations addObject:downloadOperation];
        }
            break;
            
        default:
            break;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


-(void) downloadImages
{
    for (int i = 0; i < [images count]; i++) {
        [self downloadImageAtIndex:i];
    }
}

-(NSString *) getCloudType:(VIEW_TYPE) type
{
    NSString *cloudDataType = nil;
    switch (type) {
        case DROPBOX:
        {
            cloudDataType = DROPBOX_STRING;
        }
            break;
        case SKYDRIVE:
        {
            cloudDataType = SKYDRIVE_STRING;
        }
            break;
        default:
            break;
    }
    return cloudDataType;
}


-(NSString *) getImagePath:(NSDictionary *) image
{
    NSString *fileName = [image objectForKey:FILE_NAME];
    NSString *imagePath = [NSString stringWithFormat:@"%@%@",[CacheManager getTemporaryDirectory],fileName];
    return imagePath;
}


-(NSString *) getImageThumbnailPath:(NSDictionary *) image
{
    NSString *fileName = [[image objectForKey:FILE_PATH] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *cloudDataType = [self getCloudType:viewType];
    NSString *thumbPath = [NSString stringWithFormat:@"%@%@_%@",[CacheManager getTemporaryDirectory],cloudDataType,fileName];
    return thumbPath;
}


-(void) updateLabelTextForImage:(NSDictionary *)image
{
    int index = [images indexOfObject:image];
    if (index == currentDownloadIndex) {
        [currentImageIndexLabel setTextColor:NAVBAR_COLOR];
    } else {
        [currentImageIndexLabel setTextColor:[UIColor whiteColor]];
    }
    [currentImageIndexLabel setText:[NSString stringWithFormat:@"%d/%d",index + 1,[images count]]];
    [currentImageIndexLabel sizeToFit];
}


-(void) showImage:(NSDictionary *) image
{
    NSString *fileName = [image objectForKey:FILE_NAME];
    [self setTitle:fileName];
    NSString *filePath = [self getImagePath:image];
    UIImage *imageToBeShown = [UIImage imageWithContentsOfFile:filePath];
    downloadProgressButton.hidden = YES;
    saveButton.hidden = NO;
    if (!imageToBeShown) {
        NSString *thumbPath = [self getImageThumbnailPath:image];
        imageToBeShown = [UIImage imageWithContentsOfFile:thumbPath];
        if (!imageToBeShown) {
            imageToBeShown = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[[fileName componentsSeparatedByString:@"."] lastObject] lowercaseString]]];
        }
        downloadProgressButton.hidden = NO;
        saveButton.hidden = YES;
        if ([downloadProgressButton progressViewHidden]) {
            [self updateDownloadProgressButtonImage:image];
        }
    }
    [mainImageView setImage:imageToBeShown];
    [self updateLabelTextForImage:image];
}



-(void) createToolBarItems
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *saveImage = [UIImage imageNamed:@"save.png"];
    saveButton.frame = CGRectMake(0, 0, saveImage.size.width, saveImage.size.height);
    [saveButton setImage:saveImage forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
//    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(saveButtonClicked:)];

    [items addObject:saveBarButtonItem];
    [saveBarButtonItem release];
    
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    currentImageIndexLabel = [[UILabel alloc] init];
    [currentImageIndexLabel setBackgroundColor:[UIColor clearColor]];
    [currentImageIndexLabel setTextColor:[UIColor whiteColor]];
    [currentImageIndexLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
    UIBarButtonItem *currentImageIndexLabelBarButton = [[UIBarButtonItem alloc] initWithCustomView:currentImageIndexLabel];
    [currentImageIndexLabel release];
    [items addObject:currentImageIndexLabelBarButton];
    [currentImageIndexLabelBarButton release];
    
    flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    
    downloadProgressButton = [[CLUploadProgressButton alloc] init];
//    [downloadProgressButton setFrame:CGRectMake(0, 0, 30, 30)];
    downloadProgressButton.frame = CGRectMake(0, 0, 30, 30);
    [downloadProgressButton addTarget:self
                               action:@selector(downloadProgressButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *progressBarbuttonItem = [[UIBarButtonItem alloc] initWithCustomView:downloadProgressButton];
    [items addObject:progressBarbuttonItem];
    [progressBarbuttonItem release];
    
    [progressToolBar setItems:items animated:YES];
    [items release];
    
}



#pragma mark - Gestures


-(void) panGesture:(UIGestureRecognizer *) gesture
{
    if ([gesture numberOfTouches] == 1) {
        UIView *view = [gesture view];
        float width = view.frame.size.width;
        float ratio = width / [images count];
        CGPoint touchPoint = [gesture locationInView:view];
        int index = touchPoint.x / ratio;
        self.currentImage = [images objectAtIndex:index];
        [self showImage:currentImage];
    }
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


#pragma mark 

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return mainImageView;
}




@end
