//
//  CLDictionaryConvertor.m
//  Cloudy
//
//  Created by Parag Dulam on 23/10/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLDictionaryConvertor.h"

@implementation CLDictionaryConvertor


+(NSDictionary *) dictionaryFromQuota:(DBQuota *) quota
{
    NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];
    [retVal setObject:[NSNumber numberWithLongLong:quota.normalConsumedBytes] forKey:@"normalConsumedBytes"];
    [retVal setObject:[NSNumber numberWithLongLong:quota.sharedConsumedBytes] forKey:@"sharedConsumedBytes"];
    [retVal setObject:[NSNumber numberWithLongLong:quota.totalConsumedBytes] forKey:@"totalConsumedBytes"];
    [retVal setObject:[NSNumber numberWithLongLong:quota.totalBytes] forKey:@"totalBytes"];
    return [retVal autorelease];
}


+(NSDictionary *) dictionaryFromAccountInfo:(id) info
{
    NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];
    if ([info isKindOfClass:[DBAccountInfo class]]) {
        DBAccountInfo *accountInfo = (DBAccountInfo *)info;
        if (accountInfo) {
            [retVal setObject:accountInfo.country forKey:@"country"];
            [retVal setObject:accountInfo.displayName forKey:@"displayName"];
            [retVal setObject:[CLDictionaryConvertor dictionaryFromQuota:accountInfo.quota
] forKey:@"quota"];
            [retVal setObject:accountInfo.userId forKey:@"userId"];
            [retVal setObject:accountInfo.referralLink forKey:@"referralLink"];
            [retVal setObject:[NSNumber numberWithInt:DROPBOX] forKey:ACCOUNT_TYPE];
        }
    } else if([info isKindOfClass:[NSDictionary class]]) {
        NSDictionary *skyDriveResult = (NSDictionary *)info;
        if (skyDriveResult) {
            [retVal setObject:[skyDriveResult objectForKey:@"first_name"] forKey:@"first_name"];
            [retVal setObject:[skyDriveResult objectForKey:@"gender"] forKey:@"gender"];
            [retVal setObject:[skyDriveResult objectForKey:@"id"] forKey:@"id"];
            [retVal setObject:[skyDriveResult objectForKey:@"last_name"] forKey:@"last_name"];
            [retVal setObject:[skyDriveResult objectForKey:@"link"] forKey:@"link"];
            [retVal setObject:[skyDriveResult objectForKey:@"locale"] forKey:@"locale"];
            [retVal setObject:[skyDriveResult objectForKey:@"name"] forKey:@"displayName"]; //changed here
            [retVal setObject:[skyDriveResult objectForKey:@"updated_time"] forKey:@"updated_time"];
            [retVal setObject:[NSNumber numberWithInt:SKYDRIVE] forKey:ACCOUNT_TYPE];
        }
    }
    return [retVal autorelease];
}



+(NSDictionary *) dictionaryFromMetadata:(DBMetadata *) metadata
{
    NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];
    
    [retVal setObject:[NSNumber numberWithBool:metadata.thumbnailExists]
               forKey:@"thumbnailExists"];
    [retVal setObject:[NSNumber numberWithLongLong:metadata.totalBytes]
               forKey:@"totalBytes"];
    if (metadata.lastModifiedDate) {
        [retVal setObject:metadata.lastModifiedDate forKey:@"lastModifiedDate"];
    }
    if (metadata.clientMtime) {
        [retVal setObject:metadata.clientMtime forKey:@"clientMtime"];
    }
    [retVal setObject:metadata.path forKey:@"path"];
    [retVal setObject:[NSNumber numberWithBool:metadata.isDirectory] forKey:@"isDirectory"];
    if (metadata.hash) {
        [retVal setObject:metadata.hash forKey:@"hash"];
    }
    [retVal setObject:metadata.humanReadableSize forKey:@"humanReadableSize"];
    [retVal setObject:metadata.root forKey:@"root"];
    if (metadata.icon) {
        [retVal setObject:metadata.icon forKey:@"icon"];
    }
    if (metadata.rev) {
        [retVal setObject:metadata.rev forKey:@"rev"];
    }
    [retVal setObject:[NSNumber numberWithBool:metadata.isDeleted] forKey:@"isDeleted"];
    [retVal setObject:metadata.filename forKey:@"filename"];

    if ([metadata.contents count]) {
        NSMutableArray *contents = [[NSMutableArray alloc] init];
        [retVal setObject:contents forKey:@"contents"];
        [contents release]; //released By Parag
        for (DBMetadata *data in metadata.contents) {
            [contents addObject:[CLDictionaryConvertor dictionaryFromMetadata:data]];
        }
    } 
    return [retVal autorelease];
}


@end
