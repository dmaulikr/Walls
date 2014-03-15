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
#import "SVGame.h"
#import "SVTurn.h"
#import "SVCustomContainerController.h"
#import "SVCustomButton.h"

@interface SVGameViewController ()

/////////////////////////////////////////////////////
// Game data
/////////////////////////////////////////////////////
@property (strong) SVGame* game;
@property (strong) SVBoard* board;
@property (strong) NSArray* playerColors;

/////////////////////////////////////////////////////
// Views
/////////////////////////////////////////////////////

//Top
@property (strong) UIView* topLine;

//Board
@property (strong) SVBoardView* boardView;
@property (strong) NSMutableArray* pawnViews;
@property (strong) NSMutableDictionary* wallViews;

//Bottom
@property (strong) UIView* bottomView;
@property (strong) SVCustomView* infoView;
@property (strong) UIView* footerView;
@property (strong) UILabel* footerLabel;
@property (strong) NSMutableArray* playerCircles;
@property (strong) SVColorButton* colorButton;
@property (strong) UIButton* cancelButton;
@property (strong) UIButton* validateButton;
@property (strong) UILabel* opponentPlayerLabel;
@property (strong) NSMutableArray* infoWallViews;

/////////////////////////////////////////////////////
// Turn info
/////////////////////////////////////////////////////

@property (strong) SVTurn* currentTurn;
@property (strong) NSMutableDictionary* buildingWallInfo;
@property (assign) kSVPlayer currentPlayer;
@property (assign) kSVPlayer localPlayer;
@property (assign) kSVPlayer opponentPlayer;
@property (assign) BOOL canBuildWall;
@property (strong) NSArray* opponentName;
@property (assign) kSVPanDirection pawnPanDirection;
@property (strong) UIView* pawnPanView;
@property (assign) BOOL gameUpdated;


/////////////////////////////////////////////////////
// Other
/////////////////////////////////////////////////////

@property (assign) BOOL hiddingView;



//Private
- (void)updateUI;
- (void)newTurn;
- (UIColor*)colorForWall:(SVWall*)wall;
- (SVWallView*)wallViewForWall:(SVWall*)wall;
- (void)commitCurrentTurn;
- (void)cancelCurrentTurn;
- (SVInfoWallView*)addInfoWallOfType:(kSVWallType)type forPlayer:(kSVPlayer)player;
- (SVInfoWallView*)firstInfoWallOfType:(kSVWallType)type forPlayer:(kSVPlayer)player;
- (void)removeInfoWallOfType:(kSVWallType)type forPlayer:(kSVPlayer)player;
- (BOOL)canPlayAction:(kSVAction)action withInfo:(id)actionInfo;
- (void)didPlayAction;
- (void)playTurn:(SVTurn*)turn;
- (void)displayTurn:(SVTurn*)turn animated:(BOOL)animated delay:(NSTimeInterval)delay finishBlock:(void(^)(void))finishBlock;
- (void)reDisplayTurnAnimated:(SVTurn*)turn finishBlock:(void(^)(void))finishBlock;
- (void)performBlock:(void(^)(void))block;
- (void)movePawnToPosition:(SVPosition*)position forPlayer:(kSVPlayer)player animated:(BOOL)animated finishBlock:(void(^)(void))finishBlock;

//Button targets
- (void)didClickColorButton:(id)sender;
- (void)didClickCancelButton:(id)sender;
- (void)didClickValidateButton:(id)sender;
- (void)didClickBackButton:(id)sender;
- (void)didPanPawn:(UIPanGestureRecognizer*)gestureRecognizer;
- (void)didClickPlayerCircle:(id)sender;

@end

@implementation SVGameViewController

# pragma mark - Public

- (id)initWithGame:(SVGame *)game {
    self = [super init];
    if (self) {
        _game = game;
        _board = [[SVBoard alloc] init];
        _infoWallViews = [[NSMutableArray alloc] init];
        [_infoWallViews addObject:[[NSMutableArray alloc] init]];
        [_infoWallViews addObject:[[NSMutableArray alloc] init]];
        _pawnViews = [[NSMutableArray alloc] init];
        _wallViews = [[NSMutableDictionary alloc] init];
        _playerCircles = [[NSMutableArray alloc] init];
        _hiddingView = NO;
        _gameUpdated = NO;
        
        [self newTurn];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Prevent user from playing before last turn is shown
    self.view.userInteractionEnabled = NO;
    
    //Play turns except last one
    for (int i = 0; i < (int)self.game.turns.count - 1; i++) {
        SVTurn* turn = [self.game.turns objectAtIndex:i];
        [self playTurn:turn];
    }
    
    /////////////////////////////////////////////////////
    // Top
    /////////////////////////////////////////////////////
    
    self.topLine = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              0,
                                                              self.view.frame.size.width,
                                                              1)];
    self.topLine.backgroundColor = [SVTheme sharedTheme].squareBorderColor;
    self.topLine.alpha = 0;
    [self.view addSubview:self.topLine];
    
    /////////////////////////////////////////////////////
    // Board
    /////////////////////////////////////////////////////
    
    self.boardView = [[SVBoardView alloc] initWithFrame:CGRectMake(0,
                                                                   CGRectGetMaxY(self.topLine.frame),
                                                                   self.view.frame.size.width,
                                                                   414)
                                                rotated:self.localPlayer == kSVPlayer2];
    self.boardView.delegate = self;
    [self.boardView hideRowsAnimated:NO withFinishBlock:nil];
    [self.view addSubview:self.boardView];
    
    //Already positioned to last position (turn - 1)
    CGPoint point1 = [self.boardView squareCenterForPosition:self.board.playerPositions[self.localPlayer]];
    SVPawnView* pawnView1 = [[SVPawnView alloc] initWithFrame:CGRectMake(point1.x - 15, point1.y - 15, 30, 30)
                                                       color1:[SVTheme sharedTheme].localPlayerColor
                                                    andColor2:[SVTheme sharedTheme].localPlayerLightColor];
    
    CGPoint point2 = [self.boardView squareCenterForPosition:self.board.playerPositions[self.opponentPlayer]];
    SVPawnView* pawnView2 =  [[SVPawnView alloc] initWithFrame:CGRectMake(point2.x - 15, point2.y - 15, 30, 30)
                                                        color1:[SVTheme sharedTheme].opponentPlayerColor
                                                     andColor2:[SVTheme sharedTheme].opponentPlayerLightColor];
