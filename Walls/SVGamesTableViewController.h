//
//  SVGamesTableViewController.h
//  Walls
//
//  Created by Sebastien Villar on 28/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGameViewController.h"
#import "SVCustomViewController.h"


@interface SVGamesTableViewController : UITableViewController <GKTurnBasedMatchmakerViewControllerDelegate,
                                                               GKLocalPlayerListener,
                                                               SVGameViewControllerDelegate>
@end
