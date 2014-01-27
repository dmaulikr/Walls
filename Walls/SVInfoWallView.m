//
//  SVInfoWallView.m
//  Walls
//
//  Created by Sebastien Villar on 27/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVInfoWallView.h"

@interface SVInfoWallView ()
@property (strong) CAShapeLayer* mask;
@property (strong) void(^maskAnimationBlock)(void);
@end

@implementation SVInfoWallView

- (id)initWithFrame:(CGRect)frame andColor:(UIColor*)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = color;
        _mask = [[CAShapeLayer alloc] init];
        _mask.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.width / 2].CGPath;
        self.layer.mask = _mask;
    }
    return self;
}

- (void)showRect:(CGRect)rect animated:(BOOL)animated withFinishBlock:(void(^)(void))block {
    rect.origin.x = rect.origin.x < 0 ? 0 : rect.origin.x;
    rect.origin.x = rect.origin.x > self.frame.size.width ? self.frame.size.width : rect.origin.x;
    rect.origin.y = rect.origin.y < 0 ? 0 : rect.origin.y;
    rect.origin.y = rect.origin.y > self.frame.size.height ? self.frame.size.height : rect.origin.y;
    rect.size.width = rect.size.width + rect.origin.x > self.frame.size.width ? self.frame.size.width - rect.origin.x : rect.size.width;
    rect.size.height = rect.size.height + rect.origin.y > self.frame.size.height ? self.frame.size.height - rect.origin.y : rect.size.height;
    
    CGPathRef newPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.bounds.size.width / 2].CGPath;
    
    if (animated) {
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.duration = 0.15;
        animation.fromValue = (__bridge id)(self.mask.path);
        animation.toValue = (__bridge id)newPath;
        animation.delegate = self;
        [animation setValue:@"SVInfoWallViewMaskAnimation" forKey:@"id"];
        self.maskAnimationBlock = block;
        [self.mask addAnimation:animation forKey:@"SVInfoWallViewMaskAnimation"];
        self.mask.path = newPath;
    }
    else {
        self.mask.path = newPath;
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if ([[theAnimation valueForKey:@"id"] isEqualToString:@"SVInfoWallViewMaskAnimation"]) {
        if (self.maskAnimationBlock && flag)
            self.maskAnimationBlock();
    }
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
