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
        retVal = [object writeToFile:path
                          atomically:YES];
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
                                                 forKey:@"displayName"];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:ID
                                         FromDictionary:dictionary
                                                 forKey:@"userId"];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:TOTAL
                                         FromDictionary:[dictionary objectForKey:@"quota"]
                                                 forKey:@"totalBytes"];

                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:USED
                                         FromDictionary:[dictionary objectForKey:@"quota"]
                                                 forKey:@"totalConsumedBytes"];
                    //Email,UserName not Provided
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
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:NAME
                                         FromDictionary:dictionary
                                                 forKey:@"displayName"];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:ID
                                         FromDictionary:dictionary
                                                 forKey:@"id"];
                    
                    double used = [[[dictionary objectForKey:@"quota"] objectForKey:@"quota"] doubleValue] - [[[dictionary objectForKey:@"quota"] objectForKey:@"available"] doubleValue];
                    
                    [retVal setObject:[NSNumber numberWithFloat:used]
                               forKey:USED];
                    
                    [CacheManager setObjectInDictionary:retVal
                                                 forKey:TOTAL
                                         FromDictionary:[dictionary objectForKey:@"quota"]
                                                 forKey:@"quota"];

                    //Email and UserName not Provided

                }
                    break;
                case DATA_METADATA:
                {
                    
                }
                    break;
                case DATA_QUOTA:
                {
                    
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
    __block int index = INFINITY;
    [accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *objDict = (NSDictionary *)obj;
        if ([[objDict objectForKey:ID] isEqualToString:[account objectForKey:ID]]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

-(BOOL) addAccount:(NSDictionary *) account
{
    NSDictionary *compatibleDictionary = [CacheManager processDictionary:account
                                                             ForDataType:DATA_ACCOUNT AndViewType:[[account objectForKey:ACCOUNT_TYPE] intValue]];
    if (![self isAccountPresent:compatibleDictionary]) {
        [accounts addObject:compatibleDictionary];
    } else {
        [self updateAccount:compatibleDictionary];
    }
    return [self updateAccounts];
}


-(BOOL) updateAccount:(NSDictionary *)account
{
    NSDictionary *compatibleDictionary = [CacheManager processDictionary:account
                                                             ForDataType:DATA_ACCOUNT AndViewType:[[account objectForKey:ACCOUNT_TYPE] intValue]];
    __block int index = INFINITY;
    [accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *objDict = (NSDictionary *)obj;
        if ([[objDict objectForKey:ID] isEqualToString:[compatibleDictionary objectForKey:ID]]) {
            index = idx;
            *stop = YES;
        }
    }];
    [accounts replaceObjectAtIndex:index withObject:compatibleDictionary];
    return [self updateAccounts];
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
