//
//  SVHelpView.m
//  Walls
//
//  Created by Sebastien Villar on 23/03/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVHelpView.h"
#import "SVTheme.h"
#import "SVHelper.h"

@interface SVHelpView ()
@property (strong) UIScrollView* scrollView;

- (UILabel*)subtitleLabelForText:(NSString*)text yPosition:(int)y;
- (UILabel*)textLabelForText:(NSString*)text yPosition:(int)y;
- (void)didClickCloseButton:(id)sender;
@end

@implementation SVHelpView

#pragma mark - Public

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 20;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 2;
        self.layer.masksToBounds = NO;
        
        UIView* mask = [[UIView alloc] initWithFrame:CGRectMake(15, 20, self.frame.size.width - 30, self.frame.size.height - 40)];
        CAGradientLayer* gradient = [CAGradientLayer layer];
        gradient.frame = mask.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor,
                           (id)[UIColor whiteColor].CGColor,
                           (id)[UIColor whiteColor].CGColor,
                           (id)[UIColor clearColor].CGColor, nil];
        gradient.locations = [NSArray arrayWithObjects:@0.0, @0.035, @0.965, @1.0, nil];
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint = CGPointMake(0, 1);
        mask.layer.mask = gradient;
        [self addSubview:mask];
        
        UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:mask.bounds];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 0);
        _scrollView = scrollView;
        [mask addSubview:scrollView];
        
        
        //Title
        UIFont* titleFont = [UIFont fontWithName:@"HelveticaNeue" size:24];
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, scrollView.contentSize.width, 32)];
        titleLabel.textColor = [SVTheme sharedTheme].darkSquareColor;
        titleLabel.attributedText = [SVHelper attributedStringWithText:@"How to play" characterSpacing:3];
        titleLabel.font = titleFont;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [scrollView addSubview:titleLabel];
    
        //Start
        UILabel* startSubtitleLabel = [self subtitleLabelForText:@"Start" yPosition:CGRectGetMaxY(titleLabel.frame) + 20];
        UILabel* startTextLabel = [self textLabelForText:@"The game starts with the 2 players positioned at opposing ends of the board. Each player is given 6 normals walls and 2 walls of his color."
                                               yPosition:CGRectGetMaxY(startSubtitleLabel.frame) + 10];
        
        [scrollView addSubview:startSubtitleLabel];
        [scrollView addSubview:startTextLabel];
        
        //Basics
        UILabel* basicsSubtitleLabel = [self subtitleLabelForText:@"Basics" yPosition:CGRectGetMaxY(startTextLabel.frame) + 20];
        UILabel* basicsTextLabel1 = [self textLabelForText:@"At each turn, a player can either move or build a wall. A wall is always 2 squares wide and can only be build if the 2 players can still reach their goal after the wall is built. A normal wall blocks the way to both players while special wall allow their owner to go through."
                                               yPosition:CGRectGetMaxY(basicsSubtitleLabel.frame) + 10];
        
        UIImage* basicImage1 = [UIImage imageNamed:@"helpImage1.png"];
        UIImageView* basicsImageView1 = [[UIImageView alloc] initWithImage:basicImage1];
        basicsImageView1.frame = CGRectMake((scrollView.contentSize.width - basicsImageView1.frame.size.width) / 2,
                                            CGRectGetMaxY(basicsTextLabel1.frame) + 20,
                                            basicsImageView1.frame.size.width,
                                            basicsImageView1.frame.size.height);
        basicsImageView1.layer.shadowColor = [UIColor blackColor].CGColor;
        basicsImageView1.layer.shadowOpacity = 0.5;
        basicsImageView1.layer.shadowOffset = CGSizeZero;
        basicsImageView1.layer.shadowRadius = 2;
        
        UILabel* basicsTextLabel2 = [self textLabelForText:@"A player can only move to the top, left, right, or bottom adjacent square if not blocked by a wall."
                                                 yPosition:CGRectGetMaxY(basicsImageView1.frame) + 20];
        
        UIImage* basicImage2 = [UIImage imageNamed:@"helpImage2.png"];
        UIImageView* basicsImageView2 = [[UIImageView alloc] initWithImage:basicImage2];
        basicsImageView2.frame = CGRectMake((scrollView.contentSize.width - basicsImageView2.frame.size.width) / 2,
                                            CGRectGetMaxY(basicsTextLabel2.frame) + 20,
                                            basicsImageView2.frame.size.width,
                                            basicsImageView2.frame.size.height);
        basicsImageView2.layer.shadowColor = [UIColor blackColor].CGColor;
        basicsImageView2.layer.shadowOpacity = 0.5;
        basicsImageView2.layer.shadowOffset = CGSizeZero;
        basicsImageView2.layer.shadowRadius = 2;
        
        [scrollView addSubview:basicsSubtitleLabel];
        [scrollView addSubview:basicsTextLabel1];
        [scrollView addSubview:basicsImageView1];
        [scrollView addSubview:basicsTextLabel2];
        [scrollView addSubview:basicsImageView2];
        
        //Win
        UILabel* winSubtitleLabel = [self subtitleLabelForText:@"How to win" yPosition:CGRectGetMaxY(basicsImageView2.frame) + 20];
        UILabel* winTextLabel = [self textLabelForText:@"A player wins if he reaches the row of the board where the opponent is initially positioned or if the other player resigns."
                                                yPosition:CGRectGetMaxY(winSubtitleLabel.frame) + 10];
        
        [scrollView addSubview:winSubtitleLabel];
        [scrollView addSubview:winTextLabel];
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((scrollView.contentSize.width - 105) / 2,
                                  CGRectGetMaxY(winTextLabel.frame) + 20,
                                  105,
                                  30);
        button.layer.cornerRadius = 15;
        button.layer.borderWidth = 2;
        button.layer.borderColor = [SVTheme sharedTheme].darkSquareColor.CGColor;
        button.titleLabel.textColor = [SVTheme sharedTheme].darkSquareColor;
        [button setAttributedTitle:[SVHelper attributedStringWithText:@"Close" characterSpacing:3] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didClickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
        
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width,
                                            CGRectGetMaxY(button.frame) + 15);
    }
    return self;
}

#pragma mark - Private

- (UILabel*)subtitleLabelForText:(NSString*)text yPosition:(int)y {
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.scrollView.contentSize.width, 0)];
    label.textColor = [SVTheme sharedTheme].darkSquareColor;
    label.attributedText = [SVHelper attributedStringWithText:text characterSpacing:3];
    label.font = font;
    label.textAlignment = NSTextAlignmentLeft;
    [label sizeToFit];
    return label;
}

- (UILabel*)textLabelForText:(NSString*)text yPosition:(int)y {
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.scrollView.contentSize.width, 0)];
    label.textColor = [SVTheme sharedTheme].darkSquareColor;
    label.text = text;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    label.textAlignment = NSTextAlignmentJustified;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [label sizeToFit];
    return label;
}

#pragma mark - Target

- (void)didClickCloseButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(helpViewDidClickCloseButton)]) {
        [self.delegate helpViewDidClickCloseButton];
    }
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
