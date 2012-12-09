//
//  CLMediaPlayerViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 08/12/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLMediaPlayerViewController.h"

@interface CLMediaPlayerViewController ()
{
    MPMoviePlayerController *moviePlayer;
}
@end

@implementation CLMediaPlayerViewController
@synthesize mediaURL;
@synthesize video;
@synthesize viewType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(id) initWithVideoFile:(NSDictionary *) videoFile
         withInViewType:(VIEW_TYPE) type
{
    if (self = [super init]) {
        self.viewType = type;
        self.video = videoFile;
    }
    return self;
}


-(id) initWithMediaURL:(NSURL *) url
{
    if (self = [super init]) {
        self.mediaURL = url;
    }
    return self;
}


-(void) setUpMediaPlayer
{
    moviePlayer = [[MPMoviePlayerController alloc] init];
    [self.view addSubview:moviePlayer.view];
    [moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
}

-(void) playMovie
{
    [moviePlayer setContentURL:mediaURL];
    [moviePlayer prepareToPlay];
    [moviePlayer play];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setUpMediaPlayer];
    switch (viewType) {
        case DROPBOX:
        {
            [self.appDelegate.restClient loadStreamableURLForFile:[video objectForKey:@"path"]];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
            break;
        case SKYDRIVE:
        {
            self.mediaURL = [NSURL URLWithString:[video objectForKey:@"source"]];
            [self playMovie];
        }
            break;
        default:
            break;
    }
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    moviePlayer.view.frame = self.view.bounds;
    self.appDelegate.restClient.delegate = self;
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [moviePlayer stop];
    self.appDelegate.restClient.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) dealloc
{
    [video release];
    video = nil;
    
    [moviePlayer release];
    moviePlayer = nil;
    
    [mediaURL release];
    mediaURL = nil;
    
    [super dealloc];
}



#pragma mark - DBRestClientDelegate


- (void)restClient:(DBRestClient*)restClient loadedStreamableURL:(NSURL*)url forFile:(NSString*)path
{
    self.mediaURL = url;
    [self playMovie];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)restClient:(DBRestClient*)restClient loadStreamableURLFailedWithError:(NSError*)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
