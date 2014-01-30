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
#import "SVCustomView.h"
#import "SVTheme.h"
#import "SVColorButton.h"
#import "SVInfoWallView.h"
#import "SVPawnView.h"

@interface SVGameViewController ()

@property (strong) GKTurnBasedMatch* match;

//Game data
@property (strong) SVBoard* board;
@property (strong) NSArray* playerColors;
@property (strong) NSMutableArray* normalWallsRemaining;
@property (strong) NSMutableArray* specialWallsRemaining;

//Views
@property (strong) NSMutableDictionary* wallViews;
@property (strong) SVBoardView* boardView;
@property (strong) UIView* topView;
@property (strong) UIView* infoView;
@property (strong) UIView* bottomView;
@property (strong) UILabel* bottomLabel;
@property (strong) UILabel* bottomLabel2;
@property (strong) NSMutableArray* infoWallViews;
@property (strong) NSMutableArray* pawnViews;
@property (strong) SVColorButton* colorButton;

//Turn info
@property (strong) NSMutableDictionary* buildingWallInfo;
@property (strong) NSMutableDictionary* turnChanges;
@property (assign) kSVPlayer currentPlayer;
@property (assign) BOOL canBuildWall;
@property (assign) int turn;
@property (strong) UIColor* selectedWallColor;

@property (strong) UIPanGestureRecognizer* bottomViewGestureRecognizer;

- (void)revertChanges;
- (void)commitChanges;
- (void)startTurn;
- (void)endTurn;
- (void)didClickColorButton:(id)sender;
- (void)didPanBottomView:(UIPanGestureRecognizer*)gestureRecognizer;
- (SVInfoWallView*)firstInfoWallForType:(kSVWallType)type andPlayer:(kSVPlayer)player;
- (void)removeInfoWallAtIndex:(int)index forPlayer:(kSVPlayer)player;
- (BOOL)canPlayAction:(NSString*)action withInfo:(NSDictionary*)info;
@end

@implementation SVGameViewController

//////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////

