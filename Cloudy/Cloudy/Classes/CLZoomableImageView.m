//
//  CLZoomableImageView.m
//  Cloudy
//
//  Created by Parag Dulam on 18/03/13.
//  Copyright (c) 2013 Parag Dulam. All rights reserved.
//

#import "CLZoomableImageView.h"

@interface CLZoomableImageView ()
{
}

@end

@implementation CLZoomableImageView

-(void) setImage:(UIImage *)anImage
{
    imageView.image = anImage;
}


-(void) setTag:(NSInteger)tag
{
    [super setTag:tag];
//    [label setText:[NSString stringWithFormat:@"%d",tag]];
//    [label sizeToFit];
}

-(UIImage *) image
{
    return imageView.image;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        zoomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        frame.size.width,
                                                                        frame.size.height)];
        [self addSubview:zoomScrollView];
        zoomScrollView.delegate = self;
        [zoomScrollView release];
        
        imageView = [[UIImageView alloc] initWithFrame:zoomScrollView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [zoomScrollView addSubview:imageView];
        [imageView release];
        
//        label = [[UILabel alloc] initWithFrame:CGRectZero];
//        [label setFont:[UIFont boldSystemFontOfSize:72.f]];
//        [label setBackgroundColor:[UIColor clearColor]];
//        [label setTextColor:[UIColor whiteColor]];
//        [imageView addSubview:label];
//        label.center = imageView.center;
//        [label release];
        

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




-(void) dealloc
{
    [super dealloc];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

@end
