//
//  CLFileBrowserTableViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 12/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLFileBrowserTableViewController.h"
#import "CLPathSelectionViewController.h"

@interface CLFileBrowserTableViewController ()
{
    UIButton *uploadButton;
    
    UIButton *moveButton;
    UIButton *copyButton;
    UIButton *shareButton;
    UIButton *deleteButton;
    
    
    NSArray *editingToolBarItems;
    
    NSMutableArray *selectedItems;
}


-(void) hideButtons:(NSArray *) buttons;
-(void) showButtons:(NSArray *) buttons;
-(NSArray *) getSelectedDataArray;
-(void) performFileOperation;
-(void) removeSelectedRow:(NSDictionary *) file;
-(void) removeSelectedRowForPath:(NSString *)filePath;
-(void) removeSelectedRows;
-(void) shareURLsThroughMail:(NSArray *) urls;
-(void) createEditingToolbarItems;
-(void) completeToolbarItems;



@property (nonatomic,retain)     NSMutableArray *selectedItems;


@end

@implementation CLFileBrowserTableViewController
@synthesize selectedItems;

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
	// Do any additional setup after loading the view.
    
    [super viewDidLoad]; 
    [self completeToolbarItems];
    [fileOperationsToolbar setItems:toolBarItems animated:YES];
    [self createEditingToolbarItems];
    //currentFileOperation = INFINITY;
    [barItem setTitle:@"Edit" forState:UIControlStateNormal];
    [barItem setTitle:@"Done" forState:UIControlStateSelected];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [barItem deselectAll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) dealloc
{
    [toolBarItems release];
    toolBarItems = nil;
    
    [editingToolBarItems release];
    editingToolBarItems = nil;
    
    [selectedItems release];
    selectedItems = nil;
    
    [super dealloc];
}


#pragma mark - LiveUploadOperationDelegate

- (void) liveUploadOperationProgressed:(LiveOperationProgress *)progress
                             operation:(LiveOperation *)operation
{
    
}


#pragma mark - LiveOperationDelegate

- (void) liveOperationSucceeded:(LiveOperation *)operation
{
    [super liveOperationSucceeded:operation];
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveOperation*)operation
{
    [super liveOperationFailed:error
                     operation:operation];
}



#pragma mark - DBRestClientDelegate


#pragma mark - Upload File Operation Methods

-(void) restClient:(DBRestClient *)client
    uploadProgress:(CGFloat)progress
           forFile:(NSString *)destPath
              from:(NSString *)srcPath
{
    
}

#pragma mark - Share File Operation Methods

-(void) restClient:(DBRestClient *)restClient
loadedSharableLink:(NSString *)link
           forFile:(NSString *)pathStr
{
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    NSDictionary *file = nil;
    for (NSDictionary *data in selectedItems) {
        if ([[data objectForKey:@"path"] isEqualToString:pathStr]) {
            [urls addObject:[NSDictionary dictionaryWithObject:link
                                                        forKey:[data objectForKey:@"filename"]]];
            file = data;
            break;
        }
    }
    [selectedItems removeObject:file];
    if (![selectedItems count]) {
        //
        [self stopAnimating];
        [self shareURLsThroughMail:urls];
        [urls release];
    }
}



-(void) restClient:(DBRestClient *)restClient loadSharableLinkFailedWithError:(NSError *)error
{
    
}


#pragma mark - Copy File Operation Methods

- (void)restClient:(DBRestClient*)client copiedPath:(NSString *)fromPath to:(DBMetadata *)to
{
    [self stopAnimating];
    NSDictionary *metaData = [CLDictionaryConvertor dictionaryFromMetadata:to];
    [CLCacheManager insertFile:metaData
        whereTraversingPointer:nil
               inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                   ForViewType:viewType];
}

- (void)restClient:(DBRestClient*)client copyPathFailedWithError:(NSError*)error
{
    [self stopAnimating];
}


#pragma mark - Move File Operation Methods

- (void)restClient:(DBRestClient*)client movedPath:(NSString *)from_path to:(DBMetadata *)result
{
    [self stopAnimating];
    NSDictionary *metaData = [CLDictionaryConvertor dictionaryFromMetadata:result];
    [CLCacheManager insertFile:metaData
        whereTraversingPointer:nil
               inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                   ForViewType:viewType];
    [self removeSelectedRowForPath:from_path];
}

