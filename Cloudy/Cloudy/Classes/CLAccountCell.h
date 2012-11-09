//
//  CLAccountCell.h
//  Cloudy
//
//  Created by Parag Dulam on 09/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLConstants.h"

@interface CLAccountCell : UITableViewCell
-(void) startAnimating;
-(void) stopAnimating;
-(void) stopAnimating:(BOOL) accountAdded;
-(void) setData:(id) data;
@property (nonatomic) BOOL isAnimating;
@end
