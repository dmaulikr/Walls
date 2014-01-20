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

//- (void)testCanSimplifiedMoveFails {
//    SVBoard* board;
//    SVPosition* start;
//    SVPosition* end;
//    
//    //Move off board
//    board = [[SVBoard alloc] init];
//    start = [[SVPosition alloc] initWithX:0 andY:1];
//    end = [[SVPosition alloc] initWithX:-1 andY:1];
//    XCTAssertFalse([board canSimplifiedMoveFrom:start to:end], "Move off board not detected from %@ to %@", start, end);
//    
//    board = [[SVBoard alloc] init];
//    start = [[SVPosition alloc] initWithX:board.size.width - 1 andY:1];
//    end = [[SVPosition alloc] initWithX:board.size.width andY:1];
//    XCTAssertFalse([board canSimplifiedMoveFrom:start to:end], "Move off board not detected from %@ to %@", start, end);
//    
//    board = [[SVBoard alloc] init];
//    start = [[SVPosition alloc] initWithX:0 andY:0];
//    end = [[SVPosition alloc] initWithX:0 andY:-1];
//    XCTAssertFalse([board canSimplifiedMoveFrom:start to:end], "Move off board not detected from %@ to %@", start, end);
//    
//    board = [[SVBoard alloc] init];
//    start = [[SVPosition alloc] initWithX:0 andY:board.size.height - 1];
//    end = [[SVPosition alloc] initWithX:-1 andY:board.size.height];
//    XCTAssertFalse([board canSimplifiedMoveFrom:start to:end], "Move off board not detected from %@ to %@", start, end);
//    
//    //Move more than one square
//    board = [[SVBoard alloc] init];
//    start = [[SVPosition alloc] initWithX:0 andY:1];
//    end = [[SVPosition alloc] initWithX:2 andY:1];
//    XCTAssertFalse([board canSimplifiedMoveFrom:start to:end], "Move more than one square not detected from %@ to %@", start, end);
//    
//    board = [[SVBoard alloc] init];
//    start = [[SVPosition alloc] initWithX:0 andY:1];
//    end = [[SVPosition alloc] initWithX:0 andY:3];
//    XCTAssertFalse([board canSimplifiedMoveFrom:start to:end], "Move more than one square not detected from %@ to %@", start, end);
//   
//    //Move in diagonal
//    board = [[SVBoard alloc] init];
//    start = [[SVPosition alloc] initWithX:0 andY:1];
//    end = [[SVPosition alloc] initWithX:1 andY:2];
//    XCTAssertFalse([board canSimplifiedMoveFrom:start to:end], "Move in diagonal not detected from %@ to %@", start, end);
//}
//
//- (void)testCanSimplifiedMoveSuccesses {
//    SVBoard* board;
//    SVPosition* start;
//    SVPosition* end;
//    
//    //Move 1 square on 1 direction
//    board = [[SVBoard alloc] init];
//    start = [[SVPosition alloc] initWithX:0 andY:1];
//    end = [[SVPosition alloc] initWithX:1 andY:1];
//    XCTAssertTrue([board canSimplifiedMoveFrom:start to:end], "Move not accepted from %@ to %@", start, end);
//    
//    board = [[SVBoard alloc] init];
//    start = [[SVPosition alloc] initWithX:1 andY:1];
//    end = [[SVPosition alloc] initWithX:0 andY:1];
//    XCTAssertTrue([board canSimplifiedMoveFrom:start to:end], "Move not accepted from %@ to %@", start, end);
//    
//    board = [[SVBoard alloc] init];
//    start = [[SVPosition alloc] initWithX:0 andY:1];
//    end = [[SVPosition alloc] initWithX:0 andY:0];
//    XCTAssertTrue([board canSimplifiedMoveFrom:start to:end], "Move not accepted from %@ to %@", start, end);
//    
//    board = [[SVBoard alloc] init];
//    start = [[SVPosition alloc] initWithX:0 andY:1];
//    end = [[SVPosition alloc] initWithX:0 andY:2];
//    XCTAssertTrue([board canSimplifiedMoveFrom:start to:end], "Move not accepted from %@ to %@", start, end);
//}


