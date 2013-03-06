//
//  CacheManager.m
//  Cloudy
//
//  Created by Parag Dulam on 28/02/13.
//  Copyright (c) 2013 Parag Dulam. All rights reserved.
//

#import "CacheManager.h"

@interface CacheManager ()

+(void) setObjectInDictionary:(NSMutableDictionary *) toDict
                       forKey:(NSString *) aKey
               FromDictionary:(NSDictionary *) fromDict
                       forKey:(NSString *) key;

+(NSDictionary *) processDictionary:(NSDictionary *) dictionary
                        ForDataType:(TYPE_DATA) dataType
                        AndViewType:(VIEW_TYPE) type;

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
    NSDictionary *cachedMetadata = [[NSDictionary alloc] initWithContentsOfFile:metadataPlistPath];
    metadata = [[NSMutableDictionary alloc] init];
    [metadata addEntriesFromDictionary:cachedMetadata];
    [cachedMetadata release];
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


+(void) setObjectInDictionary:(NSMutableDictionary *) toDict
                       forKey:(NSString *) aKey
               FromDictionary:(NSDictionary *) fromDict
                       forKey:(NSString *) key
{
    id object = [fromDict objectForKey:key];
    if (object) {
        [toDict setObject:object forKey:aKey];
    } else {
        NSLog(@"object not available for %@",key);
    }
}

+(NSDictionary *) processDictionary:(NSDictionary *) dictionary
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
                    NSString *fileName = [[[dictionary objectForKey:@"path"] componentsSeparatedByString:@"/"] lastObject];
                    if (![fileName length]) {
                        fileName = ROOT_DROPBOX_PATH;
                    }
                    [retVal setObject:fileName forKey:FILE_NAME];
                    
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
                        for (NSDictionary *metadata in contents) {
                            [mutableContents addObject:[CacheManager processDictionary:metadata ForDataType:DATA_METADATA AndViewType:DROPBOX]];
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
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:FILE_ID
                                         FromDictionary:dictionary
                                                 forKey:@"id"];

                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:FILE_NAME
                                         FromDictionary:dictionary
                                                 forKey:@"name"];
                    
                    if ([[dictionary objectForKey:NAME] isEqualToString:@"SkyDrive"]) {
                        [retVal setObject:@"/" forKey:FILE_PATH];
                    }
                    
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
                                                 forKey:FILE_LAST_UPDATED_TIME
                                         FromDictionary:dictionary
                                                 forKey:@"updated_time"];
                    
                    NSArray *images = [dictionary objectForKey:@"images"];
                    if ([images count]) {
                        [retVal setObject:[[images objectAtIndex:2] objectForKey:@"source"]
                                   forKey:FILE_THUMBNAIL_URL];
                    }
                    
                    
                    NSArray *contents = [dictionary objectForKey:@"data"];
                    if ([contents count]) {
                        NSMutableArray *mutableContents = [[NSMutableArray alloc] initWithCapacity:0];
                        for (NSDictionary *metadata in [dictionary objectForKey:@"data"]) {
                            [mutableContents addObject:[CacheManager processDictionary:metadata ForDataType:DATA_METADATA AndViewType:SKYDRIVE]];
                        }
                        [retVal setObject:mutableContents forKey:FILE_CONTENTS];
                        [mutableContents release];
                    }
                    
                    //have to work on path calculation
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

/*
-(NSDictionary *) metadataAtPath:(NSString *) path
                      InViewType:(VIEW_TYPE) type
{
    NSNumber *typeNumber = [NSNumber numberWithInt:type];
    NSDictionary *rootDictionary = [metadata objectForKey:[typeNumber stringValue]];
    if ([path isEqualToString:ROOT_DROPBOX_PATH]) {
        return rootDictionary;
    } else {
        NSArray *contents = [rootDictionary objectForKey:FILE_CONTENTS];
        for (NSDictionary *content in contents) {
            NSDictionary *result = [self metadataAtPath:[content objectForKey:FILE_PATH]
                                             InViewType:type];
            if (result) {
                return result;
            }
        }
    }
    return nil;
}
*/


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

-(NSDictionary *) metadataAtPath:(NSString *) path
                      InViewType:(VIEW_TYPE) type
{
    NSArray *components = [CacheManager trimmedArrayForPath:path];
    NSDictionary *metadataDict = [metadata objectForKey:[NSString stringWithFormat:@"%d",type]];
    NSDictionary *retVal = metadataDict;
    
    for (NSString *component in components) {
        NSArray *contents = [metadataDict objectForKey:FILE_CONTENTS];
        for (NSDictionary *data in contents) {
            if ([[data objectForKey:FILE_NAME] isEqualToString:component]) {
                return retVal;
            }
        }
    }
    
//    [components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSString *component = (NSString *)obj;
//        NSArray *contents = [metadataDict objectForKey:FILE_CONTENTS];
//        [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            NSDictionary *data = (NSDictionary *)obj;
//            if ([[data objectForKey:FILE_NAME] isEqualToString:component]) {
//                retVal = data;
//                *stop = YES;
//            }
//        }];
//        *stop = YES;
//    }];
    
    return retVal;
}


//dictionary with account_type = {metadata dictionary}
-(BOOL) updateMetadata:(NSDictionary *) metadataDict
{
    VIEW_TYPE type = [[metadataDict objectForKey:ACCOUNT_TYPE] intValue];
    NSNumber *typeNumber = [NSNumber numberWithInt:type];
    NSDictionary *oldMetadata = [metadata objectForKey:[typeNumber stringValue]];
    NSString *path = [metadataDict objectForKey:FILE_PATH];
    NSDictionary *dict = [self metadataAtPath:path
                                   InViewType:type];
    if (!dict) {
        [metadata setObject:metadataDict forKey:[typeNumber stringValue]];
    } else {
        
    }
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



+(NSString *) getSystemDirectoryPath:(NSSearchPathDirectory) directoryType
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directoryType,     NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}



@end