//    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanPawn:)];
//    panGestureRecognizer.minimumNumberOfTouches = 1;
//    panGestureRecognizer.maximumNumberOfTouches = 1;
//    [pawnView1 addGestureRecognizer:panGestureRecognizer];
    
    /////////////////////////////////////////////////////
    // Bottom
    /////////////////////////////////////////////////////
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                               CGRectGetMaxY(self.boardView.frame),
                                                               self.view.frame.size.width,
                                                               self.view.frame.size.height - CGRectGetMaxY(self.boardView.frame))];
    [self.view addSubview:self.bottomView];
    
    self.infoView = [[SVCustomView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   self.view.frame.size.width,
                                                                   45)];
    self.infoView.backgroundColor = [SVTheme sharedTheme].darkSquareColor;
    __weak SVCustomView* weakInfoView = self.infoView;
    [self.infoView drawBlock:^(CGContextRef context) {
        UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, weakInfoView.frame.size.width, 1)];
        [[SVTheme sharedTheme].squareBorderColor setFill];
        [bezierPath fill];
    }];
    
    //Build info walls
    int leftOffset = 38;
    int specialWallsCount = ((NSNumber*)[self.board.specialWallsRemaining objectAtIndex:self.localPlayer]).intValue;
    int normalWallsCount = ((NSNumber*)[self.board.normalWallsRemaining objectAtIndex:self.localPlayer]).intValue;
    for (int i = 0; i <  specialWallsCount + normalWallsCount ; i++) {
        UIColor* color;
        if (i < specialWallsCount)
            color = self.playerColors[self.localPlayer];
        else
            color = [SVTheme sharedTheme].normalWallColor;
        
        SVInfoWallView* wall = [[SVInfoWallView alloc] initWithFrame:CGRectMake(leftOffset, (self.infoView.frame.size.height - 15) / 2, 4, 15)
                                                            andColor:color];
        leftOffset = CGRectGetMaxX(wall.frame) + 3;
        [[self.infoWallViews objectAtIndex:self.localPlayer] addObject:wall];
        [self.infoView addSubview:wall];
    }
    
    int rightOffset = self.infoView.frame.size.width - 38 - 4;
    specialWallsCount = ((NSNumber*)[self.board.specialWallsRemaining objectAtIndex:self.opponentPlayer]).intValue;
    normalWallsCount = ((NSNumber*)[self.board.normalWallsRemaining objectAtIndex:self.opponentPlayer]).intValue;
    for (int i = 0; i <  specialWallsCount + normalWallsCount ; i++) {
        UIColor* color;
        if (i < specialWallsCount)
            color = self.playerColors[self.opponentPlayer];
        else
            color = [SVTheme sharedTheme].normalWallColor;
        
        SVInfoWallView* wall = [[SVInfoWallView alloc] initWithFrame:CGRectMake(rightOffset, (self.infoView.frame.size.height - 15) / 2, 4, 15)
                                                            andColor:color];
        rightOffset = CGRectGetMinX(wall.frame) - 3 - 4;
        [[self.infoWallViews objectAtIndex:self.opponentPlayer] addObject:wall];
        [self.infoView addSubview:wall];
    }

    
    [self.bottomView addSubview:self.infoView];
    
    SVCustomButton* localPlayerCircle = [[SVCustomButton alloc] initWithFrame:CGRectMake(7,
                                                                                         (self.infoView.frame.size.height - 24) / 2,
                                                                                         24,
                                                                                         24)];
    __weak SVCustomButton* weakSelf = localPlayerCircle;
    [localPlayerCircle drawBlock:^(CGContextRef context) {
        UIBezierPath* largeCircle = [UIBezierPath bezierPathWithOvalInRect:weakSelf.bounds];
        [[UIColor whiteColor] setFill];
        [largeCircle fill];
        
        UIBezierPath* smallCircle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2,
                                                                                      2,
                                                                                      weakSelf.bounds.size.width - 4,
                                                                                      weakSelf.bounds.size.height - 4)];
        [[SVTheme sharedTheme].localPlayerColor setFill];
        [smallCircle fill];
    }];
    [self.infoView addSubview:localPlayerCircle];
    [localPlayerCircle addTarget:self action:@selector(didClickPlayerCircle:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* localPlayerLabel = [[UILabel alloc] initWithFrame:CGRectMake(2,
                                                                          2,
                                                                          localPlayerCircle.frame.size.width - 4,
                                                                          localPlayerCircle.frame.size.height - 4)];
    localPlayerLabel.textAlignment = NSTextAlignmentCenter;
    localPlayerLabel.textColor = [UIColor whiteColor];
    localPlayerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
    NSArray* words = [[GKLocalPlayer localPlayer].displayName componentsSeparatedByString:@" "];
    if (words.count == 1) {
        localPlayerLabel.text = [[words objectAtIndex:0] substringWithRange:NSMakeRange(0, 2)];
    }
    else {
        localPlayerLabel.text = [[[words objectAtIndex:0] substringWithRange:NSMakeRange(0, 1)]
                                 stringByAppendingString:[[words objectAtIndex:1] substringWithRange:NSMakeRange(0, 1)]];
    }
    localPlayerLabel.numberOfLines = 1;
    [localPlayerCircle addSubview:localPlayerLabel];
    
    SVCustomButton* opponentPlayerCircle = [[SVCustomButton alloc] initWithFrame:CGRectMake(self.infoView.frame.size.width - 7 - 24,
                                                                                            (self.infoView.frame.size.height - 24) / 2,
                                                                                            24,
                                                                                            24)];
    weakSelf = opponentPlayerCircle;
    [opponentPlayerCircle drawBlock:^(CGContextRef context) {
        UIBezierPath* largeCircle = [UIBezierPath bezierPathWithOvalInRect:weakSelf.bounds];
        [[UIColor whiteColor] setFill];
        [largeCircle fill];
        
        UIBezierPath* smallCircle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2, 2, weakSelf.bounds.size.width - 4, opponentPlayerCircle.bounds.size.height - 4)];
        [[SVTheme sharedTheme].opponentPlayerColor setFill];
        [smallCircle fill];
    }];
    [self.infoView addSubview:opponentPlayerCircle];
    [opponentPlayerCircle addTarget:self action:@selector(didClickPlayerCircle:) forControlEvents:UIControlEventTouchUpInside];
    UILabel* opponentPlayerLabel = [[UILabel alloc] initWithFrame:CGRectMake(2,
                                                                             2,
                                                                             opponentPlayerCircle.frame.size.width - 4,
                                                                             opponentPlayerCircle.frame.size.height - 4)];
    opponentPlayerLabel.textAlignment = NSTextAlignmentCenter;
    opponentPlayerLabel.textColor = [UIColor whiteColor];
    opponentPlayerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
    opponentPlayerLabel.numberOfLines = 1;
    self.opponentPlayerLabel = opponentPlayerLabel;
    [opponentPlayerCircle addSubview:opponentPlayerLabel];
    
    self.colorButton = [[SVColorButton alloc] initWithFrame:CGRectMake((self.infoView.frame.size.width -  42) / 2,
                                                                       (self.infoView.frame.size.height - 26) / 2, 42, 26)];
    [self.colorButton addTarget:self action:@selector(didClickColorButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoView addSubview:self.colorButton];
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                               CGRectGetMaxY(self.infoView.frame),
                                                               self.bottomView.frame.size.width,
                                                               self.bottomView.frame.size.height - CGRectGetMaxY(self.infoView.frame))];
    [self.bottomView addSubview:self.footerView];
    
    self.footerLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.footerView.frame.size.width - 250) / 2,
                                                                 0,
                                                                 250,
                                                                 self.footerView.frame.size.height)];
    self.footerLabel.textColor = [UIColor whiteColor];
    self.footerLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    self.footerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.footerLabel.textAlignment = NSTextAlignmentCenter;
    [self.footerView addSubview:self.footerLabel];
    
    //Move off screen for animation
    self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x,
                                       self.view.frame.size.height,
                                       self.bottomView.frame.size.width,
                                       self.bottomView.frame.size.height);
    
    //Store views in the right order
    if (self.localPlayer == kSVPlayer1) {
        [self.pawnViews addObject:pawnView1];
        [self.pawnViews addObject:pawnView2];
        [self.playerCircles addObject:localPlayerCircle];
        [self.playerCircles addObject:opponentPlayerCircle];
    }
    else {
        [self.pawnViews addObject:pawnView2];
        [self.pawnViews addObject:pawnView1];
        [self.playerCircles addObject:opponentPlayerCircle];
        [self.playerCircles addObject:localPlayerCircle];
    }
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)opponentPlayerDidPlayTurn:(SVGame*)game {
    self.game = game;
    
    //Prevent player to play until new turn is played
    self.view.userInteractionEnabled = NO;
    [self playTurn:[self.game.turns lastObject]];
    [self displayTurn:[self.game.turns lastObject] animated:YES delay:0 finishBlock:^{
        self.view.userInteractionEnabled = YES;
    }];
    
    [self newTurn];
    [self updateUI];
}

