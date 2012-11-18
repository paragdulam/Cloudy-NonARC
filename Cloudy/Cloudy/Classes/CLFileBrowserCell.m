//
//  CLFileBrowserCell.m
//  Cloudy
//
//  Created by Parag Dulam on 11/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLFileBrowserCell.h"

@interface CLFileBrowserCell()
{
    UIImageView *backgroundImageView;
}
@end

@implementation CLFileBrowserCell


-(void) setBackgroundImage:(UIImage *)anImage
{
    backgroundImageView.image = anImage;
}

-(UIImage *) backgroundImage
{
    return backgroundImageView.image;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        backgroundImageView = [[UIImageView alloc] init];
        [self addSubview:backgroundImageView];
        [backgroundImageView release];
        [self sendSubviewToBack:backgroundImageView];
        self.textLabel.textColor = CELL_TEXTLABEL_COLOR;
        self.detailTextLabel.textColor = CELL_DETAILTEXTLABEL_COLOR;
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
    backgroundImageView.frame = self.bounds;
}

@end
