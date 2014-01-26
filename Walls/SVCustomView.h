//
//  SVCustomView.h
//  Walls
//
//  Created by Sebastien Villar on 26/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVCustomView : UIView
- (void)drawBlock:(void(^)(CGContextRef context)) block;
@end