- (void)restClient:(DBRestClient*)client movePathFailedWithError:(NSError*)error
{
    [self stopAnimating];
}

#pragma mark - Delete File Operation Methods

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)pathStr
{
    [self stopAnimating];
    [self removeSelectedRowForPath:pathStr];
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error
{
    [self stopAnimating];
    [AppDelegate showError:error alertOnView:self.view];
}


#pragma mark - CLPathSelectionViewControllerDelegate

-(void) pathDidSelect:(NSString *) pathString ForViewController:(CLPathSelectionViewController *) viewController
{
    NSLog(@"path %@",pathString);
    switch (viewController.viewType) {
        case DROPBOX:
        {
            NSArray *indexPaths = [dataTableView indexPathsForSelectedRows];
            for (NSIndexPath *indexPath in indexPaths) {
                NSDictionary *data = [tableDataArray objectAtIndex:indexPath.row];
                NSString *fileName = [[[data objectForKey:@"path"] componentsSeparatedByString:@"/"] lastObject];
                
                switch (currentFileOperation) {
                    case MOVE:
                        [self.restClient moveFrom:[data objectForKey:@"path"]
                                           toPath:[NSString stringWithFormat:@"%@/%@",pathString,fileName]];
                        CLFileBrowserCell *cell = (CLFileBrowserCell *)[dataTableView cellForRowAtIndexPath:indexPath];
                        [cell startAnimating];
                        break;
                    case COPY:
                        [self.restClient copyFrom:[data objectForKey:@"path"]
                                           toPath:[NSString stringWithFormat:@"%@/%@",pathString,fileName]];
                        break;
                        
                    default:
                        break;
                }
            }
        }
            break;
        case SKYDRIVE:
        {
            NSArray *indexPaths = [dataTableView indexPathsForSelectedRows];
            pathString = [NSString stringWithFormat:@"%@",[[pathString componentsSeparatedByString:@"/"] objectAtIndex:0]];
            if (![pathString hasPrefix:@"folder."]) { //only folders are input here
                pathString = [NSString stringWithFormat:@"folder.%@",pathString];
            }
            for (NSIndexPath *indexPath in indexPaths) {
                
                NSDictionary *data = [tableDataArray objectAtIndex:indexPath.row];
                switch (currentFileOperation) {
                    case MOVE:
                    {
                        LiveOperation *moveOperation =                         [self.appDelegate.liveClient moveFromPath:[data objectForKey:@"id"]
                                                                                                           toDestination:pathString delegate:self userState:[data objectForKey:@"id"]];
                        [liveOperations addObject:moveOperation];
                        CLFileBrowserCell *cell = (CLFileBrowserCell *)[dataTableView cellForRowAtIndexPath:indexPath];
                        [cell startAnimating];
                    }
                        break;
                    case COPY:
                    {
                        LiveOperation *copyOperation =                          [self.appDelegate.liveClient copyFromPath:[data objectForKey:@"id"]
                                                                                                            toDestination:pathString delegate:self userState:[data objectForKey:@"id"]];
                        [liveOperations addObject:copyOperation];

                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
    switch (result) {
        case MFMailComposeResultSent:
            //Success
            break;
        case MFMailComposeResultSaved:
            //Saved
            break;
        case MFMailComposeResultCancelled:
            //Cancelled
            break;
        case MFMailComposeResultFailed:
            //Failed
            break;
        default:
            break;
    }
}

#pragma mark - Helper Methods



-(void) performFileOperation:(LiveOperation *)operation
{
    [super performFileOperation:operation];
    switch (currentFileOperation) {
        case MOVE:
            [self removeSelectedRowForPath:operation.userState];
        case COPY:
        {
            [CLCacheManager insertFile:operation.result
                whereTraversingPointer:nil
                       inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                           ForViewType:viewType];
        }
            break;
        case DELETE:
        {
            [self removeSelectedRowForPath:operation.userState];
            //currentFileOperation = INFINITY;
        }
            break;
        default:
            break;
    }
}


-(void) completeToolbarItems
{
    UIImage *baseImage = [UIImage imageNamed:@"button_background_base.png"];
    UIImage *buttonImage = [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    
    
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
    
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBarItems addObject:flexiSpace];
    [flexiSpace release];
    
    UIBarButtonItem *uploadBarButton = [[UIBarButtonItem alloc] initWithCustomView:uploadButton];
    [toolBarItems addObject:uploadBarButton];
    [uploadBarButton release];
}


-(void) createEditingToolbarItems
{
    UIImage *baseImage = [UIImage imageNamed:@"button_background_base.png"];
    UIImage *buttonImage = [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];

    
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
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
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
}

-(void) shareURLsThroughMail:(NSArray *) urls
{
    NSMutableString *htmlString = [[NSMutableString alloc] init];
    for (NSDictionary *dict in urls) {
        [htmlString appendFormat:@"<a href=\"%@\">%@</a><br/>",[[dict allValues] objectAtIndex:0],[[dict allKeys] objectAtIndex:0]];
    }
    
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Sharing Files"];
    [controller setMessageBody:htmlString isHTML:YES];
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

-(void) startAnimating
{
    [super startAnimating];
}

-(void) stopAnimating
{
    [super stopAnimating];
}


-(void) removeSelectedRowForPath:(NSString *)filePath
{
    for (NSDictionary *data in selectedItems) {
        if (([[data objectForKey:@"path"] isEqualToString:filePath]) ||
            ([[data objectForKey:@"id"] isEqualToString:filePath])) {
            [self removeSelectedRow:data];
            [selectedItems removeObject:data];
            break;
        }
    }
    if (![selectedItems count]) {
        [barItem deselectAll];
    }
}


-(void) removeSelectedRow:(NSDictionary *) file
{
    [CLCacheManager deleteFile:file
        whereTraversingPointer:nil
               inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                   ForViewType:viewType];
    int index = [tableDataArray indexOfObject:file];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                inSection:0];
    [tableDataArray removeObject:file];
    [dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationLeft];
}


-(void) removeSelectedRows
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSDictionary *data in selectedItems) {
        //Cache Deletion Starts
        [CLCacheManager deleteFile:data
            whereTraversingPointer:nil
                   inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                       ForViewType:viewType];
        //Cache Deletion Starts
        int row = [tableDataArray indexOfObject:data];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row
                                                    inSection:0];
        [indexPaths addObject:indexPath];
    }
    [tableDataArray removeObjectsInArray:selectedItems];
    [dataTableView deleteRowsAtIndexPaths:indexPaths
                         withRowAnimation:UITableViewRowAnimationLeft];
    [indexPaths release];
}

-(void) performFileOperation
{
    NSArray *selectedData = [self getSelectedDataArray];
    if ([selectedData count]) {
        NSString *pathString = nil;
        switch (viewType) {
            case DROPBOX:
                pathString = ROOT_DROPBOX_PATH;
                break;
            case SKYDRIVE:
                pathString = ROOT_SKYDRIVE_PATH;
                break;
                
            default:
                break;
        }
        
        CLPathSelectionViewController *pathSelectionViewController = [[CLPathSelectionViewController alloc] initWithTableViewStyle:UITableViewStylePlain WherePath:pathString WithinViewType:viewType WhereExcludedFolders:selectedData];
        pathSelectionViewController.delegate = self;
        UINavigationController *nController = [[UINavigationController alloc] initWithRootViewController:pathSelectionViewController];
        [pathSelectionViewController release];
        
        [self presentModalViewController:nController animated:YES];
        [nController release];
    }
}

-(NSArray *) getSelectedDataArray
{
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    NSArray *indexPaths = [dataTableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in indexPaths) {
//        NSMutableDictionary *selectedItem = [[NSMutableDictionary alloc] init];
//        [selectedItem setObject:[tableDataArray objectAtIndex:indexPath.row]
//                         forKey:@"DATA"];
//        [selectedItem setObject:indexPath
//                         forKey:@"INDEXPATH"];
        [retVal addObject:[tableDataArray objectAtIndex:indexPath.row]];
//        [selectedItem release];
    }
    self.selectedItems = retVal;
    [retVal release];
    return selectedItems;
}



-(void) hideButtons:(NSArray *) buttons
{
    for (UIButton *button in buttons) {
        button.hidden = YES;
    }
}

-(void) showButtons:(NSArray *) buttons
{
    for (UIButton *button in buttons) {
        button.hidden = NO;
    }
}

-(void) loadFilesForPath:(NSString *)pathString WithInViewType:(VIEW_TYPE)type
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
        viewType = INFINITY;
        [self hideButtons:[NSArray arrayWithObjects:uploadButton,createFolderButton, nil]];
        [barItem hideEditButton:YES];
        [self updateView];
        return;
    }
    
    [self showButtons:[NSArray arrayWithObjects:uploadButton,createFolderButton, nil]];
    [barItem hideEditButton:NO];
    [super loadFilesForPath:pathString WithInViewType:type];
}


#pragma mark - CLBrowserBarItemDelegate

-(void) buttonClicked:(UIButton *)btn WithinView:(CLBrowserBarItem *)view
{
    [self editButtonClicked:btn];
}


#pragma mark - AGImagePickerControllerDelegate

- (void)agImagePickerController:(AGImagePickerController *)picker
  didFinishPickingMediaWithInfo:(NSArray *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    [self.appDelegate updateUploads:info
                       FolderAtPath:path
                        ForViewType:viewType ];
    //notify AppDelegate about the Uploads
}

- (void)agImagePickerController:(AGImagePickerController *)picker
                        didFail:(NSError *)error
{
    [picker dismissModalViewControllerAnimated:YES];
}


#pragma mark - IBActions

-(void) uploadButtonClicked:(UIButton *) btn
{
    AGImagePickerController *imagePicker = [[AGImagePickerController alloc] initWithDelegate:self];
    [self presentModalViewController:imagePicker animated:YES];
    [imagePicker release];
}


-(void) shareButtonClicked:(UIButton *) sender
{
    currentFileOperation = SHARE;
    NSArray *selectedData = [self getSelectedDataArray];
    switch (viewType) {
        case DROPBOX:
        {
            for (NSDictionary *data in selectedData) {
                [self.restClient loadSharableLinkForFile:[data objectForKey:@"path"] shortUrl:YES];
                [self startAnimating];
            }
        }
            break;
        case SKYDRIVE:
        {
            NSMutableArray *urls = [[NSMutableArray alloc] init];
            for (NSDictionary *data in selectedData) {
                [urls addObject:[NSDictionary dictionaryWithObject:[data objectForKey:@"link"] forKey:[data objectForKey:@"name"]]];
            }
            [self shareURLsThroughMail:urls];
            [urls release];
        }
            break;
            
        default:
            break;
    }
}

-(void) copyButtonClicked:(UIButton *) sender
{
    currentFileOperation = COPY;
    [self performFileOperation];
}


-(void) moveButtonClicked:(UIButton *) sender
{
    currentFileOperation = MOVE;
    [self performFileOperation];
}

-(void) deleteButtonClicked:(UIButton *) sender
{
    currentFileOperation = DELETE;
    NSArray *selectedData = [self getSelectedDataArray];
    [self startAnimating];
    switch (viewType) {
        case DROPBOX:
        {
            for (NSDictionary *data in selectedData) {
                [self.restClient deletePath:[data objectForKey:@"path"]];
            }
        }
            break;
        case SKYDRIVE:
        {
            for (NSDictionary *data in selectedData) {
                LiveOperation *deleteOperation =                 [self.appDelegate.liveClient deleteWithPath:[data objectForKey:@"id"]
                                                                                                    delegate:self
                                                                                                   userState:[data objectForKey:@"id"]];
                [liveOperations addObject:deleteOperation];

            }
        }
            break;
            
        default:
            break;
    }
}

-(void) editButtonClicked:(UIButton *) sender
{
    sender.selected = !sender.selected;
    
    if (!sender.selected) {
        [fileOperationsToolbar setItems:toolBarItems animated:YES];
        [dataTableView setEditing:NO animated:YES];
    } else {
        [fileOperationsToolbar setItems:editingToolBarItems animated:YES];
        [dataTableView setEditing:YES animated:YES];
    }
}


@end
