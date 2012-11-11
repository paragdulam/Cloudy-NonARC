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

@end

@protocol CLBrowserBarItemDelegate<NSObject>
-(void) editButtonClicked:(UIButton *)btn WithinView:(CLBrowserBarItem *) view;
@end
