//
//  CLCloudPlatformSelectionViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 08/01/13.
//  Copyright (c) 2013 Parag Dulam. All rights reserved.
//

#import "CLCloudPlatformSelectionViewController.h"
#import "CLPathSelectionViewController.h"
#import "CLAccountCell.h"


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
    [self.navigationItem setTitle:@"Upload To"];
    editButton.hidden = YES;
    CLBrowserBarItem *barItem = [[CLBrowserBarItem alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    barItem.delegate = self;
    [barItem setTitle:@"Cancel" forState:UIControlStateNormal];
    [barItem setImage:[UIImage imageNamed:@"button_background_base.png"]
           WithInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barItem];
    [barItem release];
    
    [self.navigationItem setRightBarButtonItem:cancelBarButtonItem];
    [cancelBarButtonItem release];
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

//-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return [tableDataArray count];
//}
//
//-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 1;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CLAccountCell *cell = (CLAccountCell *)[tableView dequeueReusableCellWithIdentifier:@"CLAccountCell"];
//    if (!cell) {
//        cell = [[[CLAccountCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CLAccountCell"] autorelease];
//    }
//    [cell setData:[tableDataArray objectAtIndex:indexPath.section]
//forCellAtIndexPath:indexPath];
//    return cell;
//}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *path = nil;
    id obj = [tableDataArray objectAtIndex:indexPath.section];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        switch (indexPath.section) {
            case DROPBOX:
                path = ROOT_DROPBOX_PATH;
                break;
            case SKYDRIVE:
            {
                path = [NSString stringWithFormat:@"folder.%@",[[sharedManager accountOfType:indexPath.section] objectForKey:ID]];
            }
                break;
            default:
                break;
        }
        CLPathSelectionViewController *pathSelectionViewController = [[CLPathSelectionViewController alloc] initWithTableViewStyle:UITableViewStylePlain WherePath:path WithinViewType:indexPath.section WhereExcludedFolders:nil];
        pathSelectionViewController.delegate = self.appDelegate;
        [self.navigationController pushViewController:pathSelectionViewController
                                             animated:YES];
        [pathSelectionViewController release];
    } else {
        NSString *errorString = nil;
        switch (indexPath.section) {
            case DROPBOX:
                errorString = @"Please Login to Dropbox Account. OverClouded cannot access your Dropbox Account until then.";
                break;
            case SKYDRIVE:
                errorString = @"Please Login to SkyDrive Account. OverClouded cannot access your SkyDrive Account until then.";
                break;
                
            default:
                break;
        }
        [AppDelegate showMessage:errorString
                       withColor:[UIColor redColor]
                     alertOnView:self.view];
    }
}


-(void) buttonClicked:(UIButton *)btn WithinView:(CLBrowserBarItem *) view
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
