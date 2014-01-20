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
- (id)init {
    self = [super init];
    if (self) {
        _size = CGSizeMake(6, 9);
        _verticalWalls = [[NSMutableDictionary alloc] init];
        _horizontalWalls = [[NSMutableDictionary alloc] init];
        _playerPositions = [[NSMutableArray alloc] init];
        [_playerPositions addObject:[[SVPosition alloc] initWithX:4 andY:8]];
        [_playerPositions addObject:[[SVPosition alloc] initWithX:4 andY:0]];
        _playerGoalsY = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                                                                [NSNumber numberWithInt:_size.height - 1], nil];
    }
    return self;
}

//////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////

- (id)copyWithZone:(NSZone *)zone {
    SVBoard* copy = [SVBoard allocWithZone:zone];
    copy.size = self.size;
    copy.verticalWalls = [self.verticalWalls mutableCopy];
    copy.horizontalWalls = [self.horizontalWalls mutableCopy];
    copy.playerPositions = self.playerPositions;
    return copy;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]])
        return false;
    SVBoard* otherBoard = (SVBoard*)object;
    return CGSizeEqualToSize(self.size, otherBoard.size) &&
           [self.verticalWalls isEqualToDictionary:otherBoard.verticalWalls] &&
           [self.horizontalWalls isEqualToDictionary:otherBoard.horizontalWalls] &&
           [self.playerPositions[kSVPlayer1] isEqual:otherBoard.playerPositions[kSVPlayer1]] &&
           [self.playerPositions[kSVPlayer2] isEqual:otherBoard.playerPositions[kSVPlayer2]];
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%@,%@,%@,%@",
                     NSStringFromCGSize(self.size),
                     self.verticalWalls,
                     self.horizontalWalls,
                     self.playerPositions] hash];
}

- (BOOL)canPlayer:(kSVPlayer)player moveTo:(SVPosition*)end {
    //Check if 1 square move
    SVPosition* start = self.playerPositions[player];
    if (abs(start.x - end.x) + abs(start.y - end.y) != 1)
        return false;
    
    //Check if positions are on board
    if (start.x >= self.size.width || start.x < 0 || start.y >= self.size.height || start.y < 0 ||
        end.x >= self.size.width || end.x < 0 || end.y >= self.size.height || end.y < 0)
        return false;
    
    if (start.y > end.y &&
        ([self.horizontalWalls objectForKey:[[SVPosition alloc] initWithX:start.x - 1
                                                           andY:start.y - 1]] ||
         [self.horizontalWalls objectForKey:[[SVPosition alloc] initWithX:start.x
                                                           andY:start.y - 1]]))
        return false;
    
    if (start.x < end.x &&
        ([self.verticalWalls objectForKey:[[SVPosition alloc] initWithX:start.x
                                                           andY:start.y - 1]] ||
         [self.verticalWalls objectForKey:[[SVPosition alloc] initWithX:start.x
                                                           andY:start.y]]))
        return false;
    
    if (start.y < end.y &&
        ([self.horizontalWalls objectForKey:[[SVPosition alloc] initWithX:start.x - 1
                                                           andY:start.y]] ||
         [self.horizontalWalls objectForKey:[[SVPosition alloc] initWithX:start.x
                                                           andY:start.y]]))
        return false;
    
    if (start.x > end.x &&
        ([self.verticalWalls objectForKey:[[SVPosition alloc] initWithX:start.x - 1
                                                           andY:start.y - 1]] ||
         [self.verticalWalls objectForKey:[[SVPosition alloc] initWithX:start.x - 1
                                                           andY:start.y]]))
        return false;
    
    return true;
}

- (void)movePlayer:(kSVPlayer)player to:(SVPosition*)end {
    if (![self canPlayer:player moveTo:end]) {
        NSException* exception = [NSException
                                  exceptionWithName:@"SVInvalidMoveException"
                                  reason:[NSString stringWithFormat:@"Player %d can't move to %@", player, end]
                                  userInfo:nil];
        @throw exception;
    }
    else {
        self.playerPositions[player] = end;
    }
}

- (BOOL)isWallLegalAtPosition:(CGPoint)position {
    return true;
}

- (void)addWallAtPosition:(SVPosition*)position withDirection:(kSVWallDirection)direction {
    
}
//
//- (BOOL)canMoveFrom:(SVPosition*)start to:(SVPosition*)end {
//    int manhattanDistance = abs(start.x - end.x) + abs(start.y - end.y);
//    if (manhattanDistance == 1) {
//        //Check if a player is on end position
//        if ([end isEqual:self.playerPositions[0]] ||
//            [end isEqual:self.playerPositions[1]])
//            return false;
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
//                return false;
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
//                return false;
//            
//            //Check if straight jump not possible
//            SVPosition* straightJumpPosition = [[SVPosition alloc] initWithX:start.x + (otherPlayerPosition.x - start.x) * 2
//                                                                        andY:start.y + (otherPlayerPosition.y - start.y) * 2];
//            if ([self canMoveFrom:start to:straightJumpPosition])
//                return false;
//            
//            //Check if no wall blocks the jump
//            return [self canSimplifiedMoveFrom:start to:otherPlayerPosition] &&
//            [self canSimplifiedMoveFrom:otherPlayerPosition to:end];
//        }
//    }
//    
//    else {
//        return false;
//    }
//    
//    return true;
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
    NSMutableDictionary* visitedBoards = [[NSMutableDictionary alloc] init];
    int goalY = ((NSNumber*)self.playerGoalsY[player]).intValue;
    
    [queue addObject:self];
    while (queue.count > 0) {
        SVBoard* board = [queue firstObject];
        if (((SVPosition*)board.playerPositions[player]).y == goalY)
            return true;
        NSArray* positions = [board movesForPlayer:player];
        for (SVPosition* position in positions) {
            SVBoard* copy = [self mutableCopy];
            [copy movePlayer:player to:position];
            if (![visitedBoards objectForKey:copy]) {
                [visitedBoards setObject:[NSNumber numberWithBool:true] forKey:copy];
                [queue addObject:copy];
            }
        }
    }
    return false;
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

@end
