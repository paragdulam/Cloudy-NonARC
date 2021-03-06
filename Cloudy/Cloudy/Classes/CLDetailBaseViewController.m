//
//  CLDetailBaseViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 23/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLDetailBaseViewController.h"

@interface CLDetailBaseViewController ()

@end

@implementation CLDetailBaseViewController

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
    [self setWantsFullScreenLayout:YES];
    [self setHidesBottomBarWhenPushed:YES];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self.navigationController.navigationBar setTranslucent:YES];
    
    
    
    originalViewRect = self.appDelegate.window.rootViewController.view.frame;
    self.appDelegate.window.rootViewController.view.frame = self.appDelegate.window.bounds;
    self.navigationController.view.frame = self.appDelegate.window.rootViewController.view.bounds;
    self.view.frame = self.navigationController.view.bounds;
    
    CGRect rect = self.navigationController.navigationBar.frame;
    rect.origin.y = CGRectGetMaxY([[UIApplication sharedApplication] statusBarFrame]);
    self.navigationController.navigationBar.frame = rect;
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [CLCacheManager deleteAllContentsOfFolderAtPath:[CLCacheManager getTemporaryDirectory]];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.navigationController.navigationBar.tintColor = NAVBAR_COLOR;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.appDelegate.window.rootViewController.view.frame = originalViewRect;
    self.navigationController.view.frame = self.appDelegate.window.rootViewController.view.bounds;
    self.view.frame = self.navigationController.view.bounds;
    
    CGRect rect = self.navigationController.navigationBar.frame;
    rect.origin.y = 0;
    self.navigationController.navigationBar.frame = rect;
}


-(void) dealloc
{
    [super dealloc];
}






@end
