//
//  AppDelegate.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDMenuController.h"
#import "LiveConnectClient.h"
#import <DropboxSDK/DropboxSDK.h>

@class CLFileBrowserTableViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    DDMenuController *menuController;
    CLFileBrowserTableViewController *rootFileBrowserViewController;
    DBSession *dropboxSession;
    LiveConnectClient *liveClient;
    BOOL liveClientFlag;
}

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) DDMenuController *menuController;
@property (assign, nonatomic) CLFileBrowserTableViewController *rootFileBrowserViewController;
@property (retain, nonatomic) DBSession *dropboxSession;
@property (retain, nonatomic) LiveConnectClient *liveClient;
@property (assign, nonatomic) BOOL liveClientFlag;

-(void) initialSetup;


@end
