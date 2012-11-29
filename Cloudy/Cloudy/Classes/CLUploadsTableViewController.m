//
//  CLUploadsTableViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 29/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLUploadsTableViewController.h"
#import "CLUploadCell.h"

@interface CLUploadsTableViewController ()

@end

@implementation CLUploadsTableViewController

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
    self.appDelegate.uploadsViewController = self;
    [self setTitle:@"Uploads"];
    
    CLBrowserBarItem *barItem = [[CLBrowserBarItem alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    barItem.delegate = self;
    [barItem setTitle:@"Cancel" forState:UIControlStateNormal];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barItem];
    [barItem release];
    
    [self.navigationItem setRightBarButtonItem:cancelBarButtonItem];
    [cancelBarButtonItem release];
    
    [tableDataArray addObjectsFromArray:self.appDelegate.uploads];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    self.appDelegate.uploadsViewController = nil;
    [super dealloc];
}


#pragma mark - Helper Methods


-(void) removeFirstRowWithAnimation
{
    [tableDataArray removeObjectAtIndex:0];
    [dataTableView beginUpdates];
    [dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                         withRowAnimation:UITableViewRowAnimationBottom];
    [dataTableView endUpdates];
}

-(void) cancelButtonClicked:(UIButton *) btn
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - CLBrowserBarItemDelegate

-(void) buttonClicked:(UIButton *)btn WithinView:(CLBrowserBarItem *) view
{
    [self cancelButtonClicked:btn];
}


#pragma mark - UITableViewDataSource

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLUploadCell *cell = (CLUploadCell *)[tableView dequeueReusableCellWithIdentifier:@"CLUploadCell"];
    if (!cell) {
        cell = [[[CLUploadCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:@"CLUploadCell"] autorelease];
    }
    NSDictionary *data = [tableDataArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:[data objectForKey:@"NAME"]];
    [cell.detailTextLabel setText:[data objectForKey:@"TOPATH"]];
    [cell setButtonImage:[UIImage imageWithData:[data objectForKey:@"THUMBNAIL"]]];
    if (!indexPath.row) {
        NSLog(@"progress %f",self.appDelegate.uploadProgressButton.progress);
        [cell setProgress:self.appDelegate.uploadProgressButton.progress];
    } else {
        [cell setProgress:0];
    }
    return cell;
}



@end
