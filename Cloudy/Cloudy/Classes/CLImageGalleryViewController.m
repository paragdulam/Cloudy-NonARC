//
//  CLImageGalleryViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 22/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLImageGalleryViewController.h"
#define VIEW_COUNT 5


typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface CLImageGalleryViewController ()
{
    UIImageView *mainImageView;
    NSMutableArray *liveOperations;
    NSMutableArray *scrollViews;
    CGRect originalViewRect;
    int currentDownloadIndex;
    UIToolbar *progressToolBar;
    UIButton *saveButton;
    CLUploadProgressButton *downloadProgressButton;
    UILabel *currentImageIndexLabel;
    UIScrollView *mainScrollView;
    CGPoint previousContentOffset;
    ScrollDirection scrollDirection;
    int viewCount;
    int previousIndex;
    BOOL shouldCallScrollViewDelegate;
    LiveDownloadOperation *downloadOperation;
}

-(void) downloadImageAtIndex:(int) index;
-(void) createToolBarItems;

@property(nonatomic,retain) LiveDownloadOperation *downloadOperation;



@end

@implementation CLImageGalleryViewController
@synthesize images;
@synthesize currentImage;
@synthesize viewType;
@synthesize downloadOperation;

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
        scrollViews = [[NSMutableArray alloc] init];
        liveOperations = [[NSMutableArray alloc] init];
        currentDownloadIndex = [images indexOfObject:currentImage];
    }
    return self;
}

-(id) initWithViewType:(VIEW_TYPE) type
           ImagesArray:(NSArray *)imagesArray
     CurrentImageIndex:(int) index
{
    if (self = [super init]) {
        self.viewType = type;
        self.images = imagesArray;
        scrollViews = [[NSMutableArray alloc] init];
        liveOperations = [[NSMutableArray alloc] init];
        currentDownloadIndex = index;
    }
    return self;
}


-(void) layoutImageViews
{
    for (CLZoomableImageView *scrollView in scrollViews) {
        [self layoutImageView:scrollView];
    }
}



-(void) layoutImageView:(CLZoomableImageView *)scrollView
{
    int origin = scrollView.frame.size.width;
    if (currentDownloadIndex >= viewCount/2 &&
        currentDownloadIndex <= ([images count] - 1 - (viewCount/2))) {
        origin = scrollView.frame.size.width * (currentDownloadIndex + scrollView.tag);
    } else if (currentDownloadIndex < viewCount/2) {
        origin = scrollView.frame.size.width * [scrollViews indexOfObject:scrollView];
    } else if (currentDownloadIndex > ([images count] - 1 - (viewCount/2))) {
        int diff = currentDownloadIndex - ([images count] - 1 - (viewCount/2));
        origin = scrollView.frame.size.width * (currentDownloadIndex + scrollView.tag - diff);
    }
    scrollView.frame = CGRectMake(origin,
                                  scrollView.frame.origin.y,
                                  scrollView.frame.size.width,
                                  scrollView.frame.size.height);
}

-(void) createImageViews
{
    int multiplier;
    int index = [self getScrollViewIndexForIndex:currentDownloadIndex];
    for (int i = 0; i < viewCount; i++) {
        if ([images count] <= VIEW_COUNT) {
            multiplier = i;
        } else {
            multiplier = i + currentDownloadIndex - index;
        }
        CGRect frame = CGRectMake(mainScrollView.frame.size.width * multiplier,
                                  mainScrollView.frame.origin.y,
                                  mainScrollView.frame.size.width,
                                  mainScrollView.frame.size.height);
        
        CLZoomableImageView * aView = [[CLZoomableImageView alloc] initWithFrame:frame];
        aView.tag = i;
        
//        CGFloat hue = ( arc4random() % 256 / 256.0 ); // 0.0 to 1.0
//        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0, away from white
//        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0, away from black
//        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
//        aView.backgroundColor = color;
        aView.backgroundColor = [UIColor clearColor];
        NSDictionary *image = [images objectAtIndex:multiplier];
        [aView setImage:[self getImageForImageDictionary:image]];
        [mainScrollView addSubview:aView];
        [scrollViews addObject:aView];
        [aView release];
    }
}


