//
//  CLAccountCell.h
//  Cloudy
//
//  Created by Parag Dulam on 09/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CLConstants.h"

@interface CLAccountCell : UITableViewCell
-(void) startAnimating;
-(void) stopAnimating;
-(void) stopAnimating:(BOOL) accountAdded;
-(void) setData:(id) data forCellAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic) BOOL isAnimating;
@end
