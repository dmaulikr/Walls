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
@property (assign) BOOL clicked;


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
@property (assign) kSVWallType buildingWallType;
@property (assign) kSVWallOrientation buildingWallOrientation;
@property (strong) SVPosition* buildingWallPosition;
@property (assign) BOOL ignoreBuildingWall;
@property (strong) UIColor* buildingWallViewColor;

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
        _clicked = NO;
        _buildingWallViewColor = [UIColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
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

- (NSDictionary*)wallViewParametersForPosition:(SVPosition*)position andOrientation:(kSVWallOrientation)orientation {
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    SVWall* topLeft;
    SVWall* topRight;
    SVWall* bottomLeft;
    SVWall* bottomRight;
    SVWall* leftSameOrientation;
    SVWall* rightSameOrientation;
    SVWall* leftOtherOrientation;
    SVWall* rightOtherOrientation;
    
    float height = 8;
    if (orientation == kSVHorizontalOrientation) {
        topLeft = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x - 1 andY:position.y - 1]
                             withOrientation:kSVVerticalOrientation];
        topRight = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x + 1 andY:position.y - 1]
                              withOrientation:kSVVerticalOrientation];
        bottomLeft = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x - 1 andY:position.y + 1]
                                withOrientation:kSVVerticalOrientation];;
        bottomRight = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x + 1 andY:position.y + 1]
                                 withOrientation:kSVVerticalOrientation];;
        leftSameOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x - 2 andY:position.y]
                                          withOrientation:kSVHorizontalOrientation];
        rightSameOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x + 2 andY:position.y]
                                          withOrientation:kSVHorizontalOrientation];
        leftOtherOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x - 1 andY:position.y]
                                           withOrientation:kSVVerticalOrientation];
        rightOtherOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x + 1 andY:position.y]
                                           withOrientation:kSVVerticalOrientation];
    }
    else {
        topLeft = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x + 1 andY:position.y - 1]
                             withOrientation:kSVHorizontalOrientation];
        topRight = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x + 1 andY:position.y + 1]
                              withOrientation:kSVHorizontalOrientation];
        bottomLeft = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x - 1 andY:position.y - 1]
                                withOrientation:kSVHorizontalOrientation];;
        bottomRight = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x - 1 andY:position.y + 1]
                                 withOrientation:kSVHorizontalOrientation];;
        leftSameOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x andY:position.y - 2 ]
                                         withOrientation:kSVVerticalOrientation];
        rightSameOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x andY:position.y + 2]
                                          withOrientation:kSVVerticalOrientation];
        leftOtherOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x andY:position.y - 1]
                                          withOrientation:kSVHorizontalOrientation];
        rightOtherOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:position.x andY:position.y + 1]
                                           withOrientation:kSVHorizontalOrientation];
    }
    
    //Left
    if ((topLeft && bottomLeft) || leftOtherOrientation) {
        [dictionary setObject:[NSNumber numberWithInt:kSVWallViewSquared] forKey:@"leftType"];
        [dictionary setObject:self.buildingWallViewColor forKey:@"leftColor"];
        [dictionary setObject:[NSNumber numberWithFloat:height / 2] forKey:@"leftOffset"];
    }
    else if (leftSameOrientation) {
        SVWallView* wallView = [self.wallViews objectForKey:leftSameOrientation.position];
        [dictionary setObject:[NSNumber numberWithInt:kSVWallViewSquared] forKey:@"leftType"];
        [dictionary setObject:wallView.centerColor forKey:@"leftColor"];
        [dictionary setObject:[NSNumber numberWithFloat:-height / 2] forKey:@"leftOffset"];
    }
    else if (topLeft) {
        SVWallView* wallView = [self.wallViews objectForKey:topLeft.position];
        [dictionary setObject:[NSNumber numberWithInt:kSVWallViewTopOriented] forKey:@"leftType"];
        [dictionary setObject:wallView.centerColor forKey:@"leftColor"];
        [dictionary setObject:[NSNumber numberWithFloat:-height / 2] forKey:@"leftOffset"];
    }
    else if (bottomLeft) {
        SVWallView* wallView = [self.wallViews objectForKey:bottomLeft.position];
        [dictionary setObject:[NSNumber numberWithInt:kSVWallViewBottomOriented] forKey:@"leftType"];
        [dictionary setObject:wallView.centerColor forKey:@"leftColor"];
        [dictionary setObject:[NSNumber numberWithFloat:-height / 2] forKey:@"leftOffset"];
    }
    else {
        [dictionary setObject:[NSNumber numberWithInt:kSVWallViewRounded] forKey:@"leftType"];
        [dictionary setObject:self.buildingWallViewColor forKey:@"leftColor"];
        [dictionary setObject:[NSNumber numberWithFloat:0] forKey:@"leftOffset"];
    }
    
    //Right
    if ((topRight && bottomRight) || rightOtherOrientation) {
        [dictionary setObject:[NSNumber numberWithInt:kSVWallViewSquared] forKey:@"rightType"];
        [dictionary setObject:self.buildingWallViewColor forKey:@"rightColor"];
        [dictionary setObject:[NSNumber numberWithFloat:-height / 2] forKey:@"rightOffset"];
    }
    else if (rightSameOrientation) {
        SVWallView* wallView = [self.wallViews objectForKey:rightSameOrientation.position];
        [dictionary setObject:[NSNumber numberWithInt:kSVWallViewSquared] forKey:@"rightType"];
        [dictionary setObject:wallView.centerColor forKey:@"rightColor"];
        [dictionary setObject:[NSNumber numberWithFloat:height / 2] forKey:@"rightOffset"];
    }
    else if (topRight) {
        SVWallView* wallView = [self.wallViews objectForKey:topRight.position];
        [dictionary setObject:[NSNumber numberWithInt:kSVWallViewTopOriented] forKey:@"rightType"];
        [dictionary setObject:wallView.centerColor forKey:@"rightColor"];
        [dictionary setObject:[NSNumber numberWithFloat:height / 2] forKey:@"rightOffset"];
    }
    else if (bottomRight) {
        SVWallView* wallView = [self.wallViews objectForKey:bottomRight.position];
        [dictionary setObject:[NSNumber numberWithInt:kSVWallViewBottomOriented] forKey:@"rightType"];
        [dictionary setObject:wallView.centerColor forKey:@"rightColor"];
        [dictionary setObject:[NSNumber numberWithFloat:height / 2] forKey:@"rightOffset"];
    }
    else {
        [dictionary setObject:[NSNumber numberWithInt:kSVWallViewRounded] forKey:@"rightType"];
        [dictionary setObject:self.buildingWallViewColor forKey:@"rightColor"];
        [dictionary setObject:[NSNumber numberWithFloat:0] forKey:@"rightOffset"];
    }
    
    //Center
    [dictionary setObject:self.buildingWallViewColor forKey:@"centerColor"];
    
    return dictionary;
}

