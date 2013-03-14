//
//  CLFileBrowserCell.m
//  Cloudy
//
//  Created by Parag Dulam on 11/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLFileBrowserCell.h"
#import "CacheManager.h"

@interface CLFileBrowserCell()
{
    UIImageView *backgroundImageView;
    UIActivityIndicatorView *activityIndicator;
}
@end

@implementation CLFileBrowserCell


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

-(void) setBackgroundImage:(UIImage *)anImage
{
    backgroundImageView.image = anImage;
}

-(UIImage *) backgroundImage
{
    return backgroundImageView.image;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        backgroundImageView = [[UIImageView alloc] init];
        [self addSubview:backgroundImageView];
        [backgroundImageView release];
        [self sendSubviewToBack:backgroundImageView];
        self.textLabel.textColor = CELL_TEXTLABEL_COLOR;
        self.detailTextLabel.textColor = CELL_DETAILTEXTLABEL_COLOR;
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self setAccessoryView:activityIndicator];
        [activityIndicator release];
        activityIndicator.hidesWhenStopped = YES;
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
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
    [super dealloc];
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    backgroundImageView.frame = rect;
    
    
    float width = rect.size.height - (2 * CELL_OFFSET);
    self.imageView.frame = CGRectMake(CELL_OFFSET,
                                      CELL_OFFSET,
                                      width,
                                      width);

    rect = self.textLabel.frame;
    rect.origin.x = CGRectGetMaxX(self.imageView.frame) + CELL_OFFSET;
    rect.size.width -= rect.size.width >= (self.frame.size.width - (4 * CELL_OFFSET)) ? self.imageView.frame.size.width : 0;
    
    self.textLabel.frame = rect;
    
    rect.origin.y = self.detailTextLabel.frame.origin.y;
    rect.size.width = self.detailTextLabel.frame.size.width;
    rect.size.height = self.frame.size.height - rect.origin.y;
    self.detailTextLabel.frame = rect;
    
//    rect = activityIndicator.frame;
//    rect.origin.x = CGRectGetMaxX(self.textLabel.frame) + (activityIndicator.frame.size.width / 2);
//    rect.origin.y = self.textLabel.frame.origin.y;
//    activityIndicator.frame = rect;
//    activityIndicator.center = self.imageView.center;
}



-(void) setData:(id)data
{
    NSDictionary *dataDictionary = (NSDictionary *)data;
    NSString *titleText = nil;
    NSString *detailText = nil;
    UIImage *cellImage = nil;
    
    titleText = [dataDictionary objectForKey:FILE_NAME];
    
    id size = [dataDictionary objectForKey:FILE_SIZE];
    detailText = [size isKindOfClass:[NSNumber class]] ? [NSString stringWithFormat:@"%.2f MB",[size floatValue]/(1024*1024)] : size;
    
    switch ([[dataDictionary objectForKey:FILE_TYPE] intValue]) {
        case 0: //file
        {
            NSString *cloudDataType = [[dataDictionary objectForKey:ACCOUNT_TYPE] intValue] ? SKYDRIVE_STRING : DROPBOX_STRING;
            NSString *thumbPath = [NSString stringWithFormat:@"%@%@_%@",[CacheManager getTemporaryDirectory],cloudDataType,[[data objectForKey:FILE_PATH] stringByReplacingOccurrencesOfString:@"/" withString:@""]];
            if ([[data objectForKey:FILE_THUMBNAIL] boolValue] && [CacheManager fileExistsAtPath:thumbPath]) {
                cellImage = [UIImage imageWithContentsOfFile:thumbPath];
            } else {
                NSString *extention = [[titleText pathExtension] lowercaseString];
                cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",extention]];
                if (!cellImage) {
                    cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"_blank.png"]];
                }
            }
        }
            break;
        case 1: //folder
            cellImage = [UIImage imageNamed:@"folder.png"];
            break;
        default:
            break;
    }
    
    [self.textLabel setText:titleText];
    [self.detailTextLabel setText:detailText];
    [self.imageView setImage:cellImage];
}

-(void) setData:(id) data ForViewType:(VIEW_TYPE) type
{
    NSDictionary *dataDictionary = (NSDictionary *)data;
    NSString *titleText = nil;
    NSString *detailText = nil;
    UIImage *cellImage = nil;
    
    switch (type) {
        case DROPBOX:
            titleText = [dataDictionary objectForKey:@"filename"];
            detailText = [dataDictionary objectForKey:@"humanReadableSize"];
            if ([[dataDictionary objectForKey:@"isDirectory"] boolValue]) {
                cellImage = [UIImage imageNamed:@"folder.png"];
                detailText = nil;
            } else {
                cellImage = [UIImage imageWithData:[dataDictionary objectForKey:THUMBNAIL_DATA]];
                if (!cellImage) {
                    NSString *extention = [[titleText pathExtension] lowercaseString];
                    cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",extention]];
                    if (!cellImage) {
                        cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"_blank.png"]];
                    }
                }
            }
            break;

        case SKYDRIVE:
        {
            titleText = [dataDictionary objectForKey:@"name"];
            NSNumber *size = [dataDictionary objectForKey:@"size"];
            float sizeValue = [size floatValue]/(1024*1024);
            detailText = [NSString stringWithFormat:@"%.2f MB",sizeValue];
            if ([[dataDictionary objectForKey:@"type"] isEqualToString:@"folder"] || [[dataDictionary objectForKey:@"type"] isEqualToString:@"album"]) {
                cellImage = [UIImage imageNamed:@"folder.png"]; 
            } else {
                cellImage = [UIImage imageWithData:[dataDictionary objectForKey:THUMBNAIL_DATA]];
                if (!cellImage) {
                    NSString *extention = [[titleText pathExtension] lowercaseString];
                    cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",extention]];
                    if (!cellImage) {
                        cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"_blank.png"]];
                    }
                }
            }
        }
            break;
        case BOX:
        {
            titleText = [dataDictionary objectForKey:@"file_name"];
            if (!titleText) {
                titleText = [dataDictionary objectForKey:@"name"];
                cellImage = [UIImage imageNamed:@"folder.png"];
            } else {
                cellImage = [UIImage imageWithData:[dataDictionary objectForKey:THUMBNAIL_DATA]];
                if (!cellImage) {
                    NSString *extention = [[titleText pathExtension] lowercaseString];
                    cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",extention]];
                    if (!cellImage) {
                        cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"_blank.png"]];
                    }
                }
            }
            float sizeValue = [[dataDictionary objectForKey:@"size"] floatValue]/(1024*1024);
            detailText = [NSString stringWithFormat:@"%.2f MB",sizeValue];
        }
            break;
        default:
            break;
    }
    [self.textLabel setText:titleText];
    [self.detailTextLabel setText:detailText];
    [self.imageView setImage:cellImage];
}

@end
