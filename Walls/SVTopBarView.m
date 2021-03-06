//
//  SVTopBarView.m
//  Walls
//
//  Created by Sebastien Villar on 25/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVTopBarView.h"
#import "SVTheme.h"
#import "SVHelper.h"

@interface SVTopBarView ()
@property (strong) UILabel* label;
@property (strong, nonatomic) UIButton* leftButton;
@property (strong, nonatomic) UIButton* rightButton;

@end

@implementation SVTopBarView

#pragma mark - Public

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

- (void)setLeftButton:(UIButton *)button animated:(BOOL)animated {
    if (animated) {
        if (button) {
            button.frame = CGRectMake(5,
                                      -button.frame.size.height,
                                      button.frame.size.width,
                                      button.frame.size.height);
            [self addSubview:button];
        }
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if (_leftButton)
                _leftButton.alpha = 0;
            if (button) {
                button.frame = CGRectMake(5,
                                          (self.frame.size.height - button.frame.size.height) / 2,
                                          button.frame.size.width,
                                          button.frame.size.height);
            }
        } completion:^(BOOL finished) {
            if (_leftButton)
                [_leftButton removeFromSuperview];
            _leftButton = button;
        }];
    }
    else {
        if (button) {
            button.frame = CGRectMake(5,
                                      (self.frame.size.height - button.frame.size.height) / 2,
                                      button.frame.size.width,
                                      button.frame.size.height);
            [self addSubview:button];
        }
        if (_leftButton) {
            [_leftButton removeFromSuperview];
            _leftButton = nil;
        }
        _leftButton = button;
    }
    
}

- (void)setRightButton:(UIButton *)button animated:(BOOL)animated {
    if (animated) {
        if (button) {
            button.frame = CGRectMake(self.frame.size.width - button.frame.size.width - 5,
                                      -button.frame.size.height,
                                      button.frame.size.width,
                                      button.frame.size.height);
            [self addSubview:button];
        }
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
            if (_rightButton)
                _rightButton.alpha = 0;
            if (button) {
                button.frame = CGRectMake(self.frame.size.width - button.frame.size.width - 5,
                                          (self.frame.size.height - button.frame.size.height) / 2,
                                          button.frame.size.width,
                                          button.frame.size.height);
            }
        } completion:^(BOOL finished) {
            if (_rightButton)
                [_rightButton removeFromSuperview];
            _rightButton = button;
        }];
    }
    else {
        if (button) {
            button.frame = CGRectMake(self.frame.size.width - button.frame.size.width - 5,
                                      (self.frame.size.height - button.frame.size.height) / 2,
                                      button.frame.size.width,
                                      button.frame.size.height);
            [self addSubview:button];
        }
        if (_rightButton) {
            [_rightButton removeFromSuperview];
            _rightButton = nil;
        }
        _rightButton = button;
    }
    
}

- (void)setTextLabel:(NSString*)text animated:(BOOL)animated {
    if (animated) {
        UILabel* newLabel = [[UILabel alloc] initWithFrame:self.label.frame];
        newLabel.textColor = self.label.textColor;
        newLabel.font = self.label.font;
        newLabel.lineBreakMode = self.label.lineBreakMode;
        newLabel.textAlignment = self.label.textAlignment;
        newLabel.attributedText = [SVHelper attributedStringWithText:text characterSpacing:3];
        newLabel.frame = CGRectMake(newLabel.frame.origin.x,
                                    -newLabel.frame.size.height,
                                    newLabel.frame.size.width,
                                    newLabel.frame.size.height);
        newLabel.alpha = 0;
        [self addSubview:newLabel];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.label.alpha = 0;
            newLabel.frame = self.label.frame;
            newLabel.alpha = 1;
        } completion:^(BOOL finished) {
            [self.label removeFromSuperview];
            self.label = newLabel;
        }];
    }
    else {
        self.label.attributedText = [SVHelper attributedStringWithText:text characterSpacing:3];
    }
}

#pragma mark - Private

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