- (void)boardView:(SVBoardView *)boardView didStartPanAt:(CGPoint)point withDirection:(kSVPanDirection)direction {
    NSLog(@"in");
    SVPosition* position = [boardView intersectionPositionForPoint:point];
    SVPosition* wallPosition;
    kSVWallOrientation wallOrientation;
    if (direction == kSVLeftDirection) {
        wallOrientation = kSVHorizontalOrientation;
        wallPosition = [[SVPosition alloc] initWithX:position.x - 1 andY:position.y];
    }
    else if (direction == kSVRightDirection) {
        wallOrientation = kSVHorizontalOrientation;
        wallPosition = [[SVPosition alloc] initWithX:position.x + 1 andY:position.y];
    }
    else if (direction == kSVTopDirection) {
        wallOrientation = kSVVerticalOrientation;
        wallPosition = [[SVPosition alloc] initWithX:position.x andY:position.y - 1];
    }
    else {
        wallOrientation = kSVVerticalOrientation;
        wallPosition = [[SVPosition alloc] initWithX:position.x andY:position.y + 1];
    }
        
    self.ignoreBuildingWall = ![self.board isWallLegalAtPosition:wallPosition withOrientation:wallOrientation andType:normal];
    if (self.ignoreBuildingWall)
        return;
    
    int length = 92;
    int thickness = 8;
    
    if ((wallOrientation == kSVHorizontalOrientation && wallPosition.x == 1) ||
        (wallOrientation == kSVHorizontalOrientation && wallPosition.x == self.board.size.width - 1))
        length = 91;
    else if ((wallOrientation == kSVVerticalOrientation && wallPosition.y == 1) ||
        (wallOrientation == kSVVerticalOrientation && wallPosition.y == self.board.size.height - 1))
        length = 91.5;
    
    NSDictionary* dictionary = [self wallViewParametersForPosition:wallPosition andOrientation:wallOrientation];
    float leftOffset = ((NSNumber*)[dictionary objectForKey:@"leftOffset"]).floatValue;
    float rightOffset = ((NSNumber*)[dictionary objectForKey:@"rightOffset"]).floatValue;
    
    CGRect rect;
    if (direction == kSVTopDirection) {
        rect = CGRectMake(point.x - thickness / 2,
                          point.y - length + leftOffset,
                          thickness,
                          length - leftOffset + rightOffset);
    }
    else if (direction == kSVRightDirection) {
        rect = CGRectMake(point.x + leftOffset,
                          point.y - thickness / 2,
                          length - leftOffset + rightOffset,
                          thickness);
    }
    else if (direction == kSVBottomDirection) {
        rect = CGRectMake(point.x - thickness / 2 ,
                          point.y + leftOffset,
                          thickness,
                          length - leftOffset + rightOffset);
    }
    else {
        rect = CGRectMake(point.x - length + leftOffset,
                          point.y - thickness / 2,
                          length - leftOffset + rightOffset,
                          thickness);
    }
    self.buildingWallViewDirection = direction;
    self.buildingWallOrientation = wallOrientation;
    self.buildingWallType = kSVWallNormal;
    self.buildingWallPosition = wallPosition;
    self.buildingWallView = [[SVWallView alloc] initWithFrame:rect
                                                    startType:((NSNumber*)[dictionary objectForKey:@"leftType"]).floatValue
                                                      endType:((NSNumber*)[dictionary objectForKey:@"rightType"]).floatValue
                                                    leftColor:[dictionary objectForKey:@"leftColor"]
                                                  centerColor:[dictionary objectForKey:@"centerColor"]
                                                   rightColor:[dictionary objectForKey:@"rightColor"]];
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
        [self.wallViews setObject:self.buildingWallView forKey:self.buildingWallPosition];
        [self.board addWallAtPosition:self.buildingWallPosition
                      withOrientation:self.buildingWallOrientation
                              andType:self.buildingWallType];
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
    
    self.boardView = [[SVBoardView alloc] initWithFrame:CGRectMake(0, 40, 320, 600)];
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
    [self.wallViews setObject:self.buildingWallView forKey:self.buildingWallPosition];
    [self.board addWallAtPosition:self.buildingWallPosition
                  withOrientation:self.buildingWallOrientation
                          andType:self.buildingWallType];
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
    self.clicked = !self.clicked;
//    [self revertChanges];
    if (!self.clicked)
        self.buildingWallViewColor = self.normalWallColor;
    else
        self.buildingWallViewColor = [UIColor blueColor];
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