- (void)show {
    //Switch menu
    if ([self.parentViewController isKindOfClass:SVCustomContainerController.class]) {
        SVCustomContainerController* container = (SVCustomContainerController*)self.parentViewController;
        [container.topBarView setTextLabel:@"Wall" animated:YES];
        
        UIImage* backImage = [UIImage imageNamed:@"back_arrow.png"];
        UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:backImage forState:UIControlStateNormal];
        backButton.frame = CGRectMake(0,
                                      0,
                                      backImage.size.width,
                                      backImage.size.height);
        backButton.adjustsImageWhenDisabled = NO;
        backButton.adjustsImageWhenHighlighted = NO;
        [backButton addTarget:self action:@selector(didClickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [container.topBarView setLeftButton:backButton animated:YES];
        [container.topBarView setRightButton:nil animated:YES];
    
        
        [UIView animateWithDuration:0.15 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.topLine.alpha = 1.0;
        } completion:nil];
        
        self.bottomView.alpha = 0;
        [UIView animateWithDuration:0.4 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x,
                                                  CGRectGetMaxY(self.boardView.frame),
                                                  self.bottomView.frame.size.width,
                                                  self.bottomView.frame.size.height);
            self.bottomView.alpha = 1;
        } completion:nil];
        
        for (id key in self.board.walls) {
            SVWall* wall = [self.board.walls objectForKey:key];
            SVWallView* wallView = [self wallViewForWall:wall];
            [wallView showRect:wallView.bounds animated:NO duration:0 withFinishBlock:nil];
            wallView.alpha = 0;
            [self.boardView addSubview:wallView];
            [self.wallViews setObject:wallView forKey:wall.position];
        }
        
        __weak SVGameViewController* weakSelf = self;
        
        //Play last turn
        if (self.game.turns.count > 0)
            [self playTurn:[self.game.turns lastObject]];

        [self.boardView showRowsAnimated:YES withFinishBlock:^{
            //Animate pawns and walls
            CAKeyframeAnimation* animation1 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            animation1.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0],
                                [NSNumber numberWithFloat:0.6],
                                [NSNumber numberWithFloat:1.0], nil];
            animation1.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                                  [NSNumber numberWithFloat:0.8],
                                  [NSNumber numberWithFloat:1.0], nil];
            animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation1.duration = 0.5;
            animation1.delegate = weakSelf;
            CAKeyframeAnimation* animation2 = [animation1 mutableCopy];
            NSArray* animations = [NSArray arrayWithObjects:animation1, animation2, nil];
            [animation1 setValue:@"pawnAnimation1" forKey:@"id"];
            [animation2 setValue:@"pawnAnimaiton2" forKey:@"id"];
            for (int i = 0; i < weakSelf.pawnViews.count; i++) {
                UIView* pawn = [weakSelf.pawnViews objectAtIndex:i];
                [weakSelf.boardView addSubview:pawn];
                CAAnimation* animation = [animations objectAtIndex:i];
                [pawn.layer addAnimation:animation forKey:[animation valueForKey:@"id"]];
                pawn.transform = CGAffineTransformIdentity;
            }

            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                for (id key in weakSelf.wallViews) {
                    SVWallView* wallView = [weakSelf.wallViews objectForKey:key];
                    wallView.alpha = 1;
                }
            } completion:nil];
        }];
    }
}

- (void)hideWithFinishBlock:(void (^)(void))block {
    self.hiddingView = YES;
    NSMutableArray* views = [NSMutableArray arrayWithArray:self.pawnViews];
    for (id key in self.wallViews) {
        SVWallView* wallView = [self.wallViews objectForKey:key];
        [views addObject:wallView];
    }
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.topLine.alpha = 0;
        for (UIView* view in views) {
            view.alpha = 0;
        }
    } completion:nil];
    [UIView animateWithDuration:0.25 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x,
                                           self.view.frame.size.height,
                                           self.bottomView.frame.size.width,
                                           self.bottomView.frame.size.height);
        
    } completion:nil];
    [self.boardView hideRowsAnimated:YES withFinishBlock:block];
}

#pragma mark - Private

