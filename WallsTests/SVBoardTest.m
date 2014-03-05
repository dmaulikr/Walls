//
//  SVBoardTest.m
//  Walls
//
//  Created by Sebastien Villar on 19/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SVBoard.h"
#import "SVBoard_private.h"
#import "SVWall.h"

@interface SVBoardTest : XCTestCase
@end

@implementation SVBoardTest

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

- (void)testCanMoveFail {
    SVBoard* board;
    SVPosition* start;
    SVPosition* end;
    SVWall* wall;
    SVPosition* wallPosition;
    
    //Move more than 1 square
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:5 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through more than 1 square not detected from %@ to %@", start, end);
    
    //Move through horizontal wall
    //Top
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:3 andY:2];
    board.playerPositions[kSVPlayer1] = start;
    wallPosition = [[SVPosition alloc] initWithX:3 andY:3];
    wall = [[SVWall alloc] initWithPosition:wallPosition orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wallPosition];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through horizontal wall (%@) not detected from %@ to %@", wall, start, end);
    
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:3 andY:2];
    board.playerPositions[kSVPlayer1] = start;
    wallPosition = [[SVPosition alloc] initWithX:4 andY:3];
    wall = [[SVWall alloc] initWithPosition:wallPosition orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wallPosition];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through horizontal wall (%@) not detected from %@ to %@", wall, start, end);
    
    //Bottom
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:3 andY:4];
    board.playerPositions[kSVPlayer1] = start;
    wallPosition = [[SVPosition alloc] initWithX:3 andY:4];
    wall = [[SVWall alloc] initWithPosition:wallPosition orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wallPosition];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through horizontal wall (%@) not detected from %@ to %@", wall, start, end);
    
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:3 andY:4];
    board.playerPositions[kSVPlayer1] = start;
    wallPosition = [[SVPosition alloc] initWithX:4 andY:4];
    wall = [[SVWall alloc] initWithPosition:wallPosition orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wallPosition];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through horizontal wall (%@) not detected from %@ to %@", wall, start, end);
    
    //Move through vertical wall
    //Left
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:2 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    wallPosition = [[SVPosition alloc] initWithX:3 andY:3];
    wall = [[SVWall alloc] initWithPosition:wallPosition orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wallPosition];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through vertical wall (%@) not detected from %@ to %@", wall, start, end);
    
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:2 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    wallPosition = [[SVPosition alloc] initWithX:3 andY:4];
    wall = [[SVWall alloc] initWithPosition:wallPosition orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wallPosition];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through vertical wall (%@) not detected from %@ to %@", wall, start, end);
    
    //Right
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:4 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    wallPosition = [[SVPosition alloc] initWithX:4 andY:3];
    wall = [[SVWall alloc] initWithPosition:wallPosition orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wallPosition];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through vertical wall (%@) not detected from %@ to %@", wall, start, end);
    
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:4 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    wallPosition = [[SVPosition alloc] initWithX:4 andY:4];
    wall = [[SVWall alloc] initWithPosition:wallPosition orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wallPosition];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through vertical wall (%@) not detected from %@ to %@", wall, start, end);
}

- (void)testCanMoveSuccess {
    SVBoard* board;
    SVPosition* start;
    SVPosition* end;
    
    //Top
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:1 andY:1];
    board.playerPositions[kSVPlayer1] = start;
    end = [[SVPosition alloc] initWithX:1 andY:0];
    XCTAssertTrue([board canPlayer:kSVPlayer1 moveTo:end], "Move not accepted from %@ to %@", start, end);
    
    //Right
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:0 andY:1];
    board.playerPositions[kSVPlayer1] = start;
    end = [[SVPosition alloc] initWithX:1 andY:1];
    XCTAssertTrue([board canPlayer:kSVPlayer1 moveTo:end], "Move not accepted from %@ to %@", start, end);
    
    //Bottom
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:0 andY:1];
    board.playerPositions[kSVPlayer1] = start;
    end = [[SVPosition alloc] initWithX:0 andY:2];
    XCTAssertTrue([board canPlayer:kSVPlayer1 moveTo:end], "Move not accepted from %@ to %@", start, end);
    
    //Left
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:1 andY:1];
    board.playerPositions[kSVPlayer1] = start;
    end = [[SVPosition alloc] initWithX:0 andY:1];
    XCTAssertTrue([board canPlayer:kSVPlayer1 moveTo:end], "Move not accepted from %@ to %@", start, end);
}

