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
    
    mainImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    mainImageView.userInteractionEnabled = YES;
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
	// Do any additional setup after loading the view.
}


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
//                NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CLCacheManager getTemporaryDirectory],[data objectForKey:@"name"]];
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

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) dealloc
{
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



#pragma mark - Tap Gesture


-(void) panGesture:(UIGestureRecognizer *) gesture
{
    NSLog(@"panning...");
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
