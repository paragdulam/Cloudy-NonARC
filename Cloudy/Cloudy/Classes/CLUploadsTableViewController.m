//
//  CLUploadsTableViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 29/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLUploadsTableViewController.h"

@interface CLUploadsTableViewController ()

@end

@implementation CLUploadsTableViewController

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
    [self setTitle:@"Uploads"];
    
    CLBrowserBarItem *barItem = [[CLBrowserBarItem alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    barItem.delegate = self;
    [barItem setTitle:@"Cancel" forState:UIControlStateNormal];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barItem];
    [barItem release];
    
    [self.navigationItem setRightBarButtonItem:cancelBarButtonItem];
    [cancelBarButtonItem release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Helper Methods

-(void) cancelButtonClicked:(UIButton *) btn
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - CLBrowserBarItemDelegate

-(void) buttonClicked:(UIButton *)btn WithinView:(CLBrowserBarItem *) view
{
    [self cancelButtonClicked:btn];
}


@end
