//
//  SVTopBarView.m
//  Walls
//
//  Created by Sebastien Villar on 25/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVTopBarView.h"
#import "SVTheme.h"

@interface SVTopBarView ()
@property (strong) UILabel* label;
@property (strong, nonatomic) UIButton* leftButton;
@property (strong, nonatomic) UIButton* rightButton;

@end

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

- (void)setLeftButton:(UIButton *)button animated:(BOOL)animated {
    if (!button) {
        if (_leftButton) {
            [_leftButton removeFromSuperview];
            _leftButton = nil;
        }
        return;
    }
    
    button.frame = CGRectMake(15,
                              (self.frame.size.height - button.frame.size.height) / 2,
                              button.frame.size.width,
                              button.frame.size.height);
    [self addSubview:button];
    _leftButton = button;
}

- (void)setRightButton:(UIButton *)button animated:(BOOL)animated {
    if (!button) {
        if (_rightButton) {
            [_rightButton removeFromSuperview];
            _rightButton = nil;
        }
        return;
    }
    
    button.frame = CGRectMake(self.frame.size.width - button.frame.size.width - 15,
                              (self.frame.size.height - button.frame.size.height) / 2,
                              button.frame.size.width,
                              button.frame.size.height);
    [self addSubview:button];
    _rightButton = button;
}

- (void)setTextLabel:(NSString*)text animated:(BOOL)animated {
    NSMutableAttributedString* topString = [[NSMutableAttributedString alloc] initWithString:text];
    [topString addAttribute:NSKernAttributeName value:@3 range:NSMakeRange(0, 4)];
    self.label.attributedText = topString;
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
