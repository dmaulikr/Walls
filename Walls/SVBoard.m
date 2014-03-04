//
//  SVBoard.m
//  Walls
//
//  Created by Sebastien Villar on 18/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVBoard.h"
#import "SVBoard_private.h"

@interface SVBoard ()
@end

@implementation SVBoard

#pragma mark - Public

- (id)init {
    self = [super init];
    if (self) {
        _size = CGSizeMake(7, 9);
        _walls = [[NSMutableDictionary alloc] init];
        _playerPositions = [[NSMutableArray alloc] init];
        [_playerPositions addObject:[[SVPosition alloc] initWithX:floor(_size.width / 2) andY:_size.height - 1]];
        [_playerPositions addObject:[[SVPosition alloc] initWithX:floor(_size.width / 2) andY:0]];
        _playerGoalsY = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                                                                [NSNumber numberWithInt:_size.height - 1], nil];
        _normalWallsRemaining = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:6],
                                                                        [NSNumber numberWithInt:6], nil];
        _specialWallsRemaining = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:2],
                                                                         [NSNumber numberWithInt:2], nil];
    }
    return self;
}

- (BOOL)canPlayer:(kSVPlayer)player moveTo:(SVPosition*)end {
    kSVWallType playerWallType = player == kSVPlayer1 ? kSVWallPlayer1 : kSVWallPlayer2;
    
    //Check if 1 square move
    SVPosition* start = self.playerPositions[player];
    if (abs(start.x - end.x) + abs(start.y - end.y) != 1)
        return NO;
    
    //Check if positions are on board
    if (start.x >= self.size.width || start.x < 0 || start.y >= self.size.height || start.y < 0 ||
        end.x >= self.size.width || end.x < 0 || end.y >= self.size.height || end.y < 0)
        return NO;
    
    SVWall* wall1;
    SVWall* wall2;
    kSVWallOrientation wallOrientationForBlocking;
    
    
    if (start.y > end.y) {
        wall1 = [self.walls objectForKey:[[SVPosition alloc] initWithX:start.x
                                                                  andY:start.y]];
        wall2 = [self.walls objectForKey:[[SVPosition alloc] initWithX:start.x + 1
                                                                  andY:start.y]];
        wallOrientationForBlocking = kSVHorizontalOrientation;
    }
    
    else if (start.x < end.x) {
        wall1 = [self.walls objectForKey:[[SVPosition alloc] initWithX:start.x + 1
                                                                  andY:start.y]];
        wall2 = [self.walls objectForKey:[[SVPosition alloc] initWithX:start.x + 1
                                                                  andY:start.y + 1]];
        wallOrientationForBlocking = kSVVerticalOrientation;
    }
    
    else if (start.y < end.y) {
        wall1 = [self.walls objectForKey:[[SVPosition alloc] initWithX:start.x
                                                                  andY:start.y + 1]];
        wall2 = [self.walls objectForKey:[[SVPosition alloc] initWithX:start.x + 1
                                                                  andY:start.y + 1]];
        wallOrientationForBlocking = kSVHorizontalOrientation;
    }
    
    else if (start.x > end.x) {
        wall1 = [self.walls objectForKey:[[SVPosition alloc] initWithX:start.x
                                                                  andY:start.y]];
        wall2 = [self.walls objectForKey:[[SVPosition alloc] initWithX:start.x
                                                                  andY:start.y + 1]];
        wallOrientationForBlocking = kSVVerticalOrientation;
    }
    
    return !((wall1 && wall1.type != playerWallType && wall1.orientation == wallOrientationForBlocking) ||
             (wall2 && wall2.type != playerWallType && wall2.orientation == wallOrientationForBlocking));
    
}

- (void)movePlayer:(kSVPlayer)player to:(SVPosition*)end {
    if (![self canPlayer:player moveTo:end]) {
        NSException* exception = [NSException
                                  exceptionWithName:@"SVInvalidMoveException"
                                  reason:[NSString stringWithFormat:@"Player %d can't move from %@ to %@", player, self.playerPositions[player], end]
                                  userInfo:nil];
        @throw exception;
    }
    else {
        self.playerPositions[player] = end;
    }
}

