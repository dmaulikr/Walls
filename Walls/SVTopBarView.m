//
//  SVTopBarView.m
//  Walls
//
//  Created by Sebastien Villar on 25/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVTopBarView.h"
#import "SVTheme.h"

@implementation SVTopBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [SVTheme sharedTheme].darkSquareColor;
        _label = [[UILabel alloc] initWithFrame:CGRectMake(50,
                                                           10,
                                                           self.frame.size.width - 100,
                                                           self.frame.size.height - 20)];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont fontWithName:@"HelveticaNeue" size:24];
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
    }
    return self;
}

- (void)setLeftButton:(UIButton *)leftButton {
    if (!leftButton) {
        if (_leftButton) {
            [_leftButton removeFromSuperview];
            _leftButton = nil;
        }
        return;
    }
    
    _leftButton = leftButton;
    leftButton.frame = CGRectMake(15,
                                  (self.frame.size.height - leftButton.frame.size.height) / 2,
                                  leftButton.frame.size.width,
                                  leftButton.frame.size.height);
    [self addSubview:leftButton];
}

- (void)setRightButton:(UIButton *)rightButton {
    if (!rightButton) {
        if (_rightButton) {
            [_rightButton removeFromSuperview];
            _rightButton = nil;
        }
        return;
    }
    
    _rightButton = rightButton;
    rightButton.frame = CGRectMake(self.frame.size.width - rightButton.frame.size.width - 15,
                                  (self.frame.size.height - rightButton.frame.size.height) / 2,
                                  rightButton.frame.size.width,
                                  rightButton.frame.size.height);
    [self addSubview:rightButton];
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
