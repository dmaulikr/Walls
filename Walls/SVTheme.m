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
        self.player1Color = [UIColor colorWithRed:0.4 green:0.82 blue:0.53 alpha:1.0];
        self.player1LightColor = [UIColor colorWithRed:0.73 green:0.92 blue:0.79 alpha:1.0];
        self.player2Color = [UIColor colorWithRed:0.96 green:0.67 blue:0.36 alpha:1.0];
        self.player2LightColor = [UIColor colorWithRed:0.96 green:0.82 blue:0.69 alpha:1.0];
        self.lightSquareColor = [[UIColor alloc] initWithRed:0.44 green:0.44 blue:0.44 alpha:1.0];
        self.darkSquareColor = [[UIColor alloc] initWithRed:0.41 green:0.41 blue:0.41 alpha:1.0];
        self.squareBorderColor = [[UIColor alloc] initWithRed:0.46 green:0.46 blue:0.46 alpha:1.0];
        self.normalWallColor = [[UIColor alloc] initWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
    }
    return self;
}
@end
