//
//  SVBoard_private.h
//  Walls
//
//  Created by Sebastien Villar on 19/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVBoard.h"

@interface SVBoard ()
@property (assign) CGSize size;
@property (strong) NSMutableDictionary* walls;
@property (strong) NSMutableArray* playerPositions;
@property (strong) NSMutableArray* playerGoalsY;
@property (strong) NSMutableArray* normalWallsRemaining;
@property (strong) NSMutableArray* specialWallsRemaining;
@property (assign) BOOL flipped;

- (NSArray*)movesForPlayer:(kSVPlayer)player;
- (BOOL)isGoalReachableByPlayer:(kSVPlayer)player;
- (void)flipBoard;
+ (SVBoard*)boardFromData:(NSData*)data flipped:(BOOL)flipped;

@end
