//
//  SVGameTableViewCell.ù
//  Walls
//
//  Created by Sebastien Villar on 09/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVGameTableViewCell.h"
#import "SVTheme.h"

static NSCache* imageCache;

@interface SVGameTableViewCell ()
@property (strong) UILabel* label;
@property (strong) UIImageView* leftImageView;
@property (strong) UIImageView* rightImageView;
@property (strong) UIColor* originalColor;

- (void)setText:(NSString*)text;
- (void)setLeftImage:(UIImage*)image;
- (void)setRightImage:(UIImage*)image;
- (void)setColor:(UIColor*)color;
@end

@implementation SVGameTableViewCell
@synthesize highlighted = _highlighted;

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
        [self.contentView addSubview:_label];
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.contentView.layer.borderWidth = 1;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    GKTurnBasedParticipant* participant1 = [game.match.participants objectAtIndex:0];
    GKTurnBasedParticipant* participant2 = [game.match.participants objectAtIndex:1];
    UIImage* image1 = [imageCache objectForKey:participant1.playerID];
    UIImage* image2 = [imageCache objectForKey:participant2.playerID];
    if (!image1) {
        [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:participant1.playerID]
                      withCompletionHandler:^(NSArray *players, NSError *error) {
                          if (!error) {
                              GKPlayer* player = [players objectAtIndex:0];
                              [player loadPhotoForSize:GKPhotoSizeSmall
                                 withCompletionHandler:^(UIImage *photo, NSError *error) {
                                  if (!error)
                                      [self setLeftImage:photo];
                              }];
                          }
                      }];
    }
    else
        [self setLeftImage:image1];
    
    if (!image2) {
        [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:participant2.playerID]
                      withCompletionHandler:^(NSArray *players, NSError *error) {
                          if (!error) {
                              GKPlayer* player = [players objectAtIndex:0];
                              [player loadPhotoForSize:GKPhotoSizeSmall
                                 withCompletionHandler:^(UIImage *photo, NSError *error) {
                                  if (!error)
                                      [self setRightImage:photo];
                              }];
                          }
                      }];
    }
    else
        [self setRightImage:image2];
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
