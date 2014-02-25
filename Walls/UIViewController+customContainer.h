//
//  UIViewController+customContainer.h
//  Walls
//
//  Created by Sebastien Villar on 25/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "SVCustomContainerController.h"

@interface UIViewController (customContainer)
@property (strong) SVCustomContainerController* customContainer;
@end

static void * const kMyPropertyAssociatedStorageKey = (void*)&kMyPropertyAssociatedStorageKey;

