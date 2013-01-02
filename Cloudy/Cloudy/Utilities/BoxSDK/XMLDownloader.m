//
//  XMLDownloader.m
//  FreseniusResearch
//
//  Created by Parag Dulam on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLDownloader.h"


@implementation XMLDownloader

@synthesize downloadDelagate;

-(id) initWithURL:(NSURL *) url
{
	if (self = [super init]) {
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] 
																	  delegate:self];
	
		[connection autorelease];
		downloadedData = [[NSMutableData data] retain];
		[downloadedData setLength:0];
	}
	return self;
}

-(id) initWithURLString:(NSString *) urlString
{
	return [self initWithURL:[NSURL URLWithString:urlString]];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if ([downloadDelagate respondsToSelector:@selector(connection:didFailWithError:)]) {
		[downloadDelagate connection:connection 
					didFailWithError:error];
	}
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[downloadedData appendData:data];
	if ([downloadDelagate respondsToSelector:@selector(connection:didReceiveData:)]) {
		[downloadDelagate connection:connection 
					  didReceiveData:downloadedData];
	}
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	if ([downloadDelagate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
		[downloadDelagate connection:connection 
				  didReceiveResponse:response];
	}
}


-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([downloadDelagate respondsToSelector:@selector(connectionDidFinishLoading:WithData:)]) {
		[downloadDelagate connectionDidFinishLoading:connection WithData:downloadedData];
	}
}


-(void) dealloc
{
	downloadDelagate = nil;
	[downloadedData release];
	[super dealloc];
}

@end
