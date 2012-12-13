//
//  CLAccountsTableViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLAccountsTableViewController.h"
#import "CLFileBrowserBaseTableViewController.h"
#import "CLAboutViewController.h"

@interface CLAccountsTableViewController ()
{
    UIButton *editButton;
    UIButton *aboutButton;
    NSString *initialUserState;
}
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
    
    //Setting Up Edit Button Start
    
    editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [editButton setTitle:@"Done" forState:UIControlStateSelected];
    UIImage *baseImage = [UIImage imageNamed:@"button_background_base.png"];
    UIImage *buttonImage = [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 5)];
    [editButton setBackgroundImage:buttonImage
                          forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editButton addTarget:self
                   action:@selector(editButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [editButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
    [editButton setFrame:CGRectMake(0, 0, 50, 30)];
    UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    [self.navigationItem setLeftBarButtonItem:editBarButtonItem];
    [editBarButtonItem release];
    
    //Setting Up Edit Button End
    
    //Setting Up About Button Start
    
    aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aboutButton setTitle:@"About" forState:UIControlStateNormal];
    buttonImage = [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 5)];
    [aboutButton setBackgroundImage:buttonImage
                          forState:UIControlStateNormal];
    [aboutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [aboutButton addTarget:self
                   action:@selector(aboutButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [aboutButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
    [aboutButton setFrame:CGRectMake(0, 0, 50, 30)];
    UIBarButtonItem *aboutBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aboutButton];
    [self.navigationItem setRightBarButtonItem:aboutBarButtonItem];
    [aboutBarButtonItem release];
    
    //Setting Up About Button End

    
    
    [self initialModelSetup];
    [self updateView];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![CLCacheManager getAccountForType:DROPBOX] && [self.appDelegate.dropboxSession isLinked]) {
        [self authenticationDoneForSession:self.appDelegate.dropboxSession];
    }
    
    if (!self.appDelegate.liveClient.session && [CLCacheManager getAccountForType:SKYDRIVE]) {
        [self startAnimatingCellAtIndexPath:[NSIndexPath indexPathForRow:0
                                                               inSection:SKYDRIVE]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

-(void) aboutButtonTapped:(UIButton *) btn
{
    CLAboutViewController *aboutViewController = [[CLAboutViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
    [aboutViewController release];
    [self.appDelegate.window.rootViewController presentModalViewController:navController animated:YES];
    [navController release];
}


-(void)editButtonTapped:(UIButton *) btn
{
    btn.selected = !btn.selected;
    [dataTableView setEditing:btn.selected animated:YES];
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
            case 0:
                break;
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
            case 2:
            {
                NSDictionary *account = [accounts objectAtIndex:0];
                VIEW_TYPE accountType = [[account objectForKey:ACCOUNT_TYPE] intValue];
                switch (accountType) {
                    case SKYDRIVE:
                    {
                        [accounts exchangeObjectAtIndex:0 withObjectAtIndex:1];
                    }
                        break;
                        
                    default:
                        break;
                }

            }
                break;
        }
    }
    [self updateModel:accounts];
    [accounts release];
    
    editButton.hidden = [storedAccounts count] ? NO : YES ;
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
    [cell setData:[tableDataArray objectAtIndex:indexPath.section] forCellAtIndexPath:indexPath];
    return cell;
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = CELL_BACKGROUND_COLOR;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case DROPBOX:
        {
            if (![self.appDelegate.dropboxSession isLinked]) {
                [self.appDelegate.dropboxSession linkFromController:self.appDelegate.menuController];
            } else {
                UINavigationController *navController = (UINavigationController *)self.appDelegate.menuController.rootViewController;
                [navController popToRootViewControllerAnimated:NO];
                [self.appDelegate.menuController setRootController:navController animated:YES];
                
                [self.appDelegate.rootFileBrowserViewController loadFilesForPath:@"/" WithInViewType:DROPBOX];
            }
            break;
        }
        case SKYDRIVE:
        {
            if (self.appDelegate.liveClient.session == nil) {
                [self.appDelegate.liveClient login:self.appDelegate.menuController
                                            scopes:SCOPE_ARRAY
                                          delegate:self];
            } else {
                UINavigationController *navController = (UINavigationController *)self.appDelegate.menuController.rootViewController;
                [navController popToRootViewControllerAnimated:NO];
                [self.appDelegate.menuController setRootController:navController animated:YES];
                
                [self.appDelegate.rootFileBrowserViewController loadFilesForPath:ROOT_SKYDRIVE_PATH WithInViewType:SKYDRIVE];
            }
            break;
        }
        default:
            break;
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLAccountCell *cell = (CLAccountCell *)[tableView cellForRowAtIndexPath:indexPath];
    return ![[tableDataArray objectAtIndex:indexPath.section] isKindOfClass:[NSString class]] && ![cell isAnimating];
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}



- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *retVal = @"Logout";
    switch (indexPath.section)
    {
        case DROPBOX:
            retVal = @"UnLink";
            break;
            
        default:
            break;
    }
    return retVal;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //animate button starts
//    CLAccountCell *cell = [self cellAtIndexPath:indexPath];
//    UIButton *disclosureButton = (UIButton *)[cell accessoryView];
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:1.f];
//    disclosureButton.transform = CGAffineTransformMakeRotation(3.142/2);
//    [UIView commitAnimations];
    //animate button ends
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *account = [CLCacheManager getAccountForType:indexPath.section];
    [CLCacheManager deleteAccount:account];
    [CLCacheManager deleteFileStructureForView:indexPath.section];
    
    switch (indexPath.section) {
        case 0:
        {
            [tableDataArray replaceObjectAtIndex:0 withObject:DROPBOX_STRING];
            DBSession *sharedSession = self.appDelegate.dropboxSession;
            NSString *userId = [[sharedSession userIds] objectAtIndex:0];
            [sharedSession unlinkUserId:userId];
        }
            break;
        case 1:
        {
            [tableDataArray replaceObjectAtIndex:1 withObject:SKYDRIVE_STRING];
            [self.appDelegate.liveClient logoutWithDelegate:self
                                                  userState:@"LOGOUT_SKYDRIVE"];
        }
            break;
        default:
            break;
    }
    NSArray *sequenceArray = [NSArray arrayWithObjects:[NSNumber numberWithInteger:UITableViewRowAnimationRight],[NSNumber numberWithInteger:UITableViewRowAnimationLeft], nil];
    [self performTableViewAnimationForIndexPath:indexPath withAnimationSequence:sequenceArray];
    [self editButtonTapped:editButton];
    [self.appDelegate initialSetup];
    if (![[CLCacheManager accounts] count]) {
        editButton.hidden = YES;
    }
}



#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info
{
    NSDictionary *accountDictionary = [CLDictionaryConvertor dictionaryFromAccountInfo:info];
    BOOL isAccountStored = [CLCacheManager storeAccount:accountDictionary];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:DROPBOX];
    [self stopAnimatingCellAtIndexPath:indexPath];
    if (isAccountStored) {
        [tableDataArray replaceObjectAtIndex:DROPBOX withObject:accountDictionary];
        NSArray *sequenceArray = [NSArray arrayWithObjects:[NSNumber numberWithInteger:UITableViewRowAnimationLeft],[NSNumber numberWithInteger:UITableViewRowAnimationRight], nil];
        [self performTableViewAnimationForIndexPath:indexPath
                              withAnimationSequence:sequenceArray];
    }
    editButton.hidden = NO;
    [self tableView:dataTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:DROPBOX]];
}

- (void)restClient:(DBRestClient*)client loadAccountInfoFailedWithError:(NSError*)error
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:DROPBOX];
    [self stopAnimatingCellAtIndexPath:indexPath];
    [AppDelegate showError:error
               alertOnView:self.view];
}



