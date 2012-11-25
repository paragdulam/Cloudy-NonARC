//
//  CLFileDetailViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 23/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLDetailBaseViewController.h"

@interface CLFileDetailViewController : CLDetailBaseViewController<LiveDownloadOperationDelegate,DBRestClientDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate>
{
    VIEW_TYPE viewType;
    NSDictionary *file;
}

@property (nonatomic,assign) VIEW_TYPE viewType;
@property (nonatomic,retain) NSDictionary *file;

-(id) initWithFile:(NSDictionary *) file
    WithinViewType:(VIEW_TYPE) type;

@end
