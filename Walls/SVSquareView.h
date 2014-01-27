//
//  SVSquareView.h
//  Walls
//
//  Created by Sebastien Villar on 20/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSVSquareViewColLeft,
    kSVSquareViewColCenter,
    kSVSquareViewColRight
} kSVSquareViewCol;

typedef enum {
    kSVSquareViewRowTop,
    kSVSquareViewRowCenter,
    kSVSquareViewRowBottom
} kSVSquareViewRow;

typedef enum {
    kSVSquareViewLight,
    kSVSquareViewDark
} kSVSquareViewColor;

@interface SVSquareView : UIView
@property (weak) id delegate;
- (id)initWithOrigin:(CGPoint)origin row:(kSVSquareViewRow)row col:(kSVSquareViewCol)col andColor:(kSVSquareViewColor)color;
@end

@protocol SVSquareViewDelegate <NSObject>
- (void)squareViewDidTap:(SVSquareView*)squareView;
@end