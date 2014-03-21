//
//  SVGameViewController.h
//  Walls
//
//  Created by Sebastien Villar on 20/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "SVBoardView.h"
#import "SVGame.h"

@interface SVGameViewController : UIViewController <SVBoardViewDelegate,
                                                    UIGestureRecognizerDelegate,
                                                    UIAlertViewDelegate>
@property (strong, readonly) SVGame* game;
@property (weak) id delegate;

- (id)initWithGame:(SVGame*)game;
- (void)opponentPlayerDidPlayTurn:(SVGame*)game;
- (void)show;
- (void)hideWithFinishBlock:(void(^)(void))block;
@end

@protocol SVGameViewControllerDelegate <NSObject>
- (void)gameViewControllerDidClickBack:(SVGameViewController*)controller gameUpdated:(BOOL)updated;
@end

