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

//////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////

- (id)init {
    self = [super init];
    if (self) {
        _size = CGSizeMake(7, 10);
        _walls = [[NSMutableArray alloc] initWithObjects:[[NSMutableDictionary alloc] init],
                                                         [[NSMutableDictionary alloc] init], nil];
        _playerPositions = [[NSMutableArray alloc] init];
        [_playerPositions addObject:[[SVPosition alloc] initWithX:floor(_size.width / 2) andY:_size.height - 1]];
        [_playerPositions addObject:[[SVPosition alloc] initWithX:floor(_size.width / 2) andY:0]];
        _playerGoalsY = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                                                                [NSNumber numberWithInt:_size.height - 1], nil];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SVBoard* copy = [SVBoard allocWithZone:zone];
    copy.size = self.size;
    NSMutableArray* walls = [[NSMutableArray alloc] init];
    walls[kSVVerticalOrientation] = [self.walls[kSVVerticalOrientation] mutableCopy];
    walls[kSVHorizontalOrientation] = [self.walls[kSVHorizontalOrientation] mutableCopy];
    copy.walls = walls;
    copy.playerPositions = [self.playerPositions mutableCopy];
    copy.playerGoalsY = [self.playerGoalsY mutableCopy];
    return copy;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]])
        return NO;
    SVBoard* otherBoard = (SVBoard*)object;
    return CGSizeEqualToSize(self.size, otherBoard.size) &&
           [self.walls[kSVHorizontalOrientation] isEqualToDictionary:otherBoard.walls[kSVHorizontalOrientation]] &&
           [self.walls[kSVVerticalOrientation] isEqualToDictionary:otherBoard.walls[kSVVerticalOrientation]] &&
           [self.playerPositions[kSVPlayer1] isEqual:otherBoard.playerPositions[kSVPlayer1]] &&
           [self.playerPositions[kSVPlayer2] isEqual:otherBoard.playerPositions[kSVPlayer2]] &&
           [self.playerGoalsY isEqual:otherBoard.playerGoalsY];
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%@,%@,%@, %@",
                     NSStringFromCGSize(self.size),
                     self.walls,
                     self.playerPositions,
                     self.playerGoalsY] hash];
}

