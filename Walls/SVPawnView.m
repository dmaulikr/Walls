//
//  SVPawnView.m
//  Walls
//
//  Created by Sebastien Villar on 24/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVPawnView.h"

@interface SVPawnView ()
@property (strong) UIColor* color1;
@property (strong) UIColor* color2;
@end

@implementation SVPawnView

- (id)initWithFrame:(CGRect)frame color1:(UIColor *)color1 andColor2:(UIColor *)color2 {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _color1 = color1;
        _color2 = color2;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath* largeCircle = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [self.color2 setFill];
    [largeCircle fill];
    
    UIBezierPath* smallCircle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(4, 4, self.frame.size.width - 8, self.frame.size.height - 8)];
    [self.color1 setFill];
    [smallCircle fill];
}


@end