- (BOOL)isWallLegalAtPosition:(SVPosition*)position
              withOrientation:(kSVWallOrientation)orientation
                         type:(kSVWallType)type
                    forPlayer:(kSVPlayer)player {
    if (position.x <= 0 || position.x >= self.size.width || position.y <= 0 || position.y >= self.size.height)
        return NO;
    
    if ([self.walls objectForKey:position])
        return NO;
    
    if (type == kSVWallNormal && ((NSNumber*)[self.normalWallsRemaining objectAtIndex:player]).intValue <= 0)
        return NO;
    
    if (type == kSVWallPlayer1 && player == kSVPlayer1 && ((NSNumber*)[self.specialWallsRemaining objectAtIndex:player]).intValue <= 0)
        return NO;
    
    if (type == kSVWallPlayer2 && player == kSVPlayer2 && ((NSNumber*)[self.specialWallsRemaining objectAtIndex:player]).intValue <= 0)
        return NO;
    
    int xOffset = orientation == kSVHorizontalOrientation ? 1 : 0;
    int yOffset = orientation == kSVHorizontalOrientation ? 0 : 1;
    
    SVWall* wall1 = [self.walls objectForKey:[[SVPosition alloc] initWithX:position.x - xOffset andY:position.y - yOffset]];
    SVWall* wall2 = [self.walls objectForKey:[[SVPosition alloc] initWithX:position.x + xOffset andY:position.y + yOffset]];
    if ((wall1 && wall1.orientation == orientation) ||
        (wall2 && wall2.orientation == orientation))
        return NO;
    
    //Add wall to test if goal reachable then remove it
    SVWall* testWall = [[SVWall alloc] initWithPosition:position orientation:orientation andType:type];
    [self.walls setObject:testWall forKey:position];
    if (![self isGoalReachableByPlayer:kSVPlayer1] || ![self isGoalReachableByPlayer:kSVPlayer2]) {
        [self.walls removeObjectForKey:position];
        return NO;
    }
    
    [self.walls removeObjectForKey:position];
    return YES;
}

- (void)addWallAtPosition:(SVPosition*)position
          withOrientation:(kSVWallOrientation)orientation
                     type:(kSVWallType)type
                forPlayer:(kSVPlayer)player {
    if (![self isWallLegalAtPosition:position withOrientation:orientation type:type forPlayer:player]) {
        NSException* exception = [NSException
                                  exceptionWithName:@"SVInvalidWallException"
                                  reason:[NSString stringWithFormat:@"Wall of orientation %d can't be built at %@", orientation, position]
                                  userInfo:nil];
        @throw exception;
    }
    else {
        SVWall* newWall = [[SVWall alloc] initWithPosition:position orientation:orientation andType:type];
        [self.walls setObject:newWall forKey:position];
        if (type == kSVWallNormal) {
            int count = ((NSNumber*)[self.normalWallsRemaining objectAtIndex:player]).intValue;
            [self.normalWallsRemaining replaceObjectAtIndex:player withObject:[NSNumber numberWithInt:count - 1]];
        }
        else {
            int count = ((NSNumber*)[self.specialWallsRemaining objectAtIndex:player]).intValue;
            [self.specialWallsRemaining replaceObjectAtIndex:player withObject:[NSNumber numberWithInt:count - 1]];
        }
    }
}

- (BOOL)didPlayerWin:(kSVPlayer)player {
    return ((SVPosition*)self.playerPositions[player]).y == [self.playerGoalsY[player] intValue];
}

- (SVWall*)wallAtPosition:(SVPosition *)position withOrientation:(kSVWallOrientation)orientation {
    SVWall* wall = [self.walls objectForKey:position];
    if (wall && wall.orientation == orientation)
        return wall;
    else
        return nil;
}

- (NSString*)description {
    NSString* description = [NSString stringWithFormat:@"Size: %@\n"
                              "Walls: %@\n"
                              "Player positions: %@\n"
                              "Player goals: %@\n"
                              "Normal walls remaining: %@\n"
                              "Special walls remaining: %@\n"
                              "Flipped: %d",
                             NSStringFromCGSize(self.size),
                             self.walls,
                             self.playerPositions,
                             self.playerGoalsY,
                             self.normalWallsRemaining,
                             self.specialWallsRemaining,
                             self.flipped];
    return description;
}

- (BOOL)isGoalReachableByPlayer:(kSVPlayer)player {
    NSMutableArray* queue = [[NSMutableArray alloc] init];
    NSMutableDictionary* visitedPositions = [[NSMutableDictionary alloc] init];
    [visitedPositions setObject:[NSNumber numberWithBool:YES] forKey:self.playerPositions[player]];
    int goalY = ((NSNumber*)self.playerGoalsY[player]).intValue;
    
    [queue addObject:self];
    while (queue.count > 0) {
        SVBoard* board = [queue firstObject];
        [queue removeObjectAtIndex:0];
        if (((SVPosition*)board.playerPositions[player]).y == goalY)
            return YES;
        NSArray* positions = [board movesForPlayer:player];
        for (SVPosition* position in positions) {
            if (![visitedPositions objectForKey:position]) {
                SVBoard* copy = [board copy];
                [copy movePlayer:player to:position];
                [visitedPositions setObject:[NSNumber numberWithBool:YES] forKey:position];
                [queue addObject:copy];
            }
        }
    }
    return NO;
}

