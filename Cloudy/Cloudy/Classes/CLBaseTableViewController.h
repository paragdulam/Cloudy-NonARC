//
//  CLBaseTableViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseViewController.h"
#import "AppDelegate.h"
#import "BoxClient.h"

@interface CLBaseTableViewController : CLBaseViewController<UITableViewDataSource,UITableViewDelegate,DBRestClientDelegate,BoxClientDelegate>
{
    NSMutableArray *tableDataArray;
    UITableView *dataTableView;
    UITableViewStyle tableViewStyle;
    DBRestClient *restClient;
    BoxClient *boxClient;
}

@property(nonatomic,assign) UITableViewStyle tableViewStyle;
@property(nonatomic,retain) DBRestClient *restClient;
@property(nonatomic,retain) BoxClient *boxClient;



-(id) initWithTableViewStyle:(UITableViewStyle) style;
-(void) updateView;

@end
