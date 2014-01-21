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
@property (strong) NSMutableArray* squareViews;
@property (strong) NSMutableArray* squarePositions;
@property (strong) SVBoard* board;
@property (strong) NSArray* playerColors;
@property (strong) UIView* boardView;
@property (strong) SVBoardCanvas* boardCanvas;

@property (assign) kSVPlayer currentPlayer;
@property (assign) int turn;

//Touch
@property (strong) NSArray* wallPoints;
@property (strong) SVPosition* wallPosition;
@property (assign) kSVWallOrientation wallOrientation;
@property (assign) kSVWallDirection wallDirection;
@property (assign) CGPoint lastWallPoint;

- (void)didPanOnBoard:(UIPanGestureRecognizer*)gestureRecognizer;
- (void)didTapSquare:(UIGestureRecognizer*)gestureRecognizer;
@end

@implementation SVGameViewController

//////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////

- (id)init
{
    self = [super init];
    if (self) {
        _squareViews = [[NSMutableArray alloc] init];
        _squarePositions = [[NSMutableArray alloc] init];
        _wallPoints = [[NSMutableArray alloc] init];
        _board = [[SVBoard alloc] init];
        _turn = 0;
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
            
            [self.squareViews addObject:squareView];
            [self.squarePositions addObject:[[SVPosition alloc] initWithX:j andY:i]];
            
            UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSquare:)];
            [squareView addGestureRecognizer:gestureRecognizer];
            gestureRecognizer.delegate = self;
            [self.boardView addSubview:squareView];
        }
    }
    
//    SVSquareView* player1View = [self squareViewForPosition:self.board.playerPositions[kSVPlayer1]];
//    player1View.backgroundColor = self.playerColors[kSVPlayer1];
//    SVSquareView* player2View = [self squareViewForPosition:self.board.playerPositions[kSVPlayer2]];
//    player2View.backgroundColor = self.playerColors[kSVPlayer2];
    
    self.boardCanvas = [[SVBoardCanvas alloc] initWithFrame:self.boardView.bounds];
    self.boardCanvas.userInteractionEnabled = NO;
    [self.boardView addSubview:self.boardCanvas];
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
}

