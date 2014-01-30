//
//  SVPosition.h
//  Walls
//
//  Created by Sebastien Villar on 19/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVPosition : NSObject <NSCopying, NSCoding>
@property (assign, readonly) int x;
@property (assign, readonly) int y;
- (id)initWithX:(int)x andY:(int)y;
@end
