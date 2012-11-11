//
//  CLFileBrowserTableViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseTableViewController.h"
#import "CLBrowserBarItem.h"

@interface CLFileBrowserTableViewController : CLBaseTableViewController<CLBrowserBarItemDelegate,LiveOperationDelegate>
{
    BOOL hidesFiles;
    NSArray *excludedFolders;
    NSString *path;
    VIEW_TYPE viewType;
}


@property(nonatomic,assign) BOOL hidesFiles;
@property(nonatomic,retain) NSArray *excludedFolders;
@property(nonatomic,retain) NSString *path;
@property(nonatomic,assign) VIEW_TYPE viewType;


-(id) initWithTableViewStyle:(UITableViewStyle)style WhereHidesFiles:(BOOL) aBool andExcludedFolders:(NSArray *) folders;


-(id) initWithTableViewStyle:(UITableViewStyle)style WhereHidesFiles:(BOOL) aBool andExcludedFolders:(NSArray *) folders andPath:(NSString *) pString ForViewType:(VIEW_TYPE) type;

-(void) loadFilesForPath:(NSString *) pathString WithInViewType:(VIEW_TYPE) type;

@end