-(void) setImagesInitially
{
    if (currentDownloadIndex >= (viewCount/2) &&
        currentDownloadIndex <= [images count] - 1 - (viewCount/2)) {
        int index = -(viewCount/2);
        for (CLZoomableImageView *scrollView in scrollViews) {
            NSDictionary *image = [images objectAtIndex:currentDownloadIndex + (index++)];
            [scrollView setImage:[self getImageForImageDictionary:image]];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewCount = [images count];
    if (viewCount > VIEW_COUNT) {
        viewCount = VIEW_COUNT;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect bounds = self.appDelegate.window.bounds;
    mainScrollView = [[UIScrollView alloc] initWithFrame:bounds];
    [self.view addSubview:mainScrollView];
    [mainScrollView release];

    mainScrollView.delegate = self;
    mainScrollView.minimumZoomScale = 1.0;
    mainScrollView.maximumZoomScale = 2.0;
    mainScrollView.pagingEnabled = YES;
    mainScrollView.scrollEnabled = YES;
    mainScrollView.backgroundColor = [UIColor blackColor];
    [mainScrollView setShowsHorizontalScrollIndicator:NO];
    [mainScrollView setShowsVerticalScrollIndicator:NO];
    
    mainScrollView.contentSize = CGSizeMake(bounds.size.width * [images count],
                                            bounds.size.height);
    shouldCallScrollViewDelegate = NO;
    [mainScrollView setContentOffset:CGPointMake(currentDownloadIndex * mainScrollView.frame.size.width, mainScrollView.frame.origin.y)];
    shouldCallScrollViewDelegate = YES;


    
    progressToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (TOOLBAR_HEIGHT - [[UIApplication sharedApplication] statusBarFrame].size.height), self.view.frame.size.width, TOOLBAR_HEIGHT)];
    [self.view addSubview:progressToolBar];
    progressToolBar.tintColor = [UIColor blackColor];
    [progressToolBar release];
    
    [self createToolBarItems];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture release];
    
//    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
//    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
//    [mainScrollView addGestureRecognizer:swipeGesture];
//    [swipeGesture release];

    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createImageViews];
        [self updateUIForImageDictionaryAtIndex:currentDownloadIndex];
        [self downloadImageAtIndex:currentDownloadIndex];
    });
}




-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.appDelegate.restClient.delegate = self;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [CacheManager deleteAllContentsOfFolderAtPath:[sharedManager getTempPath:viewType]];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            NSLog(@"Portrait");
            break;
        case UIInterfaceOrientationLandscapeLeft:
            NSLog(@"UIInterfaceOrientationLandscapeLeft");
            break;
        case UIInterfaceOrientationLandscapeRight:
            NSLog(@"UIInterfaceOrientationLandscapeRight");
            break;
        default:
            break;
    }
}


-(void) dealloc
{
    [downloadOperation cancel];
    
    [downloadOperation release];
    downloadOperation = nil;
    
    [scrollViews release];
    scrollViews = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"thumbnail.loaded"
                                                  object:nil];
    
    
    self.appDelegate.restClient.delegate = nil;

    
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
    UIImage *imageToBeSaved = [UIImage imageWithContentsOfFile:[self getImagePath:[images objectAtIndex:currentDownloadIndex]]];
    UIImageWriteToSavedPhotosAlbum(imageToBeSaved,
                                   nil,
                                   nil,
                                   NULL);
    [self imageDidSave];
}





#pragma mark - DBRestClientDelegate



-(void) restClient:(DBRestClient *)client
      loadProgress:(CGFloat)progress
           forFile:(NSString *)destPath
{
    [self downloadProgress:progress
                   forPath:destPath];
}

-(void) restClient:(DBRestClient *)client
        loadedFile:(NSString *)destPath
       contentType:(NSString *)contentType
          metadata:(DBMetadata *)metadata
{
}


