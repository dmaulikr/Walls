//
//  SVGameViewController.m
//  Walls
//
//  Created by Sebastien Villar on 20/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVGameViewController.h"
#import "SVBoard.h"
#import "SVWallView.h"

@interface SVGameViewController ()
@property (strong) NSMutableDictionary* wallViews;
@property (strong) SVBoard* board;
@property (strong) NSArray* playerColors;
@property (strong) NSMutableArray* wallsRemaining;
@property (strong) NSMutableArray* specialWallsRemaining;
@property (strong) SVBoardView* boardView;

@property (assign) kSVPlayer currentPlayer;
@property (assign) int turn;
@property (strong) NSMutableDictionary* changes;

//Walls
@property (strong) SVWallView* buildingWallView;
@property (assign) kSVPanDirection buildingWallViewDirection;
@property (assign) BOOL ignoreBuildingWall;

@property (strong) UIAlertView* playerDidWinAlert;
@property (strong) SVWallView* wall;
@property (strong, readonly) UIColor* normalWallColor;

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
        _wallViews = [[NSMutableDictionary alloc] init];
        _wallsRemaining = [[NSMutableArray alloc] init];
        [_wallsRemaining addObject:[NSNumber numberWithInt:6]];
        [_wallsRemaining addObject:[NSNumber numberWithInt:6]];
        _specialWallsRemaining = [[NSMutableArray alloc] init];
        [_specialWallsRemaining addObject:[NSNumber numberWithInt:2]];
        [_specialWallsRemaining addObject:[NSNumber numberWithInt:2]];
        _normalWallColor = [UIColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
        _board = [[SVBoard alloc] init];
        _turn = 0;
        _changes = [[NSMutableDictionary alloc] init];
        _playerColors = [[NSArray alloc] initWithObjects:[UIColor blueColor], [UIColor redColor], nil];
    }
    return self;
}

- (void)boardView:(SVBoardView *)boardView didStartPanAt:(CGPoint)point withDirection:(kSVPanDirection)direction {
    SVPosition* position = [boardView intersectionPositionForPoint:point];
    SVPosition* wallPosition;
    kSVWallOrientation orientation;
    if (direction == kSVLeftDirection) {
        orientation = kSVHorizontalOrientation;
        wallPosition = [[SVPosition alloc] initWithX:position.x - 1 andY:position.y];
    }
    else if (direction == kSVRightDirection) {
        orientation = kSVHorizontalOrientation;
        wallPosition = [[SVPosition alloc] initWithX:position.x + 1 andY:position.y];
    }
    else if (direction == kSVTopDirection) {
        orientation = kSVVerticalOrientation;
        wallPosition = [[SVPosition alloc] initWithX:position.x andY:position.y - 1];
    }
    else {
        orientation = kSVVerticalOrientation;
        wallPosition = [[SVPosition alloc] initWithX:position.x andY:position.y + 1];
    }
        
    self.ignoreBuildingWall = ![self.board isWallLegalAtPosition:wallPosition withOrientation:orientation andType:normal];
    if (self.ignoreBuildingWall)
        return;
    
    int length = 92;
    int thickness = 8;
    
    if ((orientation == kSVHorizontalOrientation && wallPosition.x == 1) ||
        (orientation == kSVHorizontalOrientation && wallPosition.x == self.board.size.width - 1))
        length = 91;
    else if ((orientation == kSVVerticalOrientation && wallPosition.y == 1) ||
        (orientation == kSVVerticalOrientation && wallPosition.y == self.board.size.height - 1))
        length = 91.5;
    
    CGRect rect;
    if (direction == kSVTopDirection) {
        rect = CGRectMake(point.x - thickness / 2,
                          point.y - length,
                          thickness,
                          length);
    }
    else if (direction == kSVRightDirection) {
        rect = CGRectMake(point.x,
                          point.y - thickness / 2,
                          length,
                          thickness);
    }
    else if (direction == kSVBottomDirection) {
        rect = CGRectMake(point.x - thickness / 2,
                          point.y,
                          thickness,
                          length);
    }
    else {
        rect = CGRectMake(point.x - length,
                          point.y - thickness / 2,
                          length,
                          thickness);
    }
    self.buildingWallViewDirection = direction;
    self.buildingWallView = [[SVWallView alloc] initWithFrame:rect
                                                    startType:kSVWallViewTopOriented
                                                      endType:kSVWallViewBottomOriented leftColor:self.normalWallColor centerColor:[UIColor blueColor] rightColor:self.normalWallColor];
    [self.boardView addSubview:self.buildingWallView];
}

