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
@property (strong) SVCustomContainerController* containerController;
@end

@implementation SVRootViewController

- (id)init {
    self = [super init];
    if (self) {
        _containerController = [[SVCustomContainerController alloc] init];
        _containerController.delegate = self;
        [self authenticateLocalPlayer];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.containerController.view];
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
    [self.containerController pushViewController:controller];
}

@end
