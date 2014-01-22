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
#import "SVBoardCanvas.h"

typedef enum {
    kSVLeftDirection,
    kSVRightDirection,
    kSVTopDirection,
    kSVBottomDirection
} kSVWallDirection;

const int kSVSquareSize = 46;

@interface SVGameViewController ()
@property (strong) NSMutableDictionary* squareViews;
@property (strong) NSMutableDictionary* wallViews;
@property (strong) SVBoard* board;
@property (strong) NSArray* playerColors;
@property (strong) NSMutableArray* wallsRemaining;
@property (strong) UIView* boardView;
@property (strong) SVBoardCanvas* boardCanvas;

@property (assign) kSVPlayer currentPlayer;
@property (assign) int turn;
@property (strong) NSMutableDictionary* changes;

//Walls
@property (strong) NSArray* wallPoints;
@property (strong) SVPosition* wallPosition;
@property (assign) kSVWallOrientation wallOrientation;
@property (assign) kSVWallDirection wallDirection;
@property (assign) CGPoint lastWallPoint;

@property (strong) UIAlertView* playerDidWinAlert;

- (NSArray*)wallPointsForPosition:(SVPosition*)position withOrientation:(kSVWallOrientation)orientation andDirection:(kSVWallDirection) direction;
- (void)didPanOnBoard:(UIPanGestureRecognizer*)gestureRecognizer;
- (void)didTapSquare:(UIGestureRecognizer*)gestureRecognizer;
- (void)didClickCancel;
- (void)didClickValidate;
- (void)revertChanges;
- (void)commitChanges;
- (void)startTurn;
- (void)endTurn;
@end

@implementation SVGameViewController

//////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////

