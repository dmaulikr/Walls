//
//  SVGameTableViewCell.ù
//  Walls
//
//  Created by Sebastien Villar on 09/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVGameTableViewCell.h"
#import "SVTheme.h"
#import "SVCustomView.h"

static NSCache* imageCache;

@interface SVGameTableViewCell ()
@property (strong) UILabel* label;
@property (strong) UIColor* originalColor;
@property (strong) SVCustomView* leftImageView;
@property (strong) SVCustomView* rightImageView;

- (void)setText:(NSString*)text;
- (void)setColor:(UIColor*)color;
- (UIImage*)resizedImage:(UIImage*)image;
@end

@implementation SVGameTableViewCell
@synthesize highlighted = _highlighted;

#pragma mark - Public

+ (void)initialize {
    [super initialize];
    imageCache = [[NSCache alloc] init];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _label = [[UILabel alloc] init];
        _label.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _leftImageView = [[SVCustomView alloc] initWithFrame:CGRectMake(4, 4, 34, 34)];
        _leftImageView.layer.cornerRadius = 17;
        _leftImageView.layer.borderWidth = 1;
        _leftImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _rightImageView = [[SVCustomView alloc] initWithFrame:CGRectMake(self.frame.size.width - 4 - 34, 4, 34, 34)];
        _rightImageView.layer.cornerRadius = 17;
        _rightImageView.layer.borderWidth = 1;
        _rightImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:_leftImageView];
        [self.contentView addSubview:_rightImageView];
        [self.contentView addSubview:_label];
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.contentView.layer.borderWidth = 1;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += kSVGameTableViewCellXOffset;
    frame.size.width = self.superview.frame.size.width -  2 * kSVGameTableViewCellXOffset;
    self.label.frame = CGRectMake(30,
                                  (frame.size.height - 30) / 2,
                                  frame.size.width - 60, 30);
    self.contentView.layer.cornerRadius = frame.size.height / 2;
    self.rightImageView.frame = CGRectMake(self.frame.size.width - 4 - 34, 4, 34, 34);
    [super setFrame:frame];
}

- (void)setText:(NSString *)text {
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSKernAttributeName value:@2 range:NSMakeRange(0, text.length)];
    self.label.attributedText = attributedString;
}

- (void)setColor:(UIColor *)color {
    self.contentView.backgroundColor = color;
}

- (void)displayForGame:(SVGame *)game {
    if (game.match.status == GKTurnBasedMatchStatusEnded) {
        for (GKTurnBasedParticipant* participant in game.match.participants) {
            if ([participant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                if (participant.matchOutcome == GKTurnBasedMatchOutcomeWon)
                    [self setText:@"Won"];
                else
                    [self setText:@"Lost"];
            }
            self.originalColor = [SVTheme sharedTheme].endedGameColor;
        }
    }
    else {
        if ([game.match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            [self setText:@"Your turn"];
            self.originalColor = [SVTheme sharedTheme].localPlayerColor;
        }
        else {
            [self setText:@"Waiting"];
            self.originalColor = [SVTheme sharedTheme].opponentPlayerColor;
        }
    }
    [self setColor:self.originalColor];
    
    //Load images
    
    UIImage* image1 = [imageCache objectForKey:game.firstPlayerID];
    UIImage* image2 = [imageCache objectForKey:game.secondPlayerID];
    if (!image1) {
        [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:game.firstPlayerID]
                      withCompletionHandler:^(NSArray *players, NSError *error) {
                          if (!error) {
                              GKPlayer* player = [players objectAtIndex:0];
                              [player loadPhotoForSize:GKPhotoSizeSmall
                                 withCompletionHandler:^(UIImage *photo, NSError *error) {
                                     if (!error) {
                                         UIImage* image = [self resizedImage:photo];
                                         [imageCache setObject:image forKey:game.firstPlayerID];
                                         [self drawLeftImage:image];
                                     }
                              }];
                          }
                      }];
    }
    else
        [self drawLeftImage:image1];
    
    if (!image2) {
        [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:game.secondPlayerID]
                      withCompletionHandler:^(NSArray *players, NSError *error) {
                          if (!error) {
                              GKPlayer* player = [players objectAtIndex:0];
                              [player loadPhotoForSize:GKPhotoSizeSmall
                                 withCompletionHandler:^(UIImage *photo, NSError *error) {
                                     if (!error) {
                                         UIImage* image = [self resizedImage:photo];
                                         [imageCache setObject:image forKey:game.secondPlayerID];
                                         [self drawRightImage:image];
                                     }
                              }];
                          }
                      }];
    }
    else
        [self drawRightImage:image2];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    _highlighted = highlighted;
    if (highlighted) {
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        CGFloat alpha;
        [self.originalColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        [self setColor:[UIColor colorWithHue:hue saturation:saturation brightness:brightness + 0.1 alpha:1.0]];
    }
    else {
        [self setColor:self.originalColor];
    }
}

#pragma mark - Private
         
- (void)drawLeftImage:(UIImage*)image {
    [self.leftImageView drawBlock:^(CGContextRef context) {
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context,
                           CGRectMake(0,
                                      0,
                                      image.size.width,
                                      image.size.height),
                                      image.CGImage);
    }];
}

- (void)drawRightImage:(UIImage*)image {
    [self.rightImageView drawBlock:^(CGContextRef context) {
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context,
                           CGRectMake(0,
                                      0,
                                      image.size.width,
                                      image.size.height),
                           image.CGImage);
    }];
}

- (UIImage*)resizedImage:(UIImage*)image {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(34, 34), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, 34, 34));
    CGContextClosePath (context);
    CGContextClip (context);
    [image drawInRect:CGRectMake(0, 0, 34, 34)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