- (void)testMovesForPlayer {
    SVBoard* board;
    NSArray* expectedPositions;
    NSArray* positions;
    
    //No walls and position next to board edge
    board = [[SVBoard alloc] init];
    board.playerPositions[kSVPlayer1] = [[SVPosition alloc] initWithX:0 andY:1];
    expectedPositions = [NSArray arrayWithObjects:[[SVPosition alloc] initWithX:1 andY:1],
                                                  [[SVPosition alloc] initWithX:0 andY:2],
                                                  [[SVPosition alloc] initWithX:0 andY:0], nil];
    positions = [board movesForPlayer:kSVPlayer1];
    XCTAssertEqual(positions.count, expectedPositions.count,
                   @"Moves count returned :%d but expected :%d", (int)positions.count, (int)expectedPositions.count);
    for (SVPosition* position in positions) {
        XCTAssertTrue([expectedPositions containsObject:position], @"Move %@ returned but not legal", position);
    }
    
    //Wall
    board = [[SVBoard alloc] init];
    board.playerPositions[kSVPlayer1] = [[SVPosition alloc] initWithX:2 andY:2];
    SVPosition* wallPosition = [[SVPosition alloc] initWithX:2 andY:2];
    SVWall* wall = [[SVWall alloc] initWithPosition:wallPosition orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wallPosition];
    expectedPositions = [NSArray arrayWithObjects:[[SVPosition alloc] initWithX:2 andY:1],
                         [[SVPosition alloc] initWithX:2 andY:3],
                         [[SVPosition alloc] initWithX:3 andY:2], nil];
    positions = [board movesForPlayer:kSVPlayer1];
    XCTAssertEqual(positions.count, expectedPositions.count,
                   @"Moves count returned :%d but expected :%d", (int)positions.count, (int)expectedPositions.count);
    for (SVPosition* position in positions) {
        XCTAssertTrue([expectedPositions containsObject:position], @"Move %@ returned but not legal", position);
    }
}

- (void)testMovePlayer {
    SVBoard* board;
    SVPosition* start;
    SVPosition* end;
    
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:4 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    [board movePlayer:kSVPlayer1 to:end];
    XCTAssertEqual(board.playerPositions[kSVPlayer1], end, @"Player was not moved from %@ to %@", start, end);
}

- (void)testMovePlayerException {
    SVBoard* board;
    SVPosition* start;
    SVPosition* end;
    SVWall* wall;
    SVPosition* wallPosition;
    
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:4 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    wallPosition = [[SVPosition alloc] initWithX:4 andY:3];
    wall = [[SVWall alloc] initWithPosition:wallPosition orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wallPosition];
    XCTAssertThrows([board movePlayer:kSVPlayer1 to:end], @"Exception not throwned for move %@ to %@ with wall %@", start, end, wall);
}

- (void)testCopy {
    SVBoard* board;
    SVBoard* copy;
    SVWall* wall;
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                orientation:kSVHorizontalOrientation
                                    andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    board.playerPositions[kSVPlayer1] = [[SVPosition alloc] initWithX:3 andY:2];
    board.playerPositions[kSVPlayer2] = [[SVPosition alloc] initWithX:6 andY:2];
    copy = [board copy];
    
    XCTAssertEqualObjects(board.playerPositions, copy.playerPositions, @"Player positions not equal");
    XCTAssertEqualObjects(board.walls, copy.walls, @"Walls not equal");
    XCTAssertEqual(board.size, copy.size, @"Sizes not equal");
    XCTAssertEqualObjects(board.playerGoalsY, copy.playerGoalsY, @"Sizes not equal");
    XCTAssertEqualObjects(board.normalWallsRemaining, copy.normalWallsRemaining, @"NormalWallsRemaining not equal");
    XCTAssertEqualObjects(board.specialWallsRemaining, copy.specialWallsRemaining, @"SpecialWallsRemaining not equal");
}