- (void)updateUI {
    //Adjust the wall button color dependent on the number of walls remaining
    if ((self.currentPlayer == self.opponentPlayer) ||
        (((NSNumber*)([self.board.normalWallsRemaining objectAtIndex:self.localPlayer])).intValue <= 0 &&
        ((NSNumber*)([self.board.specialWallsRemaining objectAtIndex:self.localPlayer])).intValue <= 0)) {
        self.colorButton.enabled = NO;
    }
    else if (self.game.match.status == GKTurnBasedMatchStatusEnded) {
        self.colorButton.enabled = NO;
    }
    else {
        self.colorButton.enabled = YES;
        self.colorButton.selected = ((NSNumber*)([self.board.normalWallsRemaining objectAtIndex:self.localPlayer])).intValue <= 0;
    }
    
    //Adjust the footer color
    self.footerView.backgroundColor = [self.playerColors objectAtIndex:self.currentPlayer];
    
    if (self.game.match.status == GKTurnBasedMatchStatusEnded) {
        self.footerView.backgroundColor = [SVTheme sharedTheme].endedGameColor;
        GKTurnBasedParticipant* localParticipant;
        for (GKTurnBasedParticipant* participant in self.game.match.participants) {
            if ([participant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                localParticipant = participant;
                break;
            }
        }
        if (localParticipant.matchOutcome == GKTurnBasedMatchOutcomeWon)
            self.footerLabel.text = @"Won";
        else
            self.footerLabel.text = @"Lost";
    } else {
        if (self.currentPlayer == self.localPlayer) {
            self.footerLabel.text = @"Your turn";
        }
        else {
            if (self.opponentName) {
                self.footerLabel.text = [@"Waiting for " stringByAppendingString:[self.opponentName objectAtIndex:0]];
            }
        }
    }
    
    if (self.opponentName) {
        if (self.opponentName.count == 1) {
            self.opponentPlayerLabel.text = [[self.opponentName objectAtIndex:0] substringWithRange:NSMakeRange(0, 2)];
        }
        else {
            self.opponentPlayerLabel.text = [[[self.opponentName objectAtIndex:0] substringWithRange:NSMakeRange(0, 1)]
                                        stringByAppendingString:[[self.opponentName objectAtIndex:1] substringWithRange:NSMakeRange(0, 1)]];
        }
    }
    else {
        NSString* opponentID = [self.game.firstPlayerID isEqualToString:[GKLocalPlayer localPlayer].playerID] ? self.game.secondPlayerID : self.game.firstPlayerID;
        [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:opponentID]
                      withCompletionHandler:^(NSArray *players, NSError *error) {
                          GKPlayer* player = [players objectAtIndex:0];
                          NSArray* words = [player.displayName componentsSeparatedByString:@" "];
                          self.opponentName = words;
                          [self updateUI];
                      }];
    }
}

- (void)newTurn {
    if (self.game.turns.count == 0) {
        self.currentPlayer = kSVPlayer1;
        self.localPlayer = kSVPlayer1;
        self.opponentPlayer = kSVPlayer2;
    }
    else {
        if ([self.game.firstPlayerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            self.localPlayer = kSVPlayer1;
            self.opponentPlayer = kSVPlayer2;
        } else {
            self.localPlayer = kSVPlayer2;
            self.opponentPlayer = kSVPlayer1;
        }
        self.currentPlayer = self.game.turns.count % 2;
        
    }
    if (self.localPlayer == kSVPlayer1) {
        self.playerColors = [NSArray arrayWithObjects:[SVTheme sharedTheme].localPlayerColor,
                             [SVTheme sharedTheme].opponentPlayerColor, nil];
    }
    else {
        self.playerColors = [NSArray arrayWithObjects:[SVTheme sharedTheme].opponentPlayerColor,
                             [SVTheme sharedTheme].localPlayerColor, nil];
    }
    self.currentTurn = [[SVTurn alloc] init];
    self.currentTurn.player = self.currentPlayer;
}

- (void)commitCurrentTurn {
    self.gameUpdated = YES;
    [self.game.turns addObject:self.currentTurn];
    [self playTurn:self.currentTurn];
    
    if (self.currentTurn.action == kSVAddWallAction) {
        SVWall* wall = self.currentTurn.actionInfo;
        //Remove info wall
        [self removeInfoWallOfType:(kSVWallType)wall.type forPlayer:self.currentPlayer];
        [self.wallViews setObject:[self.buildingWallInfo objectForKey:@"view"] forKey:wall.position];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(gameViewController:didPlayTurn:ended:)]) {
        [self.delegate gameViewController:self didPlayTurn:self.game ended:[self.board didPlayerWin:self.localPlayer]];
    }
    [self newTurn];
    [self updateUI];
}

- (void)cancelCurrentTurn {
    if (self.currentTurn.action == kSVMoveAction) {
        [self movePawnToPosition:[self.board.playerPositions objectAtIndex:self.currentPlayer]
                       forPlayer:self.currentPlayer
                        animated:YES
                     finishBlock:nil];
    }
    else if (self.currentTurn.action == kSVAddWallAction) {
        SVWallView* wallView = [self.buildingWallInfo objectForKey:@"view"];
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
        
        [wallView showRect:rect animated:YES duration:0.15 withFinishBlock:^(void){
            [wallView removeFromSuperview];
        }];
        SVInfoWallView* infoWall = [self firstInfoWallOfType:((NSNumber*)[self.buildingWallInfo objectForKey:@"type"]).intValue
                                                   forPlayer:self.currentPlayer];
        [infoWall showRect:infoWall.bounds animated:YES withFinishBlock:nil];
        [self.buildingWallInfo removeAllObjects];
    }
    self.currentTurn.action = kSVNoAction;
}

- (BOOL)canPlayAction:(kSVAction)action withInfo:(id)actionInfo {
    if (self.game.match.status == GKTurnBasedMatchStatusEnded)
        return NO;
    if (self.currentTurn.action != kSVNoAction || self.currentPlayer == self.opponentPlayer)
        return NO;
    if (action == kSVMoveAction) {
        return [self.board canPlayer:self.currentPlayer moveTo:[actionInfo objectForKey:@"newPosition"]];
    }
    else if (action == kSVAddWallAction) {
        SVWall* wall = actionInfo;
        if (![self.board isWallLegalAtPosition:wall.position withOrientation:wall.orientation type:wall.type forPlayer:self.currentPlayer]) {
            return NO;
        }
        if (wall.type == kSVWallNormal) {
            return ((NSNumber*)[self.board.normalWallsRemaining objectAtIndex:self.currentPlayer]).intValue > 0;
        }
        else {
            return ((NSNumber*)[self.board.specialWallsRemaining objectAtIndex:self.currentPlayer]).intValue > 0;
        }
    }
    return YES;
}

