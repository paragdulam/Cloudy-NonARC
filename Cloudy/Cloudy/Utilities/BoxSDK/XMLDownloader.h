//
//  XMLDownloader.h
//  FreseniusResearch
//
//  Created by Parag Dulam on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol XMLDownloaderDelagate ;

@interface XMLDownloader : NSObject {
	NSMutableData *downloadedData;
	id downloadDelagate;
    int tag;
}

@property (nonatomic,assign) id downloadDelagate;
@property (nonatomic,assign) int tag;

-(id) initWithURL:(NSURL *) url;
-(id) initWithURLString:(NSString *) urlString;
-(void) cancelDownload;


@end


@protocol XMLDownloaderDelagate

-(void) downloader:(XMLDownloader *)dloader didFailWithError:(NSError *)error;
-(void) downloader:(XMLDownloader *)dloader didReceiveData:(NSData *)data;
-(void) downloader:(XMLDownloader *)dloader didReceiveResponse:(NSURLResponse *)response ;
-(void) downloaderDidFinishLoading:(XMLDownloader *)dloader WithData:(NSData *) data;


@end
