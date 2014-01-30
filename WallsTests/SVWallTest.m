//
//  SVWallTest.m
//  Walls
//
//  Created by Sebastien Villar on 22/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SVWall.h"

@interface SVWallTest : XCTestCase

@end

@implementation SVWallTest

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
    SVPosition* position = [[SVPosition alloc] initWithX:2 andY:2];
    kSVWallOrientation orientation = kSVHorizontalOrientation;
    kSVWallType type = kSVWallNormal;
    SVWall* wall = [[SVWall alloc] initWithPosition:position orientation:orientation andType:type];
    XCTAssertEqualObjects(wall.position, position, @"Incorrect position");
    XCTAssertEqual(wall.orientation, orientation, @"Incorrect orientation");
    XCTAssertEqual(wall.type, type, @"Incorrect type");
}

- (void)testCopy {
    SVWall* wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                         orientation:kSVHorizontalOrientation
                                             andType:kSVWallNormal];
    SVWall* copy = [wall copy];
    XCTAssertEqualObjects(wall.position, copy.position, @"Positions not equal");
    XCTAssertEqual(wall.orientation, copy.orientation, @"Orientations not equal");
    XCTAssertEqual(wall.type, copy.type, @"Types not equal");
}

- (void)testIsEqualFail {
    SVWall* wall1;
    SVWall* wall2;
    
    wall1 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                 orientation:kSVHorizontalOrientation
                                     andType:kSVWallNormal];
    wall2 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:1 andY:3]
                                 orientation:kSVHorizontalOrientation
                                     andType:kSVWallNormal];
    XCTAssertFalse([wall1 isEqual:wall2], @"Walls shouldn't be equal");
    
    wall1 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                 orientation:kSVHorizontalOrientation
                                     andType:kSVWallNormal];
    wall2 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                 orientation:kSVVerticalOrientation
                                     andType:kSVWallNormal];
    XCTAssertFalse([wall1 isEqual:wall2], @"Walls shouldn't be equal");
    
    wall1 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                 orientation:kSVHorizontalOrientation
                                     andType:kSVWallNormal];
    wall2 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                 orientation:kSVHorizontalOrientation
                                     andType:kSVWallPlayer1];
    XCTAssertFalse([wall1 isEqual:wall2], @"Walls shouldn't be equal");
    
}

- (void)testIsEqualSuccess {
    SVWall* wall1;
    SVWall* wall2;
    
    wall1 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                 orientation:kSVHorizontalOrientation
                                     andType:kSVWallNormal];
    wall2 = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:3]
                                 orientation:kSVHorizontalOrientation
                                     andType:kSVWallNormal];
    XCTAssertTrue([wall1 isEqual:wall2], @"Walls should be equal");
}

- (void)testEncoding {
    SVWall* wall = [[SVWall alloc] initWithPosition:[[SVPosition alloc] initWithX:2 andY:4]
                                        orientation:kSVHorizontalOrientation
                                            andType:kSVWallNormal];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:wall];
    SVWall* newWall = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(wall, newWall, @"Walls not equal after encoding");
}

@end
