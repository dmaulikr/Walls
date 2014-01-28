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

@interface SVGameViewController : UIViewController <SVBoardViewDelegate, UIGestureRecognizerDelegate>
- (id)initWithMatch:(GKTurnBasedMatch*)match;
@end
