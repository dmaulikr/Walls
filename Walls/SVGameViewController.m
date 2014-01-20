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
@property (assign) int turn;
@property (strong) NSArray* playerColors;

- (SVPosition*)squarePositionForView:(SVSquareView*)squareView;
- (SVSquareView*)squareViewForPosition:(SVPosition*)position;
- (void)didClickSquare:(UIGestureRecognizer*)gestureRecognizer;
@end

@implementation SVGameViewController

- (id)init
{
    self = [super init];
    if (self) {
        _squareViews = [[NSMutableArray alloc] init];
        _board = [[SVBoard alloc] init];
        _turn = 0;
        _playerColors = [[NSArray alloc] initWithObjects:[UIColor blueColor], [UIColor redColor], nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    for (int i = 0; i < self.board.size.height; i++) {
        for (int j = 0; j < self.board.size.width; j++) {
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
            
            [self.squareViews addObject:squareView];
            
            UITapGestureRecognizer* gestureReconizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickSquare:)];
            [squareView addGestureRecognizer:gestureReconizer];
            [self.view addSubview:squareView];
        }
    }
    
    SVSquareView* player1View = [self squareViewForPosition:self.board.playerPositions[kSVPlayer1]];
    player1View.backgroundColor = self.playerColors[kSVPlayer1];
    SVSquareView* player2View = [self squareViewForPosition:self.board.playerPositions[kSVPlayer2]];
    player2View.backgroundColor = self.playerColors[kSVPlayer2];
}

- (SVPosition*)squarePositionForView:(SVSquareView*)view {
    int index = (int)[self.squareViews indexOfObject:view];
    return [[SVPosition alloc] initWithX:index % (int)(self.board.size.width) andY:floor(index / self.board.size.width)];
}

- (SVSquareView*)squareViewForPosition:(SVPosition*)position {
    int index = position.x + position.y * (self.board.size.width);
    return self.squareViews[index];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)index {
    [alertView dismissWithClickedButtonIndex:index animated:true];
}

- (void)didClickSquare:(UITapGestureRecognizer*)gestureRecognizer {
    kSVPlayer player = self.turn % 2;
    SVSquareView* newSquareView = (SVSquareView*)gestureRecognizer.view;
    SVPosition* newSquarePosition = [self squarePositionForView:newSquareView];
    if (![self.board canPlayer:player moveTo:newSquarePosition]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid move"
                                                        message:@"Choose another square"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Ok", nil];
        [alert show];
    }
    else {
        SVPosition* lastPlayerPosition = self.board.playerPositions[player];
        SVSquareView* lastSquareView = [self squareViewForPosition:lastPlayerPosition];
        if ((lastPlayerPosition.x + lastPlayerPosition.y) % 2 == 0)
            lastSquareView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        else
            lastSquareView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        newSquareView.backgroundColor = self.playerColors[player];
        [self.board movePlayer:player to:newSquarePosition];
        self.turn++;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
