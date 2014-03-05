//
//  SVCustomButton.m
//  Walls
//
//  Created by Sebastien Villar on 05/03/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVCustomButton.h"

@interface SVCustomButton ()
@property (strong) void(^block)(CGContextRef context);
@end

@implementation SVCustomButton

#pragma mark - Public

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

#pragma mark - Private

- (void)drawRect:(CGRect)rect {
    if (self.block) {
        self.block(UIGraphicsGetCurrentContext());
    }
}
@end

