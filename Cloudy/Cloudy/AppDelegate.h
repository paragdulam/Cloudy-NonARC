//
//  AppDelegate.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDMenuController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    DDMenuController *menuController;
}

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) DDMenuController *menuController;

@end
