//
//  SVGameTest.m
//  Walls
//
//  Created by Sebastien Villar on 02/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SVGame.h"
#import "SVTurn.h"

@interface SVGameTest : XCTestCase

@end

@implementation SVGameTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testEncoding {
    SVGame* game = [[SVGame alloc] init];
    game.firstPlayerID = @"player1ID";
    game.secondPlayerID = @"player2ID";
    SVTurn* turn = [[SVTurn alloc] init];
    turn.action = kSVMoveAction;
    turn.actionInfo = [NSNumber numberWithBool:YES];
    turn.player = kSVPlayer2;
    
    NSData* data = [game data];
    SVGame* newGame = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(game.turns, newGame.turns, @"Games not equal after encoding");
    XCTAssertEqualObjects(game.firstPlayerID, newGame.firstPlayerID, @"Games not equal after encoding");
    XCTAssertEqualObjects(game.secondPlayerID, newGame.secondPlayerID, @"Games not equal after encoding");
}

- (void)testCopy {
    SVGame* game = [[SVGame alloc] init];
    game.match = [[GKTurnBasedMatch alloc] init];
    game.firstPlayerID = @"player1ID";
    game.secondPlayerID = @"player2ID";
    
    SVTurn* turn1 = [[SVTurn alloc] init];
    turn1.action = kSVMoveAction;
    turn1.actionInfo = [NSNumber numberWithBool:YES];
    turn1.player = kSVPlayer2;
    
    SVTurn* turn2 = [[SVTurn alloc] init];
    turn2.action = kSVAddWallAction;
    turn2.actionInfo = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                            orientation:kSVHorizontalOrientation
                                                andType:kSVWallNormal];;
    turn2.player = kSVPlayer1;
    game.turns = [[NSMutableArray alloc] initWithObjects:turn1, turn2, nil];
    
    SVGame* copy = [game copy];
    
    XCTAssertEqualObjects(game.match, copy.match, @"Matches not equal");
    XCTAssertEqualObjects(game.firstPlayerID, copy.firstPlayerID, @"FirstPlayer ID not equal");
    XCTAssertEqual(game.firstPlayerID, copy.firstPlayerID, @"FirstPlayer IDs same object");
    XCTAssertEqualObjects(game.secondPlayerID, copy.secondPlayerID, @"SecondPlayerID ID not equal");
    XCTAssertEqual(game.secondPlayerID, copy.secondPlayerID, @"SecondPlayerID IDs same object");
    XCTAssertEqualObjects(game.turns, copy.turns, @"Turns not equal");
    XCTAssertNotEqual(game.turns, copy.turns, @"Turns same objects");
}

@end
