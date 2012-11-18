//
//  CLUploadProgressButton.m
//  Cloudy
//
//  Created by Parag Dulam on 18/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLUploadProgressButton.h"

@interface CLUploadProgressButton()
{
    UIProgressView *progressBarView;
}
@end

@implementation CLUploadProgressButton




-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    float originPercentage = (1 - PERCENTAGE)/2;
    CGRect progressBarRect = frame;
    progressBarRect.origin.x =  frame.size.width * originPercentage;
    progressBarRect.size.width = frame.size.width * PERCENTAGE;
    progressBarRect.size.height = 10.f;
    progressBarRect.origin.y =  frame.size.height * originPercentage;
    
    progressBarView.frame = progressBarRect;
    
    self.imageView.frame = self.bounds;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

-(id )init{
    if (self = [super init]) {
        progressBarView = [[UIProgressView alloc] init];
        [self addSubview:progressBarView];
        [progressBarView release];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(void) setProgress:(float) value
{
    progressBarView.progress = value;
}

-(float) progress
{
    return progressBarView.progress;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
