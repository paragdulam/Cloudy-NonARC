//
//  CLPathSelectionViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLPathSelectionViewController.h"

@interface CLPathSelectionViewController ()
{
    UIButton *createFolderButton;
    UIButton *selectButton;
    
    NSArray *toolBarItems;
}
@end

@implementation CLPathSelectionViewController
@synthesize excludedFolders;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithTableViewStyle:(UITableViewStyle)style
                   WherePath:(NSString *) pathString
              WithinViewType:(VIEW_TYPE) type
        WhereExcludedFolders:(NSArray *) folders
{
    if (self = [super initWithTableViewStyle:style
                                   WherePath:pathString
                              WithinViewType:type])
    {
        self.excludedFolders = folders;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

//    CGRect navBarFrame = self.navigationController.navigationBar.frame;
//    navBarFrame.size.height = 60.f;
//    self.navigationController.navigationBar.frame = navBarFrame;
//    
//    
//    CGRect dataTableFrame = dataTableView.frame;
//    dataTableFrame.origin.y = self.navigationController.navigationBar.frame.size.height - 44.f;
//    dataTableFrame.size.height -= 44.f;
//
//    dataTableView.frame = dataTableFrame;

    UIImage *baseImage = [UIImage imageNamed:@"button_background_base.png"];
    UIImage *buttonImage = [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    
    [barItem setTitle:@"Cancel" forState:UIControlStateNormal];

    
    
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

    selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectButton.frame = CGRectMake(0, 0, 50, 30);
    [selectButton setTitle:@"Select"
                  forState:UIControlStateNormal];
    [selectButton setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
    [selectButton setBackgroundImage:buttonImage
                            forState:UIControlStateNormal];
    [selectButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
    [selectButton addTarget:self
                     action:@selector(selectButtonClicked:)
           forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *createFolderBarButton = [[UIBarButtonItem alloc] initWithCustomView:createFolderButton];
    UIBarButtonItem *selectBarButton = [[UIBarButtonItem alloc] initWithCustomView:selectButton];
    
    toolBarItems = [[NSArray alloc] initWithObjects:createFolderBarButton,flexiSpace,selectBarButton, nil];
    
    [createFolderBarButton release];
    [selectBarButton release];
    [flexiSpace release];
    
    [fileOperationsToolbar setItems:toolBarItems animated:YES];
    [toolBarItems release];

    
	// Do any additional setup after loading the view.
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
    delegate = nil;
    
    [excludedFolders release];
    excludedFolders = nil;
    
    [super dealloc];
}


#pragma mark - CLBrowserBarItemDelegate

-(void) buttonClicked:(UIButton *)btn WithinView:(CLBrowserBarItem *) view
{
    [self cancelButtonClicked:btn];
}


#pragma mark - Helper Methods


-(void) loadFilesForPath:(NSString *)pathString WithInViewType:(VIEW_TYPE)type
{
    [super loadFilesForPath:pathString WithInViewType:type];
}


-(void) updateModel:(NSArray *)model
{
    NSMutableArray *computedData = [[NSMutableArray alloc] initWithArray:model];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [excludedFolders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *objDict = (NSDictionary *)obj;
        for (NSDictionary *data in computedData) {
            if (([[data objectForKey:@"id"] isEqualToString:[objDict objectForKey:@"id"]]) || ([[data objectForKey:@"path"] isEqualToString:[objDict objectForKey:@"path"]])) {
                [tempArray addObject:data];
                *stop = YES;
            }
        }
    }];
    
    [computedData removeObjectsInArray:tempArray];
    [tempArray release];
    NSMutableArray *files = [[NSMutableArray alloc] init];
    for (NSDictionary *data in computedData) {
        switch (viewType) {
            case DROPBOX:
            {
                if (![[data objectForKey:@"isDirectory"] boolValue]) {
                    [files addObject:data];
                }
            }
                break;
            case SKYDRIVE:
            {
                if (![[data objectForKey:@"type"] isEqualToString:@"folder"] && ![[data objectForKey:@"type"] isEqualToString:@"album"]) {
                    [files addObject:data];
                }
            }
                break;
            default:
                break;
        }
    }
    [computedData removeObjectsInArray:files];
    [files release];
    
    [super updateModel:computedData];
    [computedData release];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource


//-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
//    if (!cell) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                      reuseIdentifier:@"CELL"] autorelease];
//    }
//    return cell;
//}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (viewType) {
        case DROPBOX:
        {
            NSDictionary *metadata = [tableDataArray objectAtIndex:indexPath.row];
            CLPathSelectionViewController *pathSelectionViewController = [[CLPathSelectionViewController alloc] initWithTableViewStyle:UITableViewStylePlain WherePath:[metadata objectForKey:@"path"] WithinViewType:DROPBOX WhereExcludedFolders:excludedFolders];
            pathSelectionViewController.delegate = delegate;
            [self.navigationController pushViewController:pathSelectionViewController animated:YES];
            [pathSelectionViewController release];
        }
            break;
        case SKYDRIVE:
        {
            NSDictionary *metadata = [tableDataArray objectAtIndex:indexPath.row];
            CLPathSelectionViewController *pathSelectionViewController = [[CLPathSelectionViewController alloc] initWithTableViewStyle:UITableViewStylePlain WherePath:[metadata objectForKey:@"id"] WithinViewType:SKYDRIVE WhereExcludedFolders:excludedFolders];
            pathSelectionViewController.delegate = delegate;
            [self.navigationController pushViewController:pathSelectionViewController animated:YES];
            [pathSelectionViewController release];
        }
            break;
        default:
            break;
    }
}



#pragma mark - IBActions

-(void) cancelButtonClicked:(UIButton *) btn
{
    [self dismissModalViewControllerAnimated:YES];
}


-(void) createFolderButtonClicked:(UIButton *) btn
{
    
}


-(void) selectButtonClicked:(UIButton *) btn
{
    if ([delegate respondsToSelector:@selector(pathDidSelect:ForViewController:)]) {
        [barItem startAnimating];
        [delegate pathDidSelect:path
              ForViewController:self];
    }
//    [self dismissModalViewControllerAnimated:YES];
}

@end
