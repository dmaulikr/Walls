//
//  SVBoardView.h
//  Walls
//
//  Created by Sebastien Villar on 24/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVSquareView.h"
#import "SVPosition.h"
#import "SVWall.h"

typedef enum {
    kSVNoDirection,
    kSVLeftDirection,
    kSVRightDirection,
    kSVTopDirection,
    kSVBottomDirection
} kSVPanDirection;

@interface SVBoardView : UIView
@property (weak) id delegate;
@property (assign, readonly) BOOL rotated;

- (id)initWithFrame:(CGRect)frame rotated:(BOOL)rotated;
- (SVPosition*)intersectionPositionForPoint:(CGPoint)point;
- (CGPoint)intersectionPointForPosition:(SVPosition*)position;
- (CGPoint)squareCenterForPosition:(SVPosition*)position;
- (void)hideRowsAnimated:(BOOL)animated withFinishBlock:(void(^)(void))block;
- (void)showRowsAnimated:(BOOL)animated withFinishBlock:(void(^)(void))block;
@end

@protocol SVBoardViewDelegate <NSObject>
- (void)boardView:(SVBoardView*)boardView didStartPanAt:(CGPoint)point withDirection:(kSVPanDirection)direction;
- (void)boardView:(SVBoardView*)boardView didChangePanTo:(CGPoint)point;
- (void)boardView:(SVBoardView*)boardView didEndPanAt:(CGPoint)point changeOfDirection:(BOOL)change;
@end
