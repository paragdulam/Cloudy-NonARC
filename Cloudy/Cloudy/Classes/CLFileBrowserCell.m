//
//  CLFileBrowserCell.m
//  Cloudy
//
//  Created by Parag Dulam on 11/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLFileBrowserCell.h"

@interface CLFileBrowserCell()
{
    UIImageView *backgroundImageView;
}
@end

@implementation CLFileBrowserCell


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
    
    CGRect rect = self.bounds;
    backgroundImageView.frame = rect;
    
    
    float width = rect.size.height - (2 * CELL_OFFSET);
    self.imageView.frame = CGRectMake(CELL_OFFSET,
                                      CELL_OFFSET,
                                      width,
                                      width);
//    self.imageView.backgroundColor = [UIColor redColor];
//    self.textLabel.backgroundColor = [UIColor greenColor];
//    self.detailTextLabel.backgroundColor = [UIColor blueColor];


    rect = self.textLabel.frame;
    rect.origin.x = CGRectGetMaxX(self.imageView.frame) + CELL_OFFSET;
    rect.size.width -= rect.size.width >= (self.frame.size.width - (4 * CELL_OFFSET)) ? self.imageView.frame.size.width : 0;
    
    self.textLabel.frame = rect;
    
    rect.origin.y = self.detailTextLabel.frame.origin.y;
    self.detailTextLabel.frame = rect;
    
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
                cellImage = [UIImage imageNamed:@"folder.png"]; //HTBA
                [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            } else {
                NSString *extention = [titleText pathExtension];
                cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",extention]];
                [self setAccessoryType:UITableViewCellAccessoryNone];
            }
            break;

        case SKYDRIVE:
        {
            titleText = [dataDictionary objectForKey:@"name"];
            NSNumber *size = [dataDictionary objectForKey:@"size"];
            float sizeValue = [size floatValue]/(1024*1024);
            detailText = [NSString stringWithFormat:@"%.2f MB",sizeValue];
            if ([[dataDictionary objectForKey:@"type"] isEqualToString:@"folder"] || [[dataDictionary objectForKey:@"type"] isEqualToString:@"album"]) {
                cellImage = [UIImage imageNamed:@"folder.png"]; //HTBA
                [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            } else {
                NSString *extention = [titleText pathExtension];
                cellImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",extention]];
                [self setAccessoryType:UITableViewCellAccessoryNone];
            }
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