- (id)initWithMatch:(GKTurnBasedMatch*)match {
    self = [super init];
    if (self) {
        _match = match;
//        GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
//        GKTurnBasedParticipant* firstPlayer = [_match.participants objectAtIndex:0];
//        if ([firstPlayer.playerID isEqualToString:localPlayer.playerID]) {
//            
//        }
        _wallViews = [[NSMutableDictionary alloc] init];
        _normalWallsRemaining = [[NSMutableArray alloc] init];
        [_normalWallsRemaining addObject:[NSNumber numberWithInt:6]];
        [_normalWallsRemaining addObject:[NSNumber numberWithInt:6]];
        _specialWallsRemaining = [[NSMutableArray alloc] init];
        [_specialWallsRemaining addObject:[NSNumber numberWithInt:2]];
        [_specialWallsRemaining addObject:[NSNumber numberWithInt:2]];
        _selectedWallColor = [SVTheme sharedTheme].normalWallColor;
        _board = [[SVBoard alloc] init];
        _turn = 0;
        _turnChanges = [[NSMutableDictionary alloc] init];
        _playerColors = [[NSArray alloc] initWithObjects:[SVTheme sharedTheme].player1Color, [SVTheme sharedTheme].player2Color, nil];
        _infoWallViews = [[NSMutableArray alloc] init];
        [_infoWallViews addObject:[[NSMutableArray alloc] init]];
        [_infoWallViews addObject:[[NSMutableArray alloc] init]];
        _bottomViewGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanBottomView:)];
        _bottomViewGestureRecognizer.minimumNumberOfTouches = 1;
        _bottomViewGestureRecognizer.maximumNumberOfTouches = 1;
        _bottomViewGestureRecognizer.delegate = self;
        _pawnViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Top
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 49)];
    self.topView.backgroundColor = self.playerColors[kSVPlayer1];
    [self.view addSubview:self.topView];
    UILabel* topLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.topView.frame.size.width - 200) / 2,
                                                                  (self.topView.frame.size.height - 30) / 2,
                                                                  200,
                                                                  30)];
    NSMutableAttributedString *topString = [[NSMutableAttributedString alloc] initWithString:@"Walls"];
    [topString addAttribute:NSKernAttributeName value:@3 range:NSMakeRange(0, 4)];
    topLabel.attributedText = topString;
    topLabel.textColor = [UIColor whiteColor];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:24];
    [self.topView addSubview:topLabel];
    
    //Board
    self.boardView = [[SVBoardView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topView.frame), self.view.frame.size.width, 415)];
    self.boardView.delegate = self;
    [self.view addSubview:self.boardView];
    
    CGPoint point1 = [self.boardView squareCenterForPosition:self.board.playerPositions[kSVPlayer1]];
    SVPawnView* pawnView1 = [[SVPawnView alloc] initWithFrame:CGRectMake(point1.x - 15, point1.y - 15, 30, 30)
                                                       color1:[SVTheme sharedTheme].player1Color
                                                    andColor2:[SVTheme sharedTheme].player1LightColor];
    [self.pawnViews addObject:pawnView1];
    [self.boardView addSubview:pawnView1];
    
    CGPoint point2 = [self.boardView squareCenterForPosition:self.board.playerPositions[kSVPlayer2]];
    SVPawnView* pawnView2 = [[SVPawnView alloc] initWithFrame:CGRectMake(point2.x - 15, point2.y - 15, 30, 30)
                                                       color1:[SVTheme sharedTheme].player2Color
                                                    andColor2:[SVTheme sharedTheme].player2LightColor];
    [self.pawnViews addObject:pawnView2];
    [self.boardView addSubview:pawnView2];
    
    //Info
    self.infoView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.boardView.frame), self.view.frame.size.width, 44)];
    self.infoView.backgroundColor = [SVTheme sharedTheme].darkSquareColor;
    [self.view addSubview:self.infoView];
    
    SVCustomView* player1Circle = [[SVCustomView alloc] initWithFrame:CGRectMake(7, (self.infoView.frame.size.height - 24) / 2, 24, 24)];
    [player1Circle drawBlock:^(CGContextRef context) {
        UIBezierPath* largeCircle = [UIBezierPath bezierPathWithOvalInRect:player1Circle.bounds];
        [[UIColor whiteColor] setFill];
        [largeCircle fill];
        
        UIBezierPath* smallCircle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2, 2, player1Circle.bounds.size.width - 4, player1Circle.bounds.size.height - 4)];
        [[SVTheme sharedTheme].player1Color setFill];
        [smallCircle fill];
    }];
    [self.infoView addSubview:player1Circle];
    UILabel* player1Label = [[UILabel alloc] initWithFrame:CGRectMake(2,
                                                                      2,
                                                                      player1Circle.frame.size.width - 4,
                                                                      player1Circle.frame.size.height - 4)];
    player1Label.textAlignment = NSTextAlignmentCenter;
    player1Label.textColor = [UIColor whiteColor];
    player1Label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
    player1Label.text = @"SV";
    player1Label.numberOfLines = 1;
    [player1Circle addSubview:player1Label];
    
    SVCustomView* player2Circle = [[SVCustomView alloc] initWithFrame:CGRectMake(self.infoView.frame.size.width - 7 - 24,
                                                                                 (self.infoView.frame.size.height - 24) / 2, 24, 24)];
    [player2Circle drawBlock:^(CGContextRef context) {
        UIBezierPath* largeCircle = [UIBezierPath bezierPathWithOvalInRect:player2Circle.bounds];
        [[UIColor whiteColor] setFill];
        [largeCircle fill];
        
        UIBezierPath* smallCircle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2, 2, player2Circle.bounds.size.width - 4, player2Circle.bounds.size.height - 4)];
        [[SVTheme sharedTheme].player2Color setFill];
        [smallCircle fill];
    }];
    [self.infoView addSubview:player2Circle];
    UILabel* player2Label = [[UILabel alloc] initWithFrame:CGRectMake(2,
                                                                      2,
                                                                      player1Circle.frame.size.width - 4,
                                                                      player1Circle.frame.size.height - 4)];
    player2Label.textAlignment = NSTextAlignmentCenter;
    player2Label.textColor = [UIColor whiteColor];
    player2Label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
    player2Label.text = @"MV";
    player2Label.numberOfLines = 1;
    [player2Circle addSubview:player2Label];
    
    self.colorButton = [[SVColorButton alloc] initWithFrame:CGRectMake((self.infoView.frame.size.width -  42) / 2,
                                                                            (self.infoView.frame.size.height - 26) / 2, 42, 26)];
    [self.colorButton addTarget:self action:@selector(didClickColorButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoView addSubview:self.colorButton];
    
    int leftOffset = 38;
    int rightOffset = self.infoView.frame.size.width - 38 - 4;
    int specialWallsCount = ((NSNumber*)[self.specialWallsRemaining objectAtIndex:0]).intValue;
    int normalWallsCount = ((NSNumber*)[self.normalWallsRemaining objectAtIndex:0]).intValue;
    for (int i = 0; i <  specialWallsCount + normalWallsCount ; i++) {
        UIColor* color;
        if (i < specialWallsCount)
            color = self.playerColors[kSVPlayer1];
        else
            color = [SVTheme sharedTheme].normalWallColor;
        
        SVInfoWallView* wall = [[SVInfoWallView alloc] initWithFrame:CGRectMake(leftOffset, (self.infoView.frame.size.height - 15) / 2, 4, 15)
                                                            andColor:color];
        leftOffset = CGRectGetMaxX(wall.frame) + 3;
        [[self.infoWallViews objectAtIndex:kSVPlayer1] addObject:wall];
        [self.infoView addSubview:wall];
        
        if (i < specialWallsCount)
            color = self.playerColors[kSVPlayer2];
        else
            color = [SVTheme sharedTheme].normalWallColor;
       
        wall = [[SVInfoWallView alloc] initWithFrame:CGRectMake(rightOffset, (self.infoView.frame.size.height - 15) / 2, 4, 15)
                                            andColor:color];
        
        rightOffset = CGRectGetMinX(wall.frame) - 3 - 4;
        [[self.infoWallViews objectAtIndex:kSVPlayer2] addObject:wall];
        [self.infoView addSubview:wall];
    }
    
    //Bottom
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.infoView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.infoView.frame))];
    self.bottomView.backgroundColor = self.playerColors[kSVPlayer1];
    [self.view addSubview:self.bottomView];
    [self.bottomView addGestureRecognizer:self.bottomViewGestureRecognizer];
    
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.bottomView.frame.size.width - 200) / 2,
                                                                     0,
                                                                     200,
                                                                     self.bottomView.frame.size.height)];
    self.bottomLabel.textColor = [UIColor whiteColor];
    self.bottomLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    self.bottomLabel.text = @"Your turn";
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomView addSubview:self.bottomLabel];
    
    self.bottomLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(self.bottomView.frame.size.width,
                                                                 0,
                                                                 200,
                                                                 self.bottomView.frame.size.height)];
    self.bottomLabel2.textColor = [UIColor whiteColor];
    self.bottomLabel2.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    self.bottomLabel2.text = @"Your turn";
    self.bottomLabel2.textAlignment = NSTextAlignmentCenter;
    [self.bottomView addSubview:self.bottomLabel2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////
// Private
//////////////////////////////////////////////////////

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
        [dictionary setObject:self.selectedWallColor forKey:@"leftColor"];
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
        [dictionary setObject:self.selectedWallColor forKey:@"leftColor"];
        [dictionary setObject:[NSNumber numberWithFloat:0] forKey:@"leftOffset"];
    }
    
    //Right
    if ((topRight && bottomRight) || rightOtherOrientation) {
        [dictionary setObject:[NSNumber numberWithInt:kSVWallViewSquared] forKey:@"rightType"];
        [dictionary setObject:self.selectedWallColor forKey:@"rightColor"];
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
        [dictionary setObject:self.selectedWallColor forKey:@"rightColor"];
        [dictionary setObject:[NSNumber numberWithFloat:0] forKey:@"rightOffset"];
    }
    
    //Center
    [dictionary setObject:self.selectedWallColor forKey:@"centerColor"];
    
    kSVWallType wallType;
    if (!self.colorButton.selected) {
        wallType = kSVWallNormal;
    }
    else {
        wallType = self.currentPlayer == kSVPlayer1 ? kSVWallPlayer1 : kSVWallPlayer2;
    }
    [dictionary setObject:[NSNumber numberWithInt:wallType] forKey:@"type"];
    return dictionary;
}


