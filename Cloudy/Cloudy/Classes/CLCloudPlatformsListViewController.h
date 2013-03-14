//
//  CLCloudPlatformsListViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 28/02/13.
//  Copyright (c) 2013 Parag Dulam. All rights reserved.
//

#import "CLBaseTableViewController.h"
#import "CLBrowserBarItem.h"

@protocol CLCloudPlatformListViewControllerDelegate;

@interface CLCloudPlatformsListViewController : CLBaseTableViewController<CLBrowserBarItemDelegate>
{
    id<CLCloudPlatformListViewControllerDelegate> delegate;
}

@property (nonatomic,assign) id<CLCloudPlatformListViewControllerDelegate> delegate;

@end


@protocol CLCloudPlatformListViewControllerDelegate <NSObject>

-(void) cloudPlatformListViewController:(CLCloudPlatformsListViewController *) viewController didSelectPlatForm:(VIEW_TYPE) type;

@end
