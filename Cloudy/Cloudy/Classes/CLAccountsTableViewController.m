//
//  CLAccountsTableViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLAccountsTableViewController.h"

@interface CLAccountsTableViewController ()

@end

@implementation CLAccountsTableViewController

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
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.navigationItem setTitle:@"Accounts"];
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper Methods


-(void) updateView
{
    [super updateView];
    NSArray *accountTypes = [[NSArray alloc] initWithObjects:@"Dropbox",@"SkyDrive", nil];
    [tableDataArray addObjectsFromArray:accountTypes];
    [accountTypes release];
    [dataTableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableDataArray count];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell.textLabel setText:[tableDataArray objectAtIndex:indexPath.section]];
    return cell;
}



@end
