//
//  SVGameTableViewCell.h
//  Walls
//
//  Created by Sebastien Villar on 09/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGame.h"

float const kSVGameTableViewCellXOffset = 20;

@interface SVGameTableViewCell : UITableViewCell
- (void)displayForGame:(SVGame*)game;
@end
