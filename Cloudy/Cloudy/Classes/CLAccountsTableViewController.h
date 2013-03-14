//
//  CLAccountsTableViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseTableViewController.h"
#import "CLAccountCell.h"
#import "CLCloudPlatformsListViewController.h"

@interface CLAccountsTableViewController : CLBaseTableViewController<DBSessionDelegate,LiveAuthDelegate,LiveOperationDelegate,CLCloudPlatformListViewControllerDelegate>
{
    UIButton *editButton;
}


-(void)authenticationDoneForSession:(DBSession *)session;
-(void)  authenticationCancelledManuallyForSession:(DBSession *) session;
-(void) authenticationDone;
-(void) getSkyDriveQuotaForUserAccount:(NSDictionary *) account;

@end

