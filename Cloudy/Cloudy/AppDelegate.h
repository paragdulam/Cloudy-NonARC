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
#import "CLUploadProgressButton.h"
#import "CLConstants.h"


@class CLFileBrowserTableViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,DBRestClientDelegate,LiveUploadOperationDelegate>
{
    DDMenuController *menuController;
    CLFileBrowserTableViewController *rootFileBrowserViewController;
    DBSession *dropboxSession;
    LiveConnectClient *liveClient;
    BOOL liveClientFlag;
    CLUploadProgressButton *uploadProgressButton;
}

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) DDMenuController *menuController;
@property (assign, nonatomic) CLFileBrowserTableViewController *rootFileBrowserViewController;
@property (retain, nonatomic) DBSession *dropboxSession;
@property (retain, nonatomic) LiveConnectClient *liveClient;
@property (assign, nonatomic) BOOL liveClientFlag;
@property (nonatomic,retain) CLUploadProgressButton *uploadProgressButton;


-(void) initialSetup;
-(void) updateUploads:(NSArray *)info
         FolderAtPath:(NSString *)path
          ForViewType:(VIEW_TYPE) type;
+(void) showError:(NSError *) error
      alertOnView:(UIView *) view;

@end
