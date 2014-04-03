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
#import "SVHelpView.h"
#import "SVHelper.h"

static NSString *spaceCellIdentifer = @"SpaceCell";
static NSString *gameCellIdentifier = @"GameCell";

@interface SVGamesTableViewController ()
@property (strong) NSMutableArray* inProgressGames;
@property (strong) NSMutableArray* endedGames;
@property (assign, getter = isSyncing) BOOL syncing;

@property (strong) SVGameViewController* currentController;
@property (strong) NSMutableDictionary* sectionViews;
@property (strong) UIButton* plusButton;
@property (strong) UIView* deleteView;
@property (strong) UILabel* deleteLabel;
@property (strong) NSMutableDictionary* backupInfo;
@property (strong) SVHelpView* helpView;
@property (strong) UIView* helpViewBackground;
@property (strong) UIButton* helpButton;

- (void)refresh;
- (void)newGame;
- (void)loadGame:(SVGame*)game;
- (void)loadGames;
- (void)showRowsAnimated:(BOOL)animated;
- (void)hideRowsAnimated:(BOOL)animated;
- (void)setTopBarButtonsAnimated:(BOOL)animated;
- (void)moveGameToEnded:(SVGame*)game;
- (void)removeGameFromEnded:(SVGame*)game;
- (void)showAlertView:(NSError*)error tag:(NSInteger)tag;
- (void)deleteGame:(SVGame*)game;
- (void)resignGame:(SVGame*)game;
- (void)performBlock:(void(^)(void))block;
- (void)didClickPlusButton:(id)sender;
- (void)didClickHelpButton:(id)sender;
- (void)didClickHelpCloseButton:(id)sender;
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
        _backupInfo = [[NSMutableDictionary alloc] init];
        _syncing = NO;
        
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(loadGames) name:@"ApplicationDidBecomeActiveNotification" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [SVTheme sharedTheme].darkSquareColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:SVGameTableViewCell.class forCellReuseIdentifier:gameCellIdentifier];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:spaceCellIdentifer];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(loadGames) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated { 
    [super viewWillAppear:animated];
    [self setTopBarButtonsAnimated:NO];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        [self didClickHelpButton:self.helpButton];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

#pragma mark - Private

- (void)refresh {
    if (!self.refreshControl.refreshing) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
        [self loadGames];
    }
}

- (void)newGame {
    GKMatchRequest* request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    GKTurnBasedMatchmakerViewController* controller = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    controller.showExistingMatches = NO;
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
            BOOL topBarVisible = [SVHelper screenSize] == kSVLargeScreen;
            [container pushViewController:controller topBarVisible:topBarVisible];
            [controller show];
            self.currentController = controller;
        } afterDelay:0.2];
    }
}

