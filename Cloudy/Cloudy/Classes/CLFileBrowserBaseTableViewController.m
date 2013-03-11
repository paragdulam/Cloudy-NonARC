//
//  CLFileBrowserTableViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLFileBrowserBaseTableViewController.h"
#import "CLFileBrowserTableViewController.h"
#import "CLImageGalleryViewController.h"
#import "CLFileDetailViewController.h"
#import "CLUploadsTableViewController.h"
#import "CLMediaPlayerViewController.h"
#import "CLWebMediaPlayerViewController.h"


@interface CLFileBrowserBaseTableViewController ()
{
    
    UITextField *inputTextField;
    UIButton *doneButton;
    UIButton *cancelButton;
    
    NSArray *createFoldertoolBarItems;
    DDPopoverBackgroundView *popOverView;
    
    NSMutableDictionary *currentFileData;
}

-(NSArray *) getCachedTableDataArrayForViewType:(VIEW_TYPE) type;
-(NSDictionary *) readCachedFileStructure;
-(void) createFolderToolbarItems;
-(void) createToolbarItems;
-(void) createPopOverViewForUploads;

@property (nonatomic,retain) NSMutableDictionary *currentFileData;

@end

@implementation CLFileBrowserBaseTableViewController
@synthesize viewType;
@synthesize path;
@synthesize currentFileData;

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

    fileSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.f)];
    [fileSearchBar setDelegate:self];
    fileSearchBar.tintColor = NAVBAR_COLOR;
    
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:fileSearchBar contentsController:self];
    [fileSearchBar release];

    [searchController setSearchResultsDataSource:self];
    [searchController setDelegate:self];
    
    
    CGRect tableFrame = dataTableView.frame;
    tableFrame.size.height -= TOOLBAR_HEIGHT;
    dataTableView.frame = tableFrame;
    dataTableView.allowsMultipleSelectionDuringEditing = YES;
    
    [self createToolbarItems];
    [self createFolderToolbarItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

  
    fileOperationsToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (TOOLBAR_HEIGHT * 2), self.view.frame.size.width, TOOLBAR_HEIGHT)];
    fileOperationsToolbar.barStyle = UIBarStyleDefault;
    fileOperationsToolbar.tintColor = NAVBAR_COLOR;
    [self.view addSubview:fileOperationsToolbar];
    [fileOperationsToolbar release];
    
    barItem = [[CLBrowserBarItem alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    barItem.delegate = self;
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:barItem];
    [barItem release];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    [rightBarButton release];
    
    liveOperations = [[NSMutableArray alloc] init];
    
    [self loadFilesForPath:path WithInViewType:viewType];
}




-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([path length]) {
        [self readCacheUpdateView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    [currentFileData release];
    currentFileData = nil;
    
    [searchController release];
    searchController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];

    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];

    
    for (LiveOperation *operation in liveOperations) {
        [operation cancel];
    }
    
    [createFoldertoolBarItems release];
    createFoldertoolBarItems = nil;
    
    [toolBarItems release];
    toolBarItems = nil;
    
    [path release];
    path = nil;
    
    [liveOperations release];
    liveOperations = nil;
    
    [super dealloc];
}



#pragma mark - UISearchBarDelegate

#pragma mark - UISearchDisplayDelegate



#pragma mark - IBActions



-(void) createFolderButtonClicked:(UIButton *) btn
{
    btn.selected = !btn.selected;
    [fileOperationsToolbar setItems:createFoldertoolBarItems animated:YES];
    [inputTextField becomeFirstResponder];
}