- (id)init
{
    self = [super init];
    if (self) {
        _squareViews = [[NSMutableDictionary alloc] init];
        _wallViews = [[NSMutableDictionary alloc] init];
        _wallPoints = [[NSMutableArray alloc] init];
        _wallsRemaining = [[NSMutableArray alloc] init];
        [_wallsRemaining addObject:[NSNumber numberWithInt:8]];
        [_wallsRemaining addObject:[NSNumber numberWithInt:8]];
        _board = [[SVBoard alloc] init];
        _turn = 0;
        _changes = [[NSMutableDictionary alloc] init];
        _playerColors = [[NSArray alloc] initWithObjects:[UIColor blueColor], [UIColor redColor], nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.boardView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 320, self.board.size.height * kSVSquareSize)];
    UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanOnBoard:)];
    gestureRecognizer.minimumNumberOfTouches = 1;
    gestureRecognizer.maximumNumberOfTouches = 1;
    gestureRecognizer.delegate = self;
    [self.boardView addGestureRecognizer:gestureRecognizer];
    [self.view addSubview:self.boardView];
    
    for (int i = 0; i < self.board.size.height; i++) {
        for (int j = 0; j < self.board.size.width; j++) {
            CGSize squareSize;
            //Due to square with different sizes
            int xOffset = 0;
            
            if (j == 0 || j == self.board.size.height - 1)
                squareSize = CGSizeMake(kSVSquareSize - 1, kSVSquareSize);
            else {
                squareSize = CGSizeMake(kSVSquareSize, kSVSquareSize);
                xOffset = -1;
            }
            
            SVSquareView* squareView = [[SVSquareView alloc] initWithFrame:CGRectMake(j * kSVSquareSize + xOffset,
                                                                                      i * kSVSquareSize,
                                                                                      squareSize.width,
                                                                                      squareSize.height)];
            if ((i + j) % 2 == 0)
                squareView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
            else
                squareView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            
            [self.squareViews setObject:squareView forKey:[[SVPosition alloc] initWithX:j andY:i]];
            
            UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSquare:)];
            [squareView addGestureRecognizer:gestureRecognizer];
            gestureRecognizer.delegate = self;
            [self.boardView addSubview:squareView];
        }
    }
    
    SVSquareView* player1View = [self.squareViews objectForKey:self.board.playerPositions[kSVPlayer1]];
    player1View.backgroundColor = self.playerColors[kSVPlayer1];
    SVSquareView* player2View = [self.squareViews objectForKey:self.board.playerPositions[kSVPlayer2]];
    player2View.backgroundColor = self.playerColors[kSVPlayer2];
    
    self.boardCanvas = [[SVBoardCanvas alloc] initWithFrame:self.boardView.bounds];
    self.boardCanvas.userInteractionEnabled = NO;
    [self.boardView addSubview:self.boardCanvas];
    
    UIButton* cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(didClickCancel) forControlEvents:UIControlEventTouchUpInside];
    cancel.frame = CGRectMake(20,
                              self.view.bounds.size.height - 30 - 20,
                              100,
                              30);
    [self.view addSubview:cancel];
    
    UIButton* validate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [validate setTitle:@"Validate" forState:UIControlStateNormal];
    [validate addTarget:self action:@selector(didClickValidate) forControlEvents:UIControlEventTouchUpInside];
    validate.frame = CGRectMake(self.view.bounds.size.width - 100 - 20,
                              self.view.bounds.size.height - 30 - 20,
                              100,
                              30);
    [self.view addSubview:validate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////
// Private
//////////////////////////////////////////////////////

- (void)startTurn {
    if (self.turn % 2 == 0)
        self.currentPlayer = kSVPlayer1;
    else
        self.currentPlayer = kSVPlayer2;
    self.changes = [[NSMutableDictionary alloc] init];
}

- (void)endTurn {
    if ([self.board didPlayerWin:self.currentPlayer]) {
        self.playerDidWinAlert = [[UIAlertView alloc] initWithTitle:@"Congratulation"
                                                        message:@"Player 1 has won"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Restart", nil];
        [self.playerDidWinAlert show];
    }
    self.turn++;
}

//Return start point and end point relative to direction
- (NSArray*)wallPointsForPosition:(SVPosition*)position withOrientation:(kSVWallOrientation)orientation andDirection:(kSVWallDirection) direction{
    NSArray* array;
    CGPoint start;
    CGPoint end;
    if (orientation == kSVHorizontalOrientation) {
        CGPoint left;
        CGPoint right;
        if (position.x == 1) {
            left = CGPointMake(0, position.y * kSVSquareSize);
            right = CGPointMake(2 * kSVSquareSize - 1, left.y);
        }
        else if (position.x == self.board.size.width - 1) {
            left = CGPointMake((position.x - 1) * kSVSquareSize - 1, position.y * kSVSquareSize);
            right = CGPointMake(left.x + 2 * kSVSquareSize - 1, left.y);
        }
        else {
            left = CGPointMake((position.x - 1) * kSVSquareSize - 1, position.y * kSVSquareSize);
            right = CGPointMake(left.x + 2 * kSVSquareSize, left.y);
        }
        if (direction == kSVLeftDirection) {
            start = right;
            end = left;
        }
        else {
            start = left;
            end = right;
        }
    }
    else {
        CGPoint top = CGPointMake(position.x * kSVSquareSize - 1, (position.y - 1) * kSVSquareSize);
        CGPoint bottom = CGPointMake(top.x, top.y + 2 * kSVSquareSize);
        if (direction == kSVTopDirection) {
            start = bottom;
            end = top;
        }
        else {
            start = top;
            end = bottom;
        }
    }
    array = [[NSArray alloc] initWithObjects:[NSValue valueWithCGPoint:start],
                                             [NSValue valueWithCGPoint:end], nil];
    return array;
}

- (void)revertChanges {
    NSArray* keys = [self.changes allKeys];
    for (NSString* key in keys) {
        if ([key isEqualToString:@"newPosition"]) {
            SVPosition* newSquarePosition = [self.changes objectForKey:key];
            SVSquareView* newSquareView = [self.squareViews objectForKey:newSquarePosition];
            SVPosition* lastPosition = self.board.playerPositions[self.currentPlayer];
            SVSquareView* lastSquareView = [self.squareViews objectForKey:lastPosition];
            if ((newSquarePosition.x + newSquarePosition.y) % 2 == 0)
                newSquareView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
            else
                newSquareView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            lastSquareView.backgroundColor = self.playerColors[self.currentPlayer];
        }
        else if ([key isEqualToString:@"newWall"]) {
            UIView* wallView = [self.wallViews objectForKey:[self.changes objectForKey:key]];
            [wallView removeFromSuperview];
            [self.changes removeObjectForKey:key];
        }
    }
    [self.changes removeAllObjects];
}

- (void)commitChanges {
    NSArray* keys = [self.changes allKeys];
    for (NSString* key in keys) {
        if ([key isEqualToString:@"newPosition"]) {
            [self.board movePlayer:self.currentPlayer to:[self.changes objectForKey:(key)]];
        }
        else if ([key isEqualToString:@"newWall"]) {
            [self.board addWallAtPosition:[self.changes objectForKey:(key)] withOrientation:self.wallOrientation];
            self.wallsRemaining[self.currentPlayer] = [NSNumber numberWithInt:[self.wallsRemaining[self.currentPlayer] intValue] - 1];
        }
    }
    [self.changes removeAllObjects];
}

- (void)didPanOnBoard:(UIPanGestureRecognizer*)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self.boardView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //Find wall position and end points
        CGPoint velocity = [gestureRecognizer velocityInView:self.boardView];
        int x = round(touchPoint.x / kSVSquareSize);
        int y = round(touchPoint.y / kSVSquareSize);
        
        if (abs(velocity.x) > abs(velocity.y)) {
            x = velocity.x > 0 ? x + 1: x - 1;
            self.wallDirection = velocity.x > 0 ? kSVRightDirection : kSVLeftDirection;
            self.wallOrientation = kSVHorizontalOrientation;
        }
        else {
            y = velocity.y > 0 ? y + 1 : y - 1;
            self.wallDirection = velocity.y > 0 ? kSVBottomDirection : kSVTopDirection;
            self.wallOrientation = kSVVerticalOrientation;
        }
        
        self.wallPosition = [[SVPosition alloc] initWithX:x andY:y];
        self.wallPoints = [self wallPointsForPosition:self.wallPosition
                                      withOrientation:self.wallOrientation
                                         andDirection:self.wallDirection];
        self.lastWallPoint = [self.wallPoints[0] CGPointValue];
    }
    
    else {
        CGPoint minPoint;
        CGPoint maxPoint;
        
        if (self.wallDirection == kSVLeftDirection ||
            self.wallDirection == kSVTopDirection) {
            minPoint = [self.wallPoints[1] CGPointValue];
            maxPoint = [self.wallPoints[0] CGPointValue];
        }
        else {
            minPoint = [self.wallPoints[0] CGPointValue];
            maxPoint = [self.wallPoints[1] CGPointValue];
        }
        
        //Draw line from last point to touchpoint if needed
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            BOOL betweenPoints = NO;
            
            if (self.wallOrientation == kSVHorizontalOrientation) {
                betweenPoints = touchPoint.x >= minPoint.x && touchPoint.x <= maxPoint.x;
                touchPoint.y = minPoint.y;
            }
            else {
                betweenPoints = touchPoint.y >= minPoint.y && touchPoint.y <= maxPoint.y;
                touchPoint.x = minPoint.x;
            }
            
            if (betweenPoints) {
                [self.boardCanvas drawLineFrom:self.lastWallPoint to:touchPoint];
                self.lastWallPoint = touchPoint;
            }
            else {
                if (!CGPointEqualToPoint(self.lastWallPoint, [self.wallPoints[1] CGPointValue])) {
                    [self.boardCanvas drawLineFrom:self.lastWallPoint to:[self.wallPoints[1] CGPointValue]];
                    self.lastWallPoint = [self.wallPoints[1] CGPointValue];
                }
            }
        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            //Build the wall if needed and clear canvas
            [self.boardCanvas clear];
            
            if ([self.board isWallLegalAtPosition:self.wallPosition withOrientation:self.wallOrientation]) {
                if (abs(self.lastWallPoint.x - [self.wallPoints[1] CGPointValue].x) < 10 &&
                    abs(self.lastWallPoint.y - [self.wallPoints[1] CGPointValue].y) < 10) {
                    UIView* wallView;
                    
                    if (self.wallOrientation == kSVHorizontalOrientation)
                        wallView = [[UIView alloc] initWithFrame:CGRectMake(minPoint.x, minPoint.y - 5, abs(maxPoint.x - minPoint.x), 10)];
                    else
                        wallView = [[UIView alloc] initWithFrame:CGRectMake(minPoint.x - 5, minPoint.y, 10, abs(maxPoint.y - minPoint.y))];
                    
                    wallView.backgroundColor = [UIColor blackColor];
                    [self.wallViews setObject:wallView forKey:self.wallPosition];
                    [self.changes setObject:self.wallPosition forKey:@"newWall"];
                    [self.boardView addSubview:wallView];
                }
            }
            else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid build"
                                                                message:@"Choose another place to build"
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Ok", nil];
                [alert show];
            }
        }
    }
}