- (void)testIsEqualFail {
    SVBoard* board1;
    SVBoard* board2;
    SVWall* wall1;
    SVWall* wall2;
    
    //Different Walls
    board1 = [[SVBoard alloc] init];
    wall1 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                orientation:kSVHorizontalOrientation
                                    andType:kSVWallNormal];
    [board1.walls setObject:wall1 forKey:wall1.position];
    board2 = [[SVBoard alloc] init];
    XCTAssertFalse([board1 isEqual:board2], @"Boards equal while shouldn't because of walls");
    XCTAssertFalse([board2 isEqual:board1], @"Boards equal while shouldn't because of walls");
    
    board1 = [[SVBoard alloc] init];
    wall1 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                 orientation:kSVHorizontalOrientation
                                     andType:kSVWallNormal];
    [board1.walls setObject:wall1 forKey:wall1.position];
    board2 = [[SVBoard alloc] init];
    wall2 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:3 andY:3]
                                 orientation:kSVHorizontalOrientation
                                     andType:kSVWallNormal];
    [board1.walls setObject:wall2 forKey:wall2.position];
    XCTAssertFalse([board1 isEqual:board2], @"Boards equal while shouldn't because of walls");
    XCTAssertFalse([board2 isEqual:board1], @"Boards equal while shouldn't because of walls");
    
    //Different player positions
    board1 = [[SVBoard alloc] init];
    board1.playerPositions[kSVPlayer1] = [[SVPosition alloc] initWithX:3 andY:3];
    board2 = [[SVBoard alloc] init];
    XCTAssertFalse([board1 isEqual:board2], @"Boards equal while shouldn't because of player 1 position");
    XCTAssertFalse([board2 isEqual:board1], @"Boards equal while shouldn't because of player 1 position");
    
    //Different number of normal walls remaining
    board1 = [[SVBoard alloc] init];
    [board1.normalWallsRemaining replaceObjectAtIndex:0
                                           withObject:[NSNumber numberWithInt:0]];
    board2 = [[SVBoard alloc] init];
    XCTAssertFalse([board1 isEqual:board2], @"Boards equal while shouldn't because of normalWalls remaining");
    XCTAssertFalse([board2 isEqual:board1], @"Boards equal while shouldn't because of normalWalls remaining");
}

- (void)testIsEqualSuccess {
    SVBoard* board1;
    SVBoard* board2;
    SVWall* wall1;
    SVWall* wall2;
    
    board1 = [[SVBoard alloc] init];
    wall1 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                 orientation:kSVHorizontalOrientation
                                     andType:kSVWallNormal];
    [board1.walls setObject:wall1 forKey:wall1.position];
    board1.playerPositions[kSVPlayer2] = [[SVPosition alloc] initWithX:3 andY:2];
    board2 = [[SVBoard alloc] init];
    wall2 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                 orientation:kSVHorizontalOrientation
                                     andType:kSVWallNormal];
    [board2
     .walls setObject:wall2 forKey:wall2.position];
    board2.playerPositions[kSVPlayer2] = [[SVPosition alloc] initWithX:3 andY:2];
    XCTAssertTrue([board1 isEqual:board2], @"Boards not equal while should");
    XCTAssertTrue([board2 isEqual:board1], @"Boards not equal while should");
}


- (void)testIsGoalReachableByPlayer {
    SVBoard* board;
    SVWall* wall;
    
    //Player 1 and 2 blocked
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:1 andY:1] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:3 andY:1] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:5 andY:1] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:6 andY:2] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:5 andY:2] orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertFalse([board isGoalReachableByPlayer:kSVPlayer1], @"Goal reachable by player 1 while shouldn't");
    XCTAssertFalse([board isGoalReachableByPlayer:kSVPlayer2], @"Goal reachable by player 2 while shouldn't");
    
    //Player 2 blocked
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:4 andY:1] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:6 andY:1] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:3 andY:1] orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertTrue([board isGoalReachableByPlayer:kSVPlayer1], @"Goal not reachable by player 1 while should");
    XCTAssertFalse([board isGoalReachableByPlayer:kSVPlayer2], @"Goal reachable by player 2 while shouldn't");
    
}