-(void) doneButtonClicked:(UIButton *) btn
{
    if ([inputTextField.text length]) {
        switch (viewType) {
            case DROPBOX:
            {
                NSString *pathStr = [NSString stringWithFormat:@"%@/%@",path,inputTextField.text];
                [self.restClient createFolder:pathStr];
            }
                break;
            case SKYDRIVE:
            {
                NSDictionary *folder = [NSDictionary dictionaryWithObjectsAndKeys:inputTextField.text,@"name", nil];
                LiveOperation *createFolderOperation = [self.appDelegate.liveClient postWithPath:path dictBody:folder delegate:self userState:[folder objectForKey:@"name"]];
                [liveOperations addObject:createFolderOperation];
            }
                break;
            case BOX:
            {
                [self.boxClient createFolderWithInFolderId:path
                                                  WithName:inputTextField.text];
            }
                break;
            default:
                break;
        }
        [self startAnimating];
        [inputTextField setText:@""];
        [inputTextField resignFirstResponder];
        currentFileOperation = CREATE;
    }
}

-(void) closeButtonClicked:(UIButton *) btn
{
    [inputTextField resignFirstResponder];
}


#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

//- (BOOL)textFieldShouldClear:(UITextField *)textField
//{
//
//}
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard Notifications

-(void) keyboardWillShow:(NSNotification *) notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    float keyBoardHeight = keyboardFrameBeginRect.size.height;
    if (createFolderButton.selected) {
        CGRect fileOperationsFrame = fileOperationsToolbar.frame;
        fileOperationsFrame.origin.y = self.view.frame.size.height - keyBoardHeight - TOOLBAR_HEIGHT;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        
        [fileOperationsToolbar setFrame:fileOperationsFrame];
        
        [UIView commitAnimations];
        dataTableView.userInteractionEnabled = NO;
    }
}


-(void) keyboardWillHide:(NSNotification *) notification
{
    CGRect fileOperationsFrame = fileOperationsToolbar.frame;
    fileOperationsFrame.origin.y = self.view.frame.size.height - TOOLBAR_HEIGHT;
    if (createFolderButton.selected) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        
        [fileOperationsToolbar setFrame:fileOperationsFrame];
        
        [UIView commitAnimations];
    }
    createFolderButton.selected = NO;
}

