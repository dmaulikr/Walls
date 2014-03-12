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
@property (strong) UIView* deleteView;
@property (strong) UILabel* deleteLabel;

- (void)newGame;
- (void)loadGame:(SVGame*)game;
- (void)loadGames;
- (void)showRowsAnimated:(BOOL)animated;
- (void)hideRowsAnimated:(BOOL)animated;
- (void)setTopBarButtonsAnimated:(BOOL)animated;
- (void)moveGameToCompleted:(SVGame*)game;
- (SVGame*)gameForMatch:(GKTurnBasedMatch*)match;
- (void)deleteGame:(SVGame*)game;
- (void)performBlock:(void(^)(void))block;
- (void)didClickPlusButton:(id)sender;
- (void)didPanCell:(UIPanGestureRecognizer*)gestureRecognizer;

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
        [self hideRowsAnimated:YES];
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
        
        void(^block)(void) = ^{
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
                    row = (i - (int)self.inProgressGames.count) * 2;
                }
                NSIndexPath* cellIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                [indexPaths addObject:cellIndexPath];
                NSIndexPath* spaceIndexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
                [indexPaths addObject:spaceIndexPath];
            }
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        };
        
        for (GKTurnBasedMatch* match in matches) {
            [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
                
//                GKTurnBasedParticipant* p1 = [match.participants objectAtIndex:0];
//                GKTurnBasedParticipant* p2 = [match.participants objectAtIndex:1];
//                p1.matchOutcome = GKTurnBasedMatchOutcomeLost;
//                p2.matchOutcome = GKTurnBasedMatchOutcomeWon;
//                [match endMatchInTurnWithMatchData:match.matchData completionHandler:^(NSError *error) {
//                    [match removeWithCompletionHandler:^(NSError *error) {
//                        NSLog(@"deleted");
//                    }];
//                }];
//                return;
                SVGame* game = [SVGame gameWithMatch:match];
                if (game.match.status == GKTurnBasedMatchStatusEnded) {
                    [self.endedGames addObject:game];
                }
                else {
                    [self.inProgressGames addObject:game];
                }
                if ([matches lastObject] == match)
                    block();
            }];
        }
    }];
}

- (void)showRowsAnimated:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:@"opacity" context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        for (id key in self.sectionViews) {
            SVGameTableSectionView* view = [self.sectionViews objectForKey:key];
            view.label.alpha = 1;
            view.line.alpha = 1;
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
            SVGameTableSectionView* view = [self.sectionViews objectForKey:key];
            view.label.alpha = 1;
            view.line.alpha = 1;
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
            SVGameTableSectionView* view = [self.sectionViews objectForKey:key];
            view.label.alpha = 0;
            view.line.alpha = 0;
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
            SVGameTableSectionView* view = [self.sectionViews objectForKey:key];
            view.label.alpha = 0;
            view.line.alpha = 0;
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

- (void)deleteGame:(SVGame*)game {
    void(^deleteBlock)(void) = ^{
        [game.match removeWithCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"error: %@", error);
            }
            else {
                NSLog(@"deleted");
            }
        }];
    };
    
    if (game.match.status == GKTurnBasedMatchStatusEnded) {
        deleteBlock();
    }
    else {
        if ([game.match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            for (GKTurnBasedParticipant* participant in game.match.participants) {
                if ([participant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
                    participant.matchOutcome = GKTurnBasedMatchOutcomeLost;
                else
                    participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
            }
            [game.match endMatchInTurnWithMatchData:game.data completionHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"%@", error);
                }
                else {
                    NSLog(@"quitted");
                    deleteBlock();
                }
            }];
        } else {
           [game.match participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeLost withCompletionHandler:^(NSError *error) {
               if (error) {
                   NSLog(@"%@", error);
               }
               else {
                   NSLog(@"quitted");
                   deleteBlock();
               }
           }];
        }
    }
}

- (void)moveGameToCompleted:(SVGame*)game {
    NSInteger index = [self.inProgressGames indexOfObject:game];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index * 2 inSection:0];
    [self.inProgressGames removeObjectAtIndex:index];
    [self.endedGames addObject:game];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:self.endedGames.count * 2 inSection:1];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

- (SVGame*)gameForMatch:(GKTurnBasedMatch*)match {
    for (SVGame* game in self.inProgressGames) {
        if ([game.match.matchID isEqual:match.matchID]) {
            return game;
        }
    }
    for (SVGame* game in self.endedGames) {
        if ([game.match.matchID isEqual:match.matchID]) {
            return game;
        }
    }
    return nil;
}

#pragma mark - Targets

- (void)didClickPlusButton:(id)sender {
    self.plusButton.enabled = NO;
    [self newGame];
}

