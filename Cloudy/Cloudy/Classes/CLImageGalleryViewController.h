//
//  CLImageGalleryViewController.h
//  Cloudy
//
//  Created by Parag Dulam on 22/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBaseViewController.h"

@interface CLImageGalleryViewController : CLBaseViewController<UIGestureRecognizerDelegate,DBRestClientDelegate,LiveDownloadOperationDelegate>
{
    NSArray *images;
    NSDictionary *currentImage;
    VIEW_TYPE viewType;
}

@property(nonatomic,retain) NSArray *images;
@property(nonatomic,retain) NSDictionary *currentImage;
@property(nonatomic,assign) VIEW_TYPE viewType;

-(id) initWithViewType:(VIEW_TYPE) type
           ImagesArray:(NSArray *)imagesArray
          CurrentImage:(NSDictionary *) imageDictionary;



@end