-(void) keyboardDidHide:(NSNotification *) notification
{
    [fileOperationsToolbar setItems:toolBarItems animated:YES];
    dataTableView.userInteractionEnabled = YES;
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
    [cell setData:[tableDataArray objectAtIndex:indexPath.row]];
//    [cell setData:[tableDataArray objectAtIndex:indexPath.row]
//      ForViewType:viewType];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!dataTableView.editing) {
        NSDictionary *selectedFile = [[currentFileData objectForKey:FILE_CONTENTS] objectAtIndex:indexPath.row];
        switch ([[selectedFile objectForKey:FILE_TYPE] intValue]) {
            case 0:
            {
                //
            }
                break;
            case 1:
            {
                //
                NSString *pathStr = nil;
                switch (viewType) {
                    case DROPBOX:
                        pathStr = [selectedFile objectForKey:FILE_PATH];
                        break;
                    case SKYDRIVE:
                        pathStr = [selectedFile objectForKey:FILE_ID];
                        break;
                    default:
                        break;
                }
                CLFileBrowserTableViewController *browserTableViewController = [[CLFileBrowserTableViewController alloc] initWithTableViewStyle:UITableViewStylePlain WherePath:pathStr WithinViewType:viewType];
                [self.navigationController pushViewController:browserTableViewController animated:YES];
                [browserTableViewController release];
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


#pragma mark - BoxClientDelegate

#pragma mark - Create Folder Methods

-(void) boxClient:(BoxClient *)client createdFolder:(NSDictionary *) folder
{
    NSDictionary *folderDictionary = [CLCacheManager processDataDictionary:folder WithinViewType:BOX];
    [CLCacheManager insertFile:folderDictionary
        whereTraversingPointer:nil
               inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                   ForViewType:viewType];
    
    
    //Updating UI
    [self stopAnimating];
    
    [tableDataArray insertObject:folderDictionary atIndex:0];
    [CLCacheManager arrangeFilesAndFolders:tableDataArray
                               ForViewType:viewType];
    
    
    [dataTableView beginUpdates];
    [dataTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[tableDataArray indexOfObject:folderDictionary] inSection:0]]
                         withRowAnimation:UITableViewRowAnimationBottom];
    [dataTableView endUpdates];
    //Updating UI

}

-(void) boxClient:(BoxClient *)client createFolderDidFailWithError:(NSError *) error
{
    [AppDelegate showError:error alertOnView:self.view];
}


#pragma mark - Thumbnail Methods
-(void) boxClient:(BoxClient *)client loadedData:(NSData *) data withUserData:(id) uData
{
    NSMutableDictionary *mData = (NSMutableDictionary *)uData;
    int index = [self getIndexOfObjectForKey:[CLCacheManager pathFiedForViewType:viewType]
                                   withValue:[mData objectForKey:@"id"]];
    [mData setObject:data
              forKey:THUMBNAIL_DATA];
    [CLCacheManager updateFile:mData
        whereTraversingPointer:nil
               inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                   ForViewType:viewType];
    if (index < [tableDataArray count]) {
        [tableDataArray replaceObjectAtIndex:index withObject:mData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                    inSection:0];
        
        [dataTableView beginUpdates];
        [dataTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
        [dataTableView endUpdates];
    }
}

-(void) boxClient:(BoxClient *)client loadDataFailedWithError:(NSError *) error withUserData:(id) uData
{
    [AppDelegate showError:error alertOnView:self.view];
}


#pragma mark - Metadata Methods

-(void) boxClient:(BoxClient *)client loadedMetadata:(NSDictionary *) metaData
{
    [self stopAnimating];
    NSDictionary *folderData = [CLCacheManager processDataDictionary:metaData
                                                      WithinViewType:BOX];
    [CLCacheManager updateFile:folderData
        whereTraversingPointer:nil
               inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                   ForViewType:viewType];
    
    [self updateModel:[folderData objectForKey:@"contents"]];
    [self updateView];

    for (NSDictionary *data in tableDataArray) {
        NSString *urlString = [data objectForKey:@"thumbnail"];
        if (urlString) {
            [self.boxClient loadDataFromURLString:urlString
                                      forUserData:data];
        }
    }
}

-(void) boxClient:(BoxClient *)client loadMetadataDidFailWithError:(NSError *) error
{
    [self stopAnimating];
    [AppDelegate showError:error alertOnView:self.view];
}

#pragma mark - LiveOperationDelegate

- (void) liveOperationSucceeded:(LiveOperation *)operation
{
    [liveOperations removeObject:operation];
    
    if ([operation.userState isKindOfClass:[NSString class]]) {
        if ([operation.userState isEqualToString:path]) {
            NSDictionary *compatibleMetaData = [sharedManager processDictionary:operation.result ForDataType:DATA_METADATA AndViewType:SKYDRIVE];
            if (![[compatibleMetaData objectForKey:FILE_LAST_UPDATED_TIME] isEqualToString:[currentFileData objectForKey:FILE_LAST_UPDATED_TIME]] || ![[currentFileData objectForKey:FILE_CONTENTS] count]) {
                NSString *pathStr = [NSString stringWithFormat:@"%@/files",operation.userState];
                [self.appDelegate.liveClient getWithPath:pathStr
                                                delegate:self
                                               userState:compatibleMetaData];
            } else {
                [self stopAnimating];
            }
        }
    } else {
        [self stopAnimating];
        NSMutableDictionary *finalMetaData = [NSMutableDictionary dictionaryWithDictionary:operation.userState];
        
        NSDictionary *compatibleMetaData = [sharedManager processDictionary:operation.result ForDataType:DATA_METADATA AndViewType:SKYDRIVE];
        [finalMetaData addEntriesFromDictionary:compatibleMetaData];
        self.currentFileData = finalMetaData;
        [self writeCacheUpdateView];
    }
}


-(void) liveOperationFailed:(NSError *)error operation:(LiveDownloadOperation *)operation
{
   
}


/*
- (void) liveOperationSucceeded:(LiveOperation *)operation
{
    [liveOperations removeObject:operation];
    [self performFileOperation:operation];
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveOperation*)operation
{
    [liveOperations removeObject:operation];
    [self stopAnimating];
    [AppDelegate showError:error alertOnView:self.view];
}
*/


#pragma mark - DBRestClientDelegate

#pragma mark - Thumbnail Methods


-(void) restClient:(DBRestClient *)client
   loadedThumbnail:(NSString *)destPath
          metadata:(DBMetadata *)metadata
{
    NSMutableDictionary *mData = [NSMutableDictionary dictionaryWithDictionary:[CLDictionaryConvertor dictionaryFromMetadata:metadata]];
    int index = [self getIndexOfObjectForKey:[CLCacheManager pathFiedForViewType:viewType]
                                   withValue:[mData objectForKey:@"path"]];
    UIImage *image = [UIImage imageWithContentsOfFile:destPath];
//    NSData *imageData = UIImagePNGRepresentation(image);
    NSData *imageData = UIImageJPEGRepresentation(image, 1);

    [mData setObject:imageData
              forKey:THUMBNAIL_DATA];
    [CLCacheManager deleteFileAtPath:destPath];
    
    [CLCacheManager updateFile:mData
        whereTraversingPointer:nil
               inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                   ForViewType:viewType];
    if (index < [tableDataArray count]) {
        [tableDataArray replaceObjectAtIndex:index withObject:mData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                    inSection:0];
        
        [dataTableView beginUpdates];
        [dataTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
        [dataTableView endUpdates];
    }
    
}


-(void) restClient:(DBRestClient *)client loadThumbnailFailedWithError:(NSError *)error
{
    
}

#pragma mark - Create Folder Methods

-(void) restClient:(DBRestClient *)client createdFolder:(DBMetadata *)folder
{
    NSDictionary *folderDictionary = [CLDictionaryConvertor dictionaryFromMetadata:folder];
    [CLCacheManager insertFile:folderDictionary
        whereTraversingPointer:nil
               inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                   ForViewType:viewType];
    
    
    //Updating UI
    [self stopAnimating];

    [tableDataArray insertObject:folderDictionary atIndex:0];
    [CLCacheManager arrangeFilesAndFolders:tableDataArray
                               ForViewType:viewType];
    

    [dataTableView beginUpdates];
    [dataTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[tableDataArray indexOfObject:folderDictionary] inSection:0]]
                         withRowAnimation:UITableViewRowAnimationBottom];
    [dataTableView endUpdates];
    //Updating UI
}

-(void) restClient:(DBRestClient *)client createFolderFailedWithError:(NSError *)error
{
    [inputTextField resignFirstResponder];
    [self stopAnimating];
    [AppDelegate showError:error alertOnView:self.view];
}


#pragma mark - Metadata Methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
    [self stopAnimating];
    NSDictionary *metadataDictionary = [metadata original];
    NSDictionary *compatibleMetaData = [sharedManager processDictionary:metadataDictionary ForDataType:DATA_METADATA AndViewType:DROPBOX];
    [currentFileData addEntriesFromDictionary:compatibleMetaData];
    [self writeCacheUpdateView];
}

