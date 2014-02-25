//
//  SVCustomContainerController.h
//  Walls
//
//  Created by Sebastien Villar on 25/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVTopBarView.h"

@interface SVCustomContainerController : UIViewController
@property (strong) SVTopBarView* topBarView;

- (void)pushViewController:(UIViewController*)controller;
- (void)popViewController;
@end

