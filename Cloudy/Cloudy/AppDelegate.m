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
@synthesize uploadProgressButton;
@synthesize restClient;
@synthesize uploads;

- (void)dealloc
{
    [restClient release];
    restClient = nil;
    
    [uploadProgressButton release];
    uploadProgressButton = nil;
    
    [uploads release];
    uploads = nil;
    
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
                path = ROOT_DROPBOX_PATH;
                break;
            case SKYDRIVE:
                path = ROOT_SKYDRIVE_PATH;
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

    CLUploadProgressButton *aButton = [[CLUploadProgressButton alloc] init];
    aButton.frame = CGRectMake(0, 0, 30, 30);
    self.uploadProgressButton = aButton;
    self.uploadProgressButton.hidden = YES;
    [aButton release];
    
    NSMutableArray *anArray = [[NSMutableArray alloc] init];
    self.uploads = anArray;
    [anArray release];
    
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
    
    DBRestClient *aRestClient = [[DBRestClient alloc] initWithSession:dropboxSession];
    self.restClient = aRestClient;
    restClient.delegate = self;
    [aRestClient release];
    
    dropboxSession.delegate = callbackViewController;
    
    self.liveClientFlag = YES;
    LiveConnectClient *aClient = [[LiveConnectClient alloc] initWithClientId:SKYDRIVE_CLIENT_ID delegate:callbackViewController userState:@"InitialAllocation"];
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
    [self updateUploads:nil
           FolderAtPath:nil
            ForViewType:INFINITY];
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


-(void) animationDidFinish:(id)obj
{
    NSLog(@"obj %@",obj);
}

+(void) showError:(NSError *) error
      alertOnView:(UIView *) view
{
    UILabel *alert = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200,200)];
    alert.layer.cornerRadius = 5.f;
    alert.numberOfLines = 0;
    alert.lineBreakMode = UILineBreakModeWordWrap;
    alert.backgroundColor = [UIColor blackColor];
    alert.userInteractionEnabled = NO;
    alert.textColor = [UIColor whiteColor];
    NSString *errorString = [error.userInfo objectForKey:@"error"];
    if (![errorString length]) {
        errorString = [error localizedDescription];
    }
    [alert setText:errorString];
    alert.center = view.center;
    [view addSubview:alert];
    [alert release];
    
    [UIView beginAnimations:@"FADE" context:alert];
    [UIView setAnimationDuration:5.f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidFinish:)];
    alert.alpha = 0.f;
    [UIView commitAnimations];
}

#pragma mark - Uploads Operation

-(void) updateUploadsFolder:(NSArray *) info
                   destPath:(NSString *) path
                ForViewType:(VIEW_TYPE) type
{
    NSString *uploadsFolderPath = [CLCacheManager getUploadsFolderPath];
    NSArray *cachedUploads = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/Uploads.plist",uploadsFolderPath]];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (id obj in cachedUploads) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [images addObject:obj];
        }
    }
    
    for (ALAsset *asset in info) {
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        UIImage *assetImage = [UIImage imageWithCGImage:[assetRepresentation CGImageWithOptions:nil]];
        UIImage *assetThumnail = [UIImage imageWithCGImage:[asset thumbnail]];
        NSString *fileName = [assetRepresentation filename];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CLCacheManager getUploadsFolderPath],fileName];
        NSData *imageData = UIImagePNGRepresentation(assetImage);
        NSData *imageThumbnailData = UIImagePNGRepresentation(assetThumnail);
        if (![CLCacheManager fileExistsAtPath:filePath]) {
            [imageData writeToFile:filePath atomically:YES];
        }
        NSDictionary *imageToBeUploaded = [NSDictionary dictionaryWithObjectsAndKeys:fileName,@"NAME",filePath,@"FROMPATH",path,@"TOPATH",imageThumbnailData,@"THUMBNAIL",[NSNumber numberWithInt:type],@"TYPE", nil];
        if (![images containsObject:imageToBeUploaded]) {
            [images addObject:imageToBeUploaded];
        }
    }
    [images removeObjectsInArray:uploads];
    [uploads addObjectsFromArray:images];
    [uploads writeToFile:[NSString stringWithFormat:@"%@/Uploads.plist",uploadsFolderPath] atomically:YES];
    [images release];
}


