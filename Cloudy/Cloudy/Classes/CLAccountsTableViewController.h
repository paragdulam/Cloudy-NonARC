//
//  CLAccountsTableViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseTableViewController.h"
#import "CLAccountCell.h"

@interface CLAccountsTableViewController : CLBaseTableViewController<DBSessionDelegate,LiveAuthDelegate,LiveOperationDelegate>
-(void)authenticationDoneForSession:(DBSession *)session;
-(void)  authenticationCancelledManuallyForSession:(DBSession *) session;
@end
