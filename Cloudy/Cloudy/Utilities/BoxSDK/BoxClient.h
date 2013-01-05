//
//  BoxClient.h
//  Cloudy
//
//  Created by Parag Dulam on 02/01/13.
//  Copyright (c) 2013 Parag Dulam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLDownloader.h"
#import "XMLReader.h"
#import "CLConstants.h"

@protocol BoxClientDelegate;

typedef enum REQUEST_TYPE {
    GET_AUTHENTICATION_TICKET = 0,
    GET_ACCOUNT_INFO,
    LOGOUT,
    GET_METADATA,
    THUMBNAIL_DOWNLOAD,
    DATA_DOWNLOAD
} REQUEST_TYPE;


@interface BoxClient : NSObject<XMLDownloaderDelagate>
{
    id <BoxClientDelegate> delegate;
}

@property (nonatomic,assign) id <BoxClientDelegate> delegate;
-(id) initWithAPIKey:(NSString *) aKey;
-(void) login;
-(void) getAccountInfo;
-(NSString *) auth_token;
- (void) logout;
-(void) loadMetadataForFolderId:(NSString *) folderId;
-(void) loadDataFromURLString:(NSString *) urlString
                  forUserData:(id) uData;
-(void) loadDataForFileId:(NSString *) fileId
              forUserData:(id) uData;






@end


@protocol BoxClientDelegate<NSObject>

@optional
-(void) boxClient:(BoxClient *) client didRecieveAuthenticationTicket:(NSString *) ticket;
-(void) boxClient:(BoxClient *) client didFailInRecievingAuthenticationTicketWithError:(NSError *) error;

-(void) boxClient:(BoxClient *) client didLoadAccountInfo:(NSDictionary *) accountInfo;
-(void) boxClient:(BoxClient *) client didLoadFailedAccountInfoWithError:(NSError *) error;

-(void) boxClient:(BoxClient *)client DidLogOutWithData:(NSDictionary *)data;
-(void) boxClient:(BoxClient *)client DidLogOutFailWithError:(NSError *) error;


-(void) boxClient:(BoxClient *)client loadedMetadata:(NSDictionary *) metaData;
-(void) boxClient:(BoxClient *)client loadMetadataDidFailWithError:(NSError *) error;

-(void) boxClient:(BoxClient *)client loadedData:(NSData *) data withUserData:(id) uData;
-(void) boxClient:(BoxClient *)client loadDataProgress:(float) progress withUserData:(id) uData;

-(void) boxClient:(BoxClient *)client loadDataFailedWithError:(NSError *) error withUserData:(id) uData;




@end