- (void)endTurn {
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

//- (SVPosition*)wallPositionForPoint:(CGPoint)point {
//    return nil;
//}
//
//- (CGPoint)pointForWallPosition:(SVPosition*)position {
//    
//}

- (void)movePlayer:(kSVPlayer)player to:(SVPosition*)position {
    SVPosition* lastPlayerPosition = self.board.playerPositions[self.currentPlayer];
    SVSquareView* lastSquareView = [self.squareViews objectAtIndex:[self.squarePositions indexOfObject:lastPlayerPosition]];
    if ((lastPlayerPosition.x + lastPlayerPosition.y) % 2 == 0)
        lastSquareView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    else
        lastSquareView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    SVSquareView* newSquareView =[self.squareViews objectAtIndex:[self.squarePositions indexOfObject:position]];
    newSquareView.backgroundColor = self.playerColors[self.currentPlayer];
    [self.board movePlayer:self.currentPlayer to:position];
}

- (void)addWallAtPosition:(SVPosition*)position withOrientation:(kSVWallOrientation)orientation {
//    CGRect frame;
//    int x;
//    int y;
//    int width;
//    int height;
//    if (orientation == kSVHorizontalOrientation) {
//        frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
//    }
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
                if (!CGPointEqualToPoint(self.lastWallPoint, maxPoint)) {
                    [self.boardCanvas drawLineFrom:self.lastWallPoint to:maxPoint];
                    self.lastWallPoint = maxPoint;
                }
            }
        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            //Build the wall if needed and clear canvas
            [self.boardCanvas clear];
            
            if ([self.board isWallLegalAtPosition:self.wallPosition withOrientation:self.wallOrientation]) {
                UIView* wallView;
    
                if (self.wallOrientation == kSVHorizontalOrientation)
                    wallView = [[UIView alloc] initWithFrame:CGRectMake(minPoint.x, minPoint.y - 5, abs(maxPoint.x - minPoint.x), 10)];
                else
                    wallView = [[UIView alloc] initWithFrame:CGRectMake(minPoint.x - 5, minPoint.y, 10, abs(maxPoint.y - minPoint.y))];
        
                wallView.backgroundColor = [UIColor blackColor];
                [self.boardView addSubview:wallView];
                [self.board addWallAtPosition:self.wallPosition withOrientation:self.wallOrientation];
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
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        CGPoint velocity = [gestureRecognizer velocityInView:self.boardView];
//        self.currentWallOrientation = abs(velocity.x) > abs(velocity.y) ? kSVHorizontalOrientation : kSVVerticalOrientation;
//        if (self.currentWallOrientation == kSVHorizontalOrientation)
//            self.currentWallBuildingDirection = velocity.x > 0 ? kSVRightDirection : kSVLeftDirection;
//        else
//            self.currentWallBuildingDirection = velocity.y > 0 ? kSVBottomDirection : kSVTopDirection;
//        
//        CGPoint startPoint = [gestureRecognizer locationInView:self.boardView];
//        CGPoint endPoint;
//        //Find the closest wall start;
//        int x = round(startPoint.x / kSVSquareSize);
//        int y = round(startPoint.y / kSVSquareSize);
//        
//        if (x == 0) {
//            startPoint = CGPointMake(, y * kSVSquareSize);
//            if (self.currentWallOrientation == kSVHorizontalOrientation) {
//                if (self.currentWallOrientation == kSVLeftDirection)
//                    endPoint = CGPointMake(-kSVSquareSize - 1, startPoint.y);
//                else
//                    endPoint = CGPointMake(2 * kSVSquareSize - 1, startPoint.y);
//            }
//            endPoint = CGPointMake(2 * kSVSquareSize - 1, startPoint.y);
//        }
//        else {
//            startPoint = CGPointMake(x * kSVSquareSize - 1, y * kSVSquareSize);
//            
//        }
//        self.startWallPoint = startPoint;
//        self.endWallPoint =
//        self.lastWallPoint = startPoint;
//    }
//    else {
//        //Adjust the point on the horizontal/vertical line
//        CGPoint newPoint = [gestureRecognizer locationInView:self.boardView];
//        int length;
//        if (self.currentWallOrientation == kSVHorizontalOrientation) {
//            newPoint = CGPointMake(newPoint.x, self.lastTouchPoint.y);
//            length = abs(newPoint.x - self.firstTouchPoint.x);
//        }
//        else {
//            newPoint = CGPointMake(self.lastTouchPoint.x, newPoint.y);
//            length = abs(newPoint.y - self.firstTouchPoint.y);
//        }
//        
//        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {;
//            //Check if wall valid and build
//            if (length >= 2 * kSVSquareSize - 10) {
//                int x = round((self.firstTouchPoint.x + self.lastTouchPoint.x) / 2);
//                int y = round((self.firstTouchPoint.y + self.lastTouchPoint.y) / 2);
//                SVPosition* wallPosition = [[SVPosition alloc] initWithX:round(x / kSVSquareSize) - 1
//                                                                    andY:round(y / kSVSquareSize) - 1];
//                if ([self.board isWallLegalAtPosition:wallPosition withOrientation:self.currentWallOrientation]) {
//                    UIView* wallView;
//                    int x;
//                    int y;
//                    int width;
//                    int height;
//                    
//                    if (self.currentWallOrientation == kSVHorizontalOrientation) {
//                        x = self.currentWallBuildingDirection == kSVLeftDirection ? self.lastTouchPoint.x : self.firstTouchPoint.x;
//                        y = self.firstTouchPoint.y - 5;
//                        width = 2 * kSVSquareSize;
//                        height = 10;
//                    }
//                    else {
//                        x = self.firstTouchPoint.x - 5;
//                        y = self.currentWallBuildingDirection == kSVTopDirection ? self.lastTouchPoint.y : self.firstTouchPoint.y;
//                        width = 10;
//                        height = 2 * kSVSquareSize;
//                    }
//                    
//                    wallView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
//                    wallView.backgroundColor = [UIColor blackColor];
//                    [self.boardView addSubview:wallView];
//                    [self.board addWallAtPosition:wallPosition withOrientation:self.currentWallOrientation];
//                }
//                else {
//                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid build"
//                                                                    message:@"Choose another place to build"
//                                                                   delegate:self
//                                                          cancelButtonTitle:nil
//                                                          otherButtonTitles:@"Ok", nil];
//                    [alert show];
//                }
//            }
//            [self.boardCanvas clear];
//        }
//        
//        else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//            if (!(self.lastTouchPoint.x == self.firstTouchPoint.x + 2 * kSVSquareSize ||
//                  self.lastTouchPoint.y == self.firstTouchPoint.y + 2 * kSVSquareSize ||
//                  self.lastTouchPoint.x == self.firstTouchPoint.x - 2 * kSVSquareSize ||
//                  self.lastTouchPoint.y == self.firstTouchPoint.y - 2 * kSVSquareSize)) {
//                
//                //Don't draw if the point is not in the wall
//                if (self.currentWallOrientation == kSVHorizontalOrientation) {
//                    if ((self.currentWallBuildingDirection == kSVLeftDirection && newPoint.x > self.lastTouchPoint.x) ||
//                        (self.currentWallBuildingDirection == kSVRightDirection && newPoint.x < self.lastTouchPoint.x))
//                        return;
//                }
//                else {
//                    if ((self.currentWallBuildingDirection == kSVTopDirection && newPoint.y > self.lastTouchPoint.y) ||
//                        (self.currentWallBuildingDirection == kSVBottomDirection && newPoint.y < self.lastTouchPoint.y))
//                        return;
//                }
//                
//                //Match the last point with the end of the wall
//                if (length > 2 * kSVSquareSize) {
//                    if (self.currentWallOrientation == kSVHorizontalOrientation) {
//                        if (self.currentWallBuildingDirection == kSVLeftDirection)
//                            newPoint = CGPointMake(self.firstTouchPoint.x - 2 * kSVSquareSize, self.firstTouchPoint.y);
//                        else
//                            newPoint = CGPointMake(self.firstTouchPoint.x + 2 * kSVSquareSize, self.firstTouchPoint.y);
//                    }
//                    else {
//                        if (self.currentWallBuildingDirection == kSVTopDirection)
//                            newPoint = CGPointMake(self.firstTouchPoint.x, self.firstTouchPoint.y - 2 * kSVSquareSize);
//                        else
//                            newPoint = CGPointMake(self.firstTouchPoint.x, self.firstTouchPoint.y + 2 * kSVSquareSize);
//                    }
//                }
//                [self.boardCanvas drawLineFrom:self.lastTouchPoint to:newPoint];
//                self.lastTouchPoint = newPoint;
//            }
//        }
//    }
}

- (void)didTapSquare:(UITapGestureRecognizer*)gestureRecognizer {
    SVSquareView* newSquareView = (SVSquareView*)gestureRecognizer.view;
    SVPosition* newSquarePosition = [self.squarePositions objectAtIndex:[self.squareViews indexOfObject:newSquareView]];
    if (![self.board canPlayer:self.currentPlayer moveTo:newSquarePosition]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid move"
                                                        message:@"Choose another square"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Ok", nil];
        [alert show];
    }
    else {
        [self movePlayer:self.currentPlayer to:newSquarePosition];
    }
}

//////////////////////////////////////////////////////
// Delegates
//////////////////////////////////////////////////////

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)index {
    [alertView dismissWithClickedButtonIndex:index animated:true];
}

@end