- (void)didPlayAction {
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    [cancelButton addTarget:self action:@selector(didClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.alpha = 0;
    cancelButton.frame = CGRectMake((self.bottomView.frame.size.width - 100) / 2,
                                    (self.bottomView.frame.size.height - 40) / 2,
                                    100,
                                    40);
    [self.bottomView addSubview:cancelButton];
    
    UIButton* validateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [validateButton setTitle:@"Validate" forState:UIControlStateNormal];
    [validateButton setTitleColor:[SVTheme sharedTheme].localPlayerColor forState:UIControlStateNormal];
    validateButton.layer.cornerRadius = 20;
    validateButton.backgroundColor = [UIColor whiteColor];
    [validateButton addTarget:self action:@selector(didClickValidateButton:) forControlEvents:UIControlEventTouchUpInside];
    validateButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    validateButton.alpha = 0;
    validateButton.frame = CGRectMake((self.bottomView.frame.size.width - 100) / 2,
                                      (self.bottomView.frame.size.height - 40) / 2,
                                      100,
                                      40);
    
    [self.bottomView addSubview:validateButton];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.footerLabel.alpha = 0;
        cancelButton.alpha = 1;
        cancelButton.frame = CGRectMake(40,
                                        cancelButton.frame.origin.y,
                                        cancelButton.frame.size.width,
                                        cancelButton.frame.size.height);
        validateButton.alpha = 1;
        validateButton.frame = CGRectMake(self.bottomView.frame.size.width - 40 - validateButton.frame.size.width,
                                          validateButton.frame.origin.y,
                                          validateButton.frame.size.width,
                                          validateButton.frame.size.height);
    }];
    
    self.cancelButton = cancelButton;
    self.validateButton = validateButton;
}

- (void)playTurn:(SVTurn*)turn {
    if (turn.action == kSVMoveAction) {
        NSDictionary* info = turn.actionInfo;
        [self.board movePlayer:turn.player to:[info objectForKey:@"newPosition"]];
    }
    else if (turn.action == kSVAddWallAction) {
        SVWall* wall = turn.actionInfo;
        [self.board addWallAtPosition:wall.position
                      withOrientation:wall.orientation
                                 type:wall.type
                            forPlayer:turn.player];
    }
}

- (void)displayTurn:(SVTurn*)turn animated:(BOOL)animated delay:(NSTimeInterval)delay finishBlock:(void(^)(void))finishBlock {
    void(^block)(void) = ^{
        if (self.hiddingView)
            return;
        
        if (turn.action == kSVMoveAction) {
            NSDictionary* info = turn.actionInfo;
            [self movePawnToPosition:[info objectForKey:@"newPosition"] forPlayer:turn.player animated:animated finishBlock:finishBlock];
        }
        else if (turn.action == kSVAddWallAction) {
            SVWall* wall = turn.actionInfo;
            SVWallView* wallView = [self wallViewForWall:wall];
            [self.wallViews setObject:wallView forKey:wall.position];
            [wallView showRect:wallView.bounds animated:NO duration:0 withFinishBlock:nil];
            if (animated) {
                wallView.alpha = 0;
                [self.boardView addSubview:wallView];
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [self firstInfoWallOfType:wall.type forPlayer:turn.player].alpha = 0;
                    wallView.alpha = 1;
                } completion:^(BOOL finished){
                    if (finished) {
                        [self removeInfoWallOfType:wall.type forPlayer:turn.player];
                        if (finishBlock)
                            finishBlock();
                    }
                }];
            }
            else {
                [self.boardView addSubview:wallView];
                [self removeInfoWallOfType:wall.type forPlayer:turn.player];
                if (finishBlock)
                    finishBlock();
            }
        }
        
        //Animate player circle
        if (animated) {
            UIView* circle = [self.playerCircles objectAtIndex:turn.player];
            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            animation.fromValue = [NSNumber numberWithFloat:1.0];
            animation.toValue = [NSNumber numberWithFloat:1.2];
            animation.autoreverses = YES;
            animation.duration = 0.3;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [circle.layer addAnimation:animation forKey:@"playerCircleAnimation"];
        }
    };
    if (delay > 0)
        [self performSelector:@selector(performBlock:) withObject:block afterDelay:delay];
    else
        block();
}

- (void)reDisplayTurnAnimated:(SVTurn*)turn finishBlock:(void(^)(void))finishBlock {
    void(^animationFinishBlock)(void) = ^{
        if (self.hiddingView)
            return;
        [self displayTurn:turn animated:YES delay:0.3 finishBlock:finishBlock];
    };
    
    if (turn.action == kSVMoveAction) {
        NSDictionary* info = turn.actionInfo;
        [self movePawnToPosition:[info objectForKey:@"oldPosition"] forPlayer:turn.player animated:YES finishBlock:animationFinishBlock];
    }
    else if (turn.action == kSVAddWallAction) {
        SVWall* wall = turn.actionInfo;
        SVInfoWallView* infoWallView = [self addInfoWallOfType:wall.type forPlayer:turn.player];
        infoWallView.alpha = 0;
        SVWallView* wallView = [self.wallViews objectForKey:wall.position];
        [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            wallView.alpha = 0;
            infoWallView.alpha = 1;
        } completion:^(BOOL finished){
            if (finished && !self.hiddingView)
                animationFinishBlock();
        }];
    }
}

- (void)movePawnToPosition:(SVPosition*)position forPlayer:(kSVPlayer)player animated:(BOOL)animated finishBlock:(void(^)(void))finishBlock {
    CGPoint point = [self.boardView squareCenterForPosition:position];
    SVPawnView* pawnView = [self.pawnViews objectAtIndex:player];
    CGRect newFrame = CGRectMake(point.x - pawnView.frame.size.width / 2,
                                 point.y - pawnView.frame.size.height / 2,
                                 pawnView.frame.size.width,
                                 pawnView.frame.size.height);
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             pawnView.frame = newFrame;
                         } completion:^(BOOL finished){
                             if (finished && finishBlock)
                                 finishBlock();
                         }];
    }
    else {
        pawnView.frame = newFrame;
        if (finishBlock)
            finishBlock();
    }
}

- (UIColor*)colorForWall:(SVWall*)wall {
    if (wall.type == kSVWallNormal)
        return [SVTheme sharedTheme].normalWallColor;
    else if (wall.type == kSVWallPlayer1)
        return [self.playerColors objectAtIndex:kSVPlayer1];
    return [self.playerColors objectAtIndex:kSVPlayer2];
}

