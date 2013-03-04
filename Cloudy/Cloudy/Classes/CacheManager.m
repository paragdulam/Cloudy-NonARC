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
        NSString *accountsPlistPath = [CacheManager getAccountsPlistPath];
        NSMutableArray *oldAccounts = [[NSMutableArray alloc] initWithContentsOfFile:accountsPlistPath];
        accounts = [[NSMutableArray alloc] init];
        [accounts addObjectsFromArray:oldAccounts];
        [oldAccounts release];
    }
    return self;
}



-(void) dealloc
{
    accounts = nil;
    metadata = nil;
    [super dealloc];
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
        NSLog(@"error %@",error);
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
