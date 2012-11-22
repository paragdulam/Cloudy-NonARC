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
}
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
    [self setWantsFullScreenLayout:YES];
    [self setHidesBottomBarWhenPushed:YES];
    
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
    
    liveOperations = [[NSMutableArray alloc] init];
    [self downloadImages];
    [self showImage];
    
	// Do any additional setup after loading the view.
}



-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    
    
    originalViewRect = self.appDelegate.window.rootViewController.view.frame;
    self.appDelegate.window.rootViewController.view.frame = self.appDelegate.window.bounds;
    self.view.frame = self.appDelegate.window.rootViewController.view.bounds;
    CGRect rect = self.navigationController.navigationBar.frame;
    rect.origin.y = 20.f;
    self.navigationController.navigationBar.frame = rect;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    self.appDelegate.window.rootViewController.view.frame = originalViewRect;
    self.view.frame = self.appDelegate.window.rootViewController.view.bounds;
    CGRect rect = self.navigationController.navigationBar.frame;
    rect.origin.y = 0.f;
    self.navigationController.navigationBar.frame = rect;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) dealloc
{
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



#pragma mark - DBRestClientDelegate

-(void) restClient:(DBRestClient *)client
        loadedFile:(NSString *)destPath
       contentType:(NSString *)contentType
          metadata:(DBMetadata *)metadata
{
}

-(void) restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    
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
    
}

#pragma mark - Helper methods


-(void) downloadImages
{
    for (NSDictionary *data in images) {
        switch (viewType) {
            case DROPBOX:
            {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CLCacheManager getTemporaryDirectory],[data objectForKey:@"filename"]];
                [self.appDelegate.restClient loadFile:[data objectForKey:@"path"]
                                                atRev:[data objectForKey:@"rev"]
                                             intoPath:filePath];
            }
                break;
            case SKYDRIVE:
            {
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
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CLCacheManager getTemporaryDirectory],fileName];
    UIImage *imageToBeShown = [UIImage imageWithContentsOfFile:filePath];
    if (!imageToBeShown) {
        imageToBeShown = [UIImage imageWithData:[currentImage objectForKey:THUMBNAIL_DATA]];
    }
    [mainImageView setImage:imageToBeShown];
}


#pragma mark - Tap Gesture


-(void) panGesture:(UIGestureRecognizer *) gesture
{
    NSLog(@"panning...");
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
    } else {
        self.navigationController.navigationBarHidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
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