- (void)testCanMoveFails {
    SVBoard* board;
    SVPosition* start;
    SVPosition* end;
    SVPosition* wall;
    
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
    wall = [[SVPosition alloc] initWithX:2 andY:2];
    [board.horizontalWalls setObject:[NSNumber numberWithBool:true] forKey:wall];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through horizontal wall (%@) not detected from %@ to %@", wall, start, end);
    
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:3 andY:2];
    board.playerPositions[kSVPlayer1] = start;
    wall = [[SVPosition alloc] initWithX:3 andY:2];
    [board.horizontalWalls setObject:[NSNumber numberWithBool:true] forKey:wall];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through horizontal wall (%@) not detected from %@ to %@", wall, start, end);
    
    //Bottom
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:3 andY:4];
    board.playerPositions[kSVPlayer1] = start;
    wall = [[SVPosition alloc] initWithX:2 andY:3];
    [board.horizontalWalls setObject:[NSNumber numberWithBool:true] forKey:wall];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through horizontal wall (%@) not detected from %@ to %@", wall, start, end);
    
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:3 andY:4];
    board.playerPositions[kSVPlayer1] = start;
    wall = [[SVPosition alloc] initWithX:3 andY:3];
    [board.horizontalWalls setObject:[NSNumber numberWithBool:true] forKey:wall];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through horizontal wall (%@) not detected from %@ to %@", wall, start, end);
    
    //Move through vertical wall
    //Left
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:2 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    wall = [[SVPosition alloc] initWithX:2 andY:2];
    [board.verticalWalls setObject:[NSNumber numberWithBool:true] forKey:wall];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through vertical wall (%@) not detected from %@ to %@", wall, start, end);
    
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:2 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    wall = [[SVPosition alloc] initWithX:2 andY:3];
    [board.verticalWalls setObject:[NSNumber numberWithBool:true] forKey:wall];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through vertical wall (%@) not detected from %@ to %@", wall, start, end);
    
    //Right
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:4 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    wall = [[SVPosition alloc] initWithX:3 andY:2];
    [board.verticalWalls setObject:[NSNumber numberWithBool:true] forKey:wall];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through vertical wall (%@) not detected from %@ to %@", wall, start, end);
    
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:4 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    wall = [[SVPosition alloc] initWithX:3 andY:3];
    [board.verticalWalls setObject:[NSNumber numberWithBool:true] forKey:wall];
    XCTAssertFalse([board canPlayer:kSVPlayer1 moveTo:end], "Move through vertical wall (%@) not detected from %@ to %@", wall, start, end);
}

- (void)testCanMoveSuccesses {
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
    SVPosition* wall = [[SVPosition alloc] initWithX:2 andY:2];
    [board.verticalWalls setObject:[NSNumber numberWithBool:true] forKey:wall];
    expectedPositions = [NSArray arrayWithObjects:[[SVPosition alloc] initWithX:2 andY:1],
                         [[SVPosition alloc] initWithX:2 andY:3],
                         [[SVPosition alloc] initWithX:1 andY:2], nil];
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
    SVPosition* wall;
    
    board = [[SVBoard alloc] init];
    start = [[SVPosition alloc] initWithX:3 andY:3];
    end = [[SVPosition alloc] initWithX:4 andY:3];
    board.playerPositions[kSVPlayer1] = start;
    wall = [[SVPosition alloc] initWithX:3 andY:3];
    [board movePlayer:kSVPlayer1 to:end];
    XCTAssertThrows([board movePlayer:kSVPlayer1 to:end], @"Exception not throwned for move %@ to %@ with wall %@", start, end, wall);
}

