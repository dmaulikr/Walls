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
#import "SVCustomViewController.h"

@interface SVGameViewController : UIViewController <SVBoardViewDelegate, UIGestureRecognizerDelegate>
@property (strong, readonly) SVGame* game;
@property (weak) id delegate;

- (id)initWithGame:(SVGame*)game;
- (void)opponentPlayerDidPlayTurn:(SVGame*)game;
@end

@protocol SVGameViewControllerDelegate <NSObject>
- (void)gameViewController:(SVGameViewController*)controller didPlayTurn:(SVGame*)game ended:(BOOL)ended;
@end

