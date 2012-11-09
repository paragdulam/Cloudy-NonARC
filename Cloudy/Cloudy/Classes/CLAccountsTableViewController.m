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
-(void) startAnimatingCellAtIndexPath:(NSIndexPath *) indexPath;
-(void) stopAnimatingCellAtIndexPath:(NSIndexPath *) indexPath;
-(CLAccountCell *) cellAtIndexPath:(NSIndexPath *)indexPath;
-(void) updateModel:(NSArray *) model;

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


-(CLAccountCell *) cellAtIndexPath:(NSIndexPath *)indexPath
{
    return (CLAccountCell *)[dataTableView cellForRowAtIndexPath:indexPath];
}

-(void) startAnimatingCellAtIndexPath:(NSIndexPath *) indexPath
{
    CLAccountCell *cell = [self cellAtIndexPath:indexPath];
    [cell startAnimating];
}

-(void) stopAnimatingCellAtIndexPath:(NSIndexPath *) indexPath
{
    CLAccountCell *cell = [self cellAtIndexPath:indexPath];
    [cell stopAnimating];
}

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
    [self updateModel:accounts];
    [accounts release];
}

-(void) updateModel:(NSArray *) model
{
    [tableDataArray removeAllObjects];
    [tableDataArray addObjectsFromArray:model];
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
    CLAccountCell *cell = (CLAccountCell *)[tableView dequeueReusableCellWithIdentifier:@"CLAccountCell"];
    if (!cell) {
        cell = [[[CLAccountCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CLAccountCell"] autorelease];
    }
    [cell setData:[tableDataArray objectAtIndex:indexPath.section]];
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case DROPBOX:
            [self.appDelegate.dropboxSession linkFromController:self.appDelegate.menuController];
            break;
            
        case SKYDRIVE:
            [self.appDelegate.liveClient login:self.appDelegate.menuController
                                      delegate:self];
            break;
        default:
            break;
    }
}


#pragma mark - DBSessionDelegate


-(void)authenticationDoneForSession:(DBSession *)session
{
    
}

-(void)  authenticationCancelledManuallyForSession:(DBSession *) session
{
}



- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    
}


#pragma mark - LiveAuthDelegate


- (void) authCompleted: (LiveConnectSessionStatus) status
               session: (LiveConnectSession *) session
             userState: (id) userState
{
    
}

- (void) authFailed: (NSError *) error
          userState: (id)userState
{
    
}


#pragma mark - LiveOperationDelegate

- (void) liveOperationSucceeded:(LiveOperation *)operation
{
    
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveOperation*)operation
{
    
}



@end
