//
//  CLUploadCell.m
//  Cloudy
//
//  Created by Parag Dulam on 29/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLUploadCell.h"

@interface CLUploadCell ()
{
    CLUploadProgressButton *progressButton;
    NSString *userState;
    NSString *detailText;
    LiveOperation *getFolderNameOperation;
    AppDelegate *appDelegate;
}

@property (nonatomic,retain) NSString *userState;
@property (nonatomic,retain) NSString *detailText;
@property (nonatomic,retain) LiveOperation *getFolderNameOperation;


@end

@implementation CLUploadCell
@synthesize userState;
@synthesize detailText;
@synthesize getFolderNameOperation;

-(void) setProgress:(float)aFloat
{
    [progressButton setProgress:aFloat];
}

-(float) progress
{
    return progressButton.progress;
}

-(void) setButtonImage:(UIImage *)image
{
    [progressButton setImage:image forState:UIControlStateNormal];
}


-(UIImage *) buttonImage
{
    return progressButton.imageView.image;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        progressButton = [[CLUploadProgressButton alloc] init];
        [self addSubview:progressButton];
        [progressButton release];
        
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    float buttonHeight = 30;
    float progressButtonOriginX = (self.frame.size.height - buttonHeight)/2;
    
    progressButton.frame = CGRectMake(progressButtonOriginX, 0, buttonHeight, buttonHeight);
    CGPoint centerPoint = progressButton.center;
    centerPoint.y = self.frame.size.height/2;
    progressButton.center = centerPoint;
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = CGRectGetMaxX(progressButton.frame) + progressButtonOriginX;
    self.textLabel.frame = textLabelFrame;
    
    CGRect detailLabelFrame = self.detailTextLabel.frame;
    detailLabelFrame.origin.x = self.textLabel.frame.origin.x;
    self.detailTextLabel.frame = detailLabelFrame;
}


-(void) setData:(NSDictionary *) dictionary
{
    [self.textLabel setText:[dictionary objectForKey:@"NAME"]];
    [self setButtonImage:[UIImage imageWithData:[dictionary objectForKey:@"THUMBNAIL"]]];
    VIEW_TYPE type = [[dictionary objectForKey:@"TYPE"] intValue];
    switch (type) {
        case DROPBOX:
            [self.detailTextLabel setText:DROPBOX_STRING];
            break;
        case SKYDRIVE:
        {
            [self.detailTextLabel setText:SKYDRIVE_STRING];
//            [self.detailTextLabel setText:@"Finding Destination Path...."];
//            if (![detailText length]) {
//                self.userState = [dictionary objectForKey:@"TOPATH"];
//                self.getFolderNameOperation = [appDelegate.liveClient getWithPath:userState
//                                           delegate:self
//                                          userState:userState];
//            } else {
//                [self.detailTextLabel setText:detailText];
//            }
        }
        default:
            break;
    }
}


-(void) dealloc
{
    [getFolderNameOperation cancel];
    [getFolderNameOperation release];
    getFolderNameOperation = nil;
    
    [detailText release];
    detailText = nil;
    
    [userState release];
    userState = nil;
    
    [super dealloc];
}

#pragma mark - LiveOperationDelegate


- (void) liveOperationSucceeded:(LiveOperation *)operation
{
    if ([operation.userState isEqualToString:userState])
    {
        self.detailText = [operation.result objectForKey:@"name"];
        [self.detailTextLabel setText:detailText];
    }
}

- (void) liveOperationFailed:(NSError *)error
                   operation:(LiveOperation*)operation
{
    
}


@end
