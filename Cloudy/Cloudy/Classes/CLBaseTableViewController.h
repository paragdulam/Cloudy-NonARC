//
//  CLBaseTableViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseViewController.h"

@interface CLBaseTableViewController : CLBaseViewController<UITableViewDataSource,UITableViewDelegate,DBRestClientDelegate>
{
    NSMutableArray *tableDataArray;
    UITableView *dataTableView;
    UITableViewStyle tableViewStyle;
    DBRestClient *restClient;
}

@property(nonatomic,assign) UITableViewStyle tableViewStyle;
@property(nonatomic,retain) DBRestClient *restClient;


-(id) initWithTableViewStyle:(UITableViewStyle) style;
-(void) updateView;

@end
