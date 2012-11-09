//
//  CLBaseTableViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseTableViewController.h"

@interface CLBaseTableViewController ()

@end

@implementation CLBaseTableViewController
@synthesize tableViewStyle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithTableViewStyle:(UITableViewStyle) style
{
    if (self = [super init]) {
        self.tableViewStyle = style;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    tableDataArray = [[NSMutableArray alloc] init];
    dataTableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                 style:tableViewStyle];
    dataTableView.dataSource = self;
    dataTableView.delegate = self;
    dataTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:dataTableView];
    [dataTableView release];
    
    NSString *userId = nil;
    NSArray *userIds = [self.appDelegate.dropboxSession userIds];
    if ([userIds count]) {
        userId = [userIds objectAtIndex:0];
    }
    restClient = [[DBRestClient alloc] initWithSession:self.appDelegate.dropboxSession userId:userId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) dealloc
{
    [restClient release];
    restClient = nil;
    
    tableViewStyle = -9999;
    
    [tableDataArray release];
    tableDataArray = nil;
    [super dealloc];
}


#pragma mark - Helper Methods

-(void) updateView
{
    
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"CELL"] autorelease];
    }
    return cell;
}


@end
