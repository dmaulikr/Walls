//
//  SVGamesTableViewController.m
//  Walls
//
//  Created by Sebastien Villar on 28/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "SVGamesTableViewController.h"
#import "SVGameViewController.h"
#import "SVTheme.h"
#import "SVCustomView.h"
#import "SVGameTableViewCell.h"
#import "SVCustomContainerController.h"

static NSString *spaceCellIdentifer = @"SpaceCell";
static NSString *gameCellIdentifier = @"GameCell";

@interface SVGamesTableViewController ()
@property (strong) NSMutableArray* inProgressGames;
@property (strong) NSMutableArray* endedGames;
@property (strong) SVGameViewController* currentController;
@property (strong) NSMutableDictionary* sectionViews;

- (void)newGame;
- (void)loadGame:(SVGame*)game;
- (void)loadGames;

- (void)didClickAddButton;
@end

@implementation SVGamesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _inProgressGames = [[NSMutableArray alloc] init];
        _endedGames = [[NSMutableArray alloc] init];
        _sectionViews = [[NSMutableDictionary alloc] init];
        [[GKLocalPlayer localPlayer] unregisterAllListeners];
        [[GKLocalPlayer localPlayer] registerListener:self];
        [self loadGames];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [SVTheme sharedTheme].darkSquareColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:SVGameTableViewCell.class forCellReuseIdentifier:gameCellIdentifier];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:spaceCellIdentifer];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.parentViewController isKindOfClass:SVCustomContainerController.class]) {
        SVCustomContainerController* container = (SVCustomContainerController*)self.parentViewController;
        NSMutableAttributedString* topString = [[NSMutableAttributedString alloc] initWithString:@"Games"];
        [topString addAttribute:NSKernAttributeName value:@3 range:NSMakeRange(0, 4)];
        container.topBarView.label.attributedText = topString;
        
        UIButton* plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* plusImage = [UIImage imageNamed:@"plusSign.png"];
        [plusButton setBackgroundImage:plusImage forState:UIControlStateNormal];
        plusButton.adjustsImageWhenHighlighted = NO;
        plusButton.adjustsImageWhenDisabled = NO;
        plusButton.frame = CGRectMake(0,
                                      0,
                                      plusImage.size.width,
                                      plusImage.size.height);
        container.topBarView.rightButton = plusButton;
    }
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"New" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickAddButton) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 500, 100, 30);
    
    [self.view addSubview:button];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [UIView beginAnimations:@"opacity" context:NULL];
//    [UIView setAnimationDuration:0.3];
//    for (id key in self.sectionViews) {
//        UIView* view = [self.sectionViews objectForKey:key];
//        view.alpha = 0;
//    }
//    [UIView commitAnimations];
//    
//    NSArray* cells = self.tableView.visibleCells;
//    float i = 0;
//    for (UITableViewCell* cell in cells) {
//        if ([cell isKindOfClass:SVGameTableViewCell.class]) {
//            //2. Define the initial state (Before the animation)
//            
//            //3. Define the final state (After the animation) and commit the animation
//            [UIView beginAnimations:@"frame" context:NULL];
//            [UIView setAnimationDelay:i];
//            [UIView setAnimationDuration:0.3];
//            cell.layer.frame = CGRectMake(-cell.layer.frame.size.width,
//                                          cell.layer.frame.origin.y,
//                                          cell.layer.frame.size.width,
//                                          cell.layer.frame.size.height);
//            [UIView commitAnimations];
//            i += 0.05;
//        }
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////
// Private
//////////////////////////////////////////////////////

- (void)newGame {
    GKMatchRequest* request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    GKTurnBasedMatchmakerViewController* controller = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    [self presentViewController:controller
                       animated:YES
                     completion:nil];
    controller.turnBasedMatchmakerDelegate = self;
}

- (void)loadGame:(SVGame*)game {
    SVGameViewController* controller = [[SVGameViewController alloc] initWithGame:game];
    controller.delegate = self;
    if ([self.parentViewController isKindOfClass:SVCustomContainerController.class]) {
        SVCustomContainerController* container = (SVCustomContainerController*) self.parentViewController;
        [container pushViewController:controller];
    }
    self.currentController = controller;
}

- (void)loadGames {
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
        if (error) {
            NSLog(@"error : %@", error);
            return;
        }
        int i = 0;
        for (GKTurnBasedMatch* match in matches) {
            [match loadMatchDataWithCompletionHandler:nil];
            NSMutableArray* playerIDs = [[NSMutableArray alloc] init];
            for (GKTurnBasedParticipant* participant in match.participants) {
                [playerIDs addObject:participant.playerID];
            }
            SVGame* game = [SVGame gameWithMatch:match];
            if (game.match.status == GKTurnBasedMatchStatusEnded) {
                [self.endedGames addObject:game];
            }
            else {
                [self.inProgressGames addObject:game];
            }
            i++;
        }
        NSLog(@"loaded");
        [self.tableView reloadData];
    }];
}

