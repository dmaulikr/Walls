//
//  SVPlayer.h
//  Walls
//
//  Created by Sebastien Villar on 18/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVPlayer : NSObject
@property (strong) NSString* identifier;
@property (strong) NSString* name;
@property (assign) int wallsRemaining;
@property (assign) CGPoint position;
@end
