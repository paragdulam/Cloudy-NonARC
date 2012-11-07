//
//  CLFileBrowserTableViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseTableViewController.h"

@interface CLFileBrowserTableViewController : CLBaseTableViewController
{
    BOOL hidesFiles;
    NSArray *excludedFolders;
}


@property(nonatomic,assign) BOOL hidesFiles;
@property(nonatomic,retain) NSArray *excludedFolders;


@end
