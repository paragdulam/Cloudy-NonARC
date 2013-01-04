//
//  XMLDownloader.m
//  FreseniusResearch
//
//  Created by Parag Dulam on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLDownloader.h"


@interface XMLDownloader ()
{
    NSURLConnection *urlConnection;
}

@property (nonatomic,retain) NSURLConnection *urlConnection;

@end

@implementation XMLDownloader

@synthesize downloadDelagate;
@synthesize urlConnection;
@synthesize tag;

-(id) initWithURL:(NSURL *) url
{
	if (self = [super init]) {
		NSURLConnection *aConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url]
																	  delegate:self];
        self.urlConnection = aConnection;
		[aConnection autorelease];
		downloadedData = [[NSMutableData data] retain];
		[downloadedData setLength:0];
	}
	return self;
}

-(id) initWithURLString:(NSString *) urlString
{
	return [self initWithURL:[NSURL URLWithString:urlString]];
}


-(id) initWithRequest:(NSURLRequest *)request
{
    if (self = [super init]) {
		NSURLConnection *aConnection = [[NSURLConnection alloc] initWithRequest:request
                                                                       delegate:self];
        self.urlConnection = aConnection;
		[aConnection autorelease];
		downloadedData = [[NSMutableData data] retain];
		[downloadedData setLength:0];
	}
	return self;
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if ([downloadDelagate respondsToSelector:@selector(downloader:didFailWithError:)]) {
		[downloadDelagate downloader:self
                    didFailWithError:error];
	}
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[downloadedData appendData:data];
	if ([downloadDelagate respondsToSelector:@selector(downloader:didReceiveData:)]) {
		[downloadDelagate downloader:self
                      didReceiveData:downloadedData];
	}
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	if ([downloadDelagate respondsToSelector:@selector(downloader:didReceiveResponse:)]) {
		[downloadDelagate downloader:self
                  didReceiveResponse:response];
	}
}


-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([downloadDelagate respondsToSelector:@selector(downloaderDidFinishLoading:WithData:)]) {
		[downloadDelagate downloaderDidFinishLoading:self
                                            WithData:downloadedData];
	}
}


-(void) cancelDownload
{
    [urlConnection cancel];
}

-(void) dealloc
{
	downloadDelagate = nil;
	[downloadedData release];
    downloadedData = nil;
    
    [urlConnection release];
    urlConnection = nil;
	[super dealloc];
}

@end
