//
//  SVSquareView.m
//  Walls
//
//  Created by Sebastien Villar on 20/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVSquareView.h"

@interface SVSquareView ()
@property (strong, readonly) UIColor* kLightColor;
@property (strong, readonly) UIColor* kDarkColor;
@property (strong, readonly) UIColor* kBorderColor;

@property (assign) kSVSquareViewRow row;
@property (assign) kSVSquareViewCol col;
@property (assign) kSVSquareViewColor color;
@end

const int kSVSquareViewSize = 46;

@implementation SVSquareView

- (id)initWithOrigin:(CGPoint)origin row:(kSVSquareViewRow)row col:(kSVSquareViewCol)col andColor:(kSVSquareViewColor)color {
    self = [self init];
    if (self) {
        _row = row;
        _col = col;
        _color = color;
        
        
        //Constants
        _kLightColor = [[UIColor alloc] initWithRed:0.41 green:0.41 blue:0.41 alpha:1.0];
        _kDarkColor = [[UIColor alloc] initWithRed:0.44 green:0.44 blue:0.44 alpha:1.0];
        _kBorderColor = [[UIColor alloc] initWithRed:0.46 green:0.46 blue:0.46 alpha:1.0];
        
        if (col == kSVSquareViewColCenter)
            self.frame = CGRectMake(origin.x, origin.y, kSVSquareViewSize, kSVSquareViewSize);
        else
            self.frame = CGRectMake(origin.x, origin.y, kSVSquareViewSize - 1, kSVSquareViewSize);
        if (color == kSVSquareViewLight)
            self.backgroundColor = _kLightColor;
        else
            self.backgroundColor = _kDarkColor;
        UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self.kBorderColor setFill];

    UIBezierPath* path = [UIBezierPath bezierPath];
    if (self.col != kSVSquareViewColLeft) {
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(0.5, 0)];
        [path addLineToPoint:CGPointMake(0.5, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
        [path closePath];
        [path fill];
    }
    
    if (self.col != kSVSquareViewColRight) {
        path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.frame.size.width - 0.5, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(self.frame.size.width - 0.5, self.frame.size.height)];
        [path closePath];
        [path fill];
    }
    
    float topWidth = 0.5;
    float bottomWidth = 0.5;
    
    if (self.row == kSVSquareViewRowTop)
        topWidth = 1;
    else if (self.row == kSVSquareViewRowBottom)
        bottomWidth = 1;
    
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, 0)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, topWidth)];
    [path addLineToPoint:CGPointMake(0, topWidth)];
    [path closePath];
    [path fill];
    
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.frame.size.height - bottomWidth)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height - bottomWidth)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
    [path closePath];
    [path fill];
}

- (void)didTap:(UITapGestureRecognizer*)gestureRecognizer {
    NSLog(@"tap");
}

@end
