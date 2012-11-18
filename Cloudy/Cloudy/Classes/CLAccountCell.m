//
//  CLAccountCell.m
//  Cloudy
//
//  Created by Parag Dulam on 09/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLAccountCell.h"

@interface CLAccountCell()
{
    UIActivityIndicatorView *activityIndicator;
}

@end

@implementation CLAccountCell

-(BOOL) isAnimating
{
    return activityIndicator.isAnimating;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.hidesWhenStopped = YES;
        self.textLabel.textColor = CELL_TEXTLABEL_COLOR;
        self.detailTextLabel.textColor = CELL_DETAILTEXTLABEL_COLOR;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) dealloc
{
    [activityIndicator release];
    activityIndicator = nil;
    [super dealloc];
}


-(void) startAnimating
{
    [self setAccessoryType:UITableViewCellAccessoryNone];
    [self setAccessoryView:activityIndicator];
    [activityIndicator startAnimating];
    [self setUserInteractionEnabled:NO];
}

-(void) stopAnimating:(BOOL) accountAdded
{
    if (accountAdded) {
        [self setAccessoryView:nil];
        [self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }
    [activityIndicator stopAnimating];
    [self setUserInteractionEnabled:YES];
}

-(void) stopAnimating
{
    [self stopAnimating:NO];
}


-(void) setData:(id) data forCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleText = nil;
    NSString *detailText = nil;

    if ([data isKindOfClass:[NSString class]]) {
        titleText = (NSString *)data;
        detailText = nil;
        [self setAccessoryType:UITableViewCellAccessoryNone];
        [self setAccessoryView:activityIndicator];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDictionary = (NSDictionary *)data;
        NSDictionary *quotaDictionary = [dataDictionary objectForKey:@"quota"];
        double totalConsumedBytes = 0;
        double totalBytes = 0;
        
        switch (indexPath.section) {
            case DROPBOX:
            {
                totalConsumedBytes = [[quotaDictionary objectForKey:@"totalConsumedBytes"] doubleValue] / (1024 * 1024 * 1024);
                totalBytes = [[quotaDictionary objectForKey:@"totalBytes"] doubleValue] / (1024 * 1024 * 1024);
            }
                break;
            case SKYDRIVE:
            {
                totalConsumedBytes = ([[quotaDictionary objectForKey:@"quota"] doubleValue] - [[quotaDictionary objectForKey:@"available"] doubleValue]) / (1024 * 1024 * 1024);
                totalBytes = [[quotaDictionary objectForKey:@"quota"] doubleValue] / (1024 * 1024 * 1024);
            }
                break;
            default:
                break;
        }
        if (totalBytes) {
            detailText = [NSString stringWithFormat:@"%.2f of %.2f GB Used",totalConsumedBytes,totalBytes];
        } else {
            detailText = @"Calculating...";
        }
        titleText = [dataDictionary objectForKey:@"displayName"];
        [self setAccessoryView:nil];
        [self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }

    
    
    
//    switch (indexPath.section) {
//        case DROPBOX:
//        {
//            [self.imageView setImage:[UIImage imageNamed:@"dropbox_cell_Image.png"]];
//            if ([data isKindOfClass:[NSString class]]) {
//                titleText = (NSString *)data;
//                detailText = nil;
//                [self setAccessoryType:UITableViewCellAccessoryNone];
//                [self setAccessoryView:activityIndicator];
//            } else if ([data isKindOfClass:[NSDictionary class]]) {
//                NSDictionary *dataDictionary = (NSDictionary *)data;
//                NSDictionary *quotaDictionary = [dataDictionary objectForKey:@"quota"];
//                double totalConsumedBytes = [[quotaDictionary objectForKey:@"totalConsumedBytes"] doubleValue] / (1024 * 1024 * 1024);
//                double totalBytes = [[quotaDictionary objectForKey:@"totalBytes"] doubleValue] / (1024 * 1024 * 1024);
//                titleText = [dataDictionary objectForKey:@"displayName"];
//                detailText = [NSString stringWithFormat:@"%.2f of %.2f GB Used",totalConsumedBytes,totalBytes];
//                [self setAccessoryView:nil];
//                [self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
//            }
//        }
//            break;
//        case SKYDRIVE:
//        {
//            [self.imageView setImage:[UIImage imageNamed:@"SkyDriveIconBlue_32x32.png"]];
//            if ([data isKindOfClass:[NSString class]]) {
//                titleText = (NSString *)data;
//                detailText = nil;
//                [self setAccessoryType:UITableViewCellAccessoryNone];
//                [self setAccessoryView:activityIndicator];
//            } else if ([data isKindOfClass:[NSDictionary class]]) {
//                NSDictionary *dataDictionary = (NSDictionary *)data;
//                NSDictionary *quotaDictionary = [dataDictionary objectForKey:@"quota"];
//                double totalConsumedBytes = ([[quotaDictionary objectForKey:@"quota"] doubleValue] - [[quotaDictionary objectForKey:@"available"] doubleValue]) / (1024 * 1024 * 1024);
//                double totalBytes = [[quotaDictionary objectForKey:@"quota"] doubleValue] / (1024 * 1024 * 1024);
//                titleText = [dataDictionary objectForKey:@"displayName"];
//                detailText = [NSString stringWithFormat:@"%.2f of %.2f GB Used",totalConsumedBytes,totalBytes];
//                [self setAccessoryView:nil];
//                [self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
//            }
//            
//        }
//            break;
//            
//        default:
//            break;
//    }
    [self.textLabel setText:titleText];
    [self.detailTextLabel setText:detailText];
}

@end
