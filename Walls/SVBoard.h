//
//  SVBoard.h
//  Walls
//
//  Created by Sebastien Villar on 18/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVPosition.h"
#import "SVWall.h"

typedef enum {
    kSVPlayer1,
    kSVPlayer2
} kSVPlayer;

@interface SVBoard : NSObject <NSCopying, NSCoding>
@property (assign, readonly) CGSize size;
@property (strong, readonly) NSMutableDictionary* walls;
@property (strong, readonly) NSArray* startPositions;
@property (strong, readonly) NSMutableArray* playerPositions;
@property (strong) NSMutableArray* normalWallsRemaining;
@property (strong) NSMutableArray* specialWallsRemaining;
@property (assign) BOOL flipped;

- (BOOL)canPlayer:(kSVPlayer)player moveTo:(SVPosition*)end;
- (void)movePlayer:(kSVPlayer)player to:(SVPosition*)end;
- (BOOL)isWallLegalAtPosition:(SVPosition*)position
              withOrientation:(kSVWallOrientation)orientation
                         type:(kSVWallType)type
                    forPlayer:(kSVPlayer)player;
- (void)addWallAtPosition:(SVPosition*)position
          withOrientation:(kSVWallOrientation)orientation
                     type:(kSVWallType)type
                forPlayer:(kSVPlayer)player;
- (void)removeWallAtPosition:(SVPosition*)position;
- (BOOL)didPlayerWin:(kSVPlayer)player;
- (SVWall*)wallAtPosition:(SVPosition*)position withOrientation:(kSVWallOrientation)orientation;
//- (void)flip;

@end
