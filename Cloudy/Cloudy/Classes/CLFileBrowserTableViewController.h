//
//  CLFileBrowserTableViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 12/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLFileBrowserBaseTableViewController.h"
#import "CLPathSelectionViewController.h"
#import <MessageUI/MessageUI.h>
#import "AGImagePickerController.h"

@interface CLFileBrowserTableViewController : CLFileBrowserBaseTableViewController<CLBrowserBarItemDelegate,CLPathSelectionViewControllerDelegate,MFMailComposeViewControllerDelegate,AGImagePickerControllerDelegate>

@end
