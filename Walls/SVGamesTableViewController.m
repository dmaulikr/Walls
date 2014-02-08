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

static NSString *cellIdentifier = @"Cell";

@interface SVGamesTableViewController ()
@property (strong) NSMutableArray* matches;
@property (strong) SVGameViewController* currentController;
@end

@implementation SVGamesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _matches = [[NSMutableArray alloc] init];
        [[GKLocalPlayer localPlayer] unregisterAllListeners];
        [[GKLocalPlayer localPlayer] registerListener:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"New" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickAddButton) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 500, 100, 30);
    
    [self.view addSubview:button];
    [self loadMatches];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////
// Private
//////////////////////////////////////////////////////

- (void)newMatch {
    GKMatchRequest* request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    GKTurnBasedMatchmakerViewController* controller = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    [self presentViewController:controller
                       animated:YES
                     completion:nil];
    controller.turnBasedMatchmakerDelegate = self;
}

- (void)loadMatch:(GKTurnBasedMatch*)match {
    SVGame* game = [SVGame gameWithMatch:match];
    SVGameViewController* controller = [[SVGameViewController alloc] initWithGame:game];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:NO];
    self.currentController = controller;
}

- (void)loadMatches {
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) {
        if (error) {
            NSLog(@"error : %@", error);
            return;
        }
        [self.matches addObjectsFromArray:matches];
        for (GKTurnBasedMatch* match in self.matches) {
            [match loadMatchDataWithCompletionHandler:nil];
        }
        [self.tableView reloadData];
    }];
}

//////////////////////////////////////////////////////
// Buttons Targets
//////////////////////////////////////////////////////

- (void)didClickAddButton {
    [self newMatch];
}

//////////////////////////////////////////////////////
// Delegates
//////////////////////////////////////////////////////

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
    NSLog(@"found match: %@", match.matchID);
    [self loadMatch:match];
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

- (void)gameViewController:(SVGameViewController *)controller didPlayTurn:(SVGame *)game {
    NSData* data = [game data];
    GKTurnBasedParticipant* nextParticipant;
    for (GKTurnBasedParticipant* participant in game.match.participants) {
        if (![participant.playerID isEqualToString:game.match.currentParticipant.playerID])
            nextParticipant = participant;
    }
    [game.match endTurnWithNextParticipants:[NSArray arrayWithObject:nextParticipant]
                                turnTimeout:GKTurnTimeoutNone
                                  matchData:data
                          completionHandler:^(NSError *error) {
                                   NSLog(@"sent");
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.matches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    GKTurnBasedMatch* match = [self.matches objectAtIndex:indexPath.row];
    cell.textLabel.text = match.creationDate.description;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTurnBasedMatch* match = [self.matches objectAtIndex:indexPath.row];
    //Check if data
    [self loadMatch:match];
}

@end
