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


@interface CLFileBrowserBaseTableViewController ()
{
    
    UITextField *inputTextField;
    UIButton *doneButton;
    UIButton *cancelButton;
    
    NSArray *createFoldertoolBarItems;
    DDPopoverBackgroundView *popOverView;
}

-(NSArray *) getCachedTableDataArrayForViewType:(VIEW_TYPE) type;
-(NSDictionary *) readCachedFileStructure;
-(void) createFolderToolbarItems;
-(void) createToolbarItems;
-(void) createPopOverViewForUploads;


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
//    dataTableView.backgroundColor = [UIColor clearColor];
    dataTableView.allowsMultipleSelectionDuringEditing = YES;
//    dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
//    fileOperationsToolbar.tintColor = NAVBAR_COLOR;
    [self.view addSubview:fileOperationsToolbar];
    [fileOperationsToolbar release];
    
    barItem = [[CLBrowserBarItem alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    barItem.delegate = self;
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:barItem];
    [barItem release];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    [rightBarButton release];
    
//    [self createPopOverViewForUploads];
    
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
    for (LiveOperation *operation in liveOperations) {
        [operation cancel];
    }
    
    [liveOperations release];
    liveOperations = nil;
    
    [createFoldertoolBarItems release];
    createFoldertoolBarItems = nil;
    
    [toolBarItems release];
    toolBarItems = nil;
    
    [path release];
    path = nil;
    [super dealloc];
}


#pragma mark - IBActions


-(void) uploadProgressButtonClicked:(UIButton *) btn
{
    CLUploadsTableViewController *uploadsTableViewController = [[CLUploadsTableViewController alloc] initWithTableViewStyle:UITableViewStylePlain];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:uploadsTableViewController];
    [uploadsTableViewController release];
    [self presentModalViewController:navController
                            animated:YES];
    [navController release];
}

-(void) createFolderButtonClicked:(UIButton *) btn
{
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
    
    CGRect fileOperationsFrame = fileOperationsToolbar.frame;
    fileOperationsFrame.origin.y = self.view.frame.size.height - keyBoardHeight - TOOLBAR_HEIGHT;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    [fileOperationsToolbar setFrame:fileOperationsFrame];
    
    [UIView commitAnimations];
    dataTableView.userInteractionEnabled = NO;
}


-(void) keyboardWillHide:(NSNotification *) notification
{
    CGRect fileOperationsFrame = fileOperationsToolbar.frame;
    fileOperationsFrame.origin.y = self.view.frame.size.height - TOOLBAR_HEIGHT;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    [fileOperationsToolbar setFrame:fileOperationsFrame];
    
    [UIView commitAnimations];
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
//        [cell setBackgroundImage:[UIImage imageNamed:@"cell_background.png"]];
    }
    [cell setData:[tableDataArray objectAtIndex:indexPath.row]
      ForViewType:viewType];
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
                    fileBrowserViewController.title = [metadata objectForKey:@"filename"];
                    [fileBrowserViewController release];
                    fileBrowserViewController = nil;
                } else if ([[metadata objectForKey:@"thumbnailExists"] boolValue]) {
                    
                    __block NSMutableArray *images = [[NSMutableArray alloc] init];
                    [tableDataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSDictionary *objDict = (NSDictionary *)obj;
                        if ([[objDict objectForKey:@"thumbnailExists"] boolValue]) {
                            [images addObject:objDict];
                        }
                    }];
                    
                    CLImageGalleryViewController *imageGalleryViewController = [[CLImageGalleryViewController alloc] initWithViewType:viewType ImagesArray:images CurrentImage:metadata];
                    [images release];
                    [self.navigationController pushViewController:imageGalleryViewController animated:YES];
                    [imageGalleryViewController release];
                } else {
                    CLFileDetailViewController *fileDetailViewController = [[CLFileDetailViewController alloc] initWithFile:metadata WithinViewType:DROPBOX];
                    [self.navigationController pushViewController:fileDetailViewController animated:YES];
                    [fileDetailViewController release];
                }
            }
                break;
            case SKYDRIVE:
            {
                NSDictionary *metadata = [tableDataArray objectAtIndex:indexPath.row];
                if ([[metadata objectForKey:@"type"] isEqualToString:@"album"] || [[metadata objectForKey:@"type"] isEqualToString:@"folder"]) {
                    CLFileBrowserTableViewController *fileBrowserViewController = [[CLFileBrowserTableViewController alloc] initWithTableViewStyle:UITableViewStylePlain WherePath:[metadata objectForKey:@"id"] WithinViewType:SKYDRIVE];
                    [self.navigationController pushViewController:fileBrowserViewController animated:YES];
                    fileBrowserViewController.title = [metadata objectForKey:@"name"];
                    [fileBrowserViewController release];
                    fileBrowserViewController = nil;
                } else if ([[metadata objectForKey:@"type"] isEqualToString:@"photo"]) {
                    
                    __block NSMutableArray *images = [[NSMutableArray alloc] init];
                    [tableDataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSDictionary *objDict = (NSDictionary *)obj;
                        if ([[objDict objectForKey:@"type"] isEqualToString:@"photo"]) {
                            [images addObject:objDict];
                        }
                    }];
                    CLImageGalleryViewController *imageGalleryViewController = [[CLImageGalleryViewController alloc] initWithViewType:viewType ImagesArray:images CurrentImage:metadata];
                    [images release];
                    [self.navigationController pushViewController:imageGalleryViewController animated:YES];
                    [imageGalleryViewController release];
                } else {
                    CLFileDetailViewController *fileDetailViewController = [[CLFileDetailViewController alloc] initWithFile:metadata WithinViewType:SKYDRIVE];
                    [self.navigationController pushViewController:fileDetailViewController animated:YES];
                    [fileDetailViewController release];
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
    NSData *imageData = UIImagePNGRepresentation(image);
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
    NSDictionary *metadataDictionary = [CLDictionaryConvertor dictionaryFromMetadata:metadata];
    [CLCacheManager updateFile:metadataDictionary
        whereTraversingPointer:nil
               inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                   ForViewType:viewType];
    
    //Reading Cache is skipped only reading Table Contents Starts
    if (viewType == DROPBOX) { //cache is not referred
        NSArray *contents = [metadataDictionary objectForKey:@"contents"];
        [self updateModel:contents];
        [self updateView];
        
        //Look for images in current directory and load thumbnails for them
        NSString *dropboxCachePath = [CLCacheManager getDropboxCacheFolderPath];
        for (NSDictionary *data in contents) {
            if ([[data objectForKey:@"thumbnailExists"] boolValue]) {
                [self.restClient loadThumbnail:[data objectForKey:@"path"]
                                        ofSize:@"small"
                                      intoPath:[NSString stringWithFormat:@"%@/%@",dropboxCachePath,[data objectForKey:@"filename"]]];
            }
        }
        //Look for images in current directory and load thumbnails for them
    }
    //Reading Cache is skipped only reading Table Contents Ends
    
    
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
{
    [self stopAnimating];
    [tableDataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *objDict = (NSDictionary *)obj;
        if ([[objDict objectForKey:@"thumbnailExists"] boolValue]) {
            if (![objDict objectForKey:THUMBNAIL_DATA]) {
                [self.restClient loadThumbnail:[objDict objectForKey:@"path"]
                                        ofSize:@"small"
                                      intoPath:[NSString stringWithFormat:@"%@/%@",[CLCacheManager getDropboxCacheFolderPath],[objDict objectForKey:@"filename"]]];
            }
        }
    }];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
    [self stopAnimating];
    [AppDelegate showError:error alertOnView:self.view];
}



