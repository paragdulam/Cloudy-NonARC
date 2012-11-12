//
//  AppDelegate.m
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "AppDelegate.h"
#import "CLAccountsTableViewController.h"
#import "CLFileBrowserTableViewController.h"


@interface AppDelegate()
{
    CLAccountsTableViewController *callbackViewController;
}
@end

@implementation AppDelegate
@synthesize menuController;
@synthesize dropboxSession;
@synthesize liveClient;
@synthesize rootFileBrowserViewController;
@synthesize liveClientFlag;

- (void)dealloc
{
    rootFileBrowserViewController = nil;
    
    [dropboxSession release];
    dropboxSession = nil;
    
    [liveClient release];
    liveClient = nil;
    
    [menuController release];
    menuController = nil;
    
    [_window release];
    [super dealloc];
}


-(BOOL) application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([dropboxSession handleOpenURL:url]) {
        if ([dropboxSession isLinked]) {
            //auth Done
            if (![[[[url absoluteString] componentsSeparatedByString:@"/"] lastObject] isEqualToString:@"cancel"]) {
                [callbackViewController authenticationDoneForSession:dropboxSession];
                return YES;
            } else {
                [callbackViewController authenticationCancelledManuallyForSession:dropboxSession];
                return NO;
            }
        }
    }
    return NO;
}

-(void) initialSetup
{
    NSArray *accounts = [CLCacheManager accounts];
    NSString *path = nil;
    NSDictionary *accountData = nil;
    if ([accounts count]) {
        accountData = [accounts objectAtIndex:0];
        switch ([[accountData objectForKey:ACCOUNT_TYPE] integerValue]) {
            case DROPBOX:
                path = @"/";
                break;
            case SKYDRIVE:
                path = [NSString stringWithFormat:@"%@/files",[accountData objectForKey:@"id"]];
                break;
    
            default:
                break;
        }
    }
    [self.rootFileBrowserViewController loadFilesForPath:path
                                          WithInViewType:[[accountData objectForKey:ACCOUNT_TYPE] integerValue]];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [CLCacheManager initialSetup];

    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    DDMenuController *aController = [[DDMenuController alloc] init];
    self.menuController = aController;
    [aController release];
    
    CLAccountsTableViewController *accountsTableViewController = [[CLAccountsTableViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    UINavigationController *leftNavController = [[UINavigationController alloc] initWithRootViewController:accountsTableViewController];
    callbackViewController = accountsTableViewController;
    [accountsTableViewController release];
    
    DBSession *aSession = [[DBSession alloc] initWithAppKey:DROPBOX_APP_KEY
                                                  appSecret:DROPBOX_APP_SECRET_KEY
                                                       root:kDBRootDropbox];
    self.dropboxSession = aSession;
    [aSession release];
    [DBSession setSharedSession:dropboxSession];
    dropboxSession.delegate = callbackViewController;
    
    liveClientFlag = YES;
    LiveConnectClient *aClient = [[LiveConnectClient alloc] initWithClientId:SKYDRIVE_CLIENT_ID delegate:callbackViewController];
    self.liveClient = aClient;
    [aClient release];
    
    [menuController setLeftViewController:leftNavController];
    [leftNavController release];
    
    CLFileBrowserTableViewController *fileBrowserViewController = [[CLFileBrowserTableViewController alloc] initWithTableViewStyle:UITableViewStylePlain];
    self.rootFileBrowserViewController = fileBrowserViewController;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fileBrowserViewController];
    [fileBrowserViewController release];
    
    [menuController setRootViewController:navController];
    [navController release];
    
    [self.window setRootViewController:menuController];
    [self initialSetup];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
