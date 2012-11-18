//
//  CLUploadProgressButton.h
//  Cloudy
//
//  Created by Parag Dulam on 18/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>
#define PERCENTAGE 0.9f

@interface CLUploadProgressButton : UIButton

-(void) setProgress:(float) value;
-(float) progress;


@end
