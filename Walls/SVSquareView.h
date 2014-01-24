//
//  SVSquareView.h
//  Walls
//
//  Created by Sebastien Villar on 20/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSVSquareViewLeft,
    kSVSquareViewCenter,
    kSVSquareViewRight
} kSVSquareViewType;

typedef enum {
    kSVSquareViewLight,
    kSVSquareViewDark
} kSVSquareViewColor;

@interface SVSquareView : UIView
- (id)initWithOrigin:(CGPoint)origin type:(kSVSquareViewType)type andColor:(kSVSquareViewColor)color;
@end
