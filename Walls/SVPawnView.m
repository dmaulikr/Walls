//
//  SVPawnView.m
//  Walls
//
//  Created by Sebastien Villar on 24/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVPawnView.h"
#import <QuartzCore/QuartzCore.h>

@interface SVPawnView ()
@property (strong) UIColor* color1;
@property (strong) UIColor* color2;
@end

@implementation SVPawnView

#pragma mark - Public

- (id)initWithFrame:(CGRect)frame color1:(UIColor *)color1 andColor2:(UIColor *)color2 {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _color1 = color1;
        _color2 = color2;
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

#pragma mark - Private


- (void)drawRect:(CGRect)rect {
    UIBezierPath* largeCircle = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [self.color2 setFill];
    [largeCircle fill];
    
    float ratio = self.frame.size.width / kSVPawnViewNormalSize.width;
    
    UIBezierPath* smallCircle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(4 * ratio,
                                                                                  4 * ratio,
                                                                                  self.frame.size.width - 8 * ratio,
                                                                                  self.frame.size.height - 8 * ratio)];
    [self.color1 setFill];
    [smallCircle fill];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSValue* value = [change objectForKey:NSKeyValueChangeOldKey];
    CGRect oldFrame;
    [value getValue:&oldFrame];
    if (self.frame.size.width != oldFrame.size.width ||
        self.frame.size.height != oldFrame.size.height) {
        [self setNeedsDisplay];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"frame"];
}

@end
