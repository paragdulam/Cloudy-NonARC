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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:mediaURL];
    [self.view addSubview:moviePlayer.view];
    [moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
    [moviePlayer prepareToPlay];
    [moviePlayer play];
    
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    moviePlayer.view.frame = self.view.bounds;
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [moviePlayer stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) dealloc
{
    [moviePlayer release];
    moviePlayer = nil;
    
    [mediaURL release];
    mediaURL = nil;
    
    [super dealloc];
}

@end
