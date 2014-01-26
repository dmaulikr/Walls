//
//  SVColorButton.m
//  Walls
//
//  Created by Sebastien Villar on 26/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVColorButton.h"
#import "SVTheme.h"

@interface SVColorButton ()
@end

@implementation SVColorButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [SVTheme sharedTheme].lightSquareColor;
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [SVTheme sharedTheme].normalWallColor.CGColor;
        self.adjustsImageWhenHighlighted = NO;
        [self setBackgroundImage:[UIImage imageNamed:@"drop_gray.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"drop_blue.png"] forState:UIControlStateSelected];
    }
    return self;
}

- (CGRect)backgroundRectForBounds:(CGRect)bounds {
    UIImage* image = [UIImage imageNamed:@"drop_gray.png"];
    return CGRectMake((self.frame.size.width - image.size.width) / 2,
                      (self.frame.size.height - image.size.height) / 2,
                      image.size.width,
                      image.size.height);
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