- (void)startTurn {
    if (self.turn % 2 == 0)
        self.currentPlayer = kSVPlayer1;
    else
        self.currentPlayer = kSVPlayer2;
    [self.turnChanges removeAllObjects];
}

- (void)endTurn {
    [self commitChanges];
    self.turn++;
    self.currentPlayer = (self.currentPlayer + 1) % 2;
    
    //Adjust the color dependent on the number of walls remaining
    if (((NSNumber*)([self.normalWallsRemaining objectAtIndex:self.currentPlayer])).intValue > 0) {
        self.colorButton.selected = NO;
        self.selectedWallColor = [SVTheme sharedTheme].normalWallColor;
    }
    else {
        self.colorButton.selected = YES;
        self.selectedWallColor = self.playerColors[self.currentPlayer];
    }
}

- (void)revertChanges {
}

- (void)commitChanges {
    if ([self.turnChanges objectForKey:@"wall"]) {
        NSDictionary* dictionary = [self.turnChanges objectForKey:@"wall"];
        kSVWallType wallType = ((NSNumber*)[dictionary objectForKey:@"type"]).intValue;
        SVPosition* wallPosition = [dictionary objectForKey:@"position"];
        [self.wallViews setObject:[dictionary objectForKey:@"view"] forKey:wallPosition];
//        [self.board addWallAtPosition:wallPosition
//                      withOrientation:((NSNumber*)[dictionary objectForKey:@"orientation"]).intValue
//                              andType:wallType];
        if (wallType == kSVWallNormal) {
            int count = ((NSNumber*)[self.normalWallsRemaining objectAtIndex:self.currentPlayer]).intValue;
            [self.normalWallsRemaining replaceObjectAtIndex:self.currentPlayer withObject:[NSNumber numberWithInt:count - 1]];
        }
        else {
            int count = ((NSNumber*)[self.specialWallsRemaining objectAtIndex:self.currentPlayer]).intValue;
            [self.specialWallsRemaining replaceObjectAtIndex:self.currentPlayer withObject:[NSNumber numberWithInt:count - 1]];
        }
    }
    
    else if ([self.turnChanges objectForKey:@"move"]) {
        [self.board movePlayer:self.currentPlayer to:[self.turnChanges objectForKey:@"move"]];
    }
    [self.turnChanges removeAllObjects];
}

