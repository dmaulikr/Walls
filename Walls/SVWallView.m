//
//  SVWallView.m
//  Walls
//
//  Created by Sebastien Villar on 24/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVWallView.h"

@interface SVWallView ()
@property (strong) CAShapeLayer* mask;
@property (assign) CGRect shownRect;
@property (assign, readonly) kSVWallViewType startType;
@property (assign, readonly) kSVWallViewType endType;
@property (strong, readonly) UIColor* leftColor;
@property (strong, readonly) UIColor* centerColor;
@property (strong, readonly) UIColor* rightColor;

@property (strong) void(^maskAnimationBlock)(void);

- (UIBezierPath*)pathForRect:(CGRect)rect;
@end

@implementation SVWallView

- (id)initWithFrame:(CGRect)frame startType:(kSVWallViewType)start
            endType:(kSVWallViewType)end
          leftColor:(UIColor*)leftColor
        centerColor:(UIColor*)centerColor
         rightColor:(UIColor*)rightColor {
    self = [super initWithFrame:frame];
    if (self) {
        _startType = start;
        _endType = end;
        _leftColor = leftColor;
        _centerColor = centerColor;
        _rightColor = rightColor;
        
        self.backgroundColor = [UIColor clearColor];
        
        CAShapeLayer* mask = [CAShapeLayer layer];
        mask.frame = self.bounds;
        [mask setFillRule:kCAFillRuleEvenOdd];
        mask.fillColor = [[UIColor whiteColor] CGColor];
        self.layer.mask = mask;
        _shownRect = mask.frame;
        _mask = mask;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    float width;
    float height;
    if (self.frame.size.width > self.frame.size.height) {
        width = self.frame.size.width;
        height = self.frame.size.height;
    }
    else {
        width = self.frame.size.height;
        height = self.frame.size.width;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextRotateCTM(context, M_PI_2);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    //Left
    if (self.startType == kSVWallViewRounded) {
        UIBezierPath* left = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, height, height)
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
                                                         cornerRadii:CGSizeMake(height / 2, height / 2)];
        [self.leftColor setFill];
        [left fill];
    }
    else if (self.startType == kSVWallViewBottomOriented) {
        UIBezierPath* left = [UIBezierPath bezierPath];
        [left moveToPoint:CGPointMake(height, 0)];
        [left addArcWithCenter:CGPointMake(height, height)
                        radius:height
                    startAngle:3 * M_PI_2 endAngle:M_PI clockwise:NO];
        [left addLineToPoint:CGPointMake(height, height)];
        [left closePath];
        [self.centerColor setFill];
        [left fill];
        
        UIBezierPath* leftBot = [UIBezierPath bezierPath];
        [leftBot moveToPoint:CGPointMake(0, height)];
        [leftBot addArcWithCenter:CGPointMake(height, height)
                           radius:height
                       startAngle:M_PI endAngle:5 * M_PI_4 clockwise:YES];
        [leftBot addLineToPoint:CGPointMake(height, height)];
        [leftBot closePath];
        [self.leftColor setFill];
        [leftBot fill];
    }
    else if (self.startType == kSVWallViewTopOriented) {
        UIBezierPath* left = [UIBezierPath bezierPath];
        [left moveToPoint:CGPointMake(0, 0)];
        [left addArcWithCenter:CGPointMake(height, 0)
                        radius:height
                    startAngle:M_PI endAngle:M_PI_2 clockwise:NO];
        [left addLineToPoint:CGPointMake(height, 0)];
        [left closePath];
        [self.centerColor setFill];
        [left fill];
        
        UIBezierPath* leftTop = [UIBezierPath bezierPath];
        [leftTop moveToPoint:CGPointMake(0, 0)];
        [leftTop addArcWithCenter:CGPointMake(height, 0)
                           radius:height
                       startAngle:M_PI endAngle:3 * M_PI_4 clockwise:NO];
        [leftTop addLineToPoint:CGPointMake(height, 0)];
        [leftTop closePath];
        [self.leftColor setFill];
        [leftTop fill];
    }
    
    //Center
    UIBezierPath* center = [UIBezierPath bezierPathWithRect:CGRectMake(height, 0, width - 2 * height, height)];
    [self.centerColor setFill];
    [center fill];
    
    //Right
    if (self.endType == kSVWallViewRounded) {
        UIBezierPath* right = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(width - height, 0, height, height)
                                                    byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                                          cornerRadii:CGSizeMake(height / 2, height / 2)];
        [self.rightColor setFill];
        [right fill];
    }
    else if (self.endType == kSVWallViewBottomOriented) {
        UIBezierPath* right = [UIBezierPath bezierPath];
        [right moveToPoint:CGPointMake(width, height)];
        [right addArcWithCenter:CGPointMake(width - height, height)
                         radius:height
                     startAngle:0 endAngle:3 * M_PI_2 clockwise:NO];
        [right addLineToPoint:CGPointMake(width - height, height)];
        [right closePath];
        [self.centerColor setFill];
        [right fill];
        
        UIBezierPath* rightBottom = [UIBezierPath bezierPath];
        [rightBottom moveToPoint:CGPointMake(width, height)];
        [rightBottom addArcWithCenter:CGPointMake(width - height, height)
                               radius:height
                           startAngle:0 endAngle:7 * M_PI_4 clockwise:NO];
        [rightBottom addLineToPoint:CGPointMake(width - height, height)];
        [rightBottom closePath];
        [self.rightColor setFill];
        [rightBottom fill];
    }
    else if (self.endType == kSVWallViewTopOriented) {
        UIBezierPath* right = [UIBezierPath bezierPath];
        [right moveToPoint:CGPointMake(width, 0)];
        [right addArcWithCenter:CGPointMake(width - height, 0)
                         radius:height
                     startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [right addLineToPoint:CGPointMake(width - height, 0)];
        [right closePath];
        [self.centerColor setFill];
        [right fill];
        
        UIBezierPath* rightTop = [UIBezierPath bezierPath];
        [rightTop moveToPoint:CGPointMake(width, 0)];
        [rightTop addArcWithCenter:CGPointMake(width - height, 0)
                            radius:height
                        startAngle:0 endAngle:M_PI_4 clockwise:YES];
        [rightTop addLineToPoint:CGPointMake(width - height, 0)];
        [rightTop closePath];
        [self.rightColor setFill];
        [rightTop fill];
    }
}

