//
//  CacheManager.m
//  Cloudy
//
//  Created by Parag Dulam on 28/02/13.
//  Copyright (c) 2013 Parag Dulam. All rights reserved.
//

#import "CacheManager.h"

@interface CacheManager ()
{
    NSMutableString *skyDrivePathTracker;
}
+(void) setObjectInDictionary:(NSMutableDictionary *) toDict
                       forKey:(NSString *) aKey
               FromDictionary:(NSDictionary *) fromDict
                       forKey:(NSString *) key;

+(NSString *) getAccountsPlistPath;
-(void) readCache;


@end


@implementation CacheManager
@synthesize accounts;
@synthesize metadata;



#pragma mark - Init Methods


+(CacheManager *) sharedManager
{
    static CacheManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


-(id) init
{
    if (self = [super init]) {
        //read Account Dictionary and Metadata
        [self readCache];
    }
    return self;
}



-(void) dealloc
{
    accounts = nil;
    metadata = nil;
    
    [skyDrivePathTracker release];
    skyDrivePathTracker = nil;
    
    [super dealloc];
}

#pragma mark - Read Methods

-(void) readCache
{
    NSString *accountsPlistPath = [CacheManager getAccountsPlistPath];
    NSMutableArray *oldAccounts = [[NSMutableArray alloc] initWithContentsOfFile:accountsPlistPath];
    accounts = [[NSMutableArray alloc] init];
    [accounts addObjectsFromArray:oldAccounts];
    [oldAccounts release];
    
    NSString *metadataPlistPath = [CacheManager getMetadataPlistPath];
    metadata = [[NSMutableDictionary alloc] initWithDictionary:[self mutableDeepCopy:[NSDictionary dictionaryWithContentsOfFile:metadataPlistPath]]];
}

#pragma mark - Write Methods


-(BOOL) writeObject:(id) object atPath:(NSString *) path
{
    __block BOOL retVal = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:object
                                                                       format:kCFPropertyListXMLFormat_v1_0
                                                             errorDescription:nil];
        NSError *error = nil;
        [plistData writeToFile:path
                       options:NSDataWritingAtomic
                         error:&error];
        retVal = error ? NO : YES;
    });
    return retVal;
}




#pragma mark - Data Compatibility Methods


-(NSString *) skyDriveRootPath
{
    return [[self accountOfType:SKYDRIVE] objectForKey:ID];
}

//only for SkyDrive

-(NSString *) pathForMetadata:(NSDictionary *) mdata
             inParentMetadata:(NSDictionary *) parent
{
    if ([[mdata objectForKey:FILE_PARENT_ID] isEqualToString:@"null"] || ![mdata objectForKey:FILE_PARENT_ID]) {
        return ROOT_DROPBOX_PATH;
    } else {
        if (!parent) {
            return [NSString stringWithFormat:@"/%@",[mdata objectForKey:FILE_NAME]];//
        } else {
            if ([[mdata objectForKey:FILE_PARENT_ID] isEqualToString:[parent objectForKey:FILE_ID]]) {
                NSString *path = [parent objectForKey:FILE_PATH];
                if ([path isEqualToString:ROOT_DROPBOX_PATH]) {
                    return [NSString stringWithFormat:@"/%@",[mdata objectForKey:FILE_NAME]];
                } else {
                    return [NSString stringWithFormat:@"%@/%@",path,[mdata objectForKey:FILE_NAME]];
                }
            } else {
                for (NSDictionary *data in [parent objectForKey:FILE_CONTENTS]) {
                    NSString *path = [self pathForMetadata:mdata
                                          inParentMetadata:data];
                    if (path) {
                        return path;
                    } /*else {
                        NSLog(@"Path NIL for %@ in %@",[mdata objectForKey:FILE_NAME],[data objectForKey:FILE_PATH]);
                    }*/ //debugging
                }
            }
        }
        return nil;
    }
}

