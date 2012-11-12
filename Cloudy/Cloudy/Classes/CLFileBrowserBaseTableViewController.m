//
//  CLFileBrowserTableViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLFileBrowserBaseTableViewController.h"
#import "CLFileBrowserCell.h"


@interface CLFileBrowserBaseTableViewController ()
{
    
//    UIButton *uploadButton;
//    
//    UIButton *moveButton;
//    UIButton *copyButton;
//    UIButton *shareButton;
//    UIButton *deleteButton;
//    
//    
//    NSArray *toolBarItems;
//    NSArray *editingToolBarItems;
//    CLBrowserBarItem *barItem;
}


@end

@implementation CLFileBrowserBaseTableViewController
@synthesize viewType;
@synthesize path;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithTableViewStyle:(UITableViewStyle)style WherePath:(NSString *) pathString WithinViewType:(VIEW_TYPE) type
{
    if (self = [super initWithTableViewStyle:style]) {
        self.path = pathString;
        self.viewType = type;
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGRect tableFrame = dataTableView.frame;
    tableFrame.size.height -= TOOLBAR_HEIGHT;
    dataTableView.frame = tableFrame;
    dataTableView.backgroundColor = [UIColor clearColor];
    dataTableView.allowsMultipleSelectionDuringEditing = YES;
    dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
    fileOperationsToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (TOOLBAR_HEIGHT * 2), self.view.frame.size.width, TOOLBAR_HEIGHT)];
    fileOperationsToolbar.barStyle = UIBarStyleBlackOpaque;
    [self.view addSubview:fileOperationsToolbar];
    [fileOperationsToolbar release];
    
    /*
    UIImage *baseImage = [UIImage imageNamed:@"button_background_base.png"];
    UIImage *buttonImage = [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];

    barItem = [[CLBrowserBarItem alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    barItem.delegate = self;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barItem];
    [barItem release];
    [self.navigationItem setRightBarButtonItem:barButtonItem];
    [barButtonItem release];
    
    
    uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadButton.frame = CGRectMake(0, 0, 50, 30);
    [uploadButton setTitle:@"Upload"
                  forState:UIControlStateNormal];
    [uploadButton setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
    [uploadButton setBackgroundImage:buttonImage
                            forState:UIControlStateNormal];
    [uploadButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
    [uploadButton addTarget:self
                     action:@selector(uploadButtonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    UIBarButtonItem *uploadBarButton = [[UIBarButtonItem alloc] initWithCustomView:uploadButton];
    [items addObject:uploadBarButton];
    [uploadBarButton release];

    toolBarItems = [[NSArray alloc] initWithArray:items];
    [items release];
    

    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(0, 0, 50, 30);
    [deleteButton setTitle:@"Delete"
                  forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
    [deleteButton setBackgroundImage:buttonImage
                            forState:UIControlStateNormal];
    [deleteButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
    deleteButton.exclusiveTouch = YES;
    [deleteButton addTarget:self
                     action:@selector(deleteButtonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
    
    
    moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moveButton.frame = CGRectMake(0, 0, 50, 30);
    [moveButton setTitle:@"Move"
                forState:UIControlStateNormal];
    [moveButton setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    [moveButton setBackgroundImage:buttonImage
                          forState:UIControlStateNormal];
    [moveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
    moveButton.exclusiveTouch = YES;
    [moveButton addTarget:self
                   action:@selector(moveButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    
    
    copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    copyButton.frame = CGRectMake(0, 0, 50, 30);
    [copyButton setTitle:@"Copy"
                forState:UIControlStateNormal];
    [copyButton setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    [copyButton setBackgroundImage:buttonImage
                          forState:UIControlStateNormal];
    [copyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
    copyButton.exclusiveTouch = YES;
    [copyButton addTarget:self
                   action:@selector(copyButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    
    
    shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(0, 0, 50, 30);
    [shareButton setTitle:@"Share"
                 forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor whiteColor]
                      forState:UIControlStateNormal];
    shareButton.exclusiveTouch = YES;
    [shareButton setBackgroundImage:buttonImage
                           forState:UIControlStateNormal];
    [shareButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
    [shareButton addTarget:self
                    action:@selector(shareButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    
    items = [[NSMutableArray alloc] init];
    flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    UIBarButtonItem *deleteBarButton = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    [items addObject:deleteBarButton];
    [deleteBarButton release];
    
    flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    UIBarButtonItem *moveBarButton = [[UIBarButtonItem alloc] initWithCustomView:moveButton];
    [items addObject:moveBarButton];
    [moveBarButton release];

    flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    
    UIBarButtonItem *copyBarButton = [[UIBarButtonItem alloc] initWithCustomView:copyButton];
    [items addObject:copyBarButton];
    [copyBarButton release];

    flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];

    UIBarButtonItem *shareBarButton = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    [items addObject:shareBarButton];
    [shareBarButton release];
    
    flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];

    editingToolBarItems = [[NSArray alloc] initWithArray:items];
    [items release];
    */
    [self loadFilesForPath:path WithInViewType:viewType];
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
    [path release];
    path = nil;
    [super dealloc];
}


