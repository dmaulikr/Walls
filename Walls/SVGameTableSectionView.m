//
//  SVGameTableSectionView.m
//  Walls
//
//  Created by Sebastien Villar on 04/03/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVGameTableSectionView.h"
#import "SVTheme.h"

@interface SVGameTableSectionView ()
@property (strong) UILabel* label;
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
        
        NSMutableAttributedString* text;
        text = [[NSMutableAttributedString alloc] initWithString:title];
        [text addAttribute:NSKernAttributeName value:@2 range:NSMakeRange(0, text.length)];
        _label.attributedText = text;
        [self addSubview:_label];
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
    //Line
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(20,
                                                                     26,
                                                                     self.frame.size.width - 40,
                                                                     1)];
    [[UIColor whiteColor] setFill];
    [path fill];
}

@end