-(SVInfoWallView*)firstInfoWallForType:(kSVWallType)type andPlayer:(kSVPlayer)player {
    NSMutableArray* array = [self.infoWallViews objectAtIndex:player];
    for (SVInfoWallView* wall in array) {
        if ([wall.backgroundColor isEqual:((UIColor*)[self.buildingWallInfo objectForKey:@"color"])])
            return wall;
    }
    return nil;
}

- (void)removeInfoWallAtIndex:(int)index forPlayer:(kSVPlayer)player {
    NSMutableArray* array = [self.infoWallViews objectAtIndex:player];
    SVInfoWallView* wall = [array objectAtIndex:index];
    [wall removeFromSuperview];
    [array removeObject:wall];
    int offset = player == kSVPlayer1 ? -7 : 7;
    for (int i = index; i < array.count; i++) {
        [UIView animateWithDuration:0.5 animations:^{
            SVInfoWallView* wall = [array objectAtIndex:i];
            wall.frame = CGRectMake(wall.frame.origin.x + offset, wall.frame.origin.y, wall.frame.size.width, wall.frame.size.height);
        }];
    }
}

- (BOOL)canPlayAction:(NSString*)action withInfo:(NSDictionary*)info {
    if (self.turnChanges.count > 0)
        return NO;
    if ([action isEqualToString:@"wall"]) {
        kSVWallOrientation orientation = ((NSNumber*)[info objectForKey:@"orientation"]).intValue;
        kSVWallType type = ((NSNumber*)[info objectForKey:@"type"]).intValue;
        SVPosition* position = [info objectForKey:@"position"];
//        if (![self.board isWallLegalAtPosition:position withOrientation:orientation andType:type]) {
//            return NO;
//        }
        if (type == kSVWallNormal) {
            return ((NSNumber*)[self.normalWallsRemaining objectAtIndex:self.currentPlayer]).intValue > 0;
        }
        else {
            return ((NSNumber*)[self.specialWallsRemaining objectAtIndex:self.currentPlayer]).intValue > 0;
        }
    }
    else if ([action isEqualToString:@"move"]) {
        SVPosition* position = [info objectForKey:@"position"];
        return [self.board canPlayer:self.currentPlayer moveTo:position];
    }
    return YES;
}

//////////////////////////////////////////////////////
// Buttons targets
//////////////////////////////////////////////////////

