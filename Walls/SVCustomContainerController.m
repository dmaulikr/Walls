//
//  SVCustomContainerController.m
//  Walls
//
//  Created by Sebastien Villar on 25/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVCustomContainerController.h"


@interface SVCustomContainerController ()
@property (strong) UIViewController* topController;
@end

@implementation SVCustomContainerController

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.topBarView = [[SVTopBarView alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     self.view.frame.size.width,
                                                                     49)];
    [self.view addSubview:self.topBarView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController*)controller {
    [self addChildViewController:controller];
    self.topBarView.leftButton = nil;
    self.topBarView.rightButton = nil;
    
    controller.view.frame = CGRectMake(0,
                                       CGRectGetMaxY(self.topBarView.frame),
                                       self.view.frame.size.width,
                                       self.view.frame.size.height - CGRectGetMaxY(self.topBarView.frame));
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

- (void)popViewController {
    if (!self.topController)
        return;
    [self.topController willMoveToParentViewController:nil];
    [self.topController.view removeFromSuperview];
    [self.topController removeFromParentViewController];
    self.topController = nil;
    if (self.childViewControllers.count > 0) {
        self.topController = [self.childViewControllers lastObject];
    }
}

- (void)addChildViewController:(UIViewController *)childController {
    [super addChildViewController:childController];
    self.topController = childController;
}


@end
