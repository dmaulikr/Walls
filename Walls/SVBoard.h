//
//  SVBoard.h
//  Walls
//
//  Created by Sebastien Villar on 18/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVPosition.h"

typedef enum {
    kSVPlayer1,
    kSVPlayer2
} kSVPlayer;

typedef enum {
    kSVVerticalDirection,
    kSVHorizontalDirection
} kSVWallDirection;

@interface SVBoard : NSObject <NSCopying>
@property (assign, readonly) CGSize size;
@property (strong, readonly) NSMutableArray* walls;
@property (strong, readonly) NSMutableArray* playerPositions;

- (BOOL)canPlayer:(kSVPlayer)player moveTo:(SVPosition*)end;
- (void)movePlayer:(kSVPlayer)player to:(SVPosition*)end;
- (BOOL)isWallLegalAtPosition:(SVPosition*)position withDirection:(kSVWallDirection)direction;
- (void)addWallAtPosition:(SVPosition*)position withDirection:(kSVWallDirection)direction;

@end