- (void)testIsEqualFails {
    SVBoard* board1;
    SVBoard* board2;
    
    //Different Walls
    board1 = [[SVBoard alloc] init];
    [board1.verticalWalls setObject:[NSNumber numberWithBool:true]
                             forKey:[[SVPosition alloc] initWithX:3 andY:3]];
    board2 = [[SVBoard alloc] init];
    XCTAssertFalse([board1 isEqual:board2], @"Boards equal while shouldn't because of walls");
    XCTAssertFalse([board2 isEqual:board1], @"Boards equal while shouldn't because of walls");
    
    board1 = [[SVBoard alloc] init];
    [board1.horizontalWalls setObject:[NSNumber numberWithBool:true]
                             forKey:[[SVPosition alloc] initWithX:3 andY:3]];
    board2 = [[SVBoard alloc] init];
    [board2.horizontalWalls setObject:[NSNumber numberWithBool:true]
                             forKey:[[SVPosition alloc] initWithX:4 andY:4]];
    XCTAssertFalse([board1 isEqual:board2], @"Boards equal while shouldn't because of walls");
    XCTAssertFalse([board2 isEqual:board1], @"Boards equal while shouldn't because of walls");
    
    //Different player positions
    board1 = [[SVBoard alloc] init];
    board1.playerPositions[kSVPlayer1] = [[SVPosition alloc] initWithX:3 andY:3];
    board2 = [[SVBoard alloc] init];
    XCTAssertFalse([board1 isEqual:board2], @"Boards equal while shouldn't because of player 1 position");
    XCTAssertFalse([board2 isEqual:board1], @"Boards equal while shouldn't because of player 1 position");
}

- (void)testIsEqualSuccesses {
    SVBoard* board1;
    SVBoard* board2;
    
    board1 = [[SVBoard alloc] init];
    [board1.horizontalWalls setObject:[NSNumber numberWithBool:true]
                             forKey:[[SVPosition alloc] initWithX:3 andY:3]];
    board1.playerPositions[kSVPlayer2] = [[SVPosition alloc] initWithX:3 andY:2];
    board2 = [[SVBoard alloc] init];
    [board2.horizontalWalls setObject:[NSNumber numberWithBool:true]
                             forKey:[[SVPosition alloc] initWithX:3 andY:3]];
    board2.playerPositions[kSVPlayer2] = [[SVPosition alloc] initWithX:3 andY:2];
    XCTAssertTrue([board1 isEqual:board2], @"Boards not equal while should");
    XCTAssertTrue([board2 isEqual:board1], @"Boards not equal while should");
}

- (void)testHashEqualityFails {
    SVBoard* board1;
    SVBoard* board2;
    
    //Different Walls
    board1 = [[SVBoard alloc] init];
    [board1.verticalWalls setObject:[NSNumber numberWithBool:true]
                             forKey:[[SVPosition alloc] initWithX:3 andY:3]];
    board2 = [[SVBoard alloc] init];
    XCTAssertNotEqual([board1 hash], [board2 hash], @"Hash equal while shouldn't");
    
    board1 = [[SVBoard alloc] init];
    [board1.horizontalWalls setObject:[NSNumber numberWithBool:true]
                               forKey:[[SVPosition alloc] initWithX:3 andY:3]];
    board2 = [[SVBoard alloc] init];
    [board2.horizontalWalls setObject:[NSNumber numberWithBool:true]
                               forKey:[[SVPosition alloc] initWithX:4 andY:4]];
    XCTAssertNotEqual([board1 hash], [board2 hash], @"Hash equal while shouldn't");
    
    //Different player positions
    board1 = [[SVBoard alloc] init];
    board1.playerPositions[kSVPlayer1] = [[SVPosition alloc] initWithX:3 andY:3];
    board2 = [[SVBoard alloc] init];
    XCTAssertNotEqual([board1 hash], [board2 hash], @"Hash equal while shouldn't");
}

- (void)testHashEqualitySuccess {
    SVBoard* board1;
    SVBoard* board2;
    
    board1 = [[SVBoard alloc] init];
    [board1.horizontalWalls setObject:[NSNumber numberWithBool:true]
                               forKey:[[SVPosition alloc] initWithX:3 andY:3]];
    board1.playerPositions[kSVPlayer2] = [[SVPosition alloc] initWithX:3 andY:2];
    board2 = [[SVBoard alloc] init];
    [board2.horizontalWalls setObject:[NSNumber numberWithBool:true]
                               forKey:[[SVPosition alloc] initWithX:3 andY:3]];
    board2.playerPositions[kSVPlayer2] = [[SVPosition alloc] initWithX:3 andY:2];
    XCTAssertEqual([board1 hash], [board2 hash], @"Hash not equal while should");
}

@end
