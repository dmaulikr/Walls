//
//  SVPosition.m
//  Walls
//
//  Created by Sebastien Villar on 19/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVPosition.h"

@interface SVPosition ()
@property (assign) int x;
@property (assign) int y;
@end

@implementation SVPosition
- (id)initWithX:(int)x andY:(int)y {
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
    }
    return self;
}

//////////////////////////////////////////////////////
// Protocols
//////////////////////////////////////////////////////

- (NSString*)description {
    return [NSString stringWithFormat:@"(%d, %d)", self.x, self.y];
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"(%d, %d)", self.x, self.y] hash];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]])
        return false;
    SVPosition* otherPosition = (SVPosition*)object;
    return self.x == otherPosition.x && self.y == otherPosition.y;
}

- (id)copyWithZone:(NSZone *)zone {
    SVPosition* copy = [SVPosition allocWithZone:zone];
    copy.x = self.x;
    copy.y = self.y;
    return copy;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _x = [aDecoder decodeIntForKey:@"x"];
        _y = [aDecoder decodeIntForKey:@"y"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.x forKey:@"x"];
    [aCoder encodeInt:self.y forKey:@"y"];
}
@end
