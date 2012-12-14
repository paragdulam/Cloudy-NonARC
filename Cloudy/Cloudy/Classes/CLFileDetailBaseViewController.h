//
//  CLFileDetailBaseViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 13/12/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLDetailBaseViewController.h"

@interface CLFileDetailBaseViewController : CLDetailBaseViewController<UIGestureRecognizerDelegate,UIWebViewDelegate,DBRestClientDelegate>
{
    UIWebView *webView;
    VIEW_TYPE viewType;
    NSDictionary *file;
}

@property (nonatomic,assign) VIEW_TYPE viewType;
@property (nonatomic,retain) NSDictionary *file;

-(id) initWithFile:(NSDictionary *) file
    WithinViewType:(VIEW_TYPE) type;
-(void) tapGesture:(UIGestureRecognizer *) gesture;



@end
