//
//  SVTopBarView.h
//  Walls
//
//  Created by Sebastien Villar on 25/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVTopBarView : UIView
- (void)setLeftButton:(UIButton *)button animated:(BOOL)animated;
- (void)setRightButton:(UIButton *)button animated:(BOOL)animated;
- (void)setTextLabel:(NSString*)text animated:(BOOL)animated;
@end
