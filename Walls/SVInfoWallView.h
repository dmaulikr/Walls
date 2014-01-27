//
//  SVInfoWallView.h
//  Walls
//
//  Created by Sebastien Villar on 27/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVInfoWallView : UIView
- (id)initWithFrame:(CGRect)frame andColor:(UIColor*)color;
- (void)showRect:(CGRect)rect animated:(BOOL)animated withFinishBlock:(void(^)(void))block;
@end
