//
//  SVGame.h
//  Walls
//
//  Created by Sebastien Villar on 02/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "SVBoard.h"

@interface SVGame : NSObject <NSCoding>
@property (strong) NSMutableArray* turns;
@property (strong) GKTurnBasedMatch* match;
@property (strong) NSString* firstPlayerID;
@property (strong) NSString* secondPlayerID;

+ (id)gameWithMatch:(GKTurnBasedMatch*)match;
- (NSData*)data;
@end
