//
//  CLUploadProgressButton.h
//  Cloudy
//
//  Created by Parag Dulam on 18/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#define PERCENTAGE 0.8f

@interface CLUploadProgressButton : UIButton

-(void) setProgress:(float) value;
-(float) progress;
-(void) setProgressViewHidden:(BOOL) hide;
-(BOOL) progressViewHidden;


@end