/*
-(NSString *) pathForMetadata:(NSDictionary *) mdata
             inParentMetadata:(NSDictionary *) parent
{
    if (![mdata objectForKey:FILE_PARENT_ID] || [[mdata objectForKey:FILE_PARENT_ID] isEqualToString:@"null"] || !parent) {
        return ROOT_DROPBOX_PATH;
    } else {
        if ([[mdata objectForKey:FILE_PARENT_ID] isEqualToString:[parent objectForKey:FILE_ID]]) {
            NSString *path = [parent objectForKey:FILE_PATH];
            if ([path isEqualToString:ROOT_DROPBOX_PATH]) {
                return [NSString stringWithFormat:@"%@%@",path,[mdata objectForKey:FILE_NAME]];
            } else {
                return [NSString stringWithFormat:@"%@/%@",path,[mdata objectForKey:FILE_NAME]];
            }
        } else {
            NSArray *contents = [parent objectForKey:FILE_CONTENTS];
            for (NSDictionary *data in contents) {
                NSString *path = [self pathForMetadata:mdata
                                      inParentMetadata:data];
                if (path) {
                    return path;
                }
            }
        }
    }
    return nil;
}
 */

+(void) setObjectInDictionary:(NSMutableDictionary *) toDict
                       forKey:(NSString *) aKey
               FromDictionary:(NSDictionary *) fromDict
                       forKey:(NSString *) key
{
    id object = [fromDict objectForKey:key];
    if (object) {
        [toDict setObject:object forKey:aKey];
    }
}