- (void)didClickColorButton:(id)sender {
    UIButton* button = (UIButton*)sender;
    if (button.selected && ((NSNumber*)[self.normalWallsRemaining objectAtIndex:self.currentPlayer]).intValue > 0) {
        self.selectedWallColor = [SVTheme sharedTheme].normalWallColor;
        button.selected = !button.selected;
    }
    else if (((NSNumber*)[self.specialWallsRemaining objectAtIndex:self.currentPlayer]).intValue > 0) {
        self.selectedWallColor = [self.playerColors objectAtIndex:self.currentPlayer];
        button.selected = !button.selected;
    }
}

- (void)didPanBottomView:(UIPanGestureRecognizer*)gestureRecognizer {
    CGPoint point = [gestureRecognizer translationInView:self.bottomView];
    CGPoint velocity = [gestureRecognizer velocityInView:self.bottomView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.bottomLabel.frame = CGRectMake((self.bottomView.frame.size.width - self.bottomLabel.frame.size.width) / 2 + point.x,
                                            self.bottomLabel.frame.origin.y,
                                            self.bottomLabel.frame.size.width,
                                            self.bottomLabel.frame.size.height);
        const CGFloat *startComponents = CGColorGetComponents(((UIColor*)self.playerColors[self.currentPlayer]).CGColor);
        const CGFloat *endComponents = CGColorGetComponents(((UIColor*)self.playerColors[(self.currentPlayer + 1) % 2]).CGColor);
        float ratio = abs(point.x) / self.bottomView.frame.size.height / 2;
        ratio = ratio > 1 ? 1 : ratio;
        UIColor* color = [UIColor colorWithRed:(1 - ratio) * startComponents[0] + ratio * endComponents[0]
                                         green:(1 - ratio) * startComponents[1] + ratio * endComponents[1]
                                          blue:(1 - ratio) * startComponents[2] + ratio * endComponents[2]
                                         alpha:(1 - ratio) * startComponents[3] + ratio * endComponents[3]];
        self.bottomView.backgroundColor = color;
        self.topView.backgroundColor = color;
        
        self.bottomLabel2.frame = CGRectMake(self.bottomView.frame.size.width + point.x,
                                             self.bottomLabel2.frame.origin.y,
                                             self.bottomLabel2.frame.size.width,
                                             self.bottomLabel2.frame.size.height);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        //Accept swipe
        if (point.x < -80) {
            float duration;
            if (velocity.x >= 0)
                duration = 0.3;
            else {
                duration = fabs(self.bottomLabel.frame.origin.x + self.bottomLabel.frame.size.width) / fabs(velocity.x);
                duration = duration > 0.3 ? 0.3 : duration;
            }
            [UIView animateWithDuration:duration animations:^{
                self.bottomLabel.frame = CGRectMake((- self.bottomLabel.frame.size.width),
                                                    self.bottomLabel.frame.origin.y,
                                                    self.bottomLabel.frame.size.width,
                                                    self.bottomLabel.frame.size.height);
                self.bottomLabel2.frame = CGRectMake((self.bottomView.frame.size.width - self.bottomLabel2.frame.size.width) / 2,
                                                     self.bottomLabel2.frame.origin.y,
                                                     self.bottomLabel2.frame.size.width,
                                                     self.bottomLabel2.frame.size.height);
            } completion:^(BOOL finished) {
                self.bottomLabel.frame = CGRectMake(self.bottomView.frame.size.width,
                                                    self.bottomLabel.frame.origin.y,
                                                    self.bottomLabel.frame.size.width,
                                                    self.bottomLabel.frame.size.height);
                UILabel* bottomLabel1 = self.bottomLabel;
                self.bottomLabel = self.bottomLabel2;
                self.bottomLabel2 = bottomLabel1;
            }];
            [self endTurn];
        }
        //Deny swipe
        else {
            float duration;
            if (velocity.x < 0)
                duration = 0.3;
            else {
                duration = fabs(self.bottomLabel.frame.origin.x + self.bottomLabel.frame.size.width) / fabs(velocity.x);
                duration = duration > 0.3 ? 0.3 : duration;
            }
            [UIView animateWithDuration:duration animations:^{
                self.bottomLabel.frame = CGRectMake((self.bottomView.frame.size.width - self.bottomLabel.frame.size.width) / 2,
                                                    self.bottomLabel.frame.origin.y,
                                                    self.bottomLabel.frame.size.width,
                                                    self.bottomLabel.frame.size.height);
                self.bottomLabel2.frame = CGRectMake(self.bottomView.frame.size.width,
                                                     self.bottomLabel2.frame.origin.y,
                                                     self.bottomLabel2.frame.size.width,
                                                     self.bottomLabel2.frame.size.height);
            }];
        }
    }
}


