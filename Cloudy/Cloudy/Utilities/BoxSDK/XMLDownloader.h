//
//  XMLDownloader.h
//  FreseniusResearch
//
//  Created by Parag Dulam on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol XMLDownloaderDelagate

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response ;
-(void) connectionDidFinishLoading:(NSURLConnection *)connection WithData:(NSData *) data;

@end



@interface XMLDownloader : NSObject {
	NSMutableData *downloadedData;
	id downloadDelagate;
}

@property (nonatomic,assign) id downloadDelagate;

-(id) initWithURL:(NSURL *) url;
-(id) initWithURLString:(NSString *) urlString;

@end
