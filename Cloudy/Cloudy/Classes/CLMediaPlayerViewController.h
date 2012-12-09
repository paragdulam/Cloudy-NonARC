//
//  CLMediaPlayerViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 08/12/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "CLDetailBaseViewController.h"

@interface CLMediaPlayerViewController : CLDetailBaseViewController<DBRestClientDelegate>
{
    NSDictionary *video;
    VIEW_TYPE viewType;
    NSURL *mediaURL;
}

@property(nonatomic,retain) NSURL *mediaURL;
@property(nonatomic,retain) NSDictionary *video;
@property(nonatomic,assign) VIEW_TYPE viewType;

-(id) initWithMediaURL:(NSURL *) url;
-(id) initWithVideoFile:(NSDictionary *) videoFile
         withInViewType:(VIEW_TYPE) type;


@end
