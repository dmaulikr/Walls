//
//  SVCustomContainerController.m
//  Walls
//
//  Created by Sebastien Villar on 25/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVCustomContainerController.h"


@interface SVCustomContainerController ()
@end

@implementation SVCustomContainerController

#pragma mark - Public

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

- (void)pushViewController:(UIViewController*)controller topBarVisible:(BOOL)visible {
    [self addChildViewController:controller];
    if (visible) {
        controller.view.frame = CGRectMake(0,
                                           CGRectGetMaxY(self.topBarView.frame),
                                           self.view.frame.size.width,
                                           self.view.frame.size.height - CGRectGetMaxY(self.topBarView.frame));
    }
    else {
        controller.view.frame = self.view.bounds;
    }
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

- (void)popViewController {
    if (!self.childViewControllers.count > 1)
        return;
    
    UIViewController* topController = [self.childViewControllers lastObject];
    [topController willMoveToParentViewController:nil];
    [topController.view removeFromSuperview];
    [topController removeFromParentViewController];
}

@end