//////////////////////////////////////////////////////
// Delegates
//////////////////////////////////////////////////////

- (void)boardView:(SVBoardView *)boardView didStartPanAt:(CGPoint)point withDirection:(kSVPanDirection)direction {
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
    
    NSDictionary* parameters = [self wallViewParametersForPosition:wallPosition andOrientation:wallOrientation];


    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    [info setObject:wallPosition forKey:@"position"];
    [info setObject:[[NSNumber alloc] initWithInt:wallOrientation] forKey:@"orientation"];
    [info setObject:[parameters objectForKey:@"type"] forKey:@"type"];
    self.canBuildWall = [self canPlayAction:@"wall" withInfo:info];
    if (!self.canBuildWall)
        return;
    
    int length = 92;
    int thickness = 8;
    
    if ((wallOrientation == kSVHorizontalOrientation && wallPosition.x == 1) ||
        (wallOrientation == kSVHorizontalOrientation && wallPosition.x == self.board.size.width - 1))
        length = 91;
    else if ((wallOrientation == kSVVerticalOrientation && wallPosition.y == 1) ||
             (wallOrientation == kSVVerticalOrientation && wallPosition.y == self.board.size.height - 1))
        length = 91.5;
    
    float leftOffset = ((NSNumber*)[parameters objectForKey:@"leftOffset"]).floatValue;
    float rightOffset = ((NSNumber*)[parameters objectForKey:@"rightOffset"]).floatValue;
    
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
    SVWallView* wallView = [[SVWallView alloc] initWithFrame:rect
                                                   startType:((NSNumber*)[parameters objectForKey:@"leftType"]).floatValue
                                                     endType:((NSNumber*)[parameters objectForKey:@"rightType"]).floatValue
                                                   leftColor:[parameters objectForKey:@"leftColor"]
                                                 centerColor:[parameters objectForKey:@"centerColor"]
                                                  rightColor:[parameters objectForKey:@"rightColor"]];
    [self.boardView addSubview:wallView];
    
    kSVWallType wallType;
    if (!self.colorButton.selected) {
        wallType = kSVWallNormal;
    }
    else {
        wallType = self.currentPlayer == kSVPlayer1 ? kSVWallPlayer1 : kSVWallPlayer2;
    }
    self.buildingWallInfo = [[NSMutableDictionary alloc] init];
    [self.buildingWallInfo setObject:[NSNumber numberWithInt:direction] forKey:@"direction"];
    [self.buildingWallInfo setObject:[NSNumber numberWithInt:wallOrientation] forKey:@"orientation"];
    [self.buildingWallInfo setObject:[parameters objectForKey:@"type"] forKey:@"type"];
    [self.buildingWallInfo setObject:wallPosition forKey:@"position"];
    [self.buildingWallInfo setObject:self.selectedWallColor forKey:@"color"];
    [self.buildingWallInfo setObject:wallView forKey:@"view"];
}