- (UIBezierPath*)pathForRect:(CGRect)rect {
    //Trick to avoid transformation of wall because of flat rect
    if (rect.origin.x == 0 && rect.origin.y == 0 && rect.size.width == 0) {
        rect.origin.x = -20;
        rect.size.width = 20;
    }
    else if (rect.origin.x == self.frame.size.width && rect.origin.y == 0 && rect.size.width == 0) {
        rect.size.width = 20;
    }
    else if (rect.origin.x == 0 && rect.origin.y == self.frame.size.height && rect.size.height == 0) {
        rect.size.height = 20;
    }
    else if (rect.origin.x == 0 && rect.origin.y == 0 && rect.size.height == 0) {
        rect.origin.y = -20;
        rect.size.height = 20;
    }
    
    //Change the path to non rounded if next to extremity
    float width;
    float height;
    float rectWidth;
    float rectHeight;
    if (self.frame.size.width > self.frame.size.height) {
        width = self.frame.size.width;
        height = self.frame.size.height;
        rectWidth = rect.size.width;
        rectHeight = rect.size.height;
    }
    else {
        width = self.frame.size.height;
        height = self.frame.size.width;
        rectWidth = rect.size.height;
        rectHeight = rect.size.width;
    }
    
    UIBezierPath* path;
    
    if (rectWidth < width - height / 2 && rectWidth > height / 2) {
        if (self.frame.size.width > self.frame.size.height) {
            if (CGPointEqualToPoint(rect.origin, CGPointZero)) {
                path = [UIBezierPath bezierPathWithRoundedRect:rect
                                             byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                                   cornerRadii:CGSizeMake(height/2, height/2)];
            }
            else {
                path = [UIBezierPath bezierPathWithRoundedRect:rect
                                             byRoundingCorners:UIRectCornerTopLeft| UIRectCornerBottomLeft
                                                   cornerRadii:CGSizeMake(height/2, height/2)];
            }
        }
        else {
            if (CGPointEqualToPoint(rect.origin, CGPointZero)) {
                path = [UIBezierPath bezierPathWithRoundedRect:rect
                                             byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                   cornerRadii:CGSizeMake(height/2, height/2)];
            }
            else {
                path = [UIBezierPath bezierPathWithRoundedRect:rect
                                             byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight
                                                   cornerRadii:CGSizeMake(height/2, height/2)];
            }
        }
    }
    else {
        path = [UIBezierPath bezierPathWithRect:rect];
    }
    return path;
}


- (void)showRect:(CGRect)rect animated:(BOOL)animated withFinishBlock:(void(^)(void))block {
    rect.origin.x = rect.origin.x < 0 ? 0 : rect.origin.x;
    rect.origin.x = rect.origin.x > self.frame.size.width ? self.frame.size.width : rect.origin.x;
    rect.origin.y = rect.origin.y < 0 ? 0 : rect.origin.y;
    rect.origin.y = rect.origin.y > self.frame.size.height ? self.frame.size.height : rect.origin.y;
    rect.size.width = rect.size.width + rect.origin.x > self.frame.size.width ? self.frame.size.width - rect.origin.x : rect.size.width;
    rect.size.height = rect.size.height + rect.origin.y > self.frame.size.height ? self.frame.size.height - rect.origin.y : rect.size.height;
    if (animated) {
        CGPathRef newPath = [self pathForRect:rect].CGPath;
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.duration = 0.15;
        animation.fromValue = (__bridge id)(self.mask.path);
        animation.toValue = (__bridge id)newPath;
        animation.delegate = self;
        [animation setValue:@"SVWallViewMaskAnimation" forKey:@"id"];
        self.maskAnimationBlock = block;
        [self.mask addAnimation:animation forKey:@"SVWallViewMaskAnimation"];
        self.mask.path = [self pathForRect:rect].CGPath;
    }
    else {
        self.mask.path = [self pathForRect:rect].CGPath;
    }
    self.shownRect = rect;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if ([[theAnimation valueForKey:@"id"] isEqualToString:@"SVWallViewMaskAnimation"]) {
        if (self.maskAnimationBlock && flag)
            self.maskAnimationBlock();
    }
}


@end
