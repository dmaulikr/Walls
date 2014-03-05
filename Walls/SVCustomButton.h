//
//  SVCustomButton.h
//  Walls
//
//  Created by Sebastien Villar on 05/03/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVCustomButton : UIButton
- (void)drawBlock:(void(^)(CGContextRef context)) block;
@end
