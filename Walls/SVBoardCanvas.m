//
//  SVBoardCanvas.m
//  Walls
//
//  Created by Sebastien Villar on 21/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVBoardCanvas.h"

@interface SVBoardCanvas ()
@property (strong) UIBezierPath* path;
@property (assign) CGPoint start;
@property (assign) CGPoint end;
@end

@implementation SVBoardCanvas

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _start = CGPointMake(0, 0);
        _end = CGPointMake(0, 0);
        _path = [UIBezierPath bezierPath];
        _path.lineWidth = 4;
        self.backgroundColor = [UIColor clearColor];
        self.clearsContextBeforeDrawing = NO;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (CGPointEqualToPoint(self.start, self.end)) {
        CGContextClearRect(context, self.bounds);
    }
    else {
        [[UIColor blackColor] setStroke];
        [self.path stroke];
    }
}

- (void)drawLineFrom:(CGPoint)start to:(CGPoint)end {
    self.start = start;
    self.end = end;
    [self.path moveToPoint:self.start];
    [self.path addLineToPoint:self.end];
    [self setNeedsDisplay];
}

- (void)clear {
    self.start = CGPointMake(0, 0);
    self.end = self.start;
    [self.path removeAllPoints];
    [self setNeedsDisplay];
}


@end