- (void)loadGames {
    self.syncing = YES;
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
        if (matches.count == 0) {
            [self.refreshControl endRefreshing];
            self.syncing = NO;
            return;
        }
        if (error) {
            [self showAlertView:error tag:0];
            [self.refreshControl endRefreshing];
            self.syncing = NO;
            return;
        }
        
        NSMutableArray* newEndedGames = [[NSMutableArray alloc] init];
        NSMutableArray* newInProgressGames = [[NSMutableArray alloc] init];
        
        void(^block)(void) = ^{
            NSComparator comparator = ^(SVGame* obj1, SVGame* obj2) {
                return [obj2.match.creationDate compare:obj1.match.creationDate];
            };
            
            [newInProgressGames sortUsingComparator:comparator];
            [newEndedGames sortUsingComparator:comparator];
            
            int newInProgessGamesInsertionCount = 0;
            int newEndedGamesInsertionCount = 0;
            
            NSMutableArray* indexPathsToInsert = [[NSMutableArray alloc] init];
            NSMutableArray* indexPathsToRemove = [[NSMutableArray alloc] init];
            NSMutableArray* indexPathsToReload = [[NSMutableArray alloc] init];
            
            //Check if games have changed or were added
            
            for (SVGame* game in newInProgressGames) {
                NSUInteger index = [self.inProgressGames indexOfObject:game];
                if (index == NSNotFound) {
                    NSIndexPath* cellIndexPath = [NSIndexPath indexPathForRow:newInProgessGamesInsertionCount * 2 inSection:0];
                    NSIndexPath* spaceIndexPath = [NSIndexPath indexPathForRow:newInProgessGamesInsertionCount * 2 + 1 inSection:0];
                    [indexPathsToInsert addObject:cellIndexPath];
                    [indexPathsToInsert addObject:spaceIndexPath];
                    newInProgessGamesInsertionCount++;
                    
                } else {
                    SVGame* oldGame = [self.inProgressGames objectAtIndex:index];
                    if (game.turns.count != oldGame.turns.count) {
                        NSIndexPath* cellIndexPath = [NSIndexPath indexPathForRow:index * 2 inSection:0];
                        [indexPathsToReload addObject:cellIndexPath];
                        if (self.currentController && [game.match.matchID isEqualToString:self.currentController.game.match.matchID]) {
                            [self.currentController opponentPlayerDidPlayTurn:game];
                        }
                    }
                }
            }
            
            for (SVGame* game in newEndedGames) {
                NSUInteger index = [self.endedGames indexOfObject:game];
                if (index == NSNotFound) {
                    NSIndexPath* cellIndexPath = [NSIndexPath indexPathForRow:newEndedGamesInsertionCount * 2 inSection:1];
                    NSIndexPath* spaceIndexPath = [NSIndexPath indexPathForRow:newEndedGamesInsertionCount * 2 + 1 inSection:1];
                    [indexPathsToInsert addObject:cellIndexPath];
                    [indexPathsToInsert addObject:spaceIndexPath];
                    newEndedGamesInsertionCount++;
                    
                    NSInteger index = [self.inProgressGames indexOfObject:game];
                    if (index != NSNotFound) {
                        NSIndexPath* cellIndexPath = [NSIndexPath indexPathForRow:index * 2 inSection:0];
                        NSIndexPath* spaceIndexPath = [NSIndexPath indexPathForRow:index * 2 + 1 inSection:0];
                        [indexPathsToRemove addObject:cellIndexPath];
                        [indexPathsToRemove addObject:spaceIndexPath];
                    }
                }
            }
            
            self.inProgressGames = newInProgressGames;
            self.endedGames = newEndedGames;
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            
            self.syncing = NO;
            [self.refreshControl endRefreshing];
        };
        
        __block int count = 0;
        
        for (GKTurnBasedMatch* match in matches) {
            [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
                if (error) {
                    [self.refreshControl endRefreshing];
                    self.syncing = NO;
                    [self showAlertView:error tag:0];
                    return;
                }
                else {
                    SVGame* game = [SVGame gameWithMatch:match];
                    if (match.status == GKTurnBasedMatchStatusOpen) {
                        BOOL ended = NO;
                        for (GKTurnBasedParticipant* participant in match.participants) {
                            if (participant.matchOutcome != GKTurnBasedMatchOutcomeNone) {
                                ended = YES;
                            }
                        }
                        if (ended) {
                            GKTurnBasedParticipant* participant = match.currentParticipant;
                            participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
                            [newEndedGames addObject:game];
                            @try {
                                [match endMatchInTurnWithMatchData:[game data] completionHandler:nil];
                            } @catch(NSException* e) {}
                        }
                        else
                            [newInProgressGames addObject:game];
                    }
                    else if (match.status == GKTurnBasedMatchStatusEnded)
                        [newEndedGames addObject:game];
                    else if (match.status == GKTurnBasedMatchStatusMatching)
                        [newInProgressGames addObject:game];
                    
                    count++;
                    
                    if (count == matches.count)
                        block();
                }
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
        
        UIButton* helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* helpImage = [UIImage imageNamed:@"help_sign.png"];
        [helpButton setBackgroundImage:helpImage forState:UIControlStateNormal];
        helpButton.adjustsImageWhenHighlighted = NO;
        helpButton.adjustsImageWhenDisabled = NO;
        helpButton.frame = CGRectMake(0,
                                      0,
                                      helpImage.size.width,
                                      helpImage.size.height);
        [helpButton addTarget:self action:@selector(didClickHelpButton:) forControlEvents:UIControlEventTouchUpInside];
        self.helpButton = helpButton;
        [container.topBarView setLeftButton:helpButton animated:animated];
    }
}

- (void)resignGame:(SVGame*)game {
    //So that the game is seen as ended
    for (GKTurnBasedParticipant* participant in game.match.participants) {
        if ([participant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
            participant.matchOutcome = GKTurnBasedMatchOutcomeLost;
        else
            participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
    }
    
    [GKTurnBasedMatch loadMatchWithID:game.match.matchID withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) {
        if (error)
            [self showAlertView:error tag:1];
        else {
            [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
                if (error)
                    [self showAlertView:error tag:1];
                else {
                    SVGame* game = [SVGame gameWithMatch:match];
                    if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                        for (GKTurnBasedParticipant* participant in match.participants) {
                            if ([participant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
                                participant.matchOutcome = GKTurnBasedMatchOutcomeLost;
                            else
                                participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
                        }
                        @try {
                            [match endMatchInTurnWithMatchData:game.data completionHandler:^(NSError *error) {
                                if (error) {
                                    [self showAlertView:error tag:1];
                                }
                            }];
                        } @catch(NSException *e){}
                    }
                    else {
                        @try {
                            [match participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeLost withCompletionHandler:^(NSError *error) {
                                if (error) {
                                    [self showAlertView:error tag:1];
                                }
                            }];
                        } @catch(NSException* e) {}
                    }

                }
            }];
        }
    }];
}

- (void)deleteGame:(SVGame*)game {
    [game.match removeWithCompletionHandler:^(NSError *error) {
        if (error) {
            [self showAlertView:error tag:2];
        }
    }];
}

- (void)moveGameToEnded:(SVGame*)game {
    NSUInteger index = [self.inProgressGames indexOfObject:game];
    if (index == NSNotFound)
        return;
    NSIndexPath* cellIndexPath = [NSIndexPath indexPathForRow:index * 2 inSection:0];
    NSIndexPath* spaceIndexPath = [NSIndexPath indexPathForRow:index * 2 + 1 inSection:0];
    NSArray* indexPaths = [NSArray arrayWithObjects:cellIndexPath, spaceIndexPath, nil];
    
    NSIndexPath* newCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath* newSpaceIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    NSArray* newIndexPaths = [NSArray arrayWithObjects:newCellIndexPath, newSpaceIndexPath, nil];
    [self.inProgressGames removeObjectAtIndex:index];
    [self.endedGames insertObject:game atIndex:0];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    [self.backupInfo setObject:cellIndexPath forKey:@"oldIndexPath"];
    [self.backupInfo setObject:newCellIndexPath forKey:@"newIndexPath"];
    [self.backupInfo setObject:game forKey:@"game"];
}

- (void)removeGameFromEnded:(SVGame*)game {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.endedGames indexOfObject:game] inSection:1];
    NSIndexPath* indexPath2 = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    NSArray* indexPaths = [NSArray arrayWithObjects:indexPath, indexPath2, nil];
    [self.endedGames removeObject:game];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.backupInfo setObject:indexPath forKey:@"oldIndexPath"];
    [self.backupInfo setObject:game forKey:@"game"];
}

