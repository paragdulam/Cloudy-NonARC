//
//  CLFileBrowserCell.h
//  Cloudy
//
//  Created by Parag Dulam on 11/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLConstants.h"

#define CELL_OFFSET 5.f

@interface CLFileBrowserCell : UITableViewCell
{
    UIImage *backgroundImage;
}

@property (nonatomic,assign) UIImage *backgroundImage;

-(void) setData:(id) data ForViewType:(VIEW_TYPE) type;

@end
