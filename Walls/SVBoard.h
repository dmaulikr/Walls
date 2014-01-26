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

@interface SVBoard : NSObject <NSCopying>
@property (assign, readonly) CGSize size;
@property (strong, readonly) NSMutableDictionary* walls;
@property (strong, readonly) NSMutableArray* playerPositions;

- (BOOL)canPlayer:(kSVPlayer)player moveTo:(SVPosition*)end;
- (void)movePlayer:(kSVPlayer)player to:(SVPosition*)end;
- (BOOL)isWallLegalAtPosition:(SVPosition*)position withOrientation:(kSVWallOrientation)orientation andType:(kSVWallType)type;
- (void)addWallAtPosition:(SVPosition*)position withOrientation:(kSVWallOrientation)orientation andType:(kSVWallType)type;
- (BOOL)didPlayerWin:(kSVPlayer)player;
- (SVWall*)wallAtPosition:(SVPosition*)position withOrientation:(kSVWallOrientation)orientation;


@end
