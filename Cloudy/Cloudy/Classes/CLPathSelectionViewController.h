//
//  CLPathSelectionViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLFileBrowserBaseTableViewController.h"

@protocol CLPathSelectionViewControllerDelegate;

@interface CLPathSelectionViewController : CLFileBrowserBaseTableViewController
{
    NSArray *excludedFolders;
    id <CLPathSelectionViewControllerDelegate> delegate;
}

@property(nonatomic,retain) NSArray *excludedFolders;
@property(nonatomic,assign) id <CLPathSelectionViewControllerDelegate> delegate;

-(id) initWithTableViewStyle:(UITableViewStyle)style WherePath:(NSString *) pathString WithinViewType:(VIEW_TYPE) type WhereExcludedFolders:(NSArray *) folders;


@end


@protocol CLPathSelectionViewControllerDelegate<NSObject>
-(void) pathDidSelect:(NSString *) pathString ForViewController:(CLPathSelectionViewController *) viewController;
@end


