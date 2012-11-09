//
//  CLAccountsTableViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLAccountsTableViewController.h"

@interface CLAccountsTableViewController ()
-(void) initialModelSetup;
-(void) performTableViewAnimationForIndexPath:(NSIndexPath *) indexPath withAnimationSequence:(NSArray *) sequence;

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
    [self initialModelSetup];
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper Methods


-(void) performTableViewAnimationForIndexPath:(NSIndexPath *) indexPath withAnimationSequence:(NSArray *) sequence
{
    [dataTableView beginUpdates];
    
    [dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:[[sequence objectAtIndex:0] integerValue]];
    
    [dataTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:[[sequence objectAtIndex:1] integerValue]];
    
    
    [dataTableView endUpdates];
}


-(void) initialModelSetup
{
    NSMutableArray *accounts = nil;
    NSArray *storedAccounts = [CLCacheManager accounts];
    if (![storedAccounts count]) {
        accounts = [[NSMutableArray alloc] initWithObjects:DROPBOX_STRING,SKYDRIVE_STRING, nil];
    } else {
        accounts = [[NSMutableArray alloc] initWithArray:storedAccounts];
        switch ([storedAccounts count]) {
            case 1:
            {
                NSDictionary *account = [accounts objectAtIndex:0];
                VIEW_TYPE accountType = [[account objectForKey:ACCOUNT_TYPE] intValue];
                switch (accountType) {
                    case DROPBOX:
                        [accounts insertObject:SKYDRIVE_STRING atIndex:1];
                        break;
                    case SKYDRIVE:
                        [accounts insertObject:DROPBOX_STRING atIndex:0];
                        break;
                    default:
                        break;
                }
            }
                break;
                
            default:
                break;
        }
    }
    [tableDataArray removeAllObjects];
    [tableDataArray addObjectsFromArray:accounts];
    [accounts release];
}

-(void) updateView
{
    [super updateView];
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
