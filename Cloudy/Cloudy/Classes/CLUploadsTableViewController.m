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
{
    UILabel *progressLabel;
}

-(void)updateProgressLabel;

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

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setTitle:@"Uploads"];
    self.appDelegate.uploadsViewController = self;

    CLBrowserBarItem *barItem = [[CLBrowserBarItem alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    barItem.delegate = self;
    [barItem setTitle:@"Cancel" forState:UIControlStateNormal];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barItem];
    [barItem release];
    
    [self.navigationItem setRightBarButtonItem:cancelBarButtonItem];
    [cancelBarButtonItem release];
    
    progressLabel = [[UILabel alloc] init];
    [progressLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
    [progressLabel setTextColor:[UIColor whiteColor]];
    [progressLabel setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *labelBarButton = [[UIBarButtonItem alloc] initWithCustomView:progressLabel];
    [progressLabel release];
    [self.navigationItem setLeftBarButtonItem:labelBarButton];
    [labelBarButton release];
    
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



-(void) updateFirstCellWhereProgress:(float) progress
{
    NSLog(@"Progress %f",progress);
    [dataTableView beginUpdates];
    [dataTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                         withRowAnimation:UITableViewRowAnimationNone];
    [dataTableView endUpdates];
    [self updateProgressLabel:progress];
}

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


-(void)updateProgressLabel:(float) progress
{
    NSString *progressString = [NSString stringWithFormat:@"%.1f%%",progress * 100];
    [progressLabel setText:progressString];
    [progressLabel sizeToFit];
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
    [cell setData:data];
    if (!indexPath.row) {
        float progress = self.appDelegate.uploadProgressButton.progress;
        NSLog(@"progress %f",progress);
        [cell setProgress:progress];
        [self updateProgressLabel:progress];
    } else {
        [cell setProgress:0];
    }
    return cell;
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row) {
        return YES;
    } else {
        return NO;
    }
}


-(NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Cancel";
}


-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)  tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.appDelegate.uploads removeObjectAtIndex:indexPath.row];
    [self.appDelegate.uploads writeToFile:[NSString stringWithFormat:@"%@/Uploads.plist",[CLCacheManager getUploadsFolderPath]] atomically:YES];
    [tableDataArray removeObjectAtIndex:indexPath.row];
    [dataTableView beginUpdates];
    [dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationBottom];
    [dataTableView endUpdates];
}


@end