-(void) restClient:(DBRestClient *)client loadedFile:(NSString *)destPath
{
    [self downloadCompletionHandler];
    [self showImage];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


-(void) restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    [self downloadCompletionHandler];
    NSString *errorMessage = [[error.userInfo objectForKey:@"error"] length] ? [error.userInfo objectForKey:@"error"] : [error localizedDescription];
    [AppDelegate showMessage:errorMessage
                   withColor:[UIColor redColor]
                 alertOnView:self.view];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - LiveDownloadOperationDelegate

- (void) liveOperationSucceeded:(LiveDownloadOperation *)operation
{
    [self downloadCompletionHandler];
    NSString *filePath = operation.userState;
    [operation.data writeToFile:filePath atomically:YES];
    [self showImage];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveDownloadOperation *)operation
{
    [self downloadCompletionHandler];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [AppDelegate showError:error alertOnView:self.view];
}

- (void) liveDownloadOperationProgressed:(LiveOperationProgress *)progress
                                    data:(NSData *)receivedData
                               operation:(LiveDownloadOperation *)operation
{
    [self downloadProgress:progress.progressPercentage
                   forPath:operation.userState];
}



#pragma mark - Helper methods

-(void) downloadCompletionHandler
{
    self.downloadOperation = nil;
    if ([liveOperations count]) {
        [liveOperations removeObjectAtIndex:0];
        if ([liveOperations count]) {
            [self downloadImageAtIndex:[images indexOfObject:[liveOperations objectAtIndex:0]]];
        } else {
            downloadProgressButton.hidden = YES;
        }
    } 
}

-(void) downloadProgress:(float) progress
                 forPath:(NSString *) destPath
{
    downloadProgressButton.progress = progress;
}

-(void) thumbnailLoadedFromNotification:(NSNotification *) notification
{
//    NSDictionary *data = [notification object];
//    if ([images indexOfObject:data] == currentDownloadIndex) {
//        [self updateDownloadProgressButtonImage:data];
//        [self showImage:data];
//    }
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
    CLZoomableImageView *scrollView = [scrollViews objectAtIndex:[self getScrollViewIndexForIndex:currentDownloadIndex]];
    UIImage *image = [scrollView image];
    
    UIImageView *anImageView = [[UIImageView alloc] initWithFrame:self.appDelegate.window.bounds];
    anImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.appDelegate.window addSubview:anImageView];
    [anImageView release];
    [anImageView setImage:image];
    
    [UIView beginAnimations:@"imageView.scale" context:anImageView];
    [UIView setAnimationDuration:1.f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidFinish:finished:context:)];
    
    anImageView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    anImageView.center = CGPointMake(saveButton.center.x,
                                     self.view.frame.size.height - TOOLBAR_HEIGHT + saveButton.center.y);
    
    [UIView commitAnimations];
}


-(void) updateDownloadProgressButtonImage:(NSDictionary *) image
{
    UIImage *imageToBeShown = [UIImage imageWithContentsOfFile:[self getImageThumbnailPath:image]];
    if (!imageToBeShown) {
        NSString *fileExtention = [[[[image objectForKey:FILE_NAME] componentsSeparatedByString:@"."] lastObject] lowercaseString];
        imageToBeShown = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",fileExtention]];
    }
    downloadProgressButton.hidden = NO;
    [downloadProgressButton setImage:imageToBeShown forState:UIControlStateNormal];
}