#pragma mark - UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLFileBrowserCell *cell = (CLFileBrowserCell *)[tableView dequeueReusableCellWithIdentifier:@"CLFileBrowserCell"];
    if (!cell) {
        cell = [[[CLFileBrowserCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:@"CLFileBrowserCell"] autorelease];
    }
    NSString *titleText = [[tableDataArray objectAtIndex:indexPath.row] objectForKey:@"filename"];
    if (!titleText) {
        titleText = [[tableDataArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    }
    [cell.textLabel setText:titleText];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!dataTableView.editing) {
        switch (viewType) {
            case DROPBOX:
            {
                NSDictionary *metadata = [tableDataArray objectAtIndex:indexPath.row];
                if ([[metadata objectForKey:@"isDirectory"] boolValue]) {
                    CLFileBrowserBaseTableViewController *fileBrowserViewController = [[CLFileBrowserBaseTableViewController alloc] initWithTableViewStyle:UITableViewStylePlain WherePath:[metadata objectForKey:@"path"] WithinViewType:DROPBOX];
                    [self.navigationController pushViewController:fileBrowserViewController animated:YES];
                    [fileBrowserViewController release];
                }
            }
                break;
            case SKYDRIVE:
            {
                NSDictionary *metadata = [tableDataArray objectAtIndex:indexPath.row];
                if ([[metadata objectForKey:@"type"] isEqualToString:@"album"] || [[metadata objectForKey:@"type"] isEqualToString:@"folder"]) {
                    CLFileBrowserBaseTableViewController *fileBrowserViewController = [[CLFileBrowserBaseTableViewController alloc] initWithTableViewStyle:UITableViewStylePlain WherePath:[NSString stringWithFormat:@"%@/files",[metadata objectForKey:@"id"]] WithinViewType:SKYDRIVE];
                    [self.navigationController pushViewController:fileBrowserViewController animated:YES];
                    [fileBrowserViewController release];
                }
            }
                break;
            default:
                break;
        }
    }
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = CELL_BACKGROUND_COLOR;
}


#pragma mark - LiveOperationDelegate

- (void) liveOperationSucceeded:(LiveOperation *)operation
{
    [CLCacheManager updateFolderStructure:operation.result
                                  ForView:SKYDRIVE];
    
    //Reading Cache is skipped only reading Table Contents Starts
    if (viewType == SKYDRIVE) {
        NSArray *contents = [operation.result objectForKey:@"data"];
        {
            [tableDataArray removeAllObjects];
            [tableDataArray addObjectsFromArray:contents];
            [dataTableView reloadData];
        }
    }
    //Reading Cache is skipped only reading Table Contents Ends

}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveOperation*)operation
{
    
}



#pragma mark - DBRestClientDelegate

#pragma mark - Metadata Methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
    NSDictionary *metadataDictionary = [CLDictionaryConvertor dictionaryFromMetadata:metadata];
    [CLCacheManager updateFolderStructure:metadataDictionary
                                  ForView:DROPBOX];
    
    //Reading Cache is skipped only reading Table Contents Starts
    if (viewType == DROPBOX) {
        NSArray *contents = [metadataDictionary objectForKey:@"contents"];
        [tableDataArray removeAllObjects];
        [tableDataArray addObjectsFromArray:contents];
        [dataTableView reloadData];
    }
    //Reading Cache is skipped only reading Table Contents Ends    
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
{
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
}



#pragma mark - Helper Methods

-(void) loadFilesForPath:(NSString *) pathString WithInViewType:(VIEW_TYPE) type
{
    if (!pathString) {
        if (![[CLCacheManager accounts] count]) {
            UILabel *addAccountLabel = [[UILabel alloc] init];
            addAccountLabel.text = @"Tap here to add an account";
            [addAccountLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
            addAccountLabel.backgroundColor = [UIColor clearColor];
            addAccountLabel.textColor = [UIColor whiteColor];
            [addAccountLabel sizeToFit];
            
            UIImageView *headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1351499593_arrow_up.png"]];
            [headerView addSubview:addAccountLabel];
            addAccountLabel.center = CGPointMake(roundf(headerView.center.x + 150.f), roundf(headerView.center.y));
            headerView.frame = CGRectMake(0, 0, 320.f, 64.f);
            headerView.contentMode = UIViewContentModeLeft;
            dataTableView.tableHeaderView = headerView;
        }
        [tableDataArray removeAllObjects];
        [dataTableView reloadData];
        [self.appDelegate.menuController setLeftButtonImage:[UIImage imageNamed:@"nav_menu_icon.png"]];
        return;
    }
    dataTableView.tableHeaderView = nil;
    self.path = pathString;
    self.viewType = type;
    
    switch (viewType) {
        case DROPBOX:
        {
            //Read Cache Starts
            NSDictionary *cachedAccount = [CLCacheManager metaDataDictionaryForPath:path ForView:DROPBOX];
//            [self.navigationItem setTitle:[cachedAccount objectForKey:@"filename"]];
            NSArray *contents = [cachedAccount objectForKey:@"contents"];
            [tableDataArray removeAllObjects];
            [tableDataArray addObjectsFromArray:contents];
            [dataTableView reloadData];
            [self.appDelegate.menuController setLeftButtonImage:[UIImage imageNamed:@"dropbox_cell_Image.png"]];

            //Read Cache Ends

            //Web Request Starts
            NSString *hash = [cachedAccount objectForKey:@"hash"];
            [self.restClient loadMetadata:path
                                 withHash:hash];
            //Web Request Ends
        }
            break;
        case SKYDRIVE:
        {
            //Read Cache Starts
            NSDictionary *cachedAccount = [CLCacheManager metaDataDictionaryForPath:path ForView:SKYDRIVE];
//            [self.navigationItem setTitle:[cachedAccount objectForKey:@"name"]];
            NSArray *contents = [cachedAccount objectForKey:@"data"];
            [tableDataArray removeAllObjects];
            [tableDataArray addObjectsFromArray:contents];
            [dataTableView reloadData];
            [self.appDelegate.menuController setLeftButtonImage:[UIImage imageNamed:@"SkyDriveIconWhite_32x32.png"]];

            //Read Cache Ends
            
            //Web Request Starts
            [self.appDelegate.liveClient getWithPath:path
                                            delegate:self
                                           userState:path];
            //Web Request Ends

        }
            break;
        default:
            break;
    }
}


@end