- (NSArray*)movesForPlayer:(kSVPlayer)player {
    SVPosition* playerPosition = self.playerPositions[player];
    
    NSMutableArray* positions = [[NSMutableArray alloc] init];
    //Straight positions
    [positions addObject:[[SVPosition alloc] initWithX:playerPosition.x andY:playerPosition.y - 1]];
    [positions addObject:[[SVPosition alloc] initWithX:playerPosition.x + 1 andY:playerPosition.y]];
    [positions addObject:[[SVPosition alloc] initWithX:playerPosition.x andY:playerPosition.y + 1]];
    [positions addObject:[[SVPosition alloc] initWithX:playerPosition.x - 1 andY:playerPosition.y]];
    
    NSMutableArray* legalPositions = [[NSMutableArray alloc] init];
    
    for (SVPosition* position in positions) {
        if ([self canPlayer:player moveTo:position])
            [legalPositions addObject:position];
    }
    return legalPositions;
}

#pragma mark - Protocols

- (id)copyWithZone:(NSZone *)zone {
    SVBoard* copy = [SVBoard allocWithZone:zone];
    copy.size = self.size;
    NSMutableDictionary* wallsCopy = [[NSMutableDictionary alloc] init];
    for (id key in self.walls) {
        SVWall* wall = [self.walls objectForKey:key];
        SVWall* wallCopy = [wall copy];
        [wallsCopy setObject:wallCopy forKey:key];
    }
    copy.walls = wallsCopy;
    copy.playerPositions = [self.playerPositions mutableCopy];
    copy.playerGoalsY = [self.playerGoalsY mutableCopy];
    copy.normalWallsRemaining = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:((NSNumber*)[self.normalWallsRemaining objectAtIndex:0]).intValue], [NSNumber numberWithInt:((NSNumber*)[self.normalWallsRemaining objectAtIndex:1]).intValue], nil];
    copy.specialWallsRemaining = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:((NSNumber*)[self.specialWallsRemaining objectAtIndex:0]).intValue], [NSNumber numberWithInt:((NSNumber*)[self.specialWallsRemaining objectAtIndex:1]).intValue], nil];
    return copy;
    return nil;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]])
        return NO;
    SVBoard* otherBoard = (SVBoard*)object;
    return CGSizeEqualToSize(self.size, otherBoard.size) &&
    [self.walls isEqualToDictionary:otherBoard.walls] &&
    [self.playerPositions[kSVPlayer1] isEqual:otherBoard.playerPositions[kSVPlayer1]] &&
    [self.playerPositions[kSVPlayer2] isEqual:otherBoard.playerPositions[kSVPlayer2]] &&
    [self.playerGoalsY isEqual:otherBoard.playerGoalsY] &&
    [self.normalWallsRemaining isEqualToArray:otherBoard.normalWallsRemaining] &&
    [self.specialWallsRemaining isEqualToArray:otherBoard.specialWallsRemaining];
    return true;
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@",
             NSStringFromCGSize(self.size),
             self.walls,
             self.playerPositions,
             self.playerGoalsY,
             self.normalWallsRemaining,
             self.specialWallsRemaining] hash];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _size = [aDecoder decodeCGSizeForKey:@"size"];
        _walls = [aDecoder decodeObjectForKey:@"walls"];
        _playerPositions = [aDecoder decodeObjectForKey:@"playerPositions"];
        _playerGoalsY = [aDecoder decodeObjectForKey:@"playerGoals"];
        _normalWallsRemaining = [aDecoder decodeObjectForKey:@"normalWallsRemaining"];
        _specialWallsRemaining = [aDecoder decodeObjectForKey:@"specialWallsRemaining"];
        _flipped = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeCGSize:self.size forKey:@"size"];
    [aCoder encodeObject:self.walls forKey:@"walls"];
    [aCoder encodeObject:self.playerPositions forKey:@"playerPositions"];
    [aCoder encodeObject:self.playerGoalsY forKey:@"playerGoals"];
    [aCoder encodeObject:self.normalWallsRemaining forKey:@"normalWallsRemaining"];
    [aCoder encodeObject:self.specialWallsRemaining forKey:@"specialWallsRemaining"];
}
@end