- (void)showAlertView:(NSError*)error tag:(NSInteger)tag {
    NSString *titleString = @"Error contacting Game Center";
    NSString *messageString = [error localizedDescription];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleString
                                                        message:messageString delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Try again", nil];
    alertView.delegate =  self;
    alertView.tag = tag;
    [alertView show];
}

#pragma mark - Targets

- (void)didClickPlusButton:(id)sender {
    self.plusButton.enabled = NO;
    [self newGame];
}

- (void)didClickHelpButton:(id)sender {
    self.helpViewBackground = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.helpViewBackground.backgroundColor = [UIColor clearColor];
    self.helpView = [[SVHelpView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 250) / 2,
                                                                 - (self.tableView.superview.frame.size.height - 50),
                                                                 250,
                                                                 self.tableView.superview.frame.size.height - 100)];
    self.helpView.delegate = self;
    [self.tableView.superview addSubview:self.helpViewBackground];
    [self.tableView.superview addSubview:self.helpView];
    
    UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* closeImage = [UIImage imageNamed:@"help_cross.png"];
    [closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
    closeButton.adjustsImageWhenHighlighted = NO;
    closeButton.adjustsImageWhenDisabled = NO;
    closeButton.frame = CGRectMake(5,
                                   3,
                                   closeImage.size.width,
                                   closeImage.size.height);
    closeButton.alpha = 0;
    [closeButton addTarget:self action:@selector(didClickHelpCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.helpViewBackground addSubview:closeButton];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.helpButton.alpha = 0;
        closeButton.alpha = 1;
        self.helpView.frame = CGRectMake(self.helpView.frame.origin.x,
                                         50,
                                         self.helpView.frame.size.width,
                                         self.helpView.frame.size.height);
        self.helpViewBackground.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    } completion:nil];
    
}

