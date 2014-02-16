//
//  SVGame.m
//  Walls
//
//  Created by Sebastien Villar on 02/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVGame.h"

@implementation SVGame

+ (id)gameWithMatch:(GKTurnBasedMatch*)match {
    SVGame* game;
    if (match.matchData.length == 0) {
        game = [[SVGame alloc] init];
        game.turns = [[NSMutableArray alloc] init];
    }
    else {
        game = [NSKeyedUnarchiver unarchiveObjectWithData:match.matchData];
    }
    game.match = match;
    return game;
}

- (NSData*)data {
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

//////////////////////////////////////////////////////
// Protocols
//////////////////////////////////////////////////////

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:SVGame.class]) {
        return NO;
    }
    SVGame* other = (SVGame*)object;
    return [self.turns isEqualToArray:other.turns] &&
           [self.match isEqual:other.match];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _turns = [aDecoder decodeObjectForKey:@"turns"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.turns forKey:@"turns"];
}
@end
