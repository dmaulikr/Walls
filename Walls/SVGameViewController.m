//
//  SVGameViewController.m
//  Walls
//
//  Created by Sebastien Villar on 20/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVGameViewController.h"
#import "SVBoard.h"
#import "SVSquareView.h"

const int kSVSquareSize = 46;

@interface SVGameViewController ()
@property (strong) NSMutableArray* squareViews;
@property (strong) SVBoard* board;
@end

@implementation SVGameViewController

- (id)init
{
    self = [super init];
    if (self) {
        _squareViews = [[NSMutableArray alloc] init];
        _board = [[SVBoard alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    for (int i = 0; i < self.board.size.height; i++) {
        for (int j = 0; j < self.board.size.height; j++) {
            CGSize squareSize;
            if (j == 0 || j == self.board.size.height - 1)
                squareSize = CGSizeMake(kSVSquareSize - 1, kSVSquareSize);
            else
                squareSize = CGSizeMake(kSVSquareSize, kSVSquareSize);
            SVSquareView* squareView = [[SVSquareView alloc] initWithFrame:CGRectMake(j * kSVSquareSize,
                                                                                      i * kSVSquareSize + 40,
                                                                                      kSVSquareSize,
                                                                                      kSVSquareSize)];
            if ((i + j) % 2 == 0)
                squareView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
            else
                squareView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            [self.view addSubview:squareView];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
