//
//  CLFileBrowserTableViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseTableViewController.h"
#import "CLBrowserBarItem.h"

@interface CLFileBrowserBaseTableViewController : CLBaseTableViewController<LiveOperationDelegate>
{
    NSString *path;
    VIEW_TYPE viewType;
    UIToolbar *fileOperationsToolbar;
}

@property(nonatomic,retain) NSString *path;
@property(nonatomic,assign) VIEW_TYPE viewType;


-(id) initWithTableViewStyle:(UITableViewStyle)style WherePath:(NSString *) pathString WithinViewType:(VIEW_TYPE) type;

-(void) loadFilesForPath:(NSString *) pathString WithInViewType:(VIEW_TYPE) type;
-(void) startAnimating;
-(void) stopAnimating;

@end