- (void)didPanCell:(UIPanGestureRecognizer *)gestureRecognizer {
    SVGameTableViewCell* cell = (SVGameTableViewCell*)gestureRecognizer.view;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.deleteView = [[UIView alloc] initWithFrame:cell.frame];
        self.deleteView.layer.cornerRadius = self.deleteView.frame.size.height / 2;
        self.deleteView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.deleteView.layer.borderWidth = 1;
        self.deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.deleteView.frame.size.width - 97,
                                                                    (self.deleteView.frame.size.height - 30) / 2,
                                                                     90,
                                                                     30)];
        self.deleteLabel.layer.cornerRadius = 15;
        self.deleteLabel.backgroundColor = [UIColor clearColor];
        NSString* deleteString = @"Delete";
        NSMutableAttributedString* deleteText = [[NSMutableAttributedString alloc] initWithString:deleteString];
        [deleteText addAttribute:NSKernAttributeName value:@3 range:NSMakeRange(0, deleteString.length - 1)];
        self.deleteLabel.attributedText = deleteText;
        self.deleteLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:23];
        self.deleteLabel.textColor = [UIColor whiteColor];
        self.deleteLabel.textAlignment = NSTextAlignmentCenter;
        [self.deleteView addSubview:self.deleteLabel];
        [self.tableView addSubview:self.deleteView];
        [self.tableView sendSubviewToBack:self.deleteView];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gestureRecognizer translationInView:self.tableView];
        if (point.x < 0 && point.x > - 200) {
            cell.frame = CGRectMake(point.x,
                                    cell.frame.origin.y,
                                    cell.frame.size.width,
                                    cell.frame.size.height);
            float ratio = (float)point.x / -150;
            self.deleteLabel.backgroundColor = [UIColor colorWithRed:1 green:0.31 blue:0.31 alpha:ratio];
        }
        else if (point.x >= 0) {
            cell.frame = CGRectMake(0,
                                    cell.frame.origin.y,
                                    cell.frame.size.width,
                                    cell.frame.size.height);
            self.deleteLabel.backgroundColor = [UIColor colorWithRed:1 green:0.31 blue:0.31 alpha:1.0];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [gestureRecognizer translationInView:self.tableView];
        if (point.x <= -150) {
            NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
            NSIndexPath* indexPath2 = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            NSArray* indexPaths = [NSArray arrayWithObjects:indexPath, indexPath2, nil];
            SVGame* game;
            if (indexPath.section == 0) {
                game = [self.inProgressGames objectAtIndex:indexPath.row / 2];
                [self.inProgressGames removeObject:game];
            }
            else {
                game = [self.endedGames objectAtIndex:indexPath.row / 2];
                [self.endedGames removeObject:game];
            }
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.deleteView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.deleteView removeFromSuperview];
                self.deleteView = nil;
                self.deleteLabel = nil;
            }];
            
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
            [self deleteGame:game];
        }
        else {
            [UIView animateWithDuration:0.3 * (float)point.x / -150.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                cell.frame = CGRectMake(0,
                                        cell.frame.origin.y,
                                        cell.frame.size.width,
                                        cell.frame.size.height);
            } completion:^(BOOL finished) {
                [self.deleteView removeFromSuperview];
                self.deleteView = nil;
                self.deleteLabel = nil;
            }];
        }
    }
}

#pragma mark - Delegates

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
    SVGame* game = [SVGame gameWithMatch:match];
    [self.inProgressGames insertObject:game atIndex:0];
    NSArray* indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],
                                                    [NSIndexPath indexPathForRow:1 inSection:0], nil];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self dismissViewControllerAnimated:YES completion:^{
        [self loadGame:game];
        self.plusButton.enabled = YES;
    }];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
    NSLog(@"quit");
    self.plusButton.enabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
    NSLog(@"cancelled");
    self.plusButton.enabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    NSLog(@"fail");
    self.plusButton.enabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive {
    if (!didBecomeActive)
        return;
    
    NSLog(@"received turn");
    if (match.participants.count < 2) {
        SVGame* game = [self gameForMatch:match];
        if (game)
            [self moveGameToCompleted:game];
    }
    else {
        if (self.currentController && [match.matchID isEqualToString:self.currentController.game.match.matchID]) {
            [GKTurnBasedMatch loadMatchWithID:match.matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
                SVGame* game = [SVGame gameWithMatch:match];
                if (game.turns.count > self.currentController.game.turns.count) {
                    [self.currentController opponentPlayerDidPlayTurn:game];
                    
                }
            }];
        }
        
        int index = 0;
        for (SVGame* game in self.inProgressGames) {
            if ([game.match.matchID isEqual:match.matchID]) {
                break;
            }
            index++;
        }
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index * 2 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)player:(GKPlayer *)player didRequestMatchWithPlayers:(NSArray *)playerIDsToInvite {
    NSLog(@"did request match");
}

- (void)player:(GKPlayer *)player matchEnded:(GKTurnBasedMatch *)match {
    SVGame* game = [self gameForMatch:match];
    [self moveGameToCompleted:game];
}

- (void)gameViewController:(SVGameViewController *)controller didPlayTurn:(SVGame *)game ended:(BOOL)ended {
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

- (void)gameViewControllerDidClickBack:(SVGameViewController *)controller gameUpdated:(BOOL)updated {
    [self.currentController hideWithFinishBlock:^{
        if (updated) {
            int index = (int)[self.inProgressGames indexOfObject:controller.game];
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index * 2 inSection:0];
        
            if (controller.game.match.status == GKTurnBasedMatchStatusEnded)
                [self moveGameToCompleted:controller.game];
            else
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
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

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
    return abs(velocity.x) > abs(velocity.y);
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
        cell.backgroundColor = self.tableView.backgroundColor;
        cell.opaque = YES;
        return cell;
    }
    else {
        SVGameTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:gameCellIdentifier forIndexPath:indexPath];
        if (cell.gestureRecognizers.count == 0) {
            UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanCell:)];
            gestureRecognizer.minimumNumberOfTouches = 1;
            gestureRecognizer.maximumNumberOfTouches = 1;
            gestureRecognizer.delegate = self;
            [cell addGestureRecognizer:gestureRecognizer];
        }
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
