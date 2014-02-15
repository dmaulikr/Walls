//
//  SVGameTableViewCell.ù
//  Walls
//
//  Created by Sebastien Villar on 09/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVGameTableViewCell.h"
#import "SVTheme.h"

@interface SVGameTableViewCell ()
@property (strong) UILabel* label;
@property (strong) UIImageView* leftImageView;
@property (strong) UIImageView* rightImageView;
@end

@implementation SVGameTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _label = [[UILabel alloc] init];
        _label.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 20;
    frame.size.width -= 2 * 20;
    self.label.frame = CGRectMake(30,
                                  (frame.size.height - 30) / 2,
                                  frame.size.width - 60, 30);
    self.contentView.layer.cornerRadius = frame.size.height / 2;
    [super setFrame:frame];
}

- (void)setText:(NSString *)text {
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSKernAttributeName value:@2 range:NSMakeRange(0, text.length)];
    self.label.attributedText = attributedString;
}

- (void)setLeftImage:(UIImage *)image {
    if (!self.leftImageView) {
        self.leftImageView = [[UIImageView alloc] init];
        self.leftImageView.frame = CGRectMake(4, 4, 34, 34);
        self.leftImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.leftImageView.layer.borderWidth = 1;
        self.leftImageView.layer.cornerRadius = self.leftImageView.frame.size.height / 2;
        self.leftImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.leftImageView];
    }
    self.leftImageView.image = image;
}

- (void)setRightImage:(UIImage *)image {
    if (!self.rightImageView) {
        self.rightImageView = [[UIImageView alloc] init];
        self.rightImageView.frame = CGRectMake(self.frame.size.width - 4 - 34, 4, 34, 34);
        self.rightImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.rightImageView.layer.borderWidth = 1;
        self.rightImageView.layer.cornerRadius = self.rightImageView.frame.size.height / 2;
        self.rightImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.rightImageView];
    }
    self.rightImageView.image = image;
}

- (void)setColor:(UIColor *)color {
    self.contentView.backgroundColor = color;
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
