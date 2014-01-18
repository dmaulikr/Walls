//
//  SVGame.h
//  Walls
//
//  Created by Sebastien Villar on 18/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVPlayer.h"

@interface SVGame : NSObject
@property (assign) CGSize size;
@property (strong) NSArray* wallPositions;
@property (strong) SVPlayer* localPlayer;
@property (strong) SVPlayer* opponentPlayer;
@end
