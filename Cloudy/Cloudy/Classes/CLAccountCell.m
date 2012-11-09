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
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
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


-(void) setData:(id) data
{
    NSString *titleText = nil;
    NSString *detailText = nil;
    if ([data isKindOfClass:[NSString class]]) {
        titleText = (NSString *)data;
        [self setAccessoryType:UITableViewCellAccessoryNone];
        [self setAccessoryView:activityIndicator];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDictionary = (NSDictionary *)data;
        titleText = [dataDictionary objectForKey:@"displayName"];
        if (!titleText) {
            titleText = [dataDictionary objectForKey:@"name"];
        }
        [self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }
    [self.textLabel setText:titleText];
    [self.detailTextLabel setText:detailText];
}

@end