- (void)testIsWallLegalFail {
    SVBoard* board;
    SVWall* wall;
    
    //2 walls of same direction at same position
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertFalse([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:2]
                                withOrientation:kSVHorizontalOrientation
                                           type:kSVWallNormal
                                      forPlayer:kSVPlayer1],
                   @"2 horizontal walls on same position not rejected");
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertFalse([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:2]
                                withOrientation:kSVVerticalOrientation
                                           type:kSVWallNormal
                                      forPlayer:kSVPlayer2],
                   @"2 vertical walls on same position not rejected");
    
    //2 walls of different orientation at same position
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertFalse([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:2]
                                withOrientation:kSVVerticalOrientation
                                           type:kSVWallNormal
                                      forPlayer:kSVPlayer1],
                   @"1 horizontal wall and 1 vertical wall on same position not rejected");
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertFalse([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:2]
                                withOrientation:kSVHorizontalOrientation
                                           type:kSVWallNormal
                                      forPlayer:kSVPlayer2],
                   @"1 vertical wall and 1 horizontal wall on same position not rejected");
    
    //Horizontal walls interleaving
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertFalse([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:3 andY:2]
                                withOrientation:kSVHorizontalOrientation
                                           type:kSVWallNormal
                                      forPlayer:kSVPlayer1],
                   @"2 horizontal walls interleaving not rejected");
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertFalse([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:1 andY:2]
                                withOrientation:kSVHorizontalOrientation
                                        type:kSVWallNormal
                                      forPlayer:kSVPlayer2],
                   @"2 horizontal walls interleaving not rejected");

    
    //Vertical walls interleaving
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertFalse([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                withOrientation:kSVVerticalOrientation
                                           type:kSVWallNormal
                                      forPlayer:kSVPlayer1],
                   @"2 vertical walls interleaving not rejected");
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertFalse([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:1]
                                withOrientation:kSVVerticalOrientation
                                           type:kSVWallNormal
                                      forPlayer:kSVPlayer2],
                   @"2 vertical walls interleaving not rejected");
    
    //Goal not reachable
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:1 andY:1] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:3 andY:1] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:5 andY:1] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:6 andY:2] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertFalse([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:5 andY:2]
                                withOrientation:kSVVerticalOrientation
                                           type:kSVWallNormal
                                      forPlayer:kSVPlayer1],
                   @"goal not reachable not detected");
    
    //No normal wall remaining
    board = [[SVBoard alloc] init];
    [board.normalWallsRemaining replaceObjectAtIndex:kSVPlayer1 withObject:[NSNumber numberWithInt:0]];
    XCTAssertFalse([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                withOrientation:kSVVerticalOrientation
                                           type:kSVWallNormal
                                      forPlayer:kSVPlayer1],
                   @"No normal wall remaining not detected");
    //No special wall remaining
    board = [[SVBoard alloc] init];
    [board.specialWallsRemaining replaceObjectAtIndex:kSVPlayer2 withObject:[NSNumber numberWithInt:0]];
    XCTAssertFalse([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                withOrientation:kSVVerticalOrientation
                                           type:kSVWallPlayer2
                                      forPlayer:kSVPlayer2],
                   @"No special wall remaining not detected");
}

