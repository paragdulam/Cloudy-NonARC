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
-(BOOL) addAccount:(NSDictionary *) account;
-(BOOL) updateAccount:(NSDictionary *)account;
-(BOOL) deleteAccount:(NSDictionary *) account;
-(BOOL) deleteAccountAtIndex:(int) index;
-(NSDictionary *)accountOfType:(VIEW_TYPE) type;
+(NSDictionary *) processDictionary:(NSDictionary *) dictionary
                        ForDataType:(TYPE_DATA) dataType
                        AndViewType:(VIEW_TYPE) type;


@end