- (BOOL)canPlayer:(kSVPlayer)player moveTo:(SVPosition*)end {
    //Check if 1 square move
    SVPosition* start = self.playerPositions[player];
    if (abs(start.x - end.x) + abs(start.y - end.y) != 1)
        return NO;
    
    //Check if positions are on board
    if (start.x >= self.size.width || start.x < 0 || start.y >= self.size.height || start.y < 0 ||
        end.x >= self.size.width || end.x < 0 || end.y >= self.size.height || end.y < 0)
        return NO;
    
    if (start.y > end.y &&
        ([self.walls[kSVHorizontalOrientation] objectForKey:[[SVPosition alloc] initWithX:start.x
                                                           andY:start.y]] ||
         [self.walls[kSVHorizontalOrientation] objectForKey:[[SVPosition alloc] initWithX:start.x + 1
                                                           andY:start.y]]))
        return NO;
    
    if (start.x < end.x &&
        ([self.walls[kSVVerticalOrientation] objectForKey:[[SVPosition alloc] initWithX:start.x + 1
                                                           andY:start.y]] ||
         [self.walls[kSVVerticalOrientation] objectForKey:[[SVPosition alloc] initWithX:start.x + 1
                                                           andY:start.y + 1]]))
        return NO;
    
    if (start.y < end.y &&
        ([self.walls[kSVHorizontalOrientation] objectForKey:[[SVPosition alloc] initWithX:start.x
                                                           andY:start.y + 1]] ||
         [self.walls[kSVHorizontalOrientation] objectForKey:[[SVPosition alloc] initWithX:start.x + 1
                                                           andY:start.y + 1]]))
        return NO;
    
    if (start.x > end.x &&
        ([self.walls[kSVVerticalOrientation] objectForKey:[[SVPosition alloc] initWithX:start.x
                                                           andY:start.y]] ||
         [self.walls[kSVVerticalOrientation] objectForKey:[[SVPosition alloc] initWithX:start.x
                                                           andY:start.y + 1]]))
        return NO;
    
    return YES;
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

- (BOOL)isWallLegalAtPosition:(SVPosition*)position withOrientation:(kSVWallOrientation)orientation {
    if (position.x <= 0 || position.x >= self.size.width || position.y <= 0 || position.y >= self.size.height)
        return NO;
    
    kSVWallOrientation otherOrientation = orientation == kSVHorizontalOrientation ? kSVVerticalOrientation : kSVHorizontalOrientation;
    NSDictionary* wallsInOrientation = self.walls[orientation];
    NSDictionary* wallsInOtherOrientation = self.walls[otherOrientation];
    if ([wallsInOrientation objectForKey:position] ||
        [wallsInOtherOrientation objectForKey:position])
        return NO;
    
    int xOffset = orientation == kSVHorizontalOrientation ? 1 : 0;
    int yOffset = orientation == kSVHorizontalOrientation ? 0 : 1;
    
    if ([wallsInOrientation objectForKey:[[SVPosition alloc] initWithX:position.x - xOffset andY:position.y - yOffset]] ||
        [wallsInOrientation objectForKey:[[SVPosition alloc] initWithX:position.x + xOffset andY:position.y + yOffset]])
        return NO;
    
    //Add wall to test if goal reachable then remove it
    [self.walls[orientation] setObject:[NSNumber numberWithBool:YES] forKey:position];
    if (![self isGoalReachableByPlayer:kSVPlayer1] || ![self isGoalReachableByPlayer:kSVPlayer2]) {
        [self.walls[orientation] removeObjectForKey:position];
        return NO;
    }
    
    [self.walls[orientation] removeObjectForKey:position];
    return YES;
}

- (void)addWallAtPosition:(SVPosition*)position withOrientation:(kSVWallOrientation)orientation {
    if (![self isWallLegalAtPosition:position withOrientation:orientation]) {
        NSException* exception = [NSException
                                  exceptionWithName:@"SVInvalidWallException"
                                  reason:[NSString stringWithFormat:@"Wall of orientation %d can't be built at %@", orientation, position]
                                  userInfo:nil];
        @throw exception;
    }
    else {
        [self.walls[orientation] setObject:[NSNumber numberWithBool:YES] forKey:position];
    }
}

- (BOOL)didPlayerWin:(kSVPlayer)player {
    return ((SVPosition*)self.playerPositions[player]).y == [self.playerGoalsY[player] intValue];
}
//
//- (BOOL)canMoveFrom:(SVPosition*)start to:(SVPosition*)end {
//    int manhattanDistance = abs(start.x - end.x) + abs(start.y - end.y);
//    if (manhattanDistance == 1) {
//        //Check if a player is on end position
//        if ([end isEqual:self.playerPositions[0]] ||
//            [end isEqual:self.playerPositions[1]])
//            return NO;
//        
//        return [self canSimplifiedMoveFrom:start to:end];
//    }
//    
//    else if (manhattanDistance == 2) {
//        //Straight jump
//        if (abs(start.x - end.x) == 2 || abs(start.y - end.y) == 2) {
//            SVPosition* inBetweenPosition = [[SVPosition alloc] initWithX:(start.x + end.x) / 2 andY:(start.y + end.y) / 2];
//            if (![inBetweenPosition isEqual:self.playerPositions[0]] &&
//                ![inBetweenPosition isEqual:self.playerPositions[1]])
//                return NO;
//            
//            return [self canSimplifiedMoveFrom:start to:inBetweenPosition] && [self canSimplifiedMoveFrom:inBetweenPosition to:end];
//        }
//        
//        //Diagonal jump
//        else {
//            //Check if player inBetween
//            SVPosition* inBetweenPosition1 = [[SVPosition alloc] initWithX:start.x andY:end.y];
//            SVPosition* inBetweenPosition2 = [[SVPosition alloc] initWithX:end.x andY:start.y];
//            SVPosition* otherPlayerPosition;
//            if ([inBetweenPosition1 isEqual:self.playerPositions[0]] ||
//                [inBetweenPosition1 isEqual:self.playerPositions[1]])
//                otherPlayerPosition = inBetweenPosition1;
//            else if ([inBetweenPosition2 isEqual:self.playerPositions[0]] ||
//                     [inBetweenPosition2 isEqual:self.playerPositions[1]])
//                otherPlayerPosition = inBetweenPosition2;
//            else
//                return NO;
//            
//            //Check if straight jump not possible
//            SVPosition* straightJumpPosition = [[SVPosition alloc] initWithX:start.x + (otherPlayerPosition.x - start.x) * 2
//                                                                        andY:start.y + (otherPlayerPosition.y - start.y) * 2];
//            if ([self canMoveFrom:start to:straightJumpPosition])
//                return NO;
//            
//            //Check if no wall blocks the jump
//            return [self canSimplifiedMoveFrom:start to:otherPlayerPosition] &&
//            [self canSimplifiedMoveFrom:otherPlayerPosition to:end];
//        }
//    }
//    
//    else {
//        return NO;
//    }
//    
//    return YES;
//}


//- (NSArray*)movesForPlayer:(kSVPlayer)player {
//    CGPoint playerPosition;
//    if (player == kSVPlayer1)
//        playerPosition = self.player1Position;
//    else
//        playerPosition = self.player2Position;
//    
//    NSMutableArray* positions = [[NSMutableArray alloc] init];
//    //Straight positions
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x - 1, playerPosition.y)]];
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x - 2, playerPosition.y)]];
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x + 1, playerPosition.y)]];
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x + 2, playerPosition.y)]];
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x, playerPosition.y - 1)]];
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x, playerPosition.y - 2)]];
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x, playerPosition.y + 1)]];
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x, playerPosition.y + 2)]];
//    
//    //Diagonal positions
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x + 1, playerPosition.y - 1)]];
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x + 1, playerPosition.y + 1)]];
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x - 1, playerPosition.y + 1)]];
//    [positions addObject:[NSValue valueWithCGPoint:CGPointMake(playerPosition.x - 1, playerPosition.y - 1)]];
//    
//    for (NSValue* positionValue in positions) {
//        CGPoint position = positionValue.CGPointValue;
//        if (![self canMoveFrom:playerPosition to:position])
//            [positions removeObject:positionValue];
//    }
//    return positions;
//}

//////////////////////////////////////////////////////
// Private
//////////////////////////////////////////////////////

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

- (NSString*)description {
    return [NSString stringWithFormat:@"player1: %@; player2: %@", self.playerPositions[0], self.playerPositions[1]];
}

@end
