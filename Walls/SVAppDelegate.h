//
//  SVAppDelegate.h
//  Walls
//
//  Created by Sebastien Villar on 18/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSVSmallScreen,
    kSVLargeScreen
} kSVScreenSize;

@interface SVAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign) kSVScreenSize screenSize;
@end
