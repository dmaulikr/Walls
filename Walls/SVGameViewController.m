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

//Game data
@property (strong) SVBoard* board;
@property (strong) NSArray* playerColors;
@property (strong) NSMutableArray* wallsRemaining;
@property (strong) NSMutableArray* specialWallsRemaining;

//Views
@property (strong) NSMutableDictionary* wallViews;
@property (strong) SVBoardView* boardView;

//Turn info
@property (strong) NSMutableDictionary* buildingWallInfo;
@property (strong) NSMutableDictionary* turnChanges;
@property (assign) kSVPlayer currentPlayer;
@property (assign) BOOL ignoreBuildingWall;
@property (assign) int turn;
@property (strong) UIColor* selectedWallColor;

@property (strong, readonly) UIColor* normalWallColor;

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
        _selectedWallColor = _normalWallColor;
        _board = [[SVBoard alloc] init];
        _turn = 0;
        _turnChanges = [[NSMutableDictionary alloc] init];
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
    
    return dictionary;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithRed:0.44 green:0.44 blue:0.44 alpha:1.0];
    
    self.boardView = [[SVBoardView alloc] initWithFrame:CGRectMake(0, 40, 320, 600)];
    self.boardView.delegate = self;
    [self.view addSubview:self.boardView];
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
    [self.turnChanges removeAllObjects];
}

- (void)endTurn {
    self.turn++;
}

- (void)revertChanges {
}

- (void)commitChanges {
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
    SVWallView* wallView = [[SVWallView alloc] initWithFrame:rect
                                                   startType:((NSNumber*)[dictionary objectForKey:@"leftType"]).floatValue
                                                     endType:((NSNumber*)[dictionary objectForKey:@"rightType"]).floatValue
                                                   leftColor:[dictionary objectForKey:@"leftColor"]
                                                 centerColor:[dictionary objectForKey:@"centerColor"]
                                                  rightColor:[dictionary objectForKey:@"rightColor"]];
    [self.boardView addSubview:wallView];
    
    self.buildingWallInfo = [[NSMutableDictionary alloc] init];
    [self.buildingWallInfo setObject:[NSNumber numberWithInt:direction] forKey:@"direction"];
    [self.buildingWallInfo setObject:[NSNumber numberWithInt:wallOrientation] forKey:@"orientation"];
    [self.buildingWallInfo setObject:[NSNumber numberWithInt:kSVWallNormal] forKey:@"type"];
    [self.buildingWallInfo setObject:wallPosition forKey:@"position"];
    [self.buildingWallInfo setObject:self.normalWallColor forKey:@"color"];
    [self.buildingWallInfo setObject:wallView forKey:@"view"];
}

- (void)boardView:(SVBoardView *)boardView didChangePanTo:(CGPoint)point {
    if (self.ignoreBuildingWall)
        return;
    
    kSVPanDirection wallDirection = ((NSNumber*)[self.buildingWallInfo objectForKey:@"direction"]).intValue;
    SVWallView* wallView = [self.buildingWallInfo objectForKey:@"view"];
    
    CGRect rect;
    if (wallDirection == kSVTopDirection) {
        rect = CGRectMake(0,
                          point.y - wallView.frame.origin.y,
                          wallView.frame.size.width,
                          wallView.frame.size.height - (point.y - wallView.frame.origin.y));
    }
    else if (wallDirection == kSVRightDirection) {
        rect = CGRectMake(0,
                          0,
                          point.x - wallView.frame.origin.x,
                          wallView.frame.size.height);
    }
    else if (wallDirection == kSVBottomDirection) {
        rect = CGRectMake(0,
                          0,
                          wallView.frame.size.width,
                          point.y - wallView.frame.origin.y);
    }
    else {
        rect = CGRectMake(point.x - wallView.frame.origin.x,
                          0,
                          wallView.frame.size.width - (point.x - wallView.frame.origin.x),
                          wallView.frame.size.height);
    }
    [wallView showRect:rect animated:NO withFinishBlock:nil];
}

- (void)boardView:(SVBoardView *)boardView didEndPanAt:(CGPoint)point changeOfDirection:(BOOL)change {
    if (self.ignoreBuildingWall)
        return;
    
    SVWallView* wallView = [self.buildingWallInfo objectForKey:@"view"];

    if (wallView.shownRect.size.width >= wallView.frame.size.width - 15 &&
        wallView.shownRect.size.height >= wallView.frame.size.height - 15) {
        [wallView showRect:wallView.bounds animated:YES withFinishBlock:nil];
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
    }
}


@end
