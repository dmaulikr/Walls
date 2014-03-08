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
#import "SVGameTableSectionView.h"

static NSString *spaceCellIdentifer = @"SpaceCell";
static NSString *gameCellIdentifier = @"GameCell";

@interface SVGamesTableViewController ()
@property (strong) NSMutableArray* inProgressGames;
@property (strong) NSMutableArray* endedGames;
@property (strong) SVGameViewController* currentController;
@property (strong) NSMutableDictionary* sectionViews;
@property (strong) UIButton* plusButton;

- (void)newGame;
- (void)loadGame:(SVGame*)game;
- (void)loadGames;
- (void)showRowsAnimated:(BOOL)animated;
- (void)hideRowsAnimated:(BOOL)animated;
- (void)setTopBarButtonsAnimated:(BOOL)animated;
- (void)performBlock:(void(^)(void))block;
- (void)didClickPlusButton:(id)sender;

@end

@implementation SVGamesTableViewController

#pragma mark - Public

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


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setTopBarButtonsAnimated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

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
        [UIView beginAnimations:@"opacity" context:NULL];
        [UIView setAnimationDuration:0.3];
        for (id key in self.sectionViews) {
            UIView* view = [self.sectionViews objectForKey:key];
            view.alpha = 0;
        }
        [UIView commitAnimations];
        
        NSArray* cells = self.tableView.visibleCells;
        float i = 0;
        for (UITableViewCell* cell in cells) {
            if ([cell isKindOfClass:SVGameTableViewCell.class]) {
                [UIView beginAnimations:@"frame" context:NULL];
                [UIView setAnimationDelay:i];
                [UIView setAnimationDuration:0.3];
                cell.layer.frame = CGRectMake(-cell.layer.frame.size.width,
                                              cell.layer.frame.origin.y,
                                              cell.layer.frame.size.width,
                                              cell.layer.frame.size.height);
                [UIView commitAnimations];
                i += 0.05;
            }
        }

        SVCustomContainerController* container = (SVCustomContainerController*)self.parentViewController;
        [self performSelector:@selector(performBlock:) withObject:^{
            [container pushViewController:controller];
            [controller show];
            self.currentController = controller;
        } afterDelay:0.2];
    }
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
            SVGame* game = [SVGame gameWithMatch:match];
            if (game.match.status == GKTurnBasedMatchStatusEnded) {
                [self.endedGames addObject:game];
            }
            else {
                [self.inProgressGames addObject:game];
            }
            i++;
        }
        NSComparator comparator = ^(SVGame* obj1, SVGame* obj2) {
            return [obj2.match.creationDate compare:obj1.match.creationDate];
        };
        [self.endedGames sortUsingComparator:comparator];
        [self.inProgressGames sortUsingComparator:comparator];
        NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.inProgressGames.count + self.endedGames.count; i++) {
            int section = 0;
            int row = i * 2;
            if (i >= self.inProgressGames.count) {
                section = 1;
                row = (i - self.inProgressGames.count) * 2;
            }
            NSIndexPath* cellIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [indexPaths addObject:cellIndexPath];
            NSIndexPath* spaceIndexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
            [indexPaths addObject:spaceIndexPath];
        }

        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)showRowsAnimated:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:@"opacity" context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        for (id key in self.sectionViews) {
            UIView* view = [self.sectionViews objectForKey:key];
            view.alpha = 1;
        }
        [UIView commitAnimations];
        
        NSArray* cells = self.tableView.visibleCells;
        float i = 0;
        for (UITableViewCell* cell in cells) {
            if ([cell isKindOfClass:SVGameTableViewCell.class]) {
                [UIView beginAnimations:@"frame" context:NULL];
                [UIView setAnimationDelay:i];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                cell.layer.frame = CGRectMake(kSVGameTableViewCellXOffset,
                                              cell.layer.frame.origin.y,
                                              cell.layer.frame.size.width,
                                              cell.layer.frame.size.height);
                [UIView commitAnimations];
                i += 0.05;
            }
        }
    }
    else {
        for (id key in self.sectionViews) {
            UIView* view = [self.sectionViews objectForKey:key];
            view.alpha = 1;
        }
        
        NSArray* cells = self.tableView.visibleCells;
        for (UITableViewCell* cell in cells) {
            if ([cell isKindOfClass:SVGameTableViewCell.class]) {
                cell.layer.frame = CGRectMake(0,
                                              cell.layer.frame.origin.y,
                                              cell.layer.frame.size.width,
                                              cell.layer.frame.size.height);
            }
        }
    }
}