-(void) downloadImageAtIndex:(int) index
{
    NSDictionary *data = [images objectAtIndex:index];
    [self updateLabelTextForImage:data];
    saveButton.hidden = YES;
    
    NSString *downloadPath = [self getImagePath:data];
    
    switch (viewType) {
        case DROPBOX:
        {
            NSString *filePath = [data objectForKey:FILE_PATH];

            if ([CacheManager fileExistsAtPath:downloadPath]) {
                NSLog(@"Download completed in queue in Dropbox");
                saveButton.hidden = NO;
            } else if (![self.appDelegate.restClient isRequestAlreadyQueued:filePath] &&
                       ![CacheManager fileExistsAtPath:downloadPath] &&
                       ![self.appDelegate.restClient requestCount]) {
                [self.appDelegate.restClient loadFile:filePath
                                                atRev:[data objectForKey:FILE_REV]
                                             intoPath:downloadPath];
                [self updateDownloadProgressButtonImage:data];
                NSLog(@"Download Started in Dropbox");
            } else if ([self.appDelegate.restClient requestCount]) {
                int index = [liveOperations indexOfObject:data];
                if (index < [liveOperations count]) {
                    NSLog(@"Download already added in queue in Dropbox");
                } else {
                    [liveOperations addObject:data];
                    NSLog(@"Download added in queue in Dropbox");
                }
            } else {
                NSLog(@"Download already in Progress in Dropbox");
            }
        }
            break;
        case SKYDRIVE:
        {
            if ([liveOperations containsObject:data]) {
                NSLog(@"Already");
            } else if (![CacheManager fileExistsAtPath:downloadPath]){
                [liveOperations addObject:data];
                NSLog(@"Added");
                if (!downloadOperation) {
                    self.downloadOperation = [self.appDelegate.liveClient downloadFromPath:[data objectForKey:FILE_IMAGE_URL] delegate:self userState:downloadPath];
                    [self updateDownloadProgressButtonImage:data];
                }
                NSLog(@"Started");
            } else if ([CacheManager fileExistsAtPath:downloadPath]) {
                NSLog(@"Already Downloaded");
            }
        }
            break;
            
        default:
            break;
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
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",[sharedManager getTempPath:[[image objectForKey:ACCOUNT_TYPE] intValue]],[image objectForKey:FILE_ID]];
    return imagePath;
}


-(NSString *) getImageThumbnailPath:(NSDictionary *) image
{
    NSString *thumbPath = [NSString stringWithFormat:@"%@/%@",[sharedManager getThumbnailPath:[[image objectForKey:ACCOUNT_TYPE] intValue]],[image objectForKey:FILE_ID]];
    return thumbPath;
}


-(void) updateLabelTextForImage:(NSDictionary *)image
{
    [currentImageIndexLabel setTextColor:[UIColor whiteColor]];
    if ([liveOperations count]) {
        if (currentDownloadIndex == [images indexOfObject:[liveOperations objectAtIndex:0]]) {
            [currentImageIndexLabel setTextColor:NAVBAR_COLOR];
        }
    }
    [self.navigationItem setTitle:[image objectForKey:FILE_NAME]];
    [currentImageIndexLabel setText:[NSString stringWithFormat:@"%d/%d",currentDownloadIndex + 1,[images count]]];
    [currentImageIndexLabel sizeToFit];
}


-(UIImage *) getImageForImageDictionary:(NSDictionary *) image
{
    NSString *fileName = [image objectForKey:FILE_NAME];
    NSString *filePath = [self getImagePath:image];
    UIImage *imageToBeShown = [UIImage imageWithContentsOfFile:filePath];
    if (!imageToBeShown) {
        NSString *thumbPath = [self getImageThumbnailPath:image];
        imageToBeShown = [UIImage imageWithContentsOfFile:thumbPath];
        if (!imageToBeShown) {
            imageToBeShown = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[[fileName componentsSeparatedByString:@"."] lastObject] lowercaseString]]];
        }
    }
    return imageToBeShown;
}


-(void) updateUIForImageDictionaryAtIndex:(int) index
{
    NSDictionary *image = [images objectAtIndex:index];
    [self updateLabelTextForImage:image];
}

-(void) updateUIForImageDictionaryAtIndex:(int) index
                             inScrollView:(CLZoomableImageView *) scrollView
{
    NSDictionary *image = [images objectAtIndex:index];
    [self updateLabelTextForImage:image];
    UIImage *imageToBeShown = [self getImageForImageDictionary:image];
    [downloadProgressButton setImage:imageToBeShown forState:UIControlStateNormal];
    [scrollView setImage:imageToBeShown];
}

-(void) showImage:(NSDictionary *) image
{
    [mainImageView setImage:[self getImageForImageDictionary:image]];
    [self updateLabelTextForImage:image];
}

-(int) getScrollViewIndexForIndex:(int) index
{
    int min = (viewCount/2);
    int max = ([images count] - 1 - (viewCount/2));
    
    int scrollViewIndex = min;
    
    if (index > max) {
        int diff = index - max;
        scrollViewIndex += diff;
    } else if (index < min) {
        int diff = min - index;
        scrollViewIndex -= diff;
    }
    
    return scrollViewIndex;
}