//////////////////////////////////////////////////////
// Buttons Targets
//////////////////////////////////////////////////////

- (void)didClickAddButton {
    [self newGame];
}

//////////////////////////////////////////////////////
// Delegates
//////////////////////////////////////////////////////

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
    NSLog(@"found match: %@", match.matchID);
    [self loadGame:[SVGame gameWithMatch:match]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
    NSLog(@"quit");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
    NSLog(@"cancelled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    NSLog(@"fail");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive {
    if (self.currentController && [match.matchID isEqualToString:self.currentController.game.match.matchID]) {
        [GKTurnBasedMatch loadMatchWithID:match.matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
            SVGame* game = [SVGame gameWithMatch:match];
            if (game.turns.count > self.currentController.game.turns.count) {
                [self.currentController opponentPlayerDidPlayTurn:game];
                [[GKLocalPlayer localPlayer] unregisterAllListeners];
                [[GKLocalPlayer localPlayer] registerListener:self];
            }
        }];
    }
    else {
        //Refresh matches
    }
}

- (void)player:(GKPlayer *)player didRequestMatchWithPlayers:(NSArray *)playerIDsToInvite {
    NSLog(@"did request match");
}

- (void)player:(GKPlayer *)player matchEnded:(GKTurnBasedMatch *)match {
    NSLog(@"match ended");
}

- (void)gameViewController:(SVGameViewController *)controller didPlayTurn:(SVGame *)game ended:(BOOL)ended{
    NSData* data = [game data];
    GKTurnBasedParticipant* nextParticipant;
    for (GKTurnBasedParticipant* participant in game.match.participants) {
        if (![participant.playerID isEqualToString:game.match.currentParticipant.playerID])
            nextParticipant = participant;
    }

    if (ended) {
        for (GKTurnBasedParticipant* participant in game.match.participants) {
            if ([participant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
                participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
            else
                participant.matchOutcome = GKTurnBasedMatchOutcomeLost;
        }
        [game.match endMatchInTurnWithMatchData:data completionHandler:^(NSError *error) {
            NSLog(@"ended");
        }];
    }
    else {
        [game.match endTurnWithNextParticipants:[NSArray arrayWithObject:nextParticipant]
                                    turnTimeout:GKTurnTimeoutNone
                                      matchData:data
                              completionHandler:^(NSError *error) {
                                    NSLog(@"sent");
                              }];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.inProgressGames.count;
    }
    return self.endedGames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 1) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:spaceCellIdentifer forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else {
        SVGameTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:gameCellIdentifier forIndexPath:indexPath];
        SVGame* game;
        if (indexPath.section == 0)
            game = [self.inProgressGames objectAtIndex:ceil(indexPath.row / 2)];
        else
            game = [self.endedGames objectAtIndex:ceil(indexPath.row / 2)];
        [cell displayForGame:game];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray* games;
    if (indexPath.section == 0)
        games = self.inProgressGames;
    else
        games = self.endedGames;
    
    SVGame* game = [games objectAtIndex:ceil(indexPath.row / 2)];
    //Check if data
    [self loadGame:game];
//    [self viewWillDisappear:YES];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* view = [self.sectionViews objectForKey:[NSNumber numberWithInt:(int)section]];
    if (view) {
        return view;
    }
    SVCustomView* customView = [[SVCustomView alloc] init];
    __weak SVCustomView* weakSelf = customView;
    [customView drawBlock:^(CGContextRef context) {
        UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(20,
                                                                         27,
                                                                         weakSelf.frame.size.width - 40,
                                                                         1)];
        [[UIColor whiteColor] setFill];
        [path fill];
    }];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20,
                                                               8,
                                                               100,
                                                               15)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    
    NSMutableAttributedString* text;
    if (section == 0) {
        text = [[NSMutableAttributedString alloc] initWithString:@"In progress"];
        [text addAttribute:NSKernAttributeName value:@2 range:NSMakeRange(0, 10)];
    }
    else {
        text = [[NSMutableAttributedString alloc] initWithString:@"Completed"];
        [text addAttribute:NSKernAttributeName value:@2 range:NSMakeRange(0, 8)];
    }
    label.attributedText = text;
    [customView addSubview:label];
    [self.sectionViews setObject:customView forKey:[NSNumber numberWithInt:(int)section]];
    
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 1) {
        return 8;
    }
    return 42;
}


@end
