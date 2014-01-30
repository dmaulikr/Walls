//
//  SVPositionTest.m
//  Walls
//
//  Created by Sebastien Villar on 22/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SVPosition.h"

@interface SVPositionTest : XCTestCase

@end

@implementation SVPositionTest

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

- (void)testInitWith {
    int x = 2;
    int y = 3;
    SVPosition* position = [[SVPosition alloc] initWithX:x andY:y];
    XCTAssertEqual(position.x, x, @"Incorrect x");
    XCTAssertEqual(position.y, y, @"Incorrect y");
}

- (void)testCopy {
    SVPosition* position = [[SVPosition alloc] initWithX:2 andY:3];
    SVPosition* copy = [position copy];
    XCTAssertEqual(position.x, copy.x, @"Incorrect x");
    XCTAssertEqual(position.y, copy.y, @"Incorrect y");
}

- (void)testIsEqualFail {
    SVPosition* position1;
    SVPosition* position2;
    
    position1 = [[SVPosition alloc] initWithX:2 andY:3];
    position2 = [[SVPosition alloc] initWithX:1 andY:3];
    XCTAssertFalse([position1 isEqual:position2], @"Positions shouldn't be equal");
    
    position1 = [[SVPosition alloc] initWithX:2 andY:3];
    position2 = [[SVPosition alloc] initWithX:2 andY:4];
    XCTAssertFalse([position1 isEqual:position2], @"Positions shouldn't be equal");
}

- (void)testIsEqualSuccess {
    SVPosition* position1;
    SVPosition* position2;
    
    position1 = [[SVPosition alloc] initWithX:2 andY:3];
    position2 = [[SVPosition alloc] initWithX:2 andY:3];
    XCTAssertTrue([position1 isEqual:position2], @"Positions should be equal");
}

- (void)testEncoding {
    SVPosition* position = [[SVPosition alloc] initWithX:2 andY:4];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:position];
    SVPosition* newPosition = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(position, newPosition, @"Positions not equal after encoding");
}

@end
