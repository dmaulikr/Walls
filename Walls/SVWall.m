//
//  SVWall.m
//  Walls
//
//  Created by Sebastien Villar on 22/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVWall.h"

@implementation SVWall

- (id)initWithPosition:(SVPosition *)position orientation:(kSVWallOrientation)orientation andType:(kSVWallType)type {
    self = [self init];
    if (self) {
        _position = position;
        _orientation = orientation;
        _type = type;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SVWall* copy = [SVWall allocWithZone:zone];
    copy.position = [self.position copy];
    copy.orientation = self.orientation;
    copy.type = self.type;
    return copy;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]])
        return NO;
    SVWall* otherWall = (SVWall*)object;
    return [self.position isEqual:otherWall.position] &&
           self.orientation == otherWall.orientation &&
           self.type == otherWall.type;
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%@,%d,%d",
             self.position,
             self.orientation,
             self.type] hash];
}
@end