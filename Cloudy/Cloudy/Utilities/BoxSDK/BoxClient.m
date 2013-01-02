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
}

@property (nonatomic,retain) NSString *apiKey;



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
    }
    return self;
}

-(void) getAuthenticationTicket
{
    //GET https://www.box.com/api/1.0/rest?action=get_ticket&api_key=ux3ux0v2rl17tppcfry7ddnuj57h3bl8

    NSString *urlString = [NSString stringWithFormat:@"https://www.box.com/api/1.0/rest?action=get_ticket&api_key=%@",apiKey];
    XMLDownloader *xmlDownloader = [[[XMLDownloader alloc] initWithURLString:urlString] autorelease];
    [xmlDownloader setDownloadDelagate:self];
    [xmlDownloader setTag:GET_AUTHENTICATION_TICKET];
}



-(void) login
{
    [self getAuthenticationTicket];
}




-(void) getAccountInfo
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.box.net/api/1.0/rest?action=get_account_info&api_key=%@&auth_token=%@",apiKey,[self auth_token]];
    XMLDownloader *xmlDownloader = [[[XMLDownloader alloc] initWithURLString:urlString] autorelease];
    [xmlDownloader setDownloadDelagate:self];
    [xmlDownloader setTag:GET_ACCOUNT_INFO];
}

-(void) dealloc
{
    delegate = nil;
    
    [apiKey release];
    apiKey = nil;
    
    [super dealloc];
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
        default:
            break;
    }
}

-(void) downloader:(XMLDownloader *)dloader
    didReceiveData:(NSData *)data
{
    
}

-(void) downloader:(XMLDownloader *)dloader
didReceiveResponse:(NSURLResponse *)response
{
    
}

-(void) downloaderDidFinishLoading:(XMLDownloader *)dloader
                          WithData:(NSData *) data
{
    switch (dloader.tag) {
        case GET_AUTHENTICATION_TICKET:
        {
            NSError *error = nil;
            NSDictionary *dataDictionary = [XMLReader dictionaryForXMLData:data error:&error];
            NSString *authTicket = [[[dataDictionary objectForKey:@"response"]  objectForKey:@"ticket"] objectForKey:@"text"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://m.box.com/api/1.0/auth/%@", authTicket]]];
        }
            break;
        case GET_ACCOUNT_INFO:
        {
            NSError *error = nil;
            NSDictionary *dataDictionary = [XMLReader dictionaryForXMLData:data error:&error];
            if ([delegate respondsToSelector:@selector(boxClient:didLoadAccountInfo:)]) {
                [delegate boxClient:self didLoadAccountInfo:dataDictionary];
            }
        }
            break;
        default:
            break;
    }
}


@end