-(void) restClient:(DBRestClient *)client metadataUnchangedAtPath:(NSString *)path
{
    [self stopAnimating];
}


-(void) restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    
}

#pragma mark - Helper Methods


-(void) createToolbarItems
{
    UIImage *baseImage = [UIImage imageNamed:@"button_background_base.png"];
    UIImage *buttonImage = [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 25)];
    
    createFolderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createFolderButton.frame = CGRectMake(0, 0, 100, 30);
    createFolderButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [createFolderButton setTitle:@"Create Folder"
                        forState:UIControlStateNormal];
    [createFolderButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
    [createFolderButton setBackgroundImage:buttonImage
                                  forState:UIControlStateNormal];
    [createFolderButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
    [createFolderButton addTarget:self
                           action:@selector(createFolderButtonClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
    toolBarItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *createFolderBarButton = [[UIBarButtonItem alloc] initWithCustomView:createFolderButton];

    [toolBarItems addObject:createFolderBarButton];
    [createFolderBarButton release];

    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 2.f;
    [toolBarItems addObject:fixedSpace];
    [fixedSpace release];
    
    UIBarButtonItem *uploadProgressBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.appDelegate.uploadProgressButton];
    [toolBarItems addObject:uploadProgressBarButton];
    [uploadProgressBarButton release];
}

-(void) createFolderToolbarItems
{
    inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 30.f)];
    inputTextField.placeholder = @"Enter a Folder Name";
    inputTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    inputTextField.backgroundColor = [UIColor whiteColor];
    inputTextField.clipsToBounds = YES;
    inputTextField.layer.cornerRadius = 15.f;
    inputTextField.borderStyle = UITextBorderStyleNone;
    inputTextField.delegate = self;
    
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self
                   action:@selector(doneButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    UIImage *checkImage = [UIImage imageNamed:@"green_checkButton.png"];
    CGRect doneButtonFrame = CGRectMake(0,
                                        0,
                                        checkImage.size.width,
                                        checkImage.size.height);
    [doneButton setFrame:doneButtonFrame];
    [doneButton setImage:checkImage
                forState:UIControlStateNormal];
    //    [self.view addSubview:doneButton];
    [inputTextField setRightViewMode:UITextFieldViewModeAlways];
    [inputTextField setRightView:doneButton];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self
                     action:@selector(closeButtonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
    UIImage *cancelImage = [UIImage imageNamed:@"closeButton.png"];
    CGRect cancelButtonFrame = CGRectMake(0,
                                          0,
                                          cancelImage.size.width,
                                          cancelImage.size.height);
    [cancelButton setFrame:cancelButtonFrame];
    [cancelButton setImage:cancelImage
                  forState:UIControlStateNormal];
    [inputTextField setLeftViewMode:UITextFieldViewModeAlways];
    [inputTextField setLeftView:cancelButton];
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem * flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    UIBarButtonItem *textFieldItem = [[UIBarButtonItem alloc] initWithCustomView:inputTextField];
    [inputTextField release];
    
    [items addObject:textFieldItem];
    [textFieldItem release];
    
    flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexiSpace];
    [flexiSpace release];
    
    createFoldertoolBarItems = [[NSArray alloc] initWithArray:items];
    [items release];
    
};



-(void) loadFilesForPath:(NSString *) pathString WithInViewType:(VIEW_TYPE) type
{
    [dataTableView setContentOffset:CGPointMake(0, fileSearchBar.frame.size.height)];
    dataTableView.tableHeaderView = fileSearchBar;
    dataTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
//    self.path = [pathString hasPrefix:@"folder."] ? pathString : [NSString stringWithFormat:@"folder.%@",pathString];
    self.path = pathString;
    self.viewType = type;

    //read Cache code
    [self readCacheUpdateView];
    
    switch (viewType) {
        case DROPBOX:
        {
            [self.restClient loadMetadata:path
                                 withHash:[currentFileData objectForKey:FILE_HASH]]; //previous hash should be sent
        }
            break;
            
        case SKYDRIVE:
        {
            LiveOperation *metadataOperation = [self.appDelegate.liveClient getWithPath:path delegate:self userState:path];
            [liveOperations addObject:metadataOperation];
        }
            break;
        default:
            break;
    }
    

    [self startAnimating];
}


/*
-(void) loadFilesForPath:(NSString *) pathString WithInViewType:(VIEW_TYPE) type
{
    dataTableView.tableHeaderView = nil;
    dataTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
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
            currentFileOperation = METADATA;
        }
            break;
        case SKYDRIVE:
        {
            NSString *aPathString = [NSString stringWithFormat:@"%@/files",path];
            LiveOperation *operation = [self.appDelegate.liveClient
                                        getWithPath:aPathString
                                           delegate:self
                                          userState:aPathString];
            [liveOperations addObject:operation];
            currentFileOperation = METADATA;
        }
            break;
        case BOX:
        {
            NSString *aPathString = [NSString stringWithFormat:@"%@",path];
            [self.boxClient loadMetadataForFolderId:aPathString];
            currentFileOperation = METADATA;
        }
            break;
        default:
            break;
    }
    [self startAnimating];
    //Web Request Ends

}
*/


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
            [self.appDelegate.menuController setLeftButtonImage:[UIImage imageNamed:@"SkyDriveIconBlack_32x32.png"]];
            break;
        case BOX:
            [self.appDelegate.menuController setLeftButtonImage:[UIImage imageNamed:@"box_cellImage.png"]];
            break;
        default:
            [self.appDelegate.menuController setLeftButtonImage:[UIImage imageNamed:@"nav_menu_icon.png"]];
            break;
    }
}


