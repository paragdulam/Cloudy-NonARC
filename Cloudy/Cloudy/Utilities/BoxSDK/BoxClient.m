//
//  BoxClient.m
//  Cloudy
//
//  Created by Parag Dulam on 02/01/13.
//  Copyright (c) 2013 Parag Dulam. All rights reserved.
//

#import "BoxClient.h"


@interface BoxClient ()
{
    NSString *apiKey;
    NSMutableArray *requests;
}

@property (nonatomic,retain) NSString *apiKey;

-(void) downloadFromURLString:(NSString *) urlString
                      WithTag:(REQUEST_TYPE) type;


@end

@implementation BoxClient
@synthesize delegate;
@synthesize apiKey;

-(NSString *) auth_token
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:BOX_CREDENTIALS] objectForKey:AUTH_TOKEN];
}

-(id) initWithAPIKey:(NSString *) aKey
{
    if (self = [super init]) {
        self.apiKey = aKey;
        requests = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void) getAuthenticationTicket
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.box.com/api/1.0/rest?action=get_ticket&api_key=%@",apiKey];
    [self downloadFromURLString:urlString
                        WithTag:GET_AUTHENTICATION_TICKET];
}



-(void) login
{
    [self getAuthenticationTicket];
}


-(void) logout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:BOX_CREDENTIALS];
    NSString *urlString = [NSString stringWithFormat:@"https://www.box.net/api/1.0/rest?action=logout&api_key=%@&auth_token=%@",apiKey,[self auth_token]];
    [self downloadFromURLString:urlString
                        WithTag:LOGOUT];
}

-(void) getAccountInfo
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.box.net/api/1.0/rest?action=get_account_info&api_key=%@&auth_token=%@",apiKey,[self auth_token]];
    [self downloadFromURLString:urlString
                        WithTag:GET_ACCOUNT_INFO];
}


-(void) loadMetadataForFolderId:(NSString *) folderId
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.box.net/api/1.0/rest?action=get_account_tree&api_key=%@&auth_token=%@&folder_id=%@&params[]=onelevel&params[]=nozip&params[]=show_path_ids",apiKey,[self auth_token],folderId];
    [self downloadFromURLString:urlString WithTag:GET_METADATA];
}

-(void) loadDataFromURLString:(NSString *) urlString
                  forUserData:(id) uData
{
    [self downloadFromURLString:urlString
                   withUserData:uData
                        WithTag:THUMBNAIL_DOWNLOAD];
}


-(void) loadDataForFileId:(NSString *) fileId forUserData:(id) uData
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.box.net/api/1.0/download/%@/%@",[self auth_token],fileId];
    [self downloadFromURLString:urlString
                   withUserData:uData
                        WithTag:DATA_DOWNLOAD];
}


-(void) createFolderWithInFolderId:(NSString *) folderId WithName:(NSString *) name
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.box.net/api/1.0/rest?action=create_folder&api_key=%@&auth_token=%@&parent_id=%@&name=%@&share=1",apiKey,[self auth_token],folderId,name];
    [self downloadFromURLString:urlString
                        WithTag:CREATE_FOLDER];
}

-(void) dealloc
{
    delegate = nil;
    
    for (XMLDownloader *downloader in requests) {
        [downloader cancelDownload];
    }
    
    [requests release];
    requests = nil;
    
    [apiKey release];
    apiKey = nil;
    
    [super dealloc];
}


#pragma mark - Private Methods

-(NSString *) baseURLString
{
    return @"https://www.box.net/api/1.0/rest?action=";
}


-(void) downloadFromURLString:(NSString *) urlString
                 withUserData:(id) uData
                      WithTag:(REQUEST_TYPE) type
{
    XMLDownloader *xmlDownloader = [[XMLDownloader alloc] initWithURLString:urlString];
    [xmlDownloader setUserData:uData];
    [xmlDownloader setDownloadDelagate:self];
    [xmlDownloader setTag:type];
    [requests addObject:xmlDownloader];
    [xmlDownloader release];
}


-(void) downloadFromURLString:(NSString *) urlString
                      WithTag:(REQUEST_TYPE) type
{
    XMLDownloader *xmlDownloader = [[XMLDownloader alloc] initWithURLString:urlString];
    [xmlDownloader setDownloadDelagate:self];
    [xmlDownloader setTag:type];
    [requests addObject:xmlDownloader];
    [xmlDownloader release];
}


#pragma mark - XMLDownloaderDelegate