-(NSDictionary *) processDictionary:(NSDictionary *) dictionary
                        ForDataType:(TYPE_DATA) dataType
                         AndViewType:(VIEW_TYPE) type
{
    NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];
    
    [retVal setObject:[NSNumber numberWithInt:type] forKey:ACCOUNT_TYPE];
    //setting the account type for both
    
    switch (type) {
        case DROPBOX:
             //make OverClouded Compatible
        {
            switch (dataType) {
                case DATA_ACCOUNT:
                {
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:NAME
                                         FromDictionary:dictionary
                                                 forKey:@"display_name"];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:ID
                                         FromDictionary:dictionary
                                                 forKey:@"uid"];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:EMAIL
                                         FromDictionary:dictionary
                                                 forKey:@"email"];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:TOTAL
                                         FromDictionary:[dictionary objectForKey:@"quota_info"]
                                                 forKey:@"quota"];

                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:USED
                                         FromDictionary:[dictionary objectForKey:@"quota_info"]
                                                 forKey:@"normal"];
                    //UserName not Provided
                }
                    break;
                case DATA_METADATA:
                {
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:FILE_THUMBNAIL
                                         FromDictionary:dictionary
                                                 forKey:@"thumb_exists"];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:FILE_SIZE
                                         FromDictionary:dictionary
                                                 forKey:@"size"];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:FILE_LAST_UPDATED_TIME
                                         FromDictionary:dictionary
                                                 forKey:@"modified"];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:FILE_PATH
                                         FromDictionary:dictionary
                                                 forKey:@"path"];
                    NSArray *components = [CacheManager trimmedArrayForPath:[dictionary objectForKey:@"path"]];
                    NSString *fileName = [components lastObject];
                    if (![fileName length]) {
                        fileName = ROOT_DROPBOX_PATH;
                    }
                    [retVal setObject:fileName forKey:FILE_NAME];
                    
                    NSMutableString *parentPath = [[NSMutableString alloc] init];
                    int cnt = [components count] - 1;
                    if (cnt > 0) {
                        for (int i = 0; i < cnt; i++) {
                            NSString *component = [components objectAtIndex:i];
                            [parentPath appendFormat:@"/%@",component];
                        }
                    } else {
                        if (![fileName isEqualToString:ROOT_DROPBOX_PATH]) {
                            [parentPath appendFormat:ROOT_DROPBOX_PATH];
                        }
                    }
                    
                    [retVal setObject:parentPath forKey:FILE_PARENT_ID];
                    [parentPath release];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:FILE_CONTENTS
                                         FromDictionary:dictionary
                                                 forKey:@"contents"];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:FILE_HASH
                                         FromDictionary:dictionary
                                                 forKey:@"hash"];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:FILE_TYPE
                                         FromDictionary:dictionary
                                                 forKey:@"is_dir"];
                    
                    NSArray *contents = [dictionary objectForKey:@"contents"];
                    if ([contents count]) {
                        NSMutableArray *mutableContents = [[NSMutableArray alloc] init];
                        for (NSDictionary *mdata in contents) {
                            [mutableContents addObject:[self processDictionary:mdata ForDataType:DATA_METADATA AndViewType:DROPBOX]];
                        }
                        [retVal setObject:mutableContents forKey:FILE_CONTENTS];
                        [mutableContents release];
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SKYDRIVE:
            //make OverClouded Compatible
        {
            switch (dataType) {
                case DATA_ACCOUNT:
                {
                    NSString *displayName = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"first_name"],[dictionary objectForKey:@"last_name"]];
                    [retVal setObject:displayName forKey:NAME];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:ID
                                         FromDictionary:dictionary
                                                 forKey:@"id"];

                    //Email and UserName not Provided

                }
                    break;
                case DATA_METADATA:
                {
                    NSArray *contents = [dictionary objectForKey:@"data"];
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
                    contents = [contents sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                    [sortDescriptor release];
                    if ([contents count]) {
                        NSMutableArray *mutableContents = [[NSMutableArray alloc] initWithCapacity:0];
                        for (NSDictionary *mdata in contents) {
                            NSDictionary *metdata = [self processDictionary:mdata ForDataType:DATA_METADATA AndViewType:SKYDRIVE];
                            [mutableContents addObject:metdata];
                        }
                        [retVal setObject:mutableContents forKey:FILE_CONTENTS];
                        [mutableContents release];
                    } else {
                        [CacheManager setObjectInDictionary:retVal
                                                     forKey:FILE_ID
                                             FromDictionary:dictionary
                                                     forKey:@"id"];
                        
                        [CacheManager setObjectInDictionary:retVal
                                                     forKey:FILE_NAME
                                             FromDictionary:dictionary
                                                     forKey:@"name"];
                        
                        [CacheManager setObjectInDictionary:retVal
                                                     forKey:FILE_SIZE
                                             FromDictionary:dictionary
                                                     forKey:@"size"];
                        
                        if ([[dictionary objectForKey:@"type"] isEqualToString:@"folder"] || [[dictionary objectForKey:@"type"] isEqualToString:@"album"]) {
                            [retVal setObject:[NSNumber numberWithInt:1]
                                       forKey:FILE_TYPE];
                        } else {
                            [retVal setObject:[NSNumber numberWithInt:0]
                                       forKey:FILE_TYPE];
                        }
                        
                        [CacheManager setObjectInDictionary:retVal
                                                     forKey:FILE_PARENT_ID
                                             FromDictionary:dictionary
                                                     forKey:@"parent_id"];

                        
                        [CacheManager setObjectInDictionary:retVal
                                                     forKey:FILE_LAST_UPDATED_TIME
                                             FromDictionary:dictionary
                                                     forKey:@"updated_time"];
                        
                        NSArray *images = [dictionary objectForKey:@"images"];
                        if ([images count]) {
                            [retVal setObject:[NSNumber numberWithBool:YES]
                                       forKey:FILE_THUMBNAIL];
                            [retVal setObject:[[images objectAtIndex:2] objectForKey:@"source"]
                                       forKey:FILE_THUMBNAIL_URL];
                        }
                        
                        NSString *path = [self pathForMetadata:retVal
                                    inParentMetadata:[self rootDictionary:type]];
                        if (path) {
                            [retVal setObject:path
                                       forKey:FILE_PATH];
                        } else {
                            [retVal setObject:@"Error Getting Path"
                                       forKey:FILE_PATH];
                        }
                    }
                }
                    break;
                case DATA_QUOTA:
                {
                    double used = [[dictionary objectForKey:@"quota"] doubleValue] - [[dictionary objectForKey:@"available"] doubleValue];
                    
                    [retVal setObject:[NSNumber numberWithFloat:used]
                               forKey:USED];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:TOTAL
                                         FromDictionary:dictionary
                                                 forKey:@"quota"];

                }
                    break;
                default:
                    break;
            }
        }
            break;
        case BOX:
            //make OverClouded Compatible
            break;
        default:
            break;
    }
    return [retVal autorelease];
}





