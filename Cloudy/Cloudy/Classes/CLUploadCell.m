//
//  CLUploadCell.m
//  Cloudy
//
//  Created by Parag Dulam on 29/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLUploadCell.h"

@interface CLUploadCell ()
{
    CLUploadProgressButton *progressButton;
}

@end

@implementation CLUploadCell

-(void) setProgress:(float)aFloat
{
    [progressButton setProgress:aFloat];
}

-(float) progress
{
    return progressButton.progress;
}

-(void) setButtonImage:(UIImage *)image
{
    [progressButton setImage:image forState:UIControlStateNormal];
}


-(UIImage *) buttonImage
{
    return progressButton.imageView.image;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        progressButton = [[CLUploadProgressButton alloc] init];
        [self addSubview:progressButton];
        [progressButton release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    float buttonHeight = 30;
    float progressButtonOriginX = (self.frame.size.height - buttonHeight)/2;
    
    progressButton.frame = CGRectMake(progressButtonOriginX, 0, buttonHeight, buttonHeight);
    CGPoint centerPoint = progressButton.center;
    centerPoint.y = self.frame.size.height/2;
    progressButton.center = centerPoint;
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = CGRectGetMaxX(progressButton.frame) + progressButtonOriginX;
    self.textLabel.frame = textLabelFrame;
    
    CGRect detailLabelFrame = self.detailTextLabel.frame;
    detailLabelFrame.origin.x = self.textLabel.frame.origin.x;
    self.detailTextLabel.frame = detailLabelFrame;
}


@end
