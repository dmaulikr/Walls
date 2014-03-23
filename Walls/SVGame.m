//
//  SVGame.m
//  Walls
//
//  Created by Sebastien Villar on 02/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVGame.h"

@implementation SVGame

#pragma mark - Public

+ (id)gameWithMatch:(GKTurnBasedMatch*)match {
    SVGame* game;
    if (match.matchData.length == 0) {
        game = [[SVGame alloc] init];
        game.turns = [[NSMutableArray alloc] init];
        game.firstPlayerID = ((GKTurnBasedParticipant*)[match.participants objectAtIndex:0]).playerID;
        if (match.participants.count > 1)
            game.secondPlayerID = ((GKTurnBasedParticipant*)[match.participants objectAtIndex:1]).playerID;
    }
    else {
        game = [NSKeyedUnarchiver unarchiveObjectWithData:match.matchData];
        if (game.match.participants.count > 1)
            game.secondPlayerID = ((GKTurnBasedParticipant*)[match.participants objectAtIndex:1]).playerID;
    }
    game.match = match;
    return game;
}

- (NSData*)data {
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

#pragma mark - Protocol

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:SVGame.class]) {
        return NO;
    }
    SVGame* other = (SVGame*)object;
    return [self.match.matchID isEqual:other.match.matchID];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _turns = [aDecoder decodeObjectForKey:@"turns"];
        _firstPlayerID = [aDecoder decodeObjectForKey:@"firstPlayerID"];
        _secondPlayerID = [aDecoder decodeObjectForKey:@"secondPlayerID"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.turns forKey:@"turns"];
    [aCoder encodeObject:self.firstPlayerID forKey:@"firstPlayerID"];
    [aCoder encodeObject:self.secondPlayerID forKey:@"secondPlayerID"];
}

- (id)copyWithZone:(NSZone *)zone {
    SVGame* copy = [SVGame allocWithZone:zone];
    copy.turns = [[NSMutableArray alloc] initWithArray:self.turns copyItems:YES];
    copy.firstPlayerID = [self.firstPlayerID copy];
    copy.secondPlayerID = [self.secondPlayerID copy];
    copy.match = self.match;
    return copy;
}
@end