#pragma mark - Helper Methods


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
                NSArray *contents = [operation.result objectForKey:@"data"];
                [self updateModel:contents];
                [self updateView];
                //Looking For images and then downloading thumnails Starts
                
                for (NSDictionary *data in contents) {
                    if (![data objectForKey:THUMBNAIL_DATA]) {
                        NSArray *images = [data objectForKey:@"images"];
                        if ([images count]) {
                            NSDictionary *image = [images objectAtIndex:2];
                            LiveDownloadOperation *downloadOperation =                         [self.appDelegate.liveClient downloadFromPath:[image objectForKey:@"source"] delegate:self userState:[data objectForKey:@"name"]];
                            [liveOperations addObject:downloadOperation];
                            currentFileOperation = DOWNLOAD;
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
                [updatedData setObject:downloadOperation.data forKey:THUMBNAIL_DATA];
                
                
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
            }
        }
            break;
        default:
            break;
            //currentFileOperation = INFINITY;
    }
}

-(void) createToolbarItems
{
    UIImage *baseImage = [UIImage imageNamed:@"button_background_base.png"];
    UIImage *buttonImage = [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    
    createFolderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createFolderButton.frame = CGRectMake(0, 0, 50, 30);
    [createFolderButton setTitle:@"Folder"
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
//    UIBarButtonItem *createFolderBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Folder" style:UIBarButtonItemStyleBordered target:self action:@selector(createFolderButtonClicked:)];

    [toolBarItems addObject:createFolderBarButton];
    [createFolderBarButton release];

    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 2.f;
    [toolBarItems addObject:fixedSpace];
    [fixedSpace release];
    
    UIBarButtonItem *uploadProgressBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.appDelegate.uploadProgressButton];
    [toolBarItems addObject:uploadProgressBarButton];
    [self.appDelegate.uploadProgressButton addTarget:self
                                              action:@selector(uploadProgressButtonClicked:)
                                    forControlEvents:UIControlEventTouchUpInside];
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
            [self.appDelegate.menuController setLeftButtonImage:[UIImage imageNamed:@"SkyDriveIconBlue_32x32.png"]];
            break;
        default:
            [self.appDelegate.menuController setLeftButtonImage:[UIImage imageNamed:@"nav_menu_icon.png"]];
            break;
    }
}


-(NSDictionary *) readCachedFileStructure
{
//    return [CLCacheManager metaDataDictionaryForPath:path ForView:viewType];
    return [CLCacheManager metaDataForPath:path
                    whereTraversingPointer:nil
                       WithinFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                                   ForView:viewType];
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
    [barItem startAnimating];
}

-(void) stopAnimating
{
    [barItem stopAnimating];
}



@end