- (SVWallView*)wallViewForWall:(SVWall*)wall {
    kSVWallViewType leftWallViewType;
    kSVWallViewType rightWallViewType;
    float leftWallViewOffset;
    float rightWallViewOffset;
    UIColor* leftWallViewColor;
    UIColor* centerWallViewColor;
    UIColor* rightWallViewColor;
    
    SVWall* topLeft;
    SVWall* topRight;
    SVWall* bottomLeft;
    SVWall* bottomRight;
    SVWall* leftSameOrientation;
    SVWall* rightSameOrientation;
    SVWall* leftOtherOrientation;
    SVWall* rightOtherOrientation;
    
    float height = 8;
    if (wall.orientation == kSVHorizontalOrientation) {
        topLeft = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x - 1 andY:wall.position.y - 1]
                             withOrientation:kSVVerticalOrientation];
        topRight = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x + 1 andY:wall.position.y - 1]
                              withOrientation:kSVVerticalOrientation];
        bottomLeft = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x - 1 andY:wall.position.y + 1]
                                withOrientation:kSVVerticalOrientation];;
        bottomRight = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x + 1 andY:wall.position.y + 1]
                                 withOrientation:kSVVerticalOrientation];;
        leftSameOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x - 2 andY:wall.position.y]
                                         withOrientation:kSVHorizontalOrientation];
        rightSameOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x + 2 andY:wall.position.y]
                                          withOrientation:kSVHorizontalOrientation];
        leftOtherOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x - 1 andY:wall.position.y]
                                          withOrientation:kSVVerticalOrientation];
        rightOtherOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x + 1 andY:wall.position.y]
                                           withOrientation:kSVVerticalOrientation];
    }
    else {
        topLeft = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x + 1 andY:wall.position.y - 1]
                             withOrientation:kSVHorizontalOrientation];
        topRight = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x + 1 andY:wall.position.y + 1]
                              withOrientation:kSVHorizontalOrientation];
        bottomLeft = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x - 1 andY:wall.position.y - 1]
                                withOrientation:kSVHorizontalOrientation];;
        bottomRight = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x - 1 andY:wall.position.y + 1]
                                 withOrientation:kSVHorizontalOrientation];;
        leftSameOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x andY:wall.position.y - 2 ]
                                         withOrientation:kSVVerticalOrientation];
        rightSameOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x andY:wall.position.y + 2]
                                          withOrientation:kSVVerticalOrientation];
        leftOtherOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x andY:wall.position.y - 1]
                                          withOrientation:kSVHorizontalOrientation];
        rightOtherOrientation = [self.board wallAtPosition:[[SVPosition alloc] initWithX:wall.position.x andY:wall.position.y + 1]
                                           withOrientation:kSVHorizontalOrientation];
    }
    
    //Left
    if ((topLeft && bottomLeft) || leftOtherOrientation) {
        leftWallViewType = kSVWallViewSquared;
        leftWallViewColor = [self colorForWall:wall];
        leftWallViewOffset = height / 2;
    }
    else if (leftSameOrientation) {
        leftWallViewType = kSVWallViewSquared;
        leftWallViewColor = [self colorForWall:leftSameOrientation];
        leftWallViewOffset = - height / 2;
    }
    else if (topLeft) {
        leftWallViewType = kSVWallViewTopOriented;
        leftWallViewColor = [self colorForWall:topLeft];
        leftWallViewOffset = - height / 2;
    }
    else if (bottomLeft) {
        leftWallViewType = kSVWallViewBottomOriented;
        leftWallViewColor = [self colorForWall:bottomLeft];
        leftWallViewOffset = - height / 2;
    }
    else {
        leftWallViewType = kSVWallViewRounded;
        leftWallViewColor = [self colorForWall:wall];
        leftWallViewOffset = 0;
    }
    
    //Right
    if ((topRight && bottomRight) || rightOtherOrientation) {
        rightWallViewType = kSVWallViewSquared;
        rightWallViewColor = [self colorForWall:wall];
        rightWallViewOffset = - height / 2;
    }
    else if (rightSameOrientation) {
        rightWallViewType = kSVWallViewSquared;
        rightWallViewColor = [self colorForWall:rightSameOrientation];
        rightWallViewOffset = height / 2;
    }
    else if (topRight) {
        rightWallViewType = kSVWallViewTopOriented;
        rightWallViewColor = [self colorForWall:topRight];
        rightWallViewOffset = height / 2;
    }
    else if (bottomRight) {
        rightWallViewType = kSVWallViewBottomOriented;
        rightWallViewColor = [self colorForWall:bottomRight];
        rightWallViewOffset = height / 2;
    }
    else {
        rightWallViewType = kSVWallViewRounded;
        rightWallViewColor = [self colorForWall:wall];
        rightWallViewOffset = 0;
    }
    
    //Center
    centerWallViewColor = [self colorForWall:wall];
    
    //Build wallView
    int length = 92;
    int thickness = 8;
    int lengthDifference = 0;
    
    CGPoint center = [self.boardView intersectionPointForPosition:wall.position];
    
    if (wall.orientation == kSVHorizontalOrientation && wall.position.x == 1) {
        center.x += 2;
        lengthDifference = -1;
    }
    else if (wall.orientation == kSVHorizontalOrientation && wall.position.x == self.board.size.width - 1) {
        center.x += 1.5;
        lengthDifference = -1.5;
    }
    else if ((wall.orientation == kSVVerticalOrientation && wall.position.y == 1) ||
             (wall.orientation == kSVVerticalOrientation && wall.position.y == self.board.size.height - 1)) {
        lengthDifference = -0.5;
    }
    
    CGRect rect;
    if (wall.orientation == kSVHorizontalOrientation) {
        rect = CGRectMake(center.x - length / 2 + lengthDifference + leftWallViewOffset,
                          center.y - thickness / 2,
                          length - leftWallViewOffset + rightWallViewOffset + lengthDifference,
                          thickness);
    }
    else {
        rect = CGRectMake(center.x - thickness / 2,
                          center.y - length / 2 + lengthDifference + leftWallViewOffset,
                          thickness,
                          length -leftWallViewOffset + rightWallViewOffset + lengthDifference);
    }
    
    SVWallView* wallView = [[SVWallView alloc] initWithFrame:rect
                                                   startType:leftWallViewType
                                                     endType:rightWallViewType
                                                   leftColor:leftWallViewColor
                                                 centerColor:centerWallViewColor
                                                  rightColor:rightWallViewColor];
    return wallView;
}