-(void) writeCacheUpdateView
{
    [sharedManager updateMetadata:currentFileData
                 inParentMetadata:[sharedManager rootDictionary:viewType]]; //updates cache
    [self readCacheUpdateView];
}


-(void) readCacheUpdateView
{
    NSDictionary *cachedMetadata = [sharedManager metadata:[sharedManager rootDictionary:viewType]
                                                    AtPath:path
                                                InViewType:viewType];
    self.currentFileData = [NSMutableDictionary dictionaryWithDictionary:cachedMetadata];
    NSString *titleText = [currentFileData objectForKey:FILE_NAME];
    if ([titleText length]) {
        [self.navigationItem setTitle:[titleText isEqualToString:ROOT_DROPBOX_PATH] ? DROPBOX_STRING : titleText];
    }
    [self updateModel:[currentFileData objectForKey:FILE_CONTENTS]];
    [self updateView];
}




-(void) startAnimating
{
    [barItem startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void) stopAnimating
{
    [barItem stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}




#pragma mark - Unused Methods

-(NSString *) readCachedHash
{
    return [[self readCachedFileStructure] objectForKey:@"hash"];
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
        case BOX:
            contents = [cachedFileStructure objectForKey:@"contents"];
            break;
        default:
            break;
    }
    return contents;
}


-(NSDictionary *) readCachedFileStructure
{
    return [CLCacheManager metaDataForPath:path
                    whereTraversingPointer:nil
                       WithinFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                                   ForView:viewType];
}


-(void) createPopOverViewForUploads
{
    popOverView = [[DDPopoverBackgroundView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    [self.view addSubview:popOverView];
    [popOverView setArrowDirection:UIPopoverArrowDirectionDown];
    [popOverView setArrowOffset:-70.f];
    [popOverView release];
    popOverView.center = CGPointMake(self.view.center.x,
                                     self.view.frame.size.height - (TOOLBAR_HEIGHT *2) - (popOverView.frame.size.height / 2));
    popOverView.hidden = YES;
    
}


-(int) getIndexOfObjectForKey:(NSString *) key
                    withValue:(NSString *) value
{
    __block NSInteger index = INFINITY;
    __block NSString *valueString = value;
    __block NSString *keyString = key;
    [tableDataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *objDict = (NSDictionary *)obj;
        if ([[objDict objectForKey:keyString] isEqualToString:valueString]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

-(CLFileBrowserCell *) cellAtIndexPath:(NSIndexPath *)indexPath
{
    return (CLFileBrowserCell *)[dataTableView cellForRowAtIndexPath:indexPath];
}

-(void) startAnimatingCellAtIndexPath:(NSIndexPath *) indexPath
{
    CLFileBrowserCell *cell = [self cellAtIndexPath:indexPath];
    [cell startAnimating];
}

-(void) stopAnimatingCellAtIndexPath:(NSIndexPath *) indexPath
{
    CLFileBrowserCell *cell = [self cellAtIndexPath:indexPath];
    [cell stopAnimating];
}




-(void) performFileOperation:(LiveOperation *) operation
{
    switch (currentFileOperation) {
        case METADATA:
        {
            [self stopAnimating];
            [CLCacheManager updateFile:operation.result
                whereTraversingPointer:nil
                       inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                           ForViewType:viewType];
            //    //Reading Cache is skipped only reading Table Contents Starts
            if (viewType == SKYDRIVE) { //cache is not referred
                //                NSArray *contents = [operation.result objectForKey:@"data"];
                NSArray *contents = [self getCachedTableDataArrayForViewType:SKYDRIVE];
                [self updateModel:contents];
                [self updateView];
                //Looking For images and then downloading thumnails Starts
                for (NSDictionary *data in contents) {
                    if ([[data objectForKey:@"type"] isEqualToString:@"photo"]) {
                        NSData *thumbData = [data objectForKey:THUMBNAIL_DATA];
                        if (!thumbData) {
                            NSArray *images = [data objectForKey:@"images"];
                            if ([images count]) {
                                NSDictionary *image = [images objectAtIndex:2];
                                LiveDownloadOperation *downloadOperation =                         [self.appDelegate.liveClient downloadFromPath:[image objectForKey:@"source"] delegate:self userState:[data objectForKey:@"name"]];
                                [liveOperations addObject:downloadOperation];
                                currentFileOperation = DOWNLOAD;
                                break;
                            }
                        }
                    }
                }
                //Looking For images and then downloading thumnails Ends
            }
            
            //    //Reading Cache is skipped only reading Table Contents Ends
            
        }
            break;
        case CREATE:
        {
            [self stopAnimating];
            [CLCacheManager insertFile:operation.result
                whereTraversingPointer:nil
                       inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                           ForViewType:viewType];
            //Updating UI
            
            [tableDataArray insertObject:operation.result atIndex:0];
            [CLCacheManager arrangeFilesAndFolders:tableDataArray
                                       ForViewType:viewType];
            
            
            [dataTableView beginUpdates];
            [dataTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[tableDataArray indexOfObject:operation.result] inSection:0]]
                                 withRowAnimation:UITableViewRowAnimationBottom];
            [dataTableView endUpdates];
            //Updating UI
            
        }
            break;
        case DOWNLOAD:
        {
            LiveDownloadOperation *downloadOperation = (LiveDownloadOperation *) operation;
            int index = [self getIndexOfObjectForKey:@"name"
                                           withValue:operation.userState];
            if (index < [tableDataArray count]) {
                NSDictionary *data = [tableDataArray objectAtIndex:index];
                NSMutableDictionary *updatedData = [NSMutableDictionary dictionaryWithDictionary:data];
                [updatedData setObject:downloadOperation.data
                                forKey:THUMBNAIL_DATA];
                
                
                [CLCacheManager updateFile:updatedData
                    whereTraversingPointer:nil
                           inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                               ForViewType:viewType];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                            inSection:0];
                [tableDataArray replaceObjectAtIndex:index withObject:updatedData];
                [dataTableView beginUpdates];
                [dataTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                     withRowAnimation:UITableViewRowAnimationAutomatic];
                [dataTableView endUpdates];
                
                //Looking For images and then downloading thumnails Starts
                for (NSDictionary *data in tableDataArray) {
                    if ([[data objectForKey:@"type"] isEqualToString:@"photo"]) {
                        NSData *thumbData = [data objectForKey:THUMBNAIL_DATA];
                        if (!thumbData) {
                            NSArray *images = [data objectForKey:@"images"];
                            if ([images count]) {
                                NSDictionary *image = [images objectAtIndex:2];
                                LiveDownloadOperation *downloadOperation =                         [self.appDelegate.liveClient downloadFromPath:[image objectForKey:@"source"] delegate:self userState:[data objectForKey:@"name"]];
                                [liveOperations addObject:downloadOperation];
                                currentFileOperation = DOWNLOAD;
                                break;
                            }
                        }
                    }
                }
                //Looking For images and then downloading thumnails Ends
            }
        }
            break;
        default:
            break;
            //currentFileOperation = INFINITY;
    }
}




@end
