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
    UIButton *button;
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
//        UIImage *baseImage = [UIImage imageNamed:@"button_background_base.png"];
        UIImage *buttonImage = [UIImage imageNamed:@"editButton.png"];

        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

        [button setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
        [button setBackgroundImage:buttonImage
                              forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
        [button addTarget:self
                       action:@selector(buttonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator.center = self.center;
        [self addSubview:activityIndicator];
        [activityIndicator release];

    }
    return self;
}


-(void) setTitle:(NSString *) title forState:(UIControlState)state
{
    [button setTitle:title
            forState:state];
}

-(void) startAnimating
{
    [activityIndicator startAnimating];
    button.hidden = YES;
}

-(void) stopAnimating
{
    [activityIndicator stopAnimating];
    button.hidden = NO;
}


-(void)hideEditButton:(BOOL) aBool
{
    button.hidden = aBool;
}

-(void) buttonClicked:(UIButton *) btn
{
    if ([delegate respondsToSelector:@selector(buttonClicked:WithinView:)]) {
        [delegate buttonClicked:btn WithinView:self];
    }
}


-(void) deselectAll
{
    button.selected = YES;
    [self buttonClicked:button];
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