- (SVInfoWallView*)addInfoWallOfType:(kSVWallType)type forPlayer:(kSVPlayer)player {
    UIColor* color;
    
    int originX;
    int animationOffset;
    
    int offsetCount = 0;
    if (type != kSVWallNormal) {
        color = self.playerColors[player];
    } else {
        color = [SVTheme sharedTheme].normalWallColor;
        offsetCount = ((NSNumber*)[self.board.specialWallsRemaining objectAtIndex:player]).intValue;
    }
    
    if (player == self.localPlayer) {
        originX = 38 + 7 * offsetCount;
        animationOffset = 7;
    } else {
        originX = self.infoView.frame.size.width - 38 - 4 - 7 * offsetCount;
        animationOffset = -7;
    }
    
    NSMutableArray* infoWallViews = [self.infoWallViews objectAtIndex:player];
    SVInfoWallView* infoWallView = [[SVInfoWallView alloc] initWithFrame:CGRectMake(originX,
                                                                                    (self.infoView.frame.size.height - 15) / 2,
                                                                                    4,
                                                                                    15)
                                                        andColor:color];
    
    for (int i = offsetCount; i < infoWallViews.count; i++) {
        [UIView animateWithDuration:0.5 animations:^{
            SVInfoWallView* wall = [infoWallViews objectAtIndex:i];
            wall.frame = CGRectMake(wall.frame.origin.x + animationOffset,
                                    wall.frame.origin.y,
                                    wall.frame.size.width,
                                    wall.frame.size.height);
        }];
    }
    [infoWallViews insertObject:infoWallView atIndex:offsetCount];
    [self.infoView addSubview:infoWallView];
    return infoWallView;
    
};

- (SVInfoWallView*)firstInfoWallOfType:(kSVWallType)type forPlayer:(kSVPlayer)player {
    NSMutableArray* array = [self.infoWallViews objectAtIndex:player];
    int index = -1;
    if (type == kSVWallNormal && ((NSNumber*)[self.board.normalWallsRemaining objectAtIndex:player]).intValue > 0) {
        index = ((NSNumber*)[self.board.specialWallsRemaining objectAtIndex:player]).intValue;
    }
    else if (((NSNumber*)[self.board.specialWallsRemaining objectAtIndex:player]).intValue > 0) {
        index = 0;
    }
    if (index != -1) {
        return [array objectAtIndex:index];
    }
    return nil;
}

- (void)removeInfoWallOfType:(kSVWallType)type forPlayer:(kSVPlayer)player {
    NSMutableArray* array = [self.infoWallViews objectAtIndex:player];
    int specialWallsRemaining = ((NSNumber*)[self.board.specialWallsRemaining objectAtIndex:player]).intValue;
    int index = type == kSVWallNormal ? specialWallsRemaining : 0;
    SVInfoWallView* wall = [array objectAtIndex:index];
    [wall removeFromSuperview];
    [array removeObject:wall];
    int offset = player == self.localPlayer ? -7 : 7;
    for (int i = index; i < array.count; i++) {
        [UIView animateWithDuration:0.5 animations:^{
            SVInfoWallView* wall = [array objectAtIndex:i];
            wall.frame = CGRectMake(wall.frame.origin.x + offset, wall.frame.origin.y, wall.frame.size.width, wall.frame.size.height);
        }];
    } 
}

- (void)performBlock:(void(^)(void))block {
    block();
}

#pragma mark - Targets

- (void)didClickColorButton:(id)sender {
    UIButton* button = (UIButton*)sender;
    if (button.selected && ((NSNumber*)[self.board.normalWallsRemaining objectAtIndex:self.currentPlayer]).intValue > 0) {
        button.selected = !button.selected;
    }
    else if (((NSNumber*)[self.board.specialWallsRemaining objectAtIndex:self.currentPlayer]).intValue > 0) {
        button.selected = !button.selected;
    }
}

- (void)didClickCancelButton:(id)sender {
    self.cancelButton.enabled = NO;
    self.validateButton.enabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.footerLabel.alpha = 1;
        self.cancelButton.alpha = 0;
        self.cancelButton.frame = CGRectMake((self.bottomView.frame.size.width - 100) / 2,
                                        (self.bottomView.frame.size.height - 32) / 2,
                                        100,
                                        32);
        self.validateButton.alpha = 0;
        self.validateButton.frame = CGRectMake((self.bottomView.frame.size.width - 100) / 2,
                                          (self.bottomView.frame.size.height - 32) / 2,
                                          100,
                                          32);
    } completion:^(BOOL finished) {
        if (finished) {
            self.cancelButton = nil;
            self.validateButton = nil;
        }
    }];
    [self cancelCurrentTurn];
}

- (void)didClickValidateButton:(id)sender {
    self.cancelButton.enabled = NO;
    self.validateButton.enabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.footerLabel.alpha = 1;
        self.cancelButton.alpha = 0;
        self.cancelButton.frame = CGRectMake((self.bottomView.frame.size.width - 100) / 2,
                                             (self.bottomView.frame.size.height - 40) / 2,
                                             100,
                                             40);
        self.validateButton.alpha = 0;
        self.validateButton.frame = CGRectMake((self.bottomView.frame.size.width - 100) / 2,
                                               (self.bottomView.frame.size.height - 40) / 2,
                                               100,
                                               40);
        self.bottomView.backgroundColor = [self.playerColors objectAtIndex:self.opponentPlayer];
    } completion:^(BOOL finished) {
        if (finished) {
            self.cancelButton = nil;
            self.validateButton = nil;
        }
    }];
    [self commitCurrentTurn];
}

- (void)didClickBackButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(gameViewControllerDidClickBack:gameUpdated:)]) {
        [self.delegate gameViewControllerDidClickBack:self gameUpdated:self.gameUpdated];
    }
}

- (void)didClickPlayerCircle:(id)sender {
    UIButton* button = (UIButton*)sender;
    //Avoid double clicking
    button.enabled = NO;
    if (button == [self.playerCircles objectAtIndex:self.currentPlayer]) {
        if (self.game.turns.count >= 2) {
            SVTurn* turn = [self.game.turns objectAtIndex:self.game.turns.count - 2];
            [self reDisplayTurnAnimated:turn finishBlock:^{
                button.enabled = YES;
            }];
        }
    }
    else {
        if (self.game.turns.count >= 1) {
            SVTurn* turn = [self.game.turns objectAtIndex:self.game.turns.count - 1];
            [self reDisplayTurnAnimated:turn finishBlock:^{
                button.enabled = YES;
            }];
        }
    }
}

