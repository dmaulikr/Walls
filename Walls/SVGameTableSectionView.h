//
//  SVGameTableSectionView.h
//  Walls
//
//  Created by Sebastien Villar on 04/03/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVGameTableSectionView : UIView
@property (strong) UIView* line;
@property (strong) UILabel* label;

- (id)initWithTitle:(NSString*)title;
@end
