//
//  SVTheme.m
//  Walls
//
//  Created by Sebastien Villar on 26/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVTheme.h"

static SVTheme* singleton;

@implementation SVTheme
+ (SVTheme*)sharedTheme {
    if (!singleton) {
        singleton = [[SVTheme alloc] init];
    }
    return singleton;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end
