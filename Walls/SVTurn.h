//
//  SVTurn.h
//  Walls
//
//  Created by Sebastien Villar on 07/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVBoard.h"

typedef enum {
    kSVNoAction,
    kSVMoveAction,
    kSVAddWallAction
} kSVAction;

@interface SVTurn : NSObject <NSCoding, NSCopying>
@property (assign) kSVPlayer player;
@property (assign) kSVAction action;
@property (strong) id actionInfo;
@end