- (void)hideRowsAnimated:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:@"opacity" context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        for (id key in self.sectionViews) {
            UIView* view = [self.sectionViews objectForKey:key];
            view.alpha = 0;
        }
        [UIView commitAnimations];
    
        NSArray* cells = self.tableView.visibleCells;
        float i = 0;
        for (UITableViewCell* cell in cells) {
            if ([cell isKindOfClass:SVGameTableViewCell.class]) {
                [UIView beginAnimations:@"frame" context:NULL];
                [UIView setAnimationDelay:i];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                cell.layer.frame = CGRectMake(-cell.layer.frame.size.width,
                                              cell.layer.frame.origin.y,
                                              cell.layer.frame.size.width,
                                              cell.layer.frame.size.height);
                [UIView commitAnimations];
                i += 0.05;
            }
        }
    }
    else {
        for (id key in self.sectionViews) {
            UIView* view = [self.sectionViews objectForKey:key];
            view.alpha = 0;
        }
        
        NSArray* cells = self.tableView.visibleCells;
        for (UITableViewCell* cell in cells) {
            if ([cell isKindOfClass:SVGameTableViewCell.class]) {
                cell.layer.frame = CGRectMake(-cell.layer.frame.size.width,
                                              cell.layer.frame.origin.y,
                                              cell.layer.frame.size.width,
                                              cell.layer.frame.size.height);
            }
        }
    }
}

- (void)performBlock:(void(^)(void))block {
    block();
}

- (void)setTopBarButtonsAnimated:(BOOL)animated {
    if ([self.parentViewController isKindOfClass:SVCustomContainerController.class]) {
        SVCustomContainerController* container = (SVCustomContainerController*)self.parentViewController;
        [container.topBarView setTextLabel:@"Games" animated:animated];
        UIButton* plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* plusImage = [UIImage imageNamed:@"plus_sign.png"];
        [plusButton setBackgroundImage:plusImage forState:UIControlStateNormal];
        plusButton.adjustsImageWhenHighlighted = NO;
        plusButton.adjustsImageWhenDisabled = NO;
        plusButton.frame = CGRectMake(0,
                                      0,
                                      plusImage.size.width,
                                      plusImage.size.height);
        [plusButton addTarget:self action:@selector(didClickPlusButton:) forControlEvents:UIControlEventTouchUpInside];
        self.plusButton = plusButton;
        [container.topBarView setRightButton:plusButton animated:animated];
        [container.topBarView setLeftButton:nil animated:animated];
    }
}

#pragma mark - Targets

- (void)didClickPlusButton:(id)sender {
    self.plusButton.enabled = NO;
    [self newGame];
}

#pragma mark - Delegates

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
    NSLog(@"found match: %@", match.matchID);
    [self dismissViewControllerAnimated:YES completion:^{
        [self loadGame:[SVGame gameWithMatch:match]];
        self.plusButton.enabled = YES;
    }];
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

- (void)gameViewControllerDidClickBack:(SVGameViewController *)controller {
    [self.currentController hideWithFinishBlock:^{
        if ([controller.parentViewController isKindOfClass:SVCustomContainerController.class]) {
            SVCustomContainerController* container = (SVCustomContainerController*)controller.parentViewController;
            [container popViewController];
        }
    }];
    [self performSelector:@selector(performBlock:) withObject:^{
        [self showRowsAnimated:YES];
        [self setTopBarButtonsAnimated:YES];
    } afterDelay:0.2];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.inProgressGames.count * 2;
    }
    return self.endedGames.count * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 1) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:spaceCellIdentifer forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:SVGameTableViewCell.class]) {
        NSMutableArray* games;
        if (indexPath.section == 0)
            games = self.inProgressGames;
        else
            games = self.endedGames;
        
        SVGame* game = [games objectAtIndex:ceil(indexPath.row / 2)];
        [self loadGame:game];
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* view = [self.sectionViews objectForKey:[NSNumber numberWithInt:(int)section]];
    if (view) {
        return view;
    }
    
    NSString* title;
    if (section == 0)
        title = @"In progress";
    else
        title = @"Completed";
    
    SVGameTableSectionView* sectionView = [[SVGameTableSectionView alloc] initWithTitle:title];
    [self.sectionViews setObject:sectionView forKey:[NSNumber numberWithInt:(int)section]];
    return sectionView;
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
