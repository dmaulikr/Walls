//
//  UIViewController+customContainer.m
//  Walls
//
//  Created by Sebastien Villar on 25/02/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "UIViewController+customContainer.h"

@implementation UIViewController (customContainer)

- (void)setCustomContainer:(SVCustomContainerController *)customContainer {
    objc_setAssociatedObject(self, kMyPropertyAssociatedStorageKey, customContainer, OBJC_ASSOCIATION_COPY);
}

- (SVCustomContainerController*)customContainer {
    return objc_getAssociatedObject(self, kMyPropertyAssociatedStorageKey);
}
@end
