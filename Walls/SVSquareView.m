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

@property (assign) kSVSquareViewType type;
@property (assign) kSVSquareViewColor color;
@end

const int kSize = 46;

@implementation SVSquareView

- (id)initWithOrigin:(CGPoint)origin type:(kSVSquareViewType)type andColor:(kSVSquareViewColor)color {
    self = [self init];
    if (self) {
        _type = type;
        _color = color;
        
        
        //Constants
        _kLightColor = [[UIColor alloc] initWithRed:0.41 green:0.41 blue:0.41 alpha:1.0];
        _kDarkColor = [[UIColor alloc] initWithRed:0.44 green:0.44 blue:0.44 alpha:1.0];
        _kBorderColor = [[UIColor alloc] initWithRed:0.46 green:0.46 blue:0.46 alpha:1.0];
        
        if (type == kSVSquareViewCenter)
            self.frame = CGRectMake(origin.x, origin.y, kSize, kSize);
        else
            self.frame = CGRectMake(origin.x, origin.y, kSize - 1, kSize);
        if (color == kSVSquareViewLight)
            self.backgroundColor = _kLightColor;
        else
            self.backgroundColor = _kDarkColor;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (self.type != kSVSquareViewRight) {
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.frame.size.width - 1, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(self.frame.size.width - 1, self.frame.size.height)];
        [path closePath];
        [self.kBorderColor setFill];
        path.lineWidth = 1;
        path.lineCapStyle = kCGLineCapSquare;
        [path fill];
    }
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.frame.size.height - 1)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height - 1)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
    [path closePath];
    [self.kBorderColor setFill];
    path.lineWidth = 1;
    path.lineCapStyle = kCGLineCapSquare;
    [path fill];
}

@end
