//
//  CLFileBrowserTableViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseTableViewController.h"
#import "CLBrowserBarItem.h"
#import "CLFileBrowserCell.h"



@interface CLFileBrowserBaseTableViewController : CLBaseTableViewController<LiveOperationDelegate,CLBrowserBarItemDelegate,UITextFieldDelegate,LiveDownloadOperationDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    NSString *path;
    VIEW_TYPE viewType;
    
    UIToolbar *fileOperationsToolbar;
    CLBrowserBarItem *barItem;
    UIButton *createFolderButton;
    
    NSMutableArray *liveOperations;
    NSMutableArray *toolBarItems;
    
    FILE_FOLDER_OPERATION currentFileOperation;
    NSMutableDictionary *currentFileData;
}

@property(nonatomic,retain) NSString *path;
@property(nonatomic,assign) VIEW_TYPE viewType;
@property (nonatomic,retain) NSMutableDictionary *currentFileData;



-(id) initWithTableViewStyle:(UITableViewStyle)style
                   WherePath:(NSString *) pathString
              WithinViewType:(VIEW_TYPE) type;

-(void) loadFilesForPath:(NSString *) pathString
          WithInViewType:(VIEW_TYPE) type;

-(void) startAnimating;
-(void) stopAnimating;
-(void) readCacheUpdateView;
-(void) updateModel:(NSArray *) model;
-(void) performFileOperation:(LiveOperation *) operation;

-(CLFileBrowserCell *) cellAtIndexPath:(NSIndexPath *)indexPath;
-(void) startAnimatingCellAtIndexPath:(NSIndexPath *) indexPath;
-(void) stopAnimatingCellAtIndexPath:(NSIndexPath *) indexPath;



@end