- (void)testIsWallLegalSuccess {
    SVBoard* board;
    SVWall* wall;
    
    //2 adjacent walls of same orientation
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:3 andY:2] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertTrue([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:1 andY:2]
                               withOrientation:kSVHorizontalOrientation
                                          type:kSVWallNormal
                                     forPlayer:kSVPlayer1],
                   @"2 horizontal walls not interleaving rejected");
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertTrue([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:4 andY:2]
                               withOrientation:kSVHorizontalOrientation
                                          type:kSVWallNormal
                                     forPlayer:kSVPlayer2],
                  @"2 horizontal walls not interleaving rejected");
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3] orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertTrue([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:1]
                               withOrientation:kSVVerticalOrientation
                                          type:kSVWallNormal
                                     forPlayer:kSVPlayer1],
                  @"2 vertical walls not interleaving rejected");
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3] orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertTrue([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:5]
                               withOrientation:kSVVerticalOrientation
                                          type:kSVWallNormal
                                     forPlayer:kSVPlayer2],
                  @"2 vertical walls not interleaving rejected");
    
    //2 adjacent walls of different orientation
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertTrue([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:1 andY:2]
                               withOrientation:kSVVerticalOrientation
                                          type:kSVWallNormal
                                     forPlayer:kSVPlayer1],
                  @"2 walls not interleaving rejected");
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertTrue([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:3 andY:2]
                               withOrientation:kSVVerticalOrientation
                                          type:kSVWallNormal
                                     forPlayer:kSVPlayer2],
                  @"2 walls not interleaving rejected");
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertTrue([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:1]
                               withOrientation:kSVHorizontalOrientation
                                          type:kSVWallNormal
                                     forPlayer:kSVPlayer1],
                  @"2 walls not interleaving rejected");
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVVerticalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertTrue([board isWallLegalAtPosition:[[SVPosition alloc] initWithX:2 andY:3]
                               withOrientation:kSVHorizontalOrientation
                                          type:kSVWallNormal
                                     forPlayer:kSVPlayer2],
                  @"2 walls not interleaving rejected");
}

- (void)testAddWallSuccess {
    SVBoard* board;
    SVPosition* wallPosition;
    kSVWallOrientation wallOrientation;
    
    //Add 1 horizontal wall
    board = [[SVBoard alloc] init];
    int wallsRemaining = ((NSNumber*)[board.specialWallsRemaining objectAtIndex:kSVPlayer1]).intValue;
    wallOrientation = kSVHorizontalOrientation;
    wallPosition = [[SVPosition alloc] initWithX:2 andY:2];
    [board addWallAtPosition:wallPosition
             withOrientation:wallOrientation
                        type:kSVWallPlayer1
                   forPlayer:kSVPlayer1];
    XCTAssertTrue([board.walls objectForKey:wallPosition], @"Wall %@ was not added", wallPosition);
    XCTAssertEqual((int)((NSDictionary*)board.walls).count, 1, @"Number of walls incorrect");
    XCTAssertEqual(((NSNumber*)[board.specialWallsRemaining objectAtIndex:kSVPlayer1]).intValue,
                   wallsRemaining - 1,
                   @"SpecialWalls walls remaining not correct");
    
    //Add 1 vertical wall
    board = [[SVBoard alloc] init];
    wallsRemaining = ((NSNumber*)[board.normalWallsRemaining objectAtIndex:kSVPlayer2]).intValue;
    wallOrientation = kSVVerticalOrientation;
    wallPosition = [[SVPosition alloc] initWithX:2 andY:2];
    [board addWallAtPosition:wallPosition
             withOrientation:wallOrientation
                        type:kSVWallNormal
                   forPlayer:kSVPlayer2];
    XCTAssertTrue([board.walls objectForKey:wallPosition], @"Wall %@ was not added", wallPosition);
    XCTAssertEqual((int)((NSDictionary*)board.walls).count, 1, @"Number of walls incorrect");
    XCTAssertEqual(((NSNumber*)[board.normalWallsRemaining objectAtIndex:kSVPlayer2]).intValue,
                   wallsRemaining - 1,
                   @"Normal walls remaining not correct");
}

- (void)testAddWallFail {
    SVBoard* board;
    SVWall* wall;
    
    board = [[SVBoard alloc] init];
    wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:2] orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    [board.walls setObject:wall forKey:wall.position];
    XCTAssertThrows([board addWallAtPosition:wall.position
                             withOrientation:kSVHorizontalOrientation
                                        type:kSVWallNormal
                                   forPlayer:kSVPlayer1], @"Exception not throwned for invalid wall");
}

