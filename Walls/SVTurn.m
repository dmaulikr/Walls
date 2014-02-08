//
//  SVTurn.m
//  Walls
//
//  Created by Sebastien Villar on 07/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#define LogVariableName(x) NSLog(@"The variable is %s", #x)

#import "SVTurn.h"

@implementation SVTurn
- (id)init {
    self = [super init];
    if (self) {
        _action = kSVNoAction;
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Action: %d"
                                        "\r Action info: %@"
                                        "\r Player: %d",
                                        self.action,
                                        self.actionInfo,
                                        self.player];
}

//////////////////////////////////////////////////////
// Protocols
//////////////////////////////////////////////////////

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:SVTurn.class]) {
        return NO;
    }
    SVTurn* other = (SVTurn*)object;
    
    return self.action == other.action &&
           self.player == other.player &&
          [self.actionInfo isEqual:other.actionInfo];
    }

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _action = [aDecoder decodeIntForKey:@"action"];
        _actionInfo = [aDecoder decodeObjectForKey:@"actionInfo"];
        _player = [aDecoder decodeIntForKey:@"player"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.action forKey:@"action"];
    [aCoder encodeObject:self.actionInfo forKey:@"actionInfo"];
    [aCoder encodeInt:self.player forKey:@"player"];
}
@end