- (void)didClickHelpCloseButton:(id)sender {
    UIButton* button = (UIButton*)sender;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.helpView.frame = CGRectMake(self.helpView.frame.origin.x,
                                         self.tableView.superview.frame.size.height,
                                         self.helpView.frame.size.width,
                                         self.helpView.frame.size.height);
        self.helpViewBackground.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        button.alpha = 0;
        self.helpButton.alpha = 1;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [button removeFromSuperview];
            [self.helpView removeFromSuperview];
            self.helpView = nil;
            [self.helpViewBackground removeFromSuperview];
            self.helpViewBackground = nil;
        }
    }];
}

- (void)didPanCell:(UIPanGestureRecognizer *)gestureRecognizer {
    SVGameTableViewCell* cell = (SVGameTableViewCell*)gestureRecognizer.view;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
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
        self.deleteLabel.clipsToBounds = YES;
        self.deleteLabel.backgroundColor = [UIColor clearColor];
        self.deleteLabel.layer.borderWidth = 2;
        NSString* deleteString;
        UIColor* color;
        
        if (indexPath.section == 0) {
            deleteString = @"Resign";
            color = [UIColor colorWithRed:1 green:0.83 blue:0.27 alpha:1];
        }
    
        else {
            deleteString = @"Delete";
            color = [UIColor colorWithRed:1 green:0.31 blue:0.31 alpha:1];
        }
        self.deleteLabel.layer.borderColor = color.CGColor;

        self.deleteLabel.attributedText = [SVHelper attributedStringWithText:deleteString characterSpacing:3];
        self.deleteLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:23];
        self.deleteLabel.textColor = [UIColor whiteColor];
        self.deleteLabel.textAlignment = NSTextAlignmentCenter;
        [self.deleteView addSubview:self.deleteLabel];
        [self.tableView addSubview:self.deleteView];
        [self.tableView sendSubviewToBack:self.deleteView];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gestureRecognizer translationInView:self.tableView];
        UIColor* color;
        if (indexPath.section == 0)
            color = [UIColor colorWithRed:1 green:0.83 blue:0.27 alpha:0];
        else
            color = [UIColor colorWithRed:1 green:0.31 blue:0.31 alpha:0];
        
        if (point.x < 0 && point.x > - 200) {
            cell.frame = CGRectMake(point.x,
                                    cell.frame.origin.y,
                                    cell.frame.size.width,
                                    cell.frame.size.height);
            float ratio = (float)point.x / -150;
            self.deleteLabel.backgroundColor = [color colorWithAlphaComponent:ratio];
        }
        else if (point.x >= 0) {
            cell.frame = CGRectMake(0,
                                    cell.frame.origin.y,
                                    cell.frame.size.width,
                                    cell.frame.size.height);
            self.deleteLabel.backgroundColor = [color colorWithAlphaComponent:1];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [gestureRecognizer translationInView:self.tableView];
        if (point.x <= -150) {
            SVGame* game;
            
            if (indexPath.section == 0) {
                game = [self.inProgressGames objectAtIndex:indexPath.row / 2];
                [self resignGame:game];
                [self moveGameToEnded:game];
            }
            else {
                game = [self.endedGames objectAtIndex:indexPath.row / 2];
                [self deleteGame:game];
                [self removeGameFromEnded:game];
            }
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.deleteView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.deleteView removeFromSuperview];
                self.deleteView = nil;
                self.deleteLabel = nil;
            }];
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
    self.plusButton.enabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
    self.plusButton.enabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    self.plusButton.enabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive {
    if (self.isSyncing)
        return;
    
    SVGame* game = [SVGame gameWithMatch:match];
    
    NSUInteger index = [self.inProgressGames indexOfObject:game];
    
    //New game
    if (index == NSNotFound) {
        NSIndexPath* cellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath* spaceIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.inProgressGames insertObject:game atIndex:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:cellIndexPath, spaceIndexPath, nil]
                              withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    //Resigned when not his turn
    else if (game.turns.count == ((SVGame*)[self.inProgressGames objectAtIndex:index]).turns.count) {
        GKTurnBasedParticipant* participant = match.currentParticipant;
        participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
        @try {
            [match endMatchInTurnWithMatchData:[game data] completionHandler:nil];
        } @catch(NSException* e) {};
        [self moveGameToEnded:game];
    }

    //Reload row
    else {
        [self.inProgressGames replaceObjectAtIndex:index withObject:game];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.inProgressGames indexOfObject:game] / 2 inSection:0];
        NSArray* indexPaths = [NSArray arrayWithObject:indexPath];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if (self.currentController && [match.matchID isEqualToString:self.currentController.game.match.matchID]) {
        if (game.turns.count > self.currentController.game.turns.count) {
            [self.currentController opponentPlayerDidPlayTurn:game];
        }
    }
}

