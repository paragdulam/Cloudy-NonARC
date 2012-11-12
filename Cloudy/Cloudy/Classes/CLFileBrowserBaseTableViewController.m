//
//  CLFileBrowserTableViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLFileBrowserBaseTableViewController.h"
#import "CLFileBrowserCell.h"
#import "CLFileBrowserTableViewController.h"


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

-(void) updateModel:(NSArray *) model;
-(NSArray *) getCachedTableDataArrayForViewType:(VIEW_TYPE) type;
-(void) readCacheUpdateView;
-(NSDictionary *) readCachedFileStructure;


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
                    CLFileBrowserTableViewController *fileBrowserViewController = [[CLFileBrowserTableViewController alloc] initWithTableViewStyle:UITableViewStylePlain WherePath:[metadata objectForKey:@"path"] WithinViewType:DROPBOX];
                    [self.navigationController pushViewController:fileBrowserViewController animated:YES];
                    [fileBrowserViewController release];
                }
            }
                break;
            case SKYDRIVE:
            {
                NSDictionary *metadata = [tableDataArray objectAtIndex:indexPath.row];
                if ([[metadata objectForKey:@"type"] isEqualToString:@"album"] || [[metadata objectForKey:@"type"] isEqualToString:@"folder"]) {
                    CLFileBrowserTableViewController *fileBrowserViewController = [[CLFileBrowserTableViewController alloc] initWithTableViewStyle:UITableViewStylePlain WherePath:[NSString stringWithFormat:@"%@/files",[metadata objectForKey:@"id"]] WithinViewType:SKYDRIVE];
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
    [self stopAnimating];
    [CLCacheManager updateFolderStructure:operation.result
                                  ForView:SKYDRIVE];
    
    //Reading Cache is skipped only reading Table Contents Starts
    if (viewType == SKYDRIVE) { //cache is not referred
        NSArray *contents = [operation.result objectForKey:@"data"];
        [self updateModel:contents];
        [self updateView];
    }
    //Reading Cache is skipped only reading Table Contents Ends

}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveOperation*)operation
{
    [self stopAnimating];
}



#pragma mark - DBRestClientDelegate

#pragma mark - Metadata Methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
    [self stopAnimating];
    NSDictionary *metadataDictionary = [CLDictionaryConvertor dictionaryFromMetadata:metadata];
    [CLCacheManager updateFolderStructure:metadataDictionary
                                  ForView:DROPBOX];
    
    //Reading Cache is skipped only reading Table Contents Starts
    if (viewType == DROPBOX) { //cache is not referred
        NSArray *contents = [metadataDictionary objectForKey:@"contents"];
        [self updateModel:contents];
        [self updateView];
    }
    //Reading Cache is skipped only reading Table Contents Ends    
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
{
    [self stopAnimating];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
    [self stopAnimating];
}



#pragma mark - Helper Methods

-(void) loadFilesForPath:(NSString *) pathString WithInViewType:(VIEW_TYPE) type
{
    dataTableView.tableHeaderView = nil;
    self.path = pathString;
    self.viewType = type;

    //Read Cache Starts
    [self readCacheUpdateView];
    //Read Cache Ends

    //Web Request Starts
    switch (viewType) {
        case DROPBOX:
        {
            NSString *hash = [self readCachedHash];
            [self.restClient loadMetadata:path
                                 withHash:hash];
        }
            break;
        case SKYDRIVE:
        {
            [self.appDelegate.liveClient getWithPath:path
                                            delegate:self
                                           userState:path];
        }
            break;
        default:
            break;
    }
    [self startAnimating];
    //Web Request Ends

}


-(void) updateModel:(NSArray *) model
{
    [tableDataArray removeAllObjects];
    [tableDataArray addObjectsFromArray:model];
}

-(void) updateView
{
    [super updateView];
    switch (viewType) {
        case DROPBOX:
            [self.appDelegate.menuController setLeftButtonImage:[UIImage imageNamed:@"dropbox_cell_Image.png"]];
            break;
        case SKYDRIVE:
            [self.appDelegate.menuController setLeftButtonImage:[UIImage imageNamed:@"SkyDriveIconWhite_32x32.png"]];
            break;
        default:
            [self.appDelegate.menuController setLeftButtonImage:[UIImage imageNamed:@"nav_menu_icon.png"]];
            break;
    }
}


-(NSDictionary *) readCachedFileStructure
{
    return [CLCacheManager metaDataDictionaryForPath:path ForView:viewType];
}

-(NSArray *) getCachedTableDataArrayForViewType:(VIEW_TYPE) type
{
    NSDictionary *cachedFileStructure = [self readCachedFileStructure];
    NSArray *contents = nil;
    switch (type) {
        case DROPBOX:
            contents = [cachedFileStructure objectForKey:@"contents"];
            break;
        case SKYDRIVE:
            contents = [cachedFileStructure objectForKey:@"data"];
            break;
        default:
            break;
    }
    return contents;
}


-(void) readCacheUpdateView
{
    [self updateModel:[self getCachedTableDataArrayForViewType:viewType]];
    [self updateView];
}


-(NSString *) readCachedHash
{
    return [[self readCachedFileStructure] objectForKey:@"hash"];
}

-(void) startAnimating
{
    
}

-(void) stopAnimating
{
    
}



@end
