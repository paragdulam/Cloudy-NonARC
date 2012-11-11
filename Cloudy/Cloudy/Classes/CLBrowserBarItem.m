//
//  CLBrowserBarItem.m
//  Cloudy
//
//  Created by Parag Dulam on 11/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLBrowserBarItem.h"

@interface CLBrowserBarItem ()
{
    UIButton *editButton;
    UIActivityIndicatorView *activityIndicator;
}
@end

@implementation CLBrowserBarItem
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *baseImage = [UIImage imageNamed:@"button_background_base.png"];
        UIImage *buttonImage = [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];

        editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        editButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [editButton setTitle:@"Edit"
                    forState:UIControlStateNormal];
        [editButton setTitle:@"Done"
                    forState:UIControlStateSelected];

        [editButton setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
        [editButton setBackgroundImage:buttonImage
                              forState:UIControlStateNormal];
        [editButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
        [editButton addTarget:self
                       action:@selector(editButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:editButton];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator.center = self.center;
        [self addSubview:activityIndicator];
        [activityIndicator release];

    }
    return self;
}


-(void) startAnimating
{
    [activityIndicator startAnimating];
    editButton.hidden = YES;
}

-(void) stopAnimating
{
    [activityIndicator stopAnimating];
    editButton.hidden = NO;
}


-(void) editButtonClicked:(UIButton *) btn
{
    if ([delegate respondsToSelector:@selector(editButtonClicked:WithinView:)]) {
        [delegate editButtonClicked:btn WithinView:self];
    }
}


-(void) deselectAll
{
    editButton.selected = YES;
    [self editButtonClicked:editButton];
}


-(void) dealloc
{
    delegate = nil;
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
