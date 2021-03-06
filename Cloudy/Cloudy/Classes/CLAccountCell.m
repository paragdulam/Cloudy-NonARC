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
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [self setAccessoryView:activityIndicator];
    [activityIndicator startAnimating];
    [self setUserInteractionEnabled:NO];
}

-(void) stopAnimating:(BOOL) accountAdded
{
    if (accountAdded) {
        [self setAccessoryView:nil];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
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
    UIImage *cellImage = nil;

    if ([data isKindOfClass:[NSString class]]) {
        titleText = (NSString *)data;
        detailText = nil;
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
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
                cellImage = [UIImage imageNamed:@"dropbox_cell_Image.png"];
            }
                break;
            case SKYDRIVE:
            {
                totalConsumedBytes = ([[quotaDictionary objectForKey:@"quota"] doubleValue] - [[quotaDictionary objectForKey:@"available"] doubleValue]) / (1024 * 1024 * 1024);
                totalBytes = [[quotaDictionary objectForKey:@"quota"] doubleValue] / (1024 * 1024 * 1024);
                cellImage = [UIImage imageNamed:@"SkyDriveIconBlack_32x32.png"];
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
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    [self.textLabel setText:titleText];
    [self.detailTextLabel setText:detailText];
    [self.imageView setImage:cellImage];
}

@end
