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
@property (strong) void(^maskAnimationBlock)(void);

- (UIBezierPath*)pathForRect:(CGRect)rect;
@end

@implementation SVWallView

- (id)initWithFrame:(CGRect)frame startType:(kSVWallViewType)start endType:(kSVWallViewType)end {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
        CAShapeLayer* mask = [CAShapeLayer layer];
        mask.delegate = self;
        mask.frame = self.bounds;
        [mask setFillRule:kCAFillRuleEvenOdd];
        mask.fillColor = [[UIColor whiteColor] CGColor];
        self.layer.mask = mask;
        _shownRect = mask.frame;
        self.mask = mask;
        _startType = start;
        _endType = end;
    }
    return self;
}

- (UIBezierPath*)pathForRect:(CGRect)rect {
    if (self.startType == kSVWallViewRounded && self.endType == kSVWallViewRounded) {
        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.bounds.size.height / 2];
        return path;
    }
    return nil;
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
        animation.duration = 2.0;
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
