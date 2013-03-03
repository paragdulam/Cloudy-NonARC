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
#import "CacheManager.h"

@interface CLAccountsTableViewController ()
{
    UIButton *editButton;
    UIButton *aboutButton;
    NSString *initialUserState;
    NSIndexPath *animatingIndexPath;
}
-(void) initialModelSetup;
-(void) performTableViewAnimationForIndexPath:(NSIndexPath *) indexPath withAnimationSequence:(NSArray *) sequence;
-(void) updateModel:(NSArray *) model;

@property (nonatomic,retain) NSIndexPath *animatingIndexPath;



@end

@implementation CLAccountsTableViewController
@synthesize animatingIndexPath;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) dealloc
{
    [animatingIndexPath release];
    animatingIndexPath = nil;
    
    [super dealloc];
}

#pragma mark - IBActions

-(void) aboutButtonTapped:(UIButton *) btn
{
    CLAboutViewController *aboutViewController = [[CLAboutViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
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
//    NSArray *storedAccounts = [CLCacheManager accounts];
    NSArray *storedAccounts = [sharedManager accounts];
    accounts = [[NSMutableArray alloc] initWithObjects:DROPBOX_STRING,SKYDRIVE_STRING, nil];
//    accounts = [[NSMutableArray alloc] initWithObjects:@"Add Account", nil];
    for (NSDictionary *account in storedAccounts) {
        VIEW_TYPE accountType = [[account objectForKey:ACCOUNT_TYPE] intValue];
        [accounts replaceObjectAtIndex:accountType withObject:account];
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
}

-(void) getSkyDriveQuotaForUserAccount:(NSDictionary *) account
{
    NSString *quotaPathString = [NSString stringWithFormat:@"%@/skydrive/quota",[account objectForKey:ID]];
    [self.appDelegate.liveClient getWithPath:quotaPathString
                                    delegate:self
                                   userState:account];
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
    id object = [tableDataArray objectAtIndex:indexPath.section];
    [cell setData:object];
    if ([object isKindOfClass:[NSString class]]) {
        if ([animatingIndexPath isEqual:indexPath]) {
            [cell startAnimating];
        }
    }
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
//                UINavigationController *navController = (UINavigationController *)self.appDelegate.menuController.rootViewController;
//                [navController popToRootViewControllerAnimated:NO];
//                [self.appDelegate.menuController setRootController:navController animated:YES];
//                
//                [self.appDelegate.rootFileBrowserViewController loadFilesForPath:@"/" WithInViewType:DROPBOX];
            }
            break;
        }
        case SKYDRIVE:
        {
            if (self.appDelegate.liveClient.session == nil) {
                [self.appDelegate.liveClient login:self.appDelegate.menuController
                                            scopes:SCOPE_ARRAY
                                          delegate:self
                                         userState:@"LOGIN_ACCOUNT_VC"];
            } else {
//                UINavigationController *navController = (UINavigationController *)self.appDelegate.menuController.rootViewController;
//                [navController popToRootViewControllerAnimated:NO];
//                [self.appDelegate.menuController setRootController:navController animated:YES];
//                
//                [self.appDelegate.rootFileBrowserViewController loadFilesForPath:ROOT_SKYDRIVE_PATH WithInViewType:SKYDRIVE];
            }
            break;
        }
        case BOX:
        {
            if (![self.boxClient auth_token]) {
                [self.boxClient login];
                CLAccountCell *cell = (CLAccountCell *)[dataTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:BOX]];
                [cell startAnimating];
            } else {
                UINavigationController *navController = (UINavigationController *)self.appDelegate.menuController.rootViewController;
                [navController popToRootViewControllerAnimated:NO];
                [self.appDelegate.menuController setRootController:navController animated:YES];
                //load root folder Metadata here
                [self.appDelegate.rootFileBrowserViewController loadFilesForPath:@"0" WithInViewType:BOX];

            }
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
//    NSDictionary *account = [CLCacheManager getAccountForType:indexPath.section];
//    [CLCacheManager deleteAccount:account];
//    [CLCacheManager deleteFileStructureForView:indexPath.section];
    
    BOOL success = [sharedManager deleteAccount:[sharedManager accountOfType:indexPath.section]];
    
    switch (indexPath.section) {
        case DROPBOX:
        {
            [tableDataArray replaceObjectAtIndex:DROPBOX withObject:DROPBOX_STRING];
            DBSession *sharedSession = self.appDelegate.dropboxSession;
            NSString *userId = [[sharedSession userIds] objectAtIndex:0];
            [sharedSession unlinkUserId:userId];
        }
            break;
        case SKYDRIVE:
        {
            [tableDataArray replaceObjectAtIndex:SKYDRIVE withObject:SKYDRIVE_STRING];
            [self.appDelegate.liveClient logoutWithDelegate:self
                                                  userState:@"LOGOUT_SKYDRIVE"];
        }
            break;
        case BOX:
        {
            [tableDataArray replaceObjectAtIndex:BOX withObject:BOX_STRING];
            [self.boxClient logout];
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


#pragma mark - BoxClientDelegate

-(void) authenticationDone
{
    [self.boxClient getAccountInfo];
}


-(void) boxClient:(BoxClient *)client didLoadAccountInfo:(NSDictionary *)accountInfo
{
    //Compatible Dictionary Conversion Starts
    NSMutableDictionary *accountData = [[NSMutableDictionary alloc] init];
    [accountData addEntriesFromDictionary:accountInfo];
    [accountData setObject:[NSNumber numberWithInt:BOX] forKey:ACCOUNT_TYPE];
    BOOL isAccountStored = [CLCacheManager storeAccount:accountData];
    [accountData release];
    //Compatible Dictionary Conversion Ends
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:BOX];
    if (isAccountStored) {
        [tableDataArray replaceObjectAtIndex:BOX withObject:accountInfo];
        NSArray *sequenceArray = [NSArray arrayWithObjects:[NSNumber numberWithInteger:UITableViewRowAnimationLeft],[NSNumber numberWithInteger:UITableViewRowAnimationRight], nil];
        [self performTableViewAnimationForIndexPath:indexPath
                              withAnimationSequence:sequenceArray];
    }
    editButton.hidden = NO;
    [self tableView:dataTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:BOX]];

}


-(void) boxClient:(BoxClient *)client didLoadFailedAccountInfoWithError:(NSError *)error
{
    [AppDelegate showError:error alertOnView:self.view];
}


-(void) boxClient:(BoxClient *)client DidLogOutWithData:(NSDictionary *)data
{
    
}

-(void) boxClient:(BoxClient *)client DidLogOutFailWithError:(NSError *)error
{
    [AppDelegate showError:error alertOnView:self.view];
}

#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info
{
    NSDictionary *accountDictionary = [CLDictionaryConvertor dictionaryFromAccountInfo:info];
//    BOOL isAccountStored = [CLCacheManager storeAccount:accountDictionary];
    BOOL isAccountStored = [sharedManager addAccount:accountDictionary];

    if (isAccountStored) {
        [tableDataArray replaceObjectAtIndex:DROPBOX withObject:accountDictionary];
//        [dataTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:DROPBOX]]
//                             withRowAnimation:UITableViewRowAnimationRight];
//        NSArray *sequenceArray = [NSArray arrayWithObjects:[NSNumber numberWithInteger:UITableViewRowAnimationLeft],[NSNumber numberWithInteger:UITableViewRowAnimationRight], nil];
//        [self performTableViewAnimationForIndexPath:indexPath
//                              withAnimationSequence:sequenceArray];
    }
    editButton.hidden = NO;
//    [self tableView:dataTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:DROPBOX]];
}

- (void)restClient:(DBRestClient*)client loadAccountInfoFailedWithError:(NSError*)error
{
    [AppDelegate showError:error
               alertOnView:self.view];
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
    if ([userState isEqualToString:@"LOGIN_ACCOUNT_VC"]) {
        self.animatingIndexPath = [NSIndexPath indexPathForRow:0
                                                     inSection:SKYDRIVE];
        [self updateView];
        [self.appDelegate.liveClient getWithPath:@"/me"
                                        delegate:self
                                       userState:@"GET_SKYDRIVE_USER_DETAILS"];
    }
}

- (void) authFailed: (NSError *) error
          userState: (id)userState
{
    
}


#pragma mark - LiveOperationDelegate

- (void) liveOperationSucceeded:(LiveOperation *)operation
{
    if ([operation.userState isKindOfClass:[NSString class]]) {
        if ([operation.userState isEqualToString:@"GET_SKYDRIVE_USER_DETAILS"]) {
            
            NSDictionary *accountDictionary = [CacheManager processDictionary:operation.result ForDataType:DATA_ACCOUNT AndViewType:SKYDRIVE];
            
            BOOL isAccountAdded = [sharedManager addAccount:accountDictionary];
            
            if (isAccountAdded) {
                //perform UI Operations
                [tableDataArray replaceObjectAtIndex:SKYDRIVE
                                          withObject:accountDictionary];
                [dataTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SKYDRIVE]]
                                     withRowAnimation:UITableViewRowAnimationRight];
            }
            
            [self getSkyDriveQuotaForUserAccount:accountDictionary];
            
        }
    } else { //quota dictionary with account dictionary UserState
        NSDictionary *resultDictionary = operation.result;
        NSDictionary *quota = [CacheManager processDictionary:resultDictionary
                                                  ForDataType:DATA_QUOTA
                                                  AndViewType:SKYDRIVE];
        NSMutableDictionary *finalAccountDictionary = [NSMutableDictionary dictionaryWithDictionary:operation.userState];
        [finalAccountDictionary addEntriesFromDictionary:quota];
        BOOL isAccountUpdated = [sharedManager updateAccount:finalAccountDictionary];
        if (isAccountUpdated) {
            [tableDataArray replaceObjectAtIndex:SKYDRIVE
                                      withObject:finalAccountDictionary];
            self.animatingIndexPath = nil;
            [dataTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SKYDRIVE]]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveOperation*)operation
{
}



#pragma mark - Unused For Now
#pragma mark - CLCloudPlatformListViewControllerDelegate


-(void) login:(NSNumber *) number
{
    switch ([number intValue]) {
        case DROPBOX:
            [self.appDelegate.dropboxSession linkFromController:self.appDelegate.menuController];
            break;
        case SKYDRIVE:
            [self.appDelegate.liveClient login:self.appDelegate.menuController
                                        scopes:SCOPE_ARRAY
                                      delegate:self];
        default:
            break;
    }
}


-(void) cloudPlatformListViewController:(CLCloudPlatformsListViewController *) viewController didSelectPlatForm:(VIEW_TYPE) type
{
    [viewController dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(login:)
               withObject:[NSNumber numberWithInt:type]
               afterDelay:.5f];
}


@end
