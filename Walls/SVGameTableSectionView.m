//
//  SVGameTableSectionView.m
//  Walls
//
//  Created by Sebastien Villar on 04/03/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVGameTableSectionView.h"
#import "SVTheme.h"
#import "SVHelper.h"

@interface SVGameTableSectionView ()
@end

@implementation SVGameTableSectionView

#pragma mark - Public
- (id)initWithTitle:(NSString*)title {
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(20,
                                                           8,
                                                           100,
                                                           15)];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        _label.backgroundColor = [UIColor clearColor];
        
        _label.attributedText = [SVHelper attributedStringWithText:title characterSpacing:2];
        [self addSubview:_label];
        _line = [[UIView alloc] initWithFrame:CGRectMake(20, 26, 280, 1)];
        _line.backgroundColor = [UIColor whiteColor];
        [self addSubview:_line];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Private

- (void)drawRect:(CGRect)rect {
    //Background
    UIColor* gray = [SVTheme sharedTheme].darkSquareColor;
    UIBezierPath* background = [UIBezierPath bezierPathWithRect:CGRectMake(0,
                                                                           0,
                                                                           self.frame.size.width,
                                                                           self.frame.size.height - 3)];
    [gray setFill];
    [background fill];
    
    //Gradient
    NSArray* colors = [NSArray arrayWithObjects:(id)gray.CGColor,
                                                [(id)gray colorWithAlphaComponent:0].CGColor, nil];

    CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (CFArrayRef)colors, NULL);
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(),
                                gradient,
                                CGPointMake(0, self.frame.size.height - 3),
                                CGPointMake(0, self.frame.size.height),
                                0
                                );
}

@end
