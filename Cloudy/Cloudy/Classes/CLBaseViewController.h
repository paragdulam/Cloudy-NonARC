//
//  CLBaseViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLCacheManager.h"
#import "CLDictionaryConvertor.h"
#import "AppDelegate.h"


@interface CLBaseViewController : UIViewController
{
    AppDelegate *appDelegate;
}

@property (nonatomic,assign) AppDelegate *appDelegate;

@end
