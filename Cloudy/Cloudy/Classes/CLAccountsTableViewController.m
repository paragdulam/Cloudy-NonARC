//
//  CLAccountsTableViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLAccountsTableViewController.h"

@interface CLAccountsTableViewController ()
{
    UIButton *editButton;
    DBRestClient *restClient;
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
    UIImage *buttonImage = [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
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
    
    NSString *userId = nil;
    NSArray *userIds = [self.appDelegate.dropboxSession userIds];
    if ([userIds count]) {
        userId = [userIds objectAtIndex:0];
    }
    restClient = [[DBRestClient alloc] initWithSession:self.appDelegate.dropboxSession userId:userId];
    restClient.delegate = self;
    
    [self initialModelSetup];
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

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
    [cell setData:[tableDataArray objectAtIndex:indexPath.section]];
    switch (indexPath.section) {
        case DROPBOX:
            [cell.imageView setImage:[UIImage imageNamed:@"dropbox_cell_Image.png"]];
            break;
        case SKYDRIVE:
            [cell.imageView setImage:[UIImage imageNamed:@"SkyDriveIconWhite_32x32.png"]];
            break;
            
        default:
            break;
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
            if (![self.appDelegate.dropboxSession isLinked]) {
                [self.appDelegate.dropboxSession linkFromController:self.appDelegate.menuController];
            }
            break;
            
        case SKYDRIVE:
            if (self.appDelegate.liveClient.session == nil) {
                [self.appDelegate.liveClient login:self.appDelegate.menuController
                                            scopes:SCOPE_ARRAY
                                          delegate:self];
            }
            break;
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
            [self.appDelegate.liveClient logout];
        }
            break;
        default:
            break;
    }
    NSArray *sequenceArray = [NSArray arrayWithObjects:[NSNumber numberWithInteger:UITableViewRowAnimationRight],[NSNumber numberWithInteger:UITableViewRowAnimationLeft], nil];
    [self performTableViewAnimationForIndexPath:indexPath withAnimationSequence:sequenceArray];
    [self editButtonTapped:editButton];
    
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
}

- (void)restClient:(DBRestClient*)client loadAccountInfoFailedWithError:(NSError*)error
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:DROPBOX];
    [self stopAnimatingCellAtIndexPath:indexPath];
    
    UIView *alert = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200,200)];
    alert.backgroundColor = [UIColor blackColor];
    alert.center = self.view.center;
    [self.view addSubview:alert];
    [alert release];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.f];
    alert.alpha = 0.f;
    [UIView commitAnimations];
}



#pragma mark - DBSessionDelegate


-(void)authenticationDoneForSession:(DBSession *)session
{
    [restClient loadAccountInfo];
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
    [self.appDelegate.liveClient getWithPath:@"/me"
                                    delegate:self];
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
    NSDictionary *accountDictionary = [CLDictionaryConvertor dictionaryFromAccountInfo:operation.result];
    BOOL isAccountStored = [CLCacheManager storeAccount:accountDictionary];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:SKYDRIVE];
    CLAccountCell *cell = [self cellAtIndexPath:indexPath];
    [cell stopAnimating:YES];
    if (isAccountStored) {
        [tableDataArray replaceObjectAtIndex:SKYDRIVE withObject:accountDictionary];
        NSArray *sequenceArray = [NSArray arrayWithObjects:[NSNumber numberWithInteger:UITableViewRowAnimationLeft],[NSNumber numberWithInteger:UITableViewRowAnimationRight], nil];
        [self performTableViewAnimationForIndexPath:indexPath
                              withAnimationSequence:sequenceArray];
    }
    editButton.hidden = NO;
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveOperation*)operation
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:SKYDRIVE];
    [self stopAnimatingCellAtIndexPath:indexPath];
}



@end
