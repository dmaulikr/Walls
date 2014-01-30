//
//  SVWall.h
//  Walls
//
//  Created by Sebastien Villar on 22/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVPosition.h"

typedef enum {
    kSVWallNormal,
    kSVWallPlayer1,
    kSVWallPlayer2
} kSVWallType;

typedef enum {
    kSVVerticalOrientation,
    kSVHorizontalOrientation
} kSVWallOrientation;

@interface SVWall : NSObject <NSCopying, NSCoding>
@property (strong) SVPosition* position;
@property (assign) kSVWallType type;
@property (assign) kSVWallOrientation orientation;

- (id)initWithPosition:(SVPosition*)position orientation:(kSVWallOrientation)orientation andType:(kSVWallType)type;
@end
