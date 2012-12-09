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

@interface CLMediaPlayerViewController : CLDetailBaseViewController
{
    NSURL *mediaURL;
}

@property(nonatomic,retain) NSURL *mediaURL;
-(id) initWithMediaURL:(NSURL *) url;

@end
