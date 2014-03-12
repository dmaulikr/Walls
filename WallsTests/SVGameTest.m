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

@end