- (void)didTapSquare:(UITapGestureRecognizer*)gestureRecognizer {
    SVSquareView* newSquareView = (SVSquareView*)gestureRecognizer.view;
    SVPosition* newSquarePosition = [[self.squareViews allKeysForObject:newSquareView] objectAtIndex:0];
    if (![self.board canPlayer:self.currentPlayer moveTo:newSquarePosition]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid move"
                                                        message:@"Choose another square"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Ok", nil];
        [alert show];
    }
    else {
        SVPosition* lastPlayerPosition = self.board.playerPositions[self.currentPlayer];
        SVSquareView* lastSquareView = [self.squareViews objectForKey:lastPlayerPosition];
        if ((lastPlayerPosition.x + lastPlayerPosition.y) % 2 == 0)
            lastSquareView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        else
            lastSquareView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        newSquareView.backgroundColor = self.playerColors[self.currentPlayer];
        [self.changes setObject:newSquarePosition forKey:@"newPosition"];
    }
}

- (void)didClickCancel {
    [self revertChanges];
}

- (void)didClickValidate {
    if (self.changes.count == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Can't validate"
                                                        message:@"Please play first"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    [self commitChanges];
    [self endTurn];
    [self startTurn];
}

- (BOOL)canAddWall {
    return self.changes.count < 1 && [self.wallsRemaining[self.currentPlayer] intValue] > 0;
}

- (BOOL)canMovePlayer {
    return self.changes.count < 1;
}

//////////////////////////////////////////////////////
// Delegates
//////////////////////////////////////////////////////

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)index {
    [alertView dismissWithClickedButtonIndex:index animated:true];
    if (alertView == self.playerDidWinAlert) {
        SVGameViewController* newGameViewController = [[SVGameViewController alloc] init];
        [[[UIApplication sharedApplication] delegate] window].rootViewController = newGameViewController;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
        return [self canMovePlayer];
    else
        return [self canAddWall];
}


@end
