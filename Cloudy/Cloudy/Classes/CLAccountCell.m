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
        [self setAccessoryView:activityIndicator];
        [activityIndicator release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) startAnimating
{
    [activityIndicator startAnimating];
    [self setUserInteractionEnabled:NO];
}

-(void) stopAnimating
{
    [activityIndicator stopAnimating];
    [self setUserInteractionEnabled:YES];
}


-(void) setData:(id) data
{
    NSString *titleText = nil;
    NSString *detailText = nil;
    if ([data isKindOfClass:[NSString class]]) {
        titleText = (NSString *)data;
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDictionary = (NSDictionary *)data;
        titleText = [dataDictionary objectForKey:@"displayName"];
        if (!titleText) {
            titleText = [dataDictionary objectForKey:@"name"];
        }
    }
    [self.textLabel setText:titleText];
    [self.detailTextLabel setText:detailText];
}

@end
