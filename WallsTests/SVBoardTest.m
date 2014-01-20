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

@end
