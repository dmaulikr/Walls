//
//  SVHelper.h
//  Walls
//
//  Created by Sebastien Villar on 23/03/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SVHelper : NSObject
+ (NSMutableAttributedString*)attributedStringWithText:(NSString*)text characterSpacing:(int)spacing;
@end