#pragma mark - Metadata Manipulation Methods




+(NSArray *) trimmedArrayForPath:(NSString *) path
{
    NSArray *components = [path componentsSeparatedByString:@"/"];
    __block NSMutableArray *trimmedComponents = [NSMutableArray array];
    [components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *component = (NSString *)obj;
        if ([component length]) {
            [trimmedComponents addObject:component];
        }
    }];
    return trimmedComponents;
}

-(NSMutableDictionary *)rootDictionary:(VIEW_TYPE) type
{
    NSString *typeString = [NSString stringWithFormat:@"%d",type];
    return [metadata objectForKey:typeString];
}



-(BOOL) isMetadataPresentForViewType:(VIEW_TYPE) type
{
    return [metadata objectForKey:[NSString stringWithFormat:@"%d",type]] ? YES : NO;
}

-(int) isMetadata:(NSDictionary *) metdata
   PresentInArray:(NSArray *) contents
{
    __block int index = INVALID_INDEX;
    NSString *comparisonKey = [self comparisonKeyForViewType:[[metdata objectForKey:ACCOUNT_TYPE] intValue]];
    [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *data = (NSDictionary *)obj;
        if ([[data objectForKey:comparisonKey] isEqualToString:[metdata objectForKey:comparisonKey]]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

-(NSMutableDictionary *) mutableDeepCopy:(NSDictionary *) object
{
    NSMutableDictionary *retVal = nil;
    if (object) {
        NSMutableDictionary *mutableFileStructure = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)object, kCFPropertyListMutableContainers);
        retVal = [NSMutableDictionary dictionaryWithDictionary:mutableFileStructure];
        CFRelease(mutableFileStructure);
    }
    return retVal;
}




-(BOOL) updateMetadata:(NSDictionary *) metadataDict
        WithUpdateType:(DATA_MANIPULATION_TYPE) type
      inParentMetadata:(NSMutableDictionary *) root
{
    if (!root || [[metadataDict objectForKey:FILE_PATH] isEqualToString:ROOT_DROPBOX_PATH]) {
        return [self updateMetadata:metadataDict];
    } else {
        NSMutableArray *contents = [root objectForKey:FILE_CONTENTS];
        int index = [self isMetadata:metadataDict
                      PresentInArray:contents];
        if (index != INVALID_INDEX) {
            switch (type) {
                case UPDATE_DATA:
                    [contents replaceObjectAtIndex:index withObject:metadataDict];
                    break;
                case INSERT_DATA:
                    [contents insertObject:metadataDict atIndex:index];
                    break;
                case DELETE_DATA:
                    [contents removeObjectAtIndex:index];
                    break;
                default:
                    break;
            }
            return [self updateMetadata];
        } else {
            for (NSMutableDictionary *data in contents) {
                BOOL retVal = [self updateMetadata:metadataDict
                                    WithUpdateType:type
                                  inParentMetadata:data];
                if (retVal) {
                    return retVal;
                }
            }
        }
    }
    return NO;
}


-(NSString *) comparisonKeyForViewType:(VIEW_TYPE) type
{
    switch (type) {
        case DROPBOX:
            return FILE_PATH;
            break;
        case SKYDRIVE:
            return FILE_ID;
            break;
        default:
            break;
    }
    return nil;
}

-(NSDictionary *) metadata:(NSDictionary *) metaData
                    AtPath:(NSString *) path
                InViewType:(VIEW_TYPE) type
{
    NSString *comparisonKey = [self comparisonKeyForViewType:type];
    if ([[metaData objectForKey:comparisonKey] isEqualToString:path]) {
        return metaData;
    } else {
        for (NSDictionary *data in [metaData objectForKey:FILE_CONTENTS]) {
            NSDictionary *retVal = [self metadata:data
                                           AtPath:path
                                       InViewType:type];
            if (retVal) {
                return retVal;
            }
        }
    }
    return nil;
}


//dictionary with account_type = {metadata dictionary}
-(BOOL) updateMetadata:(NSDictionary *) metadataDict
{
    NSString *key = [[metadataDict objectForKey:ACCOUNT_TYPE] stringValue];
    [metadata setObject:metadataDict forKey:key];
    [self updateMetadata];
    return YES;
}

-(BOOL) deleteMetadata:(VIEW_TYPE) type
{
    [metadata removeObjectForKey:[NSString stringWithFormat:@"%d",type]];
    [self updateMetadata];
    return YES;
}

-(BOOL) updateMetadata
{
    NSString *path = [NSString stringWithFormat:@"%@/%@",[CacheManager getSystemDirectoryPath:NSLibraryDirectory],METADATA_PLIST];
    return [self writeObject:metadata
                      atPath:path];
}


#pragma mark - Account Manipulation Methods


-(BOOL) updateAccounts
{
    NSString *path = [NSString stringWithFormat:@"%@/%@",[CacheManager getSystemDirectoryPath:NSLibraryDirectory],ACCOUNTS_PLIST];
    return [self writeObject:accounts
                      atPath:path];
}

-(int) isAccountPresent:(NSDictionary *) account
{
    __block int index = INVALID_INDEX;
    [accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *objDict = (NSDictionary *)obj;
        if ([[objDict objectForKey:ID] isEqual:[account objectForKey:ID]]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

-(BOOL) addAccount:(NSDictionary *) account
{
    if ([self isAccountPresent:account] == INVALID_INDEX) {
        [accounts addObject:account];
        [self updateAccounts];
        return YES;
    }
    return NO;
}


-(BOOL) deleteAccount:(NSDictionary *) account
{
    int index = [accounts indexOfObject:account];
    return [self deleteAccountAtIndex:index];
}


-(BOOL) deleteAccountAtIndex:(int) index
{
    [accounts removeObjectAtIndex:index];
    if (![accounts count]) {
        [CacheManager deleteFileAtPath:[CacheManager getAccountsPlistPath]];
    }
    [self updateAccounts];
    return YES;
}

-(BOOL) updateAccount:(NSDictionary *)account
{
    int index = [self isAccountPresent:account];
    if (index != INVALID_INDEX) {
        [accounts replaceObjectAtIndex:index withObject:account];
        [self updateAccounts];
        return YES;
    }
    return NO;
}

-(NSDictionary *)accountOfType:(VIEW_TYPE) type
{
    __block NSDictionary *retVal = nil;
    [accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *objDict = (NSDictionary *)obj;
        if ([[objDict objectForKey:ACCOUNT_TYPE] intValue] == type) {
            retVal = objDict;
            *stop = YES;
        }
    }];
    return retVal;
}


#pragma mark - File Folder Operations

+(BOOL) deleteFileAtPath:(NSString *) path
{
    return [[NSFileManager defaultManager] removeItemAtPath:path
                                                      error:nil];
}

#pragma mark - Folder Paths


+(NSString *) getMetadataPlistPath
{
    return [NSString stringWithFormat:@"%@/%@",[CacheManager getSystemDirectoryPath:NSLibraryDirectory],METADATA_PLIST];
}


+(NSString *) getAccountsPlistPath
{
    return [NSString stringWithFormat:@"%@/%@",[CacheManager getSystemDirectoryPath:NSLibraryDirectory],ACCOUNTS_PLIST];
}


+(BOOL) fileExistsAtPath:(NSString *) path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


+(NSString *) getTemporaryDirectory
{
    return NSTemporaryDirectory();
}


+(NSString *) getSystemDirectoryPath:(NSSearchPathDirectory) directoryType
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directoryType,     NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}



@end