- (void)boardView:(SVBoardView *)boardView didChangePanTo:(CGPoint)point {
    if (self.ignoreBuildingWall)
        return;
    
    CGRect rect;
    if (self.buildingWallViewDirection == kSVTopDirection) {
        rect = CGRectMake(0,
                          point.y - self.buildingWallView.frame.origin.y,
                          self.buildingWallView.frame.size.width,
                          self.buildingWallView.frame.size.height - (point.y - self.buildingWallView.frame.origin.y));
    }
    else if (self.buildingWallViewDirection == kSVRightDirection) {
        rect = CGRectMake(0,
                          0,
                          point.x - self.buildingWallView.frame.origin.x,
                          self.buildingWallView.frame.size.height);
    }
    else if (self.buildingWallViewDirection == kSVBottomDirection) {
        rect = CGRectMake(0,
                          0,
                          self.buildingWallView.frame.size.width,
                          point.y - self.buildingWallView.frame.origin.y);
    }
    else {
        rect = CGRectMake(point.x - self.buildingWallView.frame.origin.x,
                          0,
                          self.buildingWallView.frame.size.width - (point.x - self.buildingWallView.frame.origin.x),
                          self.buildingWallView.frame.size.height);
    }
    [self.buildingWallView showRect:rect animated:NO withFinishBlock:nil];
}

