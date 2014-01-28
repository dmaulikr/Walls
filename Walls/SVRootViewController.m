//
//  SVRootViewController.m
//  Walls
//
//  Created by Sebastien Villar on 28/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "SVRootViewController.h"
#import "SVGamesTableViewController.h"
#import "SVGameViewController.h"

@interface SVRootViewController ()
@property (strong) UIViewController* currentViewController;
@end

@implementation SVRootViewController

- (id)init {
    self = [super init];
    if (self) {
        [self authenticateLocalPlayer];
    }
    return self;
}

- (void)showViewController:(UIViewController*)controller {
    [self.view addSubview:controller.view];
    [self addChildViewController:controller];
    if (self.currentViewController)
        [self.currentViewController.view removeFromSuperview];
    self.currentViewController = controller;
}

- (void)authenticateLocalPlayer {
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    GKLocalPlayer* __weak weakSelf = localPlayer;
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:viewController
                                                                                           animated:YES
                                                                                         completion:nil];
        }
        else if (weakSelf.isAuthenticated) {
            [self didAuthenticateLocalPlayer:weakSelf];
        }
        else {
            //You need to authenticate to play this game view
        }
    };
}

- (void)didAuthenticateLocalPlayer:(GKLocalPlayer *)localPlayer {
    SVGamesTableViewController* controller = [[SVGamesTableViewController alloc] init];
    [self showViewController:controller];
}

//////////////////////////////////////////////////////
// Delegates
//////////////////////////////////////////////////////


@end
