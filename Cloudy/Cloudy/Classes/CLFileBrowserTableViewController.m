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
    
    
    NSArray *toolBarItems;
    NSArray *editingToolBarItems;
    
    FILE_FOLDER_OPERATION currentFileOperation;
    NSMutableArray *selectedItems;
}

-(void) hideButtons:(NSArray *) buttons;
-(void) showButtons:(NSArray *) buttons;
-(NSArray *) getSelectedDataArray;
-(void) performFileOperation;
-(void) removeSelectedRows;

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

    [super viewDidLoad]; // Here the sequence is really Important
    
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
    [selectedItems release];
    selectedItems = nil;
    
    [super dealloc];
}


#pragma mark - LiveOperationDelegate

- (void) liveOperationSucceeded:(LiveOperation *)operation
{
    [barItem stopAnimating];
    if ([operation.userState isEqualToString:@"MOVE_FILES"]) {
        [self.modalViewController dismissModalViewControllerAnimated:YES];
        [self removeSelectedRows];
    } else if([operation.userState isEqualToString:@"COPY_FILES"]) {
        [self.modalViewController dismissModalViewControllerAnimated:YES];
    } else {
        [super liveOperationSucceeded:operation];
    }
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveOperation*)operation
{
    [barItem stopAnimating];
    if ([operation.userState isEqualToString:@"MOVE_FILES"] || [operation.userState isEqualToString:@"COPY_FILES"])
    {
        [self.modalViewController dismissModalViewControllerAnimated:YES];
    }

    [super liveOperationFailed:error
                     operation:operation];
}



#pragma mark - DBRestClientDelegate

#pragma mark - Copy File Operation Methods

- (void)restClient:(DBRestClient*)client copiedPath:(NSString *)fromPath to:(DBMetadata *)to
{
    [barItem stopAnimating];
    NSDictionary *metaData = [CLDictionaryConvertor dictionaryFromMetadata:to];
    [CLCacheManager updateFolderStructure:metaData
                                  ForView:DROPBOX];
    [self readCacheUpdateView];
}

- (void)restClient:(DBRestClient*)client copyPathFailedWithError:(NSError*)error
{
    [barItem stopAnimating];
}


#pragma mark - Move File Operation Methods

- (void)restClient:(DBRestClient*)client movedPath:(NSString *)from_path to:(DBMetadata *)result
{
    [barItem stopAnimating];
    NSDictionary *metaData = [CLDictionaryConvertor dictionaryFromMetadata:result];
    [CLCacheManager updateFolderStructure:metaData
                                  ForView:DROPBOX];
    [self readCacheUpdateView];
    [self removeSelectedRows];
}

- (void)restClient:(DBRestClient*)client movePathFailedWithError:(NSError*)error
{
    [barItem stopAnimating];
}

#pragma mark - Delete File Operation Methods

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path
{
    [barItem stopAnimating];
    [barItem deselectAll];
    [self removeSelectedRows];
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error
{
    [barItem stopAnimating];
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
            for (NSIndexPath *indexPath in indexPaths) {
                NSDictionary *data = [tableDataArray objectAtIndex:indexPath.row];
                switch (currentFileOperation) {
                    case MOVE:
                    {
                        [self.appDelegate.liveClient moveFromPath:[data objectForKey:@"id"]
                                                    toDestination:pathString delegate:self userState:@"MOVE_FILES"];
                    }
                        break;
                    case COPY:
                    {
                        [self.appDelegate.liveClient copyFromPath:[data objectForKey:@"id"]
                                                    toDestination:pathString delegate:self userState:@"COPY_FILES"];
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


#pragma mark - Helper Methods



-(void) removeSelectedRows
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSDictionary *data in selectedItems) {
        NSDictionary *file = [data objectForKey:@"DATA"];
        //Cache Deletion Starts
        [CLCacheManager deleteFile:file
            whereTraversingPointer:nil
                   inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:viewType]
                       ForViewType:viewType];
        //Cache Deletion Starts
        [indexPaths addObject:[data objectForKey:@"INDEXPATH"]];
        [tableDataArray removeObject:file];
    }
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
        NSMutableDictionary *selectedItem = [[NSMutableDictionary alloc] init];
        [selectedItem setObject:[tableDataArray objectAtIndex:indexPath.row]
                         forKey:@"DATA"];
        [selectedItem setObject:indexPath
                         forKey:@"INDEXPATH"];
        [retVal addObject:selectedItem];
        [selectedItem release];
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
        [self hideButtons:[NSArray arrayWithObjects:uploadButton, nil]];
        [barItem hideEditButton:YES];
        [self updateView];
        return;
    }
    
    [self showButtons:[NSArray arrayWithObjects:uploadButton, nil]];
    [barItem hideEditButton:NO];
    [super loadFilesForPath:pathString WithInViewType:type];
}


#pragma mark - CLBrowserBarItemDelegate

-(void) buttonClicked:(UIButton *)btn WithinView:(CLBrowserBarItem *)view
{
    [self editButtonClicked:btn];
}


#pragma mark - IBActions

-(void) uploadButtonClicked:(UIButton *) btn
{
}


-(void) shareButtonClicked:(UIButton *) sender
{
    currentFileOperation = SHARE;
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
    [barItem startAnimating];
    for (NSDictionary *data in selectedData) {
        [self.restClient deletePath:[data objectForKey:@"path"]];
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
