//
//  SVWallView.m
//  Walls
//
//  Created by Sebastien Villar on 24/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVWallView.h"

@interface SVWallView ()
@property (assign, readwrite) CGRect shownRect;
@end

@implementation SVWallView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
        int cornerRadius = frame.size.width > frame.size.height ? frame.size.height / 2 : frame.size.width / 2;
        CALayer* mask = [CALayer layer];
        mask.frame = CGRectMake(0, 0, 0, 0);
        mask.cornerRadius = cornerRadius;
        mask.backgroundColor = [UIColor whiteColor].CGColor;
        _shownRect = mask.frame;
        self.layer.mask = mask;
    }
    return self;
}

- (void)showRect:(CGRect)rect animated:(BOOL)animated {
    rect.origin.x = rect.origin.x < 0 ? 0 : rect.origin.x;
    rect.origin.x = rect.origin.x > self.frame.size.width ? self.frame.size.width : rect.origin.x;
    rect.origin.y = rect.origin.y < 0 ? 0 : rect.origin.y;
    rect.origin.y = rect.origin.y > self.frame.size.height ? self.frame.size.height : rect.origin.y;
    rect.size.width = rect.size.width + rect.origin.x > self.frame.size.width ? self.frame.size.width - rect.origin.x : rect.size.width;
    rect.size.height = rect.size.height + rect.origin.y > self.frame.size.height ? self.frame.size.height - rect.origin.y : rect.size.height;
    if (animated) {
        self.layer.mask.frame = rect;
    }
    else {
        [CATransaction begin];
        [CATransaction setValue: [NSNumber numberWithBool: YES]
                         forKey: kCATransactionDisableActions];
        self.layer.mask.frame = rect;
        [CATransaction commit];
    }
    self.shownRect = self.layer.mask.frame;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//}

@end
