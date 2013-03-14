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
#import "BoxClient.h"



@class CLFileBrowserTableViewController;
@class CLUploadsTableViewController;
@class CLPathSelectionViewController;
@class CLAccountsTableViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,DBRestClientDelegate,LiveUploadOperationDelegate,BoxClientDelegate>
{
    DDMenuController *menuController;
    CLFileBrowserTableViewController *rootFileBrowserViewController;
    DBSession *dropboxSession;
    LiveConnectClient *liveClient;
    BOOL liveClientFlag;
    CLUploadProgressButton *uploadProgressButton;
    NSMutableArray *uploads;
    DBRestClient *restClient;
    BoxClient *boxClient;
    CLUploadsTableViewController *uploadsViewController;
    UIBackgroundTaskIdentifier backgroundTaskIdentifier;
    LiveOperation *currentUploadOperation;
    CLAccountsTableViewController *callbackViewController;
}

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) DDMenuController *menuController;
@property (assign, nonatomic) CLAccountsTableViewController *callbackViewController;

@property (assign, nonatomic) CLFileBrowserTableViewController *rootFileBrowserViewController;
@property (retain, nonatomic) DBSession *dropboxSession;
@property (retain, nonatomic) LiveConnectClient *liveClient;
@property (assign, nonatomic) BOOL liveClientFlag;
@property (nonatomic,retain) CLUploadProgressButton *uploadProgressButton;
@property (nonatomic,retain) NSMutableArray *uploads;
@property (nonatomic,retain) DBRestClient *restClient;
@property (nonatomic,retain) BoxClient *boxClient;
@property (nonatomic,assign) CLUploadsTableViewController *uploadsViewController;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (retain, nonatomic) LiveOperation *currentUploadOperation;





-(void) initialSetup;
-(void) updateUploads:(NSArray *)info
         FolderAtPath:(NSString *)path
          ForViewType:(VIEW_TYPE) type;
+(void) showError:(NSError *) error
      alertOnView:(UIView *) view;
+(void) showMessage:(NSString *) message
          withColor:(UIColor *) color
        alertOnView:(UIView *) view;
-(void) removeUploads:(NSArray *) uploadsToBeRemoved ForViewType:(VIEW_TYPE) type;



@end
