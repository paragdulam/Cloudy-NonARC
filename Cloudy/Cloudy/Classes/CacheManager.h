//
//  CacheManager.h
//  Cloudy
//
//  Created by Parag Dulam on 28/02/13.
//  Copyright (c) 2013 Parag Dulam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLConstants.h"



@interface CacheManager : NSObject
{
    NSMutableArray *accounts;
    NSMutableDictionary *metadata;
}

@property (nonatomic,assign) NSMutableArray *accounts;
@property (nonatomic,assign) NSMutableDictionary *metadata;


+(CacheManager *) sharedManager;
-(int) isAccountPresent:(NSDictionary *) account;
-(BOOL) addAccount:(NSDictionary *) account;
-(BOOL) updateAccount:(NSDictionary *)account;
-(BOOL) deleteAccount:(NSDictionary *) account;
-(BOOL) deleteAccountAtIndex:(int) index;
-(NSDictionary *)accountOfType:(VIEW_TYPE) type;
-(NSDictionary *) processDictionary:(NSDictionary *) dictionary
                        ForDataType:(TYPE_DATA) dataType
                        AndViewType:(VIEW_TYPE) type;

-(BOOL) updateMetadata:(NSDictionary *) metadataDict
        WithUpdateType:(DATA_MANIPULATION_TYPE) type
      inParentMetadata:(NSMutableDictionary *) root;
-(NSDictionary *) metadata:(NSDictionary *) metaData
                    AtPath:(NSString *) path
                InViewType:(VIEW_TYPE) type;
-(BOOL) deleteMetadata:(VIEW_TYPE) type;
-(NSMutableDictionary *)rootDictionary:(VIEW_TYPE) type;
-(NSMutableDictionary *) mutableDeepCopy:(NSDictionary *) object;
-(BOOL) isMetadataPresentForViewType:(VIEW_TYPE) type;
+(NSString *) getTemporaryDirectory;
+(BOOL) fileExistsAtPath:(NSString *) path;
-(NSString *) skyDriveRootPath;
+(void) initialSetup;

-(NSString *) getThumbnailPath:(VIEW_TYPE) type;
-(NSString *) getFavouritesPath:(VIEW_TYPE) type;
-(NSString *) getTempPath:(VIEW_TYPE) type;
+(void) createFoldersForString:(NSString *) root;
+(BOOL) deleteFileAtPath:(NSString *) path;
+(void) loggedOut:(VIEW_TYPE) type;
+(void) deleteAllContentsOfFolderAtPath:(NSString *) path;
+(NSString *) getUploadsFolderPath;

@end