- (void)testDidPlayerWinFail {
    SVBoard* board;
    board = [[SVBoard alloc] init];
    board.playerPositions[kSVPlayer1] = [[SVPosition alloc] initWithX:3 andY:3];
    board.playerPositions[kSVPlayer2] = [[SVPosition alloc] initWithX:3 andY:3];
    XCTAssertFalse([board didPlayerWin:kSVPlayer1], @"Player 1 should not have won");
    XCTAssertFalse([board didPlayerWin:kSVPlayer2], @"Player 2 should not have won");
}

- (void)testDidPlayerWinSuccess {
    SVBoard* board;
    board = [[SVBoard alloc] init];
    board.playerPositions[kSVPlayer1] = [[SVPosition alloc] initWithX:3 andY:0];
    board.playerPositions[kSVPlayer2] = [[SVPosition alloc] initWithX:3 andY:board.size.height - 1];
    XCTAssertTrue([board didPlayerWin:kSVPlayer1], @"Player 1 should have won");
    XCTAssertTrue([board didPlayerWin:kSVPlayer2], @"Player 2 should have won");
}

- (void)testWallAtPositionFail {
    SVPosition* position = [[SVPosition alloc] initWithX:2 andY:3];
    SVWall* wall = [[SVWall alloc] initWithPosition:position orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    SVBoard* board = [[SVBoard alloc] init];
    [board.walls setObject:wall forKey:position];
    XCTAssertEqualObjects(wall, [board wallAtPosition:position withOrientation:kSVHorizontalOrientation], @"Wall not retrieved");
}

- (void)testWallAtPositionSuccess {
    SVWall* wall;
    SVPosition* position;
    SVBoard* board;
    
    board = [[SVBoard alloc] init];
    XCTAssertNil([board wallAtPosition:position withOrientation:kSVHorizontalOrientation], @"Wall not nil");
    
    position = [[SVPosition alloc] initWithX:2 andY:3];
    wall = [[SVWall alloc] initWithPosition:position orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    board = [[SVBoard alloc] init];
    [board.walls setObject:wall forKey:position];
    XCTAssertNil([board wallAtPosition:position withOrientation:kSVVerticalOrientation], @"Wall not nil");
}

- (void)testEncoding {
    SVBoard* board = [[SVBoard alloc] init];
    board.size = CGSizeMake(2, 3);
    SVWall* wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:4]
                                        orientation:kSVHorizontalOrientation
                                            andType:kSVWallPlayer1];
    [board.walls setObject:wall forKey:wall.position];
    [board.playerPositions replaceObjectAtIndex:kSVPlayer1 withObject:[[SVPosition alloc] initWithX:2 andY:3]];
    [board.playerGoalsY replaceObjectAtIndex:kSVPlayer1 withObject:[NSNumber numberWithInt:2]];
    [board.normalWallsRemaining replaceObjectAtIndex:kSVPlayer1 withObject:[[NSNumber alloc] initWithInt:2]];
    [board.specialWallsRemaining replaceObjectAtIndex:kSVPlayer2 withObject:[[NSNumber alloc] initWithInt:8]];
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:board];
    SVBoard* newBoard = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(board, newBoard, @"Boards not equal after encoding");
}

- (void)testRemoveWallAtPosition {
    SVPosition* position1 = [[SVPosition alloc] initWithX:2 andY:3];
    SVWall* wall1 = [[SVWall alloc] initWithPosition:position1 orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    SVBoard* board1 = [[SVBoard alloc] init];
    [board1.walls setObject:wall1 forKey:position1];
    [board1 removeWallAtPosition:position1];
    XCTAssertEqual((int)board1.walls.count, (int)0, @"Wall not removed");
    
    SVPosition* position2 = [[SVPosition alloc] initWithX:2 andY:3];
    SVWall* wall2 = [[SVWall alloc] initWithPosition:position2 orientation:kSVHorizontalOrientation andType:kSVWallNormal];
    SVBoard* board2 = [[SVBoard alloc] init];
    [board2.walls setObject:wall2 forKey:position2];
    [board2 removeWallAtPosition:[[SVPosition alloc] initWithX:3 andY:3]];
    XCTAssertNotEqual((int)board2.walls.count, (int)0, @"Wall removed while shouldn't");
}

@end
