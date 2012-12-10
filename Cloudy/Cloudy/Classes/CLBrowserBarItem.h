//
//  CLBrowserBarItem.h
//  Cloudy
//
//  Created by Parag Dulam on 11/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLBrowserBarItemDelegate;

@interface CLBrowserBarItem : UIView
{
    id <CLBrowserBarItemDelegate> delegate;
}

@property(nonatomic,assign) id <CLBrowserBarItemDelegate> delegate;
-(void) startAnimating;
-(void) stopAnimating;
-(void) deselectAll;
-(void)hideEditButton:(BOOL) aBool;
-(void) setTitle:(NSString *) title forState:(UIControlState)state;
-(void) setImage:(UIImage *) image WithInsets:(UIEdgeInsets) inset;


@end

@protocol CLBrowserBarItemDelegate<NSObject>
-(void) buttonClicked:(UIButton *)btn WithinView:(CLBrowserBarItem *) view;
@end
