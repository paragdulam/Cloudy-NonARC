//
//  CLUploadsTableViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 29/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseTableViewController.h"
#import "CLBrowserBarItem.h"

@interface CLUploadsTableViewController : CLBaseTableViewController<CLBrowserBarItemDelegate>


-(void) removeFirstRowWithAnimation;
-(void) updateFirstCellWhereProgress:(float) progress;


@end