#pragma mark - DBSessionDelegate


-(void)authenticationDoneForSession:(DBSession *)session
{
    [self.restClient loadAccountInfo];
    [self startAnimatingCellAtIndexPath:[NSIndexPath indexPathForRow:0
                                                           inSection:DROPBOX]];
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
    initialUserState = [userState retain];
    [self.appDelegate.liveClient getWithPath:@"/me"
                                    delegate:self
                                   userState:@"/me"];
    [self startAnimatingCellAtIndexPath:[NSIndexPath indexPathForRow:0
                                                           inSection:SKYDRIVE]];
}

- (void) authFailed: (NSError *) error
          userState: (id)userState
{
    
}


#pragma mark - LiveOperationDelegate

- (void) liveOperationSucceeded:(LiveOperation *)operation
{
    if ([operation.userState isEqualToString:@"/me"]) {
        NSDictionary *accountDictionary = [CLDictionaryConvertor dictionaryFromAccountInfo:operation.result];
        BOOL isAccountStored = [CLCacheManager storeAccount:accountDictionary];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                    inSection:SKYDRIVE];
        CLAccountCell *cell = [self cellAtIndexPath:indexPath];
        [cell stopAnimating:YES];
        if (isAccountStored) {
            [tableDataArray replaceObjectAtIndex:SKYDRIVE withObject:accountDictionary];
            NSArray *sequenceArray = [NSArray arrayWithObjects:[NSNumber numberWithInteger:UITableViewRowAnimationLeft],[NSNumber numberWithInteger:UITableViewRowAnimationRight], nil];
            [self performTableViewAnimationForIndexPath:indexPath
                                  withAnimationSequence:sequenceArray];
        }
        editButton.hidden = NO;
        [self.appDelegate.liveClient getWithPath:@"/me/skydrive/quota"
                                        delegate:self
                                       userState:@"/me/skydrive/quota"];
    } else if ([operation.userState isEqualToString:@"/me/skydrive/quota"]) {
        //read the quota dictionary
        NSDictionary *quotaDictionary = operation.result;
        
        //Read the current skydrive account
        NSMutableDictionary *skyDriveAccount = [[NSMutableDictionary alloc] initWithDictionary:[CLCacheManager getAccountForType:SKYDRIVE]];
        
        //Add the quota dictionary to the current skydrive account
        [skyDriveAccount setObject:quotaDictionary forKey:@"quota"];
        
        //update the account dictionary
        [CLCacheManager updateAccount:skyDriveAccount];
        [skyDriveAccount release];
        [self initialModelSetup];
        [self updateView];
        if (![initialUserState isEqualToString:@"InitialAllocation"]) {
            [self tableView:dataTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SKYDRIVE]];
        } else {
            [initialUserState release];
            initialUserState = nil;
        }
    }
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveOperation*)operation
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:SKYDRIVE];
    [self stopAnimatingCellAtIndexPath:indexPath];
}



@end
