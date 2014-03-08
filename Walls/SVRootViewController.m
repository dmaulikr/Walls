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
#import "SVTheme.h"

@interface SVRootViewController ()
@property (strong) UIViewController* currentViewController;
@property (strong) SVCustomContainerController* containerController;
@property (strong) UIViewController* gameCenterController;
@property (strong) UILabel* wallsLabel;
@property (strong) UIButton* signInButton;

- (void)showSignIn;
- (void)didClickButton:(id)sender;
- (void)didAuthenticateLocalPlayer:(GKLocalPlayer*)localPLayer;
@end

@implementation SVRootViewController

#pragma mark - Public

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
    self.view.backgroundColor = [SVTheme sharedTheme].localPlayerColor;
    self.wallsLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200) / 2,
                                                                self.view.frame.size.height / 2 - 50,
                                                                200,
                                                                60)];
    NSString* wallsString = @"Walls";
    NSMutableAttributedString* wallsText = [[NSMutableAttributedString alloc] initWithString:wallsString];
    [wallsText addAttribute:NSKernAttributeName value:@3 range:NSMakeRange(0, wallsString.length - 1)];
    self.wallsLabel.textColor = [UIColor whiteColor];
    self.wallsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:60];
    self.wallsLabel.textAlignment = NSTextAlignmentCenter;
    self.wallsLabel.attributedText = wallsText;
    [self.view addSubview:self.wallsLabel];
    
}

#pragma mark - Private

- (void)showSignIn {
    [self.wallsLabel removeFromSuperview];
    self.view.backgroundColor = [SVTheme sharedTheme].darkSquareColor;
    NSString* welcomeString = @"Welcome";
    NSMutableAttributedString* welcomeText = [[NSMutableAttributedString alloc] initWithString:welcomeString];
    [welcomeText addAttribute:NSKernAttributeName value:@3 range:NSMakeRange(0, welcomeString.length - 1)];
    
    UILabel* welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200) / 2,
                                                                      180,
                                                                      200,
                                                                      21)];
    welcomeLabel.textColor = [UIColor whiteColor];
    welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:23];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    welcomeLabel.attributedText = welcomeText;
    [self.view addSubview:welcomeLabel];
    
    NSString* explanationString = @"Walls uses Game Center to connect with your friends and play online";
    NSMutableAttributedString* explanationText = [[NSMutableAttributedString alloc] initWithString:explanationString];
    [explanationText addAttribute:NSKernAttributeName value:@3 range:NSMakeRange(0, explanationString.length - 1)];
    
    UILabel* explanationLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 250) / 2,
                                                                          CGRectGetMaxY(welcomeLabel.frame) + 10,
                                                                          250,
                                                                          60)];
    explanationLabel.textColor = [UIColor whiteColor];
    explanationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    explanationLabel.textAlignment = NSTextAlignmentCenter;
    explanationLabel.attributedText = explanationText;
    explanationLabel.numberOfLines = 3;
    [self.view addSubview:explanationLabel];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.frame.size.width - 105) / 2,
                              CGRectGetMaxY(explanationLabel.frame) + 10,
                              105,
                              30);
    button.layer.cornerRadius = 15;
    button.backgroundColor = [UIColor whiteColor];
    NSString* signInString = @"Sign in";
    NSMutableAttributedString* signInText = [[NSMutableAttributedString alloc] initWithString:signInString];
    [signInText addAttribute:NSKernAttributeName value:@2 range:NSMakeRange(0, signInString.length - 1)];
    button.titleLabel.textColor = [SVTheme sharedTheme].darkSquareColor;
    [button setAttributedTitle:signInText forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    self.signInButton = button;
}

- (void)authenticateLocalPlayer {
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    GKLocalPlayer* __weak weakSelf = localPlayer;
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (weakSelf.isAuthenticated) {
            [self didAuthenticateLocalPlayer:weakSelf];
        }
        
        else if (viewController != nil) {
            [self showSignIn];
            self.gameCenterController = viewController;
        }
        else {
            [self showSignIn];
        }
    };
}

- (void)didAuthenticateLocalPlayer:(GKLocalPlayer *)localPlayer {
    SVGamesTableViewController* controller = [[SVGamesTableViewController alloc] init];
    self.containerController.view.frame = self.view.bounds;
    [self.containerController pushViewController:controller];
    [self.view addSubview:self.containerController.view];
}

#pragma mark - Target

- (void)didClickButton:(id)sender {
    if (self.gameCenterController) {
        [self presentViewController:self.gameCenterController
                           animated:YES
                         completion:nil];
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Connection error"
                                                        message:@"Please check your internet connection and relaunch Walls"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
