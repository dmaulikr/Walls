//
//  SVTurnTest.m
//  Walls
//
//  Created by Sebastien Villar on 07/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SVTurn.h"

@interface SVTurnTest : XCTestCase

@end

@implementation SVTurnTest

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
    SVTurn* turn = [[SVTurn alloc] init];
    turn.action = kSVMoveAction;
    turn.actionInfo = [NSNumber numberWithBool:YES];
    turn.player = kSVPlayer2;
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:turn];
    SVTurn* turn2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(turn, turn2, @"Turns not equal after encoding");
}

@end
