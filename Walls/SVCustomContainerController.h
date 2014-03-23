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
@property (strong) id delegate;

- (void)pushViewController:(UIViewController*)controller topBarVisible:(BOOL)visible;
- (void)popViewController;
@end
