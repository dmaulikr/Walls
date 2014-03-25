//
//  SVHelper.m
//  Walls
//
//  Created by Sebastien Villar on 23/03/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVHelper.h"

@implementation SVHelper
+ (NSMutableAttributedString*)attributedStringWithText:(NSString *)text characterSpacing:(int)spacing {
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSKernAttributeName value:[NSNumber numberWithInt:spacing] range:NSMakeRange(0, text.length > 0 ? text.length - 1 : 0)];
    return attributedString;
}

+ (SystemSoundID)soundIDForName:(NSString *)name {
    SystemSoundID soundID;
    NSString* soundPath = [[NSBundle mainBundle] pathForResource:name ofType:@"caf"];
    CFURLRef soundRef = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(soundRef, &soundID);
    return soundID;
}
@end