- (void)player:(GKPlayer *)player didRequestMatchWithPlayers:(NSArray *)playerIDsToInvite {
}

- (void)player:(GKPlayer *)player matchEnded:(GKTurnBasedMatch *)match {
    SVGame* game = [SVGame gameWithMatch:match];
    NSInteger index = [self.inProgressGames indexOfObject:game];
    if (index == NSNotFound)
        return;
    
    if (self.currentController && [match.matchID isEqualToString:self.currentController.game.match.matchID]) {
        if (game.turns.count == ((SVGame*)[self.inProgressGames objectAtIndex:index]).turns.count)
            [self.currentController opponentPlayerDidResign:game];
        else
            [self.currentController opponentPlayerDidPlayTurn:game];
    }
    
    [self.inProgressGames replaceObjectAtIndex:index withObject:game];
    [self moveGameToEnded:game];
}

- (void)gameViewControllerDidPlayTurn:(SVGameViewController *)controller {
    NSUInteger index = (int)[self.inProgressGames indexOfObject:controller.game];
    if (index == NSNotFound)
        return;
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index * 2 inSection:0];
        
    if (controller.game.match.status == GKTurnBasedMatchStatusEnded)
        [self moveGameToEnded:controller.game];
    else
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)gameViewControllerDidClickBack:(SVGameViewController *)controller{
    [self hideRowsAnimated:NO];
    [self.currentController hideWithFinishBlock:^{
        if ([controller.parentViewController isKindOfClass:SVCustomContainerController.class]) {
            SVCustomContainerController* container = (SVCustomContainerController*)controller.parentViewController;
            [container popViewController];
        }
    }];
    [self performSelector:@selector(performBlock:) withObject:^{
        [self showRowsAnimated:YES];
        [self setTopBarButtonsAnimated:[SVHelper screenSize] == kSVLargeScreen];
    } afterDelay:0.2];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
    return abs(velocity.x) > abs(velocity.y);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        //Load games error
        case 0:
            if (buttonIndex == 1) {
                [self loadGames];
            }
            break;
            
        //Resign error
        case 1:
            if (buttonIndex == 0) {
                NSIndexPath* oldIndexPath = [self.backupInfo objectForKey:@"oldIndexPath"];
                NSIndexPath* newIndexPath = [self.backupInfo objectForKey:@"newIndexPath"];
                NSIndexPath* oldSpaceIndexPath = [NSIndexPath indexPathForRow:oldIndexPath.row + 1 inSection:oldIndexPath.section];
                NSIndexPath* newSpaceIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];
                NSArray* oldIndexPaths = [NSArray arrayWithObjects:oldIndexPath, oldSpaceIndexPath, nil];
                NSArray* newIndexPaths = [NSArray arrayWithObjects:newIndexPath, newSpaceIndexPath, nil];
                
                SVGame* game = [self.backupInfo objectForKey:@"game"];
                
                [self.endedGames removeObject:game];
                [self.inProgressGames insertObject:game atIndex:oldIndexPath.row / 2];
                
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView insertRowsAtIndexPaths:oldIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
            }
            else {
                [self resignGame:[self.backupInfo objectForKey:@"game"]];
            }
            break;
            
        //Delete error
        case 2:
            if (buttonIndex == 0) {
                NSIndexPath* oldIndexPath = [self.backupInfo objectForKey:@"oldIndexPath"];
                NSIndexPath* oldSpaceIndexPath = [NSIndexPath indexPathForRow:oldIndexPath.row + 1 inSection:oldIndexPath.section];
                NSArray* oldIndexPaths = [NSArray arrayWithObjects:oldIndexPath, oldSpaceIndexPath, nil];
                
                SVGame* game = [self.backupInfo objectForKey:@"game"];
                
                [self.endedGames insertObject:game atIndex:oldIndexPath.row / 2];
                
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:oldIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
            }
            else {
                [self deleteGame:[self.backupInfo objectForKey:@"game"]];
            }
            break;
            
        //End match in turn in notif
        case 3:
            if (buttonIndex == 0) {
                NSIndexPath* oldIndexPath = [self.backupInfo objectForKey:@"oldIndexPath"];
                NSIndexPath* newIndexPath = [self.backupInfo objectForKey:@"newIndexPath"];
                NSIndexPath* oldSpaceIndexPath = [NSIndexPath indexPathForRow:oldIndexPath.row + 1 inSection:oldIndexPath.section];
                NSIndexPath* newSpaceIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];
                NSArray* oldIndexPaths = [NSArray arrayWithObjects:oldIndexPath, oldSpaceIndexPath, nil];
                NSArray* newIndexPaths = [NSArray arrayWithObjects:newIndexPath, newSpaceIndexPath, nil];
                
                SVGame* game = [self.backupInfo objectForKey:@"game"];
                
                [self.endedGames removeObject:game];
                [self.inProgressGames insertObject:game atIndex:oldIndexPath.row / 2];
                
                [self.tableView beginUpdates];
                //In case already deleted
                if ([self.tableView cellForRowAtIndexPath:newIndexPath]) {
                    [self.tableView deleteRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
                }
                [self.tableView insertRowsAtIndexPaths:oldIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
            }
            else {
                SVGame* game = [self.backupInfo objectForKey:@"game"];
                GKTurnBasedParticipant* participant = game.match.currentParticipant;
                participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
                @try {
                    [game.match endMatchInTurnWithMatchData:[game data] completionHandler:^(NSError *error) {
                        [self showAlertView:error tag:3];
                    }];
                } @catch(NSException* e) {}
            }
            break;
            
    }
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
