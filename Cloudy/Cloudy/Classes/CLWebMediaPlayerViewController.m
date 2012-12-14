//
//  CLWebMediaPlayerViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 13/12/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLWebMediaPlayerViewController.h"

@interface CLWebMediaPlayerViewController ()

@end

@implementation CLWebMediaPlayerViewController

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
    
    
    switch (viewType) {
        case DROPBOX:
        {
            [self.appDelegate.restClient loadStreamableURLForFile:[file objectForKey:@"path"]];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
            break;
        case SKYDRIVE:
        {
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[file objectForKey:@"source"]]]];
        }
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



#pragma mark - DBRestClientDelegate


- (void)restClient:(DBRestClient*)restClient loadedStreamableURL:(NSURL*)url forFile:(NSString*)path
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    [webView loadHTMLString:[NSString stringWithFormat:@"<html><body><p><a href=\%@>Play mp3</a></p><script src=\"http://mediaplayer.yahoo.com/js\"></script></body></html>",[url absoluteString]]
//                    baseURL:nil];
//    [webView loadHTMLString:[NSString stringWithFormat:@"<html><body><embed height=\"100\" width=\"100\" src=%@></embed><p>If you cannot hear the sound, your computer or browser doesn't support the sound format.</p><p>Or, you have your speakers turned off.</p></body></html>",[url absoluteString]]
//                    baseURL:nil];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)restClient:(DBRestClient*)restClient loadStreamableURLFailedWithError:(NSError*)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
