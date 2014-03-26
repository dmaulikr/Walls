//
//  SVHelper.h
//  Walls
//
//  Created by Sebastien Villar on 23/03/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef enum {
    kSVSmallScreen,
    kSVLargeScreen
} kSVScreenSize;

@interface SVHelper : NSObject
+ (NSMutableAttributedString*)attributedStringWithText:(NSString*)text characterSpacing:(int)spacing;
+ (kSVScreenSize)screenSize;
@end
