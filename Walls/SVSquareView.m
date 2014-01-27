//
//  SVSquareView.m
//  Walls
//
//  Created by Sebastien Villar on 20/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVSquareView.h"
#import "SVTheme.h"


@interface SVSquareView ()
@property (assign) kSVSquareViewRow row;
@property (assign) kSVSquareViewCol col;
@property (assign) kSVSquareViewColor color;
@end

const int kSVSquareViewSize = 46;

@implementation SVSquareView

- (id)initWithOrigin:(CGPoint)origin row:(kSVSquareViewRow)row col:(kSVSquareViewCol)col andColor:(kSVSquareViewColor)color {
    self = [self init];
    if (self) {
        _row = row;
        _col = col;
        _color = color;
        
        if (col == kSVSquareViewColCenter)
            self.frame = CGRectMake(origin.x, origin.y, kSVSquareViewSize, kSVSquareViewSize);
        else
            self.frame = CGRectMake(origin.x, origin.y, kSVSquareViewSize - 1, kSVSquareViewSize);
        if (color == kSVSquareViewLight)
            self.backgroundColor = [SVTheme sharedTheme].lightSquareColor;
        else
            self.backgroundColor = [SVTheme sharedTheme].darkSquareColor;
        UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [[SVTheme sharedTheme].squareBorderColor setFill];

    UIBezierPath* path = [UIBezierPath bezierPath];
    if (self.col != kSVSquareViewColLeft) {
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(0.5, 0)];
        [path addLineToPoint:CGPointMake(0.5, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
        [path closePath];
        [path fill];
    }
    
    if (self.col != kSVSquareViewColRight) {
        path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.frame.size.width - 0.5, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(self.frame.size.width - 0.5, self.frame.size.height)];
        [path closePath];
        [path fill];
    }
    
    float borderWidth = 0.5;
    
    if (self.row != kSVSquareViewRowTop) {
        path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, borderWidth)];
        [path addLineToPoint:CGPointMake(0, 0.5)];
        [path closePath];
        [path fill];
    }
    
    if (self.row != kSVSquareViewRowBottom) {
        path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, self.frame.size.height - borderWidth)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height - borderWidth)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
        [path closePath];
        [path fill];
    }
}

- (void)didTap:(UITapGestureRecognizer*)gestureRecognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(squareViewDidTap:)])
        [self.delegate squareViewDidTap:self];
}

@end