- (void)boardView:(SVBoardView *)boardView didChangePanTo:(CGPoint)point {
    if (!self.canBuildWall)
        return;
    
    kSVPanDirection wallDirection = ((NSNumber*)[self.buildingWallInfo objectForKey:@"direction"]).intValue;
    SVWallView* wallView = [self.buildingWallInfo objectForKey:@"view"];
    float sizeRatio;
    
    CGRect rect;
    if (wallDirection == kSVTopDirection) {
        rect = CGRectMake(0,
                          point.y - wallView.frame.origin.y,
                          wallView.frame.size.width,
                          wallView.frame.size.height - (point.y - wallView.frame.origin.y));
        sizeRatio = rect.size.height / wallView.frame.size.height;
    }
    else if (wallDirection == kSVRightDirection) {
        rect = CGRectMake(0,
                          0,
                          point.x - wallView.frame.origin.x,
                          wallView.frame.size.height);
        sizeRatio = rect.size.width / wallView.frame.size.width;
    }
    else if (wallDirection == kSVBottomDirection) {
        rect = CGRectMake(0,
                          0,
                          wallView.frame.size.width,
                          point.y - wallView.frame.origin.y);
        sizeRatio = rect.size.height / wallView.frame.size.height;
    }
    else {
        rect = CGRectMake(point.x - wallView.frame.origin.x,
                          0,
                          wallView.frame.size.width - (point.x - wallView.frame.origin.x),
                          wallView.frame.size.height);
        sizeRatio = rect.size.width / wallView.frame.size.width;
    }
    [wallView showRect:rect animated:NO withFinishBlock:nil];

    sizeRatio = sizeRatio > 1 ? 1 : sizeRatio;
    
    //Hide info wall
    SVInfoWallView* infoWall = [self firstInfoWallForType:((NSNumber*)[self.buildingWallInfo objectForKey:@"type"]).intValue
                                        andPlayer:self.currentPlayer];
    CGRect infoWallRect = CGRectMake(0,
                                     infoWall.frame.size.height * sizeRatio,
                                     infoWall.frame.size.width,
                                     infoWall.frame.size.height * (1 - sizeRatio));
    [infoWall showRect:infoWallRect animated:NO withFinishBlock:nil];
}

- (void)boardView:(SVBoardView *)boardView didEndPanAt:(CGPoint)point changeOfDirection:(BOOL)change {
    if (!self.canBuildWall)
        return;
    
    SVWallView* wallView = [self.buildingWallInfo objectForKey:@"view"];

    if (wallView.shownRect.size.width >= wallView.frame.size.width - 15 &&
        wallView.shownRect.size.height >= wallView.frame.size.height - 15) {
        [wallView showRect:wallView.bounds animated:YES withFinishBlock:nil];
        [self.turnChanges setObject:self.buildingWallInfo forKey:@"wall"];
        
        //Remove info wall
        SVInfoWallView* infoWall = [self firstInfoWallForType:((NSNumber*)[self.buildingWallInfo objectForKey:@"type"]).intValue
                                            andPlayer:self.currentPlayer];
        NSMutableArray* infoWallArray = self.infoWallViews[self.currentPlayer];
        [self removeInfoWallAtIndex:(int)[infoWallArray indexOfObject:infoWall] forPlayer:self.currentPlayer];
    }
    else {
        CGRect rect;
        kSVPanDirection wallDirection = ((NSNumber*)[self.buildingWallInfo objectForKey:@"direction"]).intValue;
        if (wallDirection == kSVTopDirection)
            rect = CGRectMake(0, wallView.frame.size.height, wallView.frame.size.width, 0);
        else if (wallDirection == kSVRightDirection)
            rect = CGRectMake(0, 0, 0, wallView.frame.size.height);
        else if (wallDirection == kSVBottomDirection)
            rect = CGRectMake(0, 0, wallView.frame.size.width, 0);
        else
            rect = CGRectMake(wallView.frame.size.width, 0, 0, wallView.frame.size.height);
        
        [wallView showRect:rect animated:!change withFinishBlock:^(void){
            [wallView removeFromSuperview];
        }];
        SVInfoWallView* infoWall = [self firstInfoWallForType:((NSNumber*)[self.buildingWallInfo objectForKey:@"type"]).intValue
                                            andPlayer:self.currentPlayer];
        [infoWall showRect:infoWall.bounds animated:YES withFinishBlock:nil];
    }
}

- (void)boardView:(SVBoardView *)boardView didTapSquare:(SVPosition *)position {
    if ([self canPlayAction:@"move" withInfo:[NSDictionary dictionaryWithObject:position forKey:@"position"]]) {
        CGPoint point = [boardView squareCenterForPosition:position];
        SVPawnView* pawnView = [self.pawnViews objectAtIndex:self.currentPlayer];
        [UIView animateWithDuration:0.3 animations:^{
            pawnView.frame = CGRectMake(point.x - pawnView.frame.size.width / 2,
                                        point.y - pawnView.frame.size.height / 2,
                                        pawnView.frame.size.width,
                                        pawnView.frame.size.height);
        }];
        [self.turnChanges setObject:position forKey:@"move"];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.bottomViewGestureRecognizer) {
        CGPoint velocity = [self.bottomViewGestureRecognizer velocityInView:self.bottomView];
        return velocity.x < 0 && self.turnChanges.count > 0;
    }
    return YES;
}


@end
