//
//  SVTheme.h
//  Walls
//
//  Created by Sebastien Villar on 26/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVTheme : NSObject
@property (strong) UIColor* localPlayerColor;
@property (strong) UIColor* localPlayerLightColor;
@property (strong) UIColor* opponentPlayerColor;
@property (strong) UIColor* opponentPlayerLightColor;
@property (strong) UIColor* lightSquareColor;
@property (strong) UIColor* darkSquareColor;
@property (strong) UIColor* squareBorderColor;
@property (strong) UIColor* normalWallColor;

+ (SVTheme*)sharedTheme;
@end
