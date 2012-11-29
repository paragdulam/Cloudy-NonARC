//
//  CLUploadCell.h
//  Cloudy
//
//  Created by Parag Dulam on 29/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLUploadProgressButton.h"

@interface CLUploadCell : UITableViewCell
{
    float progress;
    UIImage *buttonImage;
}

@property (nonatomic,assign) float progress;
@property (nonatomic,assign) UIImage *buttonImage;

@end
