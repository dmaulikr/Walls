//
//  SVPawnView.h
//  Walls
//
//  Created by Sebastien Villar on 24/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGSize kSVPawnViewNormalSize = {30, 30};

@interface SVPawnView : UIView

- (id)initWithFrame:(CGRect)frame color1:(UIColor*)color1 andColor2:(UIColor*)color2;
@end
