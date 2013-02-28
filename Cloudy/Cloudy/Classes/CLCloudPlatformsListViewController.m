//
//  CLCloudPlatformsListViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 28/02/13.
//  Copyright (c) 2013 Parag Dulam. All rights reserved.
//

#import "CLCloudPlatformsListViewController.h"

@interface CLCloudPlatformsListViewController ()

@end

@implementation CLCloudPlatformsListViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSDictionary *) createDictionaryForViewType:(VIEW_TYPE) type
{
    NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];
    switch (type) {
        case DROPBOX:
        {
            [retVal setObject:[UIImage imageNamed:@"dropbox_cell_Image.png"]
                       forKey:@"IMAGE"];
            [retVal setObject:@"Dropbox"
                       forKey:@"NAME"];
        }
            break;
            
        case SKYDRIVE:
        {
            [retVal setObject:[UIImage imageNamed:@"SkyDriveIconBlack_32x32.png"]
                       forKey:@"IMAGE"];
            [retVal setObject:@"SkyDrive"
                       forKey:@"NAME"];
        }
            break;
        default:
            break;
    }
    return [retVal autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CLBrowserBarItem *barItem = [[CLBrowserBarItem alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [barItem setTitle:@"Cancel" forState:UIControlStateNormal];
    [barItem setImage:[UIImage imageNamed:@"button_background_base.png"]
           WithInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    [barItem setDelegate:self];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barItem];
    [barItem release];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    [rightBarButtonItem release];
    
    [tableDataArray addObject:[self createDictionaryForViewType:DROPBOX]];
    [tableDataArray addObject:[self createDictionaryForViewType:SKYDRIVE]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) dealloc
{
    [super dealloc];
}


#pragma mark - CLBrowserBarItemDelegate

-(void) buttonClicked:(UIButton *)btn WithinView:(CLBrowserBarItem *) view
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"CELL"];
    }
    NSDictionary *data = [tableDataArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:[data objectForKey:@"NAME"]];
    [cell.imageView setImage:[data objectForKey:@"IMAGE"]];
    return [cell autorelease];
}


#pragma mark - UITableViewDelegate


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([delegate respondsToSelector:@selector(cloudPlatformListViewController:didSelectPlatForm:)]) {
        [delegate cloudPlatformListViewController:self
                                didSelectPlatForm:indexPath.row];
    }
}

@end