- (void)boardView:(SVBoardView *)boardView didEndPanAt:(CGPoint)point changeOfDirection:(BOOL)change {
    if (self.ignoreBuildingWall)
        return;
    
    if (self.buildingWallView.shownRect.size.width >= self.buildingWallView.frame.size.width - 15 &&
        self.buildingWallView.shownRect.size.height >= self.buildingWallView.frame.size.height - 15) {
        [self.buildingWallView showRect:self.buildingWallView.bounds animated:YES withFinishBlock:nil];
        //Add wall
    }
    else {
        CGRect rect;
        if (self.buildingWallViewDirection == kSVTopDirection)
            rect = CGRectMake(0, self.buildingWallView.frame.size.height, self.buildingWallView.frame.size.width, 0);
        else if (self.buildingWallViewDirection == kSVRightDirection)
            rect = CGRectMake(0, 0, 0, self.buildingWallView.frame.size.height);
        else if (self.buildingWallViewDirection == kSVBottomDirection)
            rect = CGRectMake(0, 0, self.buildingWallView.frame.size.width, 0);
        else
            rect = CGRectMake(self.buildingWallView.frame.size.width, 0, 0, self.buildingWallView.frame.size.height);
            
        [self.buildingWallView showRect:rect animated:!change withFinishBlock:^(void){
            [self.buildingWallView removeFromSuperview];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithRed:0.44 green:0.44 blue:0.44 alpha:1.0];
    
    self.boardView = [[SVBoardView alloc] initWithFrame:CGRectMake(0, 40, 320, 400)];
    self.boardView.delegate = self;
    [self.view addSubview:self.boardView];
    
    UIButton* cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(didClickCancel) forControlEvents:UIControlEventTouchUpInside];
    cancel.frame = CGRectMake(20,
                              self.view.bounds.size.height - 50 - 10,
                              100,
                              50);
    [self.view addSubview:cancel];
    
    UIButton* validate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [validate setTitle:@"Validate" forState:UIControlStateNormal];
    [validate addTarget:self action:@selector(didClickValidate) forControlEvents:UIControlEventTouchUpInside];
    validate.frame = CGRectMake(self.view.bounds.size.width - 100 - 20,
                              self.view.bounds.size.height - 50 - 10,
                              100,
                              50);
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

- (void)revertChanges {
//    NSArray* keys = [self.changes allKeys];
//    for (NSString* key in keys) {
//        if ([key isEqualToString:@"newPosition"]) {
//            SVPosition* newSquarePosition = [self.changes objectForKey:key];
//            SVSquareView* newSquareView = [self.squareViews objectForKey:newSquarePosition];
//            SVPosition* lastPosition = self.board.playerPositions[self.currentPlayer];
//            SVSquareView* lastSquareView = [self.squareViews objectForKey:lastPosition];
//            if ((newSquarePosition.x + newSquarePosition.y) % 2 == 0)
//                newSquareView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
//            else
//                newSquareView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
//            lastSquareView.backgroundColor = self.playerColors[self.currentPlayer];
//        }
//        else if ([key isEqualToString:@"newWall"]) {
//            SVWall* wall = [self.changes objectForKey:key];
//            UIView* wallView = [self.wallViews objectForKey:wall.position];
//            [wallView removeFromSuperview];
//            [self.changes removeObjectForKey:key];
//        }
//    }
//    [self.changes removeAllObjects];
}

- (void)commitChanges {
//    NSArray* keys = [self.changes allKeys];
//    for (NSString* key in keys) {
//        if ([key isEqualToString:@"newPosition"]) {
//            [self.board movePlayer:self.currentPlayer to:[self.changes objectForKey:(key)]];
//        }
//        else if ([key isEqualToString:@"newWall"]) {
//            SVWall* wall = [self.changes objectForKey:(key)];
//            kSVWallType type;
//            if ((wall.type == kSVWallNormal && [self.wallsRemaining[self.currentPlayer] intValue] > 0) ||
//                [self.specialWallsRemaining[self.currentPlayer] intValue] <= 0) {
//                self.wallsRemaining[self.currentPlayer] = [NSNumber numberWithInt:[self.wallsRemaining[self.currentPlayer] intValue] - 1];
//                type = kSVWallNormal;
//            }
//            else {
//                self.specialWallsRemaining[self.currentPlayer] = [NSNumber numberWithInt:[self.specialWallsRemaining[self.currentPlayer] intValue] - 1];
//                type = self.currentPlayer == kSVPlayer1 ? kSVWallPlayer1 : kSVWallPlayer2;
//            }
//            [self.board addWallAtPosition:wall.position
//                          withOrientation:wall.orientation
//                                  andType:type];
//        }
//    }
//    [self.changes removeAllObjects];
}

- (void)didTapSquare:(UITapGestureRecognizer*)gestureRecognizer {
//    SVSquareView* newSquareView = (SVSquareView*)gestureRecognizer.view;
//    SVPosition* newSquarePosition = [[self.squareViews allKeysForObject:newSquareView] objectAtIndex:0];
//    if (![self.board canPlayer:self.currentPlayer moveTo:newSquarePosition]) {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid move"
//                                                        message:@"Choose another square"
//                                                       delegate:self
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:@"Ok", nil];
//        [alert show];
//    }
//    else {
//        SVPosition* lastPlayerPosition = self.board.playerPositions[self.currentPlayer];
//        SVSquareView* lastSquareView = [self.squareViews objectForKey:lastPlayerPosition];
//        if ((lastPlayerPosition.x + lastPlayerPosition.y) % 2 == 0)
//            lastSquareView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
//        else
//            lastSquareView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
//        newSquareView.backgroundColor = self.playerColors[self.currentPlayer];
//        [self.changes setObject:newSquarePosition forKey:@"newPosition"];
//    }
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
    return self.changes.count < 1 && [self.wallsRemaining[self.currentPlayer] intValue] + [self.specialWallsRemaining[self.currentPlayer] intValue] > 0;
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