-(void) uploadDictionary:(NSDictionary *) data
{
    NSString *fileName = [data objectForKey:@"NAME"];
    NSString *toPath = [data objectForKey:@"TOPATH"];
    NSString *fromPath = [data objectForKey:@"FROMPATH"];
    NSData *thumbNailData = [data objectForKey:@"THUMBNAIL"];
    VIEW_TYPE type = [[data objectForKey:@"TYPE"] integerValue];
    
    switch (type) {
        case DROPBOX:
        {
            [self.restClient uploadFile:fileName
                                 toPath:toPath
                          withParentRev:nil
                               fromPath:fromPath];
        }
            break;
        case SKYDRIVE:
        {
            UIImage *image = [UIImage imageWithContentsOfFile:fromPath];
            [self.liveClient uploadToPath:toPath
                                 fileName:fileName
                                     data:UIImagePNGRepresentation(image)
                                 delegate:self];
        }
            break;
            
            
        default:
            break;
    }
    uploadProgressButton.hidden = NO;
    [uploadProgressButton setImage:[UIImage imageWithData:thumbNailData]
                          forState:UIControlStateNormal];
    
}

-(void) updateUploads:(NSArray *)info
         FolderAtPath:(NSString *)path
          ForViewType:(VIEW_TYPE) type
{
    [self updateUploadsFolder:info destPath:path ForViewType:type];
    if ([uploads count]) {
        NSDictionary *imageToBeUploaded = [uploads objectAtIndex:0];
        [self uploadDictionary:imageToBeUploaded];
    }
}

-(void) uploadCompletionHandler:(BOOL) remove
{
    NSDictionary *uploadedImage = [uploads objectAtIndex:0];
    [CLCacheManager deleteFileAtPath:[uploadedImage objectForKey:@"FROMPATH"]];
    [uploads removeObjectAtIndex:0];
    [uploads writeToFile:[NSString stringWithFormat:@"%@/Uploads.plist",[CLCacheManager getUploadsFolderPath]] atomically:YES];
    if ([uploads count]) {
        NSDictionary *imageToBeUploaded = [uploads objectAtIndex:0];
        [self uploadDictionary:imageToBeUploaded];
    } else {
        [CLCacheManager deleteFileAtPath:[NSString stringWithFormat:@"%@/Uploads.plist",[CLCacheManager getUploadsFolderPath]]];
        uploadProgressButton.hidden = YES;
    }
}


#pragma mark - LiveUploadOperationDelegate

- (void) liveUploadOperationProgressed:(LiveOperationProgress *)progress
                             operation:(LiveOperation *)operation
{
    [uploadProgressButton setProgress:progress.progressPercentage];
}

-(void) liveOperationSucceeded:(LiveOperation *)operation
{
    [self uploadCompletionHandler:YES];
    [CLCacheManager insertFile:operation.result
        whereTraversingPointer:nil
               inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:SKYDRIVE]
                   ForViewType:SKYDRIVE];
}


-(void) liveOperationFailed:(NSError *)error operation:(LiveOperation *)operation
{
    [self uploadCompletionHandler:YES];
}


#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient*)client
      uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath
          metadata:(DBMetadata*)metadata
{
    [self uploadCompletionHandler:YES];
    NSDictionary *metadataDictionary = [CLDictionaryConvertor dictionaryFromMetadata:metadata];
    [CLCacheManager insertFile:metadataDictionary
        whereTraversingPointer:nil
               inFileStructure:[CLCacheManager makeFileStructureMutableForViewType:SKYDRIVE]
                   ForViewType:SKYDRIVE];
}

- (void)restClient:(DBRestClient*)client
    uploadProgress:(CGFloat)progress
           forFile:(NSString*)destPath
              from:(NSString*)srcPath
{
    [uploadProgressButton setProgress:progress];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    [self uploadCompletionHandler:YES];
}

@end
