//
//  SVGameTableViewCell.h
//  Walls
//
//  Created by Sebastien Villar on 09/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVGameTableViewCell : UITableViewCell
- (void)setText:(NSString*)text;
- (void)setLeftImage:(UIImage*)image;
- (void)setRightImage:(UIImage*)image;
- (void)setColor:(UIColor*)color;
@end