-(void) downloader:(XMLDownloader *)dloader
  didFailWithError:(NSError *)error
{
    switch (dloader.tag) {
        case GET_AUTHENTICATION_TICKET:
            if ([delegate respondsToSelector:@selector(boxClient:didFailInRecievingAuthenticationTicketWithError:)]) {
                [delegate boxClient:self didFailInRecievingAuthenticationTicketWithError:error];
            }
            break;
        case GET_ACCOUNT_INFO:
        {
            if ([delegate respondsToSelector:@selector(boxClient:didLoadFailedAccountInfoWithError:)]) {
                [delegate boxClient:self didLoadFailedAccountInfoWithError:error];
            }
        }
            break;
        case LOGOUT:
        {
            if ([delegate respondsToSelector:@selector(boxClient:DidLogOutFailWithError:)]) {
                [delegate boxClient:self
             DidLogOutFailWithError:error];
            }
        }
            break;
        case GET_METADATA:
        {
            if ([delegate respondsToSelector:@selector(boxClient:loadMetadataDidFailWithError:)]) {
                [delegate boxClient:self loadMetadataDidFailWithError:error];
            }
        }
            break;
        case THUMBNAIL_DOWNLOAD:
        case DATA_DOWNLOAD:
        {
            if ([delegate respondsToSelector:@selector(boxClient:loadDataFailedWithError:withUserData::)]) {
                [delegate boxClient:self
            loadDataFailedWithError:error
                       withUserData:dloader.userData];
            }
        }
            break;
        case CREATE_FOLDER:
        {
            if ([delegate respondsToSelector:@selector(boxClient:createFolderDidFailWithError:)]) {
                [delegate boxClient:self createFolderDidFailWithError:error];
            }
        }
            break;
        default:
            break;
    }
}

-(void) downloader:(XMLDownloader *)dloader
    didReceiveData:(NSData *)data
{
    switch (dloader.tag) {
        case DATA_DOWNLOAD:
            if ([delegate respondsToSelector:@selector(boxClient:loadDataProgress:withUserData:)]) {
                [delegate boxClient:self loadDataProgress:(float)[data length]/(float)dloader.bytesToBeDownloaded withUserData:dloader.userData];
            }
            break;
        default:
            break;
    }
}

-(void) downloader:(XMLDownloader *)dloader
didReceiveResponse:(NSURLResponse *)response
{
    [dloader setBytesToBeDownloaded:[response expectedContentLength] ];
}

-(void) downloaderDidFinishLoading:(XMLDownloader *)dloader
                          WithData:(NSData *) data
{
    switch (dloader.tag) {
        case GET_AUTHENTICATION_TICKET:
        {
            NSError *error = nil;
            NSDictionary *dataDictionary = [XMLReader dictionaryForXMLData:data
                                                                     error:&error];
            NSString *authTicket = [[[dataDictionary objectForKey:@"response"]  objectForKey:@"ticket"] objectForKey:@"text"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://m.box.com/api/1.0/auth/%@", authTicket]]];
        }
            break;
        case GET_ACCOUNT_INFO:
        {
            NSError *error = nil;
            NSDictionary *dataDictionary = [XMLReader dictionaryForXMLData:data error:&error];
            if ([delegate respondsToSelector:@selector(boxClient:didLoadAccountInfo:)]) {
                [delegate boxClient:self
                 didLoadAccountInfo:dataDictionary];
            }
        }
            break;
        case LOGOUT:
        {
            NSError *error = nil;
            NSDictionary *dataDictionary = [XMLReader dictionaryForXMLData:data error:&error];
            if ([delegate respondsToSelector:@selector(boxClient:DidLogOutWithData:)]) {
                [delegate boxClient:self
                  DidLogOutWithData:dataDictionary];
            }
        }
            break;
        case GET_METADATA:
        {
            NSError *error = nil;
            NSDictionary *dataDictionary = [XMLReader dictionaryForXMLData:data error:&error];
            if ([delegate respondsToSelector:@selector(boxClient:loadedMetadata:)]) {
                [delegate boxClient:self
                     loadedMetadata:dataDictionary];
            }
        }
            break;
        case THUMBNAIL_DOWNLOAD:
        case DATA_DOWNLOAD:
        {
            if ([delegate respondsToSelector:@selector(boxClient:loadedData:withUserData:)]) {
                [delegate boxClient:self
                         loadedData:data
                       withUserData:dloader.userData];
            }
        }
            break;
        case CREATE_FOLDER:
        {
            NSError *error = nil;
            NSDictionary *dataDictionary = [XMLReader dictionaryForXMLData:data error:&error];
            if ([delegate respondsToSelector:@selector(boxClient:createdFolder:)]) {
                [delegate boxClient:self createdFolder:dataDictionary];
            }
        }
            break;
        default:
            break;
    }
}


@end