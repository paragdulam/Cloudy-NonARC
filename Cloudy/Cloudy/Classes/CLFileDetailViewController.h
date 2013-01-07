//
//  CLFileDetailViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 23/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLFileDetailBaseViewController.h"

@interface CLFileDetailViewController : CLFileDetailBaseViewController<LiveDownloadOperationDelegate,DBRestClientDelegate,UIDocumentInteractionControllerDelegate>

@end
