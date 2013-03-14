//
//  CLBaseViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseViewController.h"

@interface CLBaseViewController ()
{
    UIImageView *backgroundImageView;
}
@end

@implementation CLBaseViewController

-(AppDelegate *) appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

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
    self.navigationController.navigationBar.tintColor = NAVBAR_COLOR;
    sharedManager = [CacheManager sharedManager];
//    backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    [backgroundImageView setImage:[UIImage imageNamed:@"table_background.png"]];
//    [self.view addSubview:backgroundImageView];
//    [backgroundImageView release];
//    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
