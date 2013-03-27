//
//  CLZoomableImageView.h
//  Cloudy
//
//  Created by Parag Dulam on 18/03/13.
//  Copyright (c) 2013 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLZoomableImageView : UIView<UIScrollViewDelegate>
{
    UIScrollView *zoomScrollView;
    UIImageView *imageView;
    UILabel *label;
}

-(void) setImage:(UIImage *)anImage;
-(UIImage *) image;



@end