//- (void)didPanPawn:(UIPanGestureRecognizer *)gestureRecognizer {
//    SVPawnView* pawnView = [self.pawnViews objectAtIndex:self.localPlayer];
//    CGPoint point = [gestureRecognizer translationInView:pawnView];
//    
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        CGPoint velocity = [gestureRecognizer velocityInView:pawnView];
//        if (abs(velocity.x) > abs(velocity.y)) {
//            if (velocity.x > 0) {
//                self.pawnPanDirection = kSVRightDirection;
//                self.pawnPanView = [[UIView alloc] initWithFrame:CGRectMake(pawnView.frame.origin.x,
//                                                                            pawnView.frame.origin.y,
//                                                                            point.x,
//                                                                            20)];
//            }
//            else {
//                self.pawnPanDirection = kSVLeftDirection;
//                self.pawnPanView = [[UIView alloc] initWithFrame:CGRectMake(pawnView.frame.origin.x + point.x,
//                                                                            pawnView.frame.origin.y,
//                                                                            -point.x,
//                                                                            20)];
//            }
//        }
//        else {
//            if (velocity.y > 0) {
//                self.pawnPanDirection = kSVBottomDirection;
//                self.pawnPanView = [[UIView alloc] initWithFrame:CGRectMake(pawnView.frame.origin.x,
//                                                                            pawnView.frame.origin.y,
//                                                                            20,
//                                                                            point.y)];
//            }
//            else {
//                self.pawnPanDirection = kSVTopDirection;
//                self.pawnPanView = [[UIView alloc] initWithFrame:CGRectMake(pawnView.frame.origin.x,
//                                                                            pawnView.frame.origin.y + point.y,
//                                                                            20,
//                                                                            -point.y)];
//            }
//        }
//        self.pawnPanView.backgroundColor = [UIColor redColor];
//        [self.boardView addSubview:self.pawnPanView];
//    }
//    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        if (self.pawnPanDirection == kSVLeftDirection)
//            self.pawnPanView.frame = CGRectMake(pawnView.frame.origin.x,
//                                                                        pawnView.frame.origin.y,
//                                                                        point.x,
//                                                                        20);
//        else if (self.pawnPanDirection == kSVRightDirection)
//            self.pawnPanView.frame = CGRectMake(pawnView.frame.origin.x + point.x,
//                                                                        pawnView.frame.origin.y,
//                                                                        -point.x,
//                                                                        20);
//        else if (self.pawnPanDirection == kSVTopDirection)
//            self.pawnPanView.frame = CGRectMake(pawnView.frame.origin.x,
//                                                                        pawnView.frame.origin.y,
//                                                                        20,
//                                                                        point.y);
//        else
//            self.pawnPanView.frame = CGRectMake(pawnView.frame.origin.x,
//                                                                        pawnView.frame.origin.y + point.y,
//                                                                        20,
//                                                                        -point.y);
//    }
//    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
//        SVPosition* position = [self.board.playerPositions objectAtIndex:self.localPlayer];
//        SVPosition* nextPosition;
//        if (self.pawnPanDirection == kSVLeftDirection)
//            nextPosition = [[SVPosition alloc] initWithX:position.x - 1 andY:position.y];
//        else if (self.pawnPanDirection == kSVRightDirection)
//            nextPosition = [[SVPosition alloc] initWithX:position.x + 1 andY:position.y];
//        else if (self.pawnPanDirection == kSVTopDirection)
//            nextPosition = [[SVPosition alloc] initWithX:position.x andY:position.y - 1];
//        else
//            nextPosition = [[SVPosition alloc] initWithX:position.x andY:position.y + 1];
//        
//        [self.pawnPanView removeFromSuperview];
//        if ([self.board canPlayer:self.localPlayer moveTo:nextPosition]) {
//            [self movePawnToPosition:nextPosition forPlayer:self.localPlayer animated:YES finishBlock:nil];
//        }
//    }
//}

#pragma mark - Delegates

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
    
    kSVWallType wallType;
    if (!self.colorButton.selected) {
        wallType = kSVWallNormal;
    }
    else {
        wallType = self.currentPlayer == kSVPlayer1 ? kSVWallPlayer1 : kSVWallPlayer2;
    }
    
    SVWall* wall = [[SVWall alloc] initWithPosition:wallPosition
                                        orientation:wallOrientation
                                            andType:wallType];
    self.canBuildWall = [self canPlayAction:kSVAddWallAction withInfo:wall];
    if (!self.canBuildWall)
        return;

    SVWallView* wallView = [self wallViewForWall:wall];
    [self.boardView addSubview:wallView];

    self.buildingWallInfo = [[NSMutableDictionary alloc] init];
    [self.buildingWallInfo setObject:[NSNumber numberWithInt:direction] forKey:@"direction"];
    [self.buildingWallInfo setObject:[NSNumber numberWithInt:wallOrientation] forKey:@"orientation"];
    [self.buildingWallInfo setObject:[NSNumber numberWithInt:wallType] forKey:@"type"];
    [self.buildingWallInfo setObject:wallPosition forKey:@"position"];
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
    [wallView showRect:rect animated:NO duration:0 withFinishBlock:nil];

    sizeRatio = sizeRatio > 1 ? 1 : sizeRatio;
    
    //Hide info wall
    SVInfoWallView* infoWall = [self firstInfoWallOfType:((NSNumber*)[self.buildingWallInfo objectForKey:@"type"]).intValue
                                               forPlayer:self.currentPlayer];
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
        [wallView showRect:wallView.bounds animated:YES duration:0.15 withFinishBlock:nil];
        SVWall* wall = [[SVWall alloc] initWithPosition:[self.buildingWallInfo objectForKey:@"position"]
                                            orientation:((NSNumber*)[self.buildingWallInfo objectForKey:@"orientation"]).intValue
                                                andType:((NSNumber*)[self.buildingWallInfo objectForKey:@"type"]).intValue];
        self.currentTurn.action = kSVAddWallAction;
        self.currentTurn.actionInfo = wall;
        SVInfoWallView* infoWallView = [self firstInfoWallOfType:wall.type forPlayer:self.currentPlayer];
        [infoWallView showRect:CGRectZero animated:NO withFinishBlock:nil];
        [self didPlayAction];
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
        
        [wallView showRect:rect animated:!change duration:0.15 withFinishBlock:^(void){
            [wallView removeFromSuperview];
        }];
        SVInfoWallView* infoWall = [self firstInfoWallOfType:((NSNumber*)[self.buildingWallInfo objectForKey:@"type"]).intValue
                                                   forPlayer:self.currentPlayer];
        [infoWall showRect:infoWall.bounds animated:YES withFinishBlock:nil];
    }
}

- (void)boardView:(SVBoardView *)boardView didTapSquare:(SVPosition *)position {
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    [info setObject:[self.board.playerPositions objectAtIndex:self.currentPlayer] forKey:@"oldPosition"];
    [info setObject:position forKey:@"newPosition"];
    if ([self canPlayAction:kSVMoveAction withInfo:info]) {
        [self movePawnToPosition:position forPlayer:self.currentPlayer animated:YES finishBlock:nil];
        self.currentTurn.action = kSVMoveAction;
        self.currentTurn.actionInfo = info;
        [self didPlayAction];
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if ([[theAnimation valueForKey:@"id"] isEqualToString:@"pawnAnimation1"]) {
        if (self.game.turns.count > 0) {
            [self displayTurn:[self.game.turns lastObject] animated:YES delay:0.3 finishBlock:^{
                self.view.userInteractionEnabled = YES;
            }];
        }
    }
}

@end
