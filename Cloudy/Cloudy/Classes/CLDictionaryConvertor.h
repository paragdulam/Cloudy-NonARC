//
//  CLDictionaryConvertor.h
//  Cloudy
//
//  Created by Parag Dulam on 23/10/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>
#import "CLConstants.h"

@interface CLDictionaryConvertor : NSObject

+(NSDictionary *) dictionaryFromAccountInfo:(id) info;
+(NSDictionary *) dictionaryFromMetadata:(DBMetadata *) metadata;

@end
