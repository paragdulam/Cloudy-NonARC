//
//  CLCloudPlatformSelectionViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 08/01/13.
//  Copyright (c) 2013 Parag Dulam. All rights reserved.
//

#import "CLCloudPlatformSelectionViewController.h"
#import "CLPathSelectionViewController.h"


@interface CLCloudPlatformSelectionViewController ()

@end

@implementation CLCloudPlatformSelectionViewController

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
    
    CLBrowserBarItem *barItem = [[CLBrowserBarItem alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    barItem.delegate = self;
    [barItem setTitle:@"Cancel" forState:UIControlStateNormal];
    [barItem setImage:[UIImage imageNamed:@"button_background_base.png"]
           WithInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barItem];
    [barItem release];
    
    [self.navigationItem setRightBarButtonItem:cancelBarButtonItem];
    [cancelBarButtonItem release];


    for (NSDictionary *account in [CLCacheManager accounts]) {
        VIEW_TYPE type = [[account objectForKey:ACCOUNT_TYPE] integerValue];
        switch (type) {
            case DROPBOX:
                [tableDataArray addObject:DROPBOX_STRING];
                break;
            case SKYDRIVE:
                [tableDataArray addObject:SKYDRIVE_STRING];
                break;
            default:
                break;
        }
    }
    [self updateView];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    navBarFrame.size.height = 44.f;
    self.navigationController.navigationBar.frame = navBarFrame;

    CGRect tableFrame = dataTableView.frame;
    tableFrame.origin.y = 0;
    tableFrame.size.height = self.view.frame.size.height - navBarFrame.size.height ;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"] autorelease];
    }
    [cell.textLabel setText:[tableDataArray objectAtIndex:indexPath.row]];
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *path = nil;
    switch (indexPath.row) {
        case DROPBOX:
            path = ROOT_DROPBOX_PATH;
            break;
        case SKYDRIVE:
            path = ROOT_SKYDRIVE_PATH;
            break;
        default:
            break;
    }
    CLPathSelectionViewController *pathSelectionViewController = [[CLPathSelectionViewController alloc] initWithTableViewStyle:UITableViewStylePlain WherePath:path WithinViewType:indexPath.row WhereExcludedFolders:nil];
    pathSelectionViewController.delegate = self.appDelegate;
    [self.navigationController pushViewController:pathSelectionViewController animated:YES];
    [pathSelectionViewController release];
}


-(void) buttonClicked:(UIButton *)btn WithinView:(CLBrowserBarItem *) view
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
