//
//  SVCustomView.m
//  Walls
//
//  Created by Sebastien Villar on 26/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVCustomView.h"

@interface SVCustomView ()
@property (strong) void(^block)(CGContextRef context);
@end

@implementation SVCustomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawBlock:(void(^)(CGContextRef context))block {
    self.block = block;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (self.block) {
        self.block(UIGraphicsGetCurrentContext());
    }
}
@end