-(void) showImage
{
    int currentIndex = currentDownloadIndex;
    int min = (viewCount/2);
    int max = ([images count] - 1 - (viewCount/2));
    
    if (currentIndex >= min &&
        currentIndex <= max) {
        currentIndex = viewCount/2;
    } else if (currentIndex > max) {
        int diff = currentIndex - max;
        currentIndex = (viewCount/2) + diff;
        if (currentIndex >= [scrollViews count]) {
            currentIndex = [scrollViews count] - 1;
        }
    }

    [self updateUIForImageDictionaryAtIndex:currentDownloadIndex
                               inScrollView:[scrollViews objectAtIndex:currentIndex]];
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
//    [downloadProgressButton addTarget:self
//                               action:@selector(downloadProgressButtonClicked:)
//                     forControlEvents:UIControlEventTouchUpInside];
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

-(void) swipeGesture:(UIGestureRecognizer *) gesture
{
    NSLog(@"swiping");
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


#pragma mark - UIScrollViewDelegate



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (previousContentOffset.x > scrollView.contentOffset.x)
    {
        scrollDirection = ScrollDirectionRight;
    }
    else if (previousContentOffset.x < scrollView.contentOffset.x)
    {
        scrollDirection = ScrollDirectionLeft;
    }
    previousContentOffset = scrollView.contentOffset;
    
    int index = previousContentOffset.x/scrollView.frame.size.width;
    if (index != previousIndex) {
        // new Index
//        if (index > previousIndex) {
//            NSLog(@"Left at %d",index);
//        } else {
//            NSLog(@"Right at %d",index);
//        }
        currentDownloadIndex = index;
        if (shouldCallScrollViewDelegate) {
            [self adjustScrollView:scrollView];
        }
    } else {
        // same index
//        NSLog(@"Same at %d",index);
    }
    previousIndex = index;
}



-(void) adjustScrollView:(UIScrollView *) scrollView
{
    CLZoomableImageView *firstScrollView = [scrollViews objectAtIndex:0];
    CLZoomableImageView *lastScrollView = [scrollViews lastObject];
    
    float minFirstScrollViewX = CGRectGetMinX(firstScrollView.frame);
    float maxLastScrollViewX = CGRectGetMaxX(lastScrollView.frame);
    
    float minScrollContentX = 0;
    float maxScrollContentX = scrollView.contentSize.width;
    
    __block int index = currentDownloadIndex;
    
    switch (scrollDirection) {
        case ScrollDirectionLeft:
        {
            if (currentDownloadIndex > (viewCount/2) &&
                lastScrollView.frame.origin.x < maxScrollContentX - lastScrollView.frame.size.width) {
                firstScrollView.frame = CGRectMake(maxLastScrollViewX,
                                                   firstScrollView.frame.origin.y,
                                                   firstScrollView.frame.size.width,
                                                   firstScrollView.frame.size.height);
                [scrollViews removeObject:firstScrollView];
                [scrollViews addObject:firstScrollView];
                dispatch_async(dispatch_get_main_queue(), ^{
                    index += (viewCount/2);
                    if (index < [images count]) {
                        NSDictionary *image = [images objectAtIndex:index];
                        [firstScrollView setImage:[self getImageForImageDictionary:image]];
                    }
                });
            } else {
                // first should become last
            }
        }
            break;
        case ScrollDirectionRight:
        {
            if (firstScrollView.frame.origin.x > minScrollContentX &&
                currentDownloadIndex < [images count] - (viewCount/2) - 1) {
                lastScrollView.frame = CGRectMake(minFirstScrollViewX - lastScrollView.frame.size.width,
                                                   lastScrollView.frame.origin.y,
                                                   lastScrollView.frame.size.width,
                                                   lastScrollView.frame.size.height);
                [scrollViews removeObject:lastScrollView];
                [scrollViews insertObject:lastScrollView atIndex:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    index -= (viewCount/2);
                    if (index > INVALID_INDEX) {
                        NSDictionary *image = [images objectAtIndex:index];
                        [lastScrollView setImage:[self getImageForImageDictionary:image]];
                    }
                });
            } else {
                // first should become last
            }
        }
            break;
        default:
            break;
    }
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    int index;
//    switch (scrollDirection) {
//        case ScrollDirectionLeft:
//            index = currentDownloadIndex + (viewCount/2);
//            if (index > [images count] - 1) {
//                return;
//            }
//            break;
//        case ScrollDirectionRight:
//            index = currentDownloadIndex - (viewCount/2);
//            if (index < 0) {
//                return;
//            }
//            break;
//        default:
//            break;
//    }
    [self updateUIForImageDictionaryAtIndex:currentDownloadIndex];
    [self downloadImageAtIndex:currentDownloadIndex];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
}


@end
