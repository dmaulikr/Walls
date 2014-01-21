//
//  SVBoardCanvas.h
//  Walls
//
//  Created by Sebastien Villar on 21/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVBoardCanvas : UIView
- (void)drawLineFrom:(CGPoint)start to:(CGPoint)end;
- (void)clear;
@end
