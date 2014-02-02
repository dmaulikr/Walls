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
@end

@implementation SVGamesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _matches = [[NSMutableArray alloc] init];
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
    SVGameViewController* controller = [[SVGameViewController alloc] initWithMatch:match];
    [self.navigationController pushViewController:controller animated:NO];
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
    cell.textLabel.text = match.matchID;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTurnBasedMatch* match = [self.matches objectAtIndex:indexPath.row];
    //Check if data
    [self loadMatch:match];
}

@end
