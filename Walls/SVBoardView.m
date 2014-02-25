//
//  SVBoardView.m
//  Walls
//
//  Created by Sebastien Villar on 24/01/14.
//  Copyright (c) 2014 Sebastien Villar. All rights reserved.
//

#import "SVBoardView.h"
#import "SVTheme.h"

@interface SVBoardView ()
@property (strong) NSMutableArray* squareIntersections;
@property (strong) NSMutableDictionary* positionsForIntersection;
@property (strong) NSMutableDictionary* squareViewForPosition;
@property (strong) NSMutableArray* squareRows;
@property (assign) kSVPanDirection initialPanDirection;
@property (assign) CGPoint initialPoint;
@property (assign) CGPoint nearestIntersectionPoint;
@property (assign) CGPoint offset;

@property (strong) void(^hideRowsFinishBlock)(void);
@property (strong) void(^showRowsFinishBlock)(void);
@end

@implementation SVBoardView

- (id)initWithFrame:(CGRect)frame rotated:(BOOL)rotated {
    self = [super initWithFrame:frame];
    if (self) {
        _squareIntersections = [[NSMutableArray alloc] init];
        _positionsForIntersection = [[NSMutableDictionary alloc] init];
        _squareViewForPosition = [[NSMutableDictionary alloc] init];
        _initialPanDirection = kSVNoDirection;
        _squareRows = [[NSMutableArray alloc] init];
        
        if (rotated) {
            self.transform = CGAffineTransformMakeRotation(M_PI);
        }
        
        UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        gestureRecognizer.minimumNumberOfTouches = 1;
        gestureRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:gestureRecognizer];
        
        SVSquareView* lastSquareView;
        int rowCount = 9;
        int colCount = 7;
        
        for (int i = 0; i < rowCount; i++) {
            kSVSquareViewRow row;
            if (i == 0)
                row = kSVSquareViewRowTop;
            else if (i == rowCount - 1)
                row = kSVSquareViewRowBottom;
            else
                row = kSVSquareViewRowCenter;
            
            UIView* rowView = [[UIView alloc] initWithFrame:CGRectMake(0, i * 46, self.frame.size.width, 46)];
            [self.squareRows addObject:rowView];
            [self addSubview:rowView];
            
            for (int j = 0; j < colCount; j++) {
                CGPoint origin = CGPointZero;
                kSVSquareViewCol col;
                kSVSquareViewColor color;
                
                if (lastSquareView && j == 0) {
                    origin.y = CGRectGetMaxY(lastSquareView.frame);
                }
                else if (lastSquareView) {
                    origin.x = CGRectGetMaxX(lastSquareView.frame);
                    origin.y = CGRectGetMinY(lastSquareView.frame);
                }
                
                if ((i + j) % 2 == 0)
                    color = kSVSquareViewLight;
                else
                    color = kSVSquareViewDark;
                
                if (j == 0)
                    col = kSVSquareViewColLeft;
                else if (j == colCount - 1)
                    col = kSVSquareViewColRight;
                else
                    col = kSVSquareViewColCenter;
                
                SVSquareView* squareView = [[SVSquareView alloc] initWithOrigin:origin row:row col:col andColor:color];
                [rowView addSubview:squareView];
                squareView.delegate = self;
                [_squareViewForPosition setObject:squareView forKey:[[SVPosition alloc] initWithX:j andY:i]];
                lastSquareView = squareView;
                
                //Intersections
                CGPoint point = CGPointMake(CGRectGetMinX(squareView.frame), CGRectGetMinY(squareView.frame));
                [self.squareIntersections addObject:[NSValue valueWithCGPoint:point]];
                [self.positionsForIntersection setObject:[[SVPosition alloc] initWithX:j andY:i] forKey:[NSValue valueWithCGPoint:point]];
                
                
                if (j == colCount - 1) {
                    point = CGPointMake(CGRectGetMaxX(squareView.frame), CGRectGetMinY(squareView.frame));
                    [self.squareIntersections addObject:[NSValue valueWithCGPoint:point]];
                    [self.positionsForIntersection setObject:[[SVPosition alloc] initWithX:j + 1 andY:i] forKey:[NSValue valueWithCGPoint:point]];
                }
                
                if (i == 8) {
                    point = CGPointMake(CGRectGetMinX(squareView.frame), CGRectGetMaxY(squareView.frame));
                    [self.squareIntersections addObject:[NSValue valueWithCGPoint:point]];
                    [self.positionsForIntersection setObject:[[SVPosition alloc] initWithX:j andY:i + 1] forKey:[NSValue valueWithCGPoint:point]];
                    if (j == colCount - 1) {
                        point = CGPointMake(CGRectGetMaxX(squareView.frame), CGRectGetMaxY(squareView.frame));
                        [self.squareIntersections addObject:[NSValue valueWithCGPoint:point]];
                        [self.positionsForIntersection setObject:[[SVPosition alloc] initWithX:j + 1 andY:i + 1] forKey:[NSValue valueWithCGPoint:point]];
                    }
                }
            }
        }
    }
    return self;
}

- (void)hideRowsAnimated:(BOOL)animated withFinishBlock:(void (^)(void))block {
    if (animated) {
        self.hideRowsFinishBlock = block;
        float delay = 0;
        for (UIView* row in self.squareRows) {
            [UIView beginAnimations:@"rowOut" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelay:delay];
            row.frame = CGRectMake(row.frame.origin.x + self.frame.size.width,
                                   row.frame.origin.y,
                                   row.frame.size.width,
                                   row.frame.size.height);
            delay += 0.05;
            if (row == [self.squareRows lastObject]) {
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(hideRowsAnimationDidStop:finished:context:)];
            }
            [UIView commitAnimations];
        }
    }
    else {
        for (UIView* row in self.squareRows) {
            row.frame = CGRectMake(row.frame.origin.x + self.frame.size.width,
                                   row.frame.origin.y,
                                   row.frame.size.width,
                                   row.frame.size.height);
        }
    }
}

- (void)showRowsAnimated:(BOOL)animated withFinishBlock:(void (^)(void))block {
    if (animated) {
        self.showRowsFinishBlock = block;
        float delay = 0;
        for (UIView* row in self.squareRows) {
            [UIView beginAnimations:@"rowIn" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelay:delay];
            row.frame = CGRectMake(0,
                                   row.frame.origin.y,
                                   row.frame.size.width,
                                   row.frame.size.height);
            delay += 0.05;
            if (row == [self.squareRows lastObject]) {
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(showRowsAnimationDidStop:finished:context:)];
            }
            [UIView commitAnimations];
        }
    }
    else {
        for (UIView* row in self.squareRows) {
            row.frame = CGRectMake(0,
                                   row.frame.origin.y,
                                   row.frame.size.width,
                                   row.frame.size.height);
        }
    }
}

- (SVPosition*)intersectionPositionForPoint:(CGPoint)point {
    return [self.positionsForIntersection objectForKey:[NSValue valueWithCGPoint:point]];
}

- (CGPoint)intersectionPointForPosition:(SVPosition*)position {
    NSValue* value = [[self.positionsForIntersection allKeysForObject:position] objectAtIndex:0];
    if (!value)
        return CGPointZero;
    return value.CGPointValue;
}

- (CGPoint)nearestIntersectionToPoint:(CGPoint)point {
    CGPoint nearestIntersection = CGPointZero;
    float nearestDistance = -1;
    for (NSValue* value in self.squareIntersections) {
        CGPoint intersection = value.CGPointValue;
        
        float distance = sqrtf(pow(abs(intersection.x - point.x), 2) + pow(abs(intersection.y - point.y), 2));
        if (distance < nearestDistance || nearestDistance == -1) {
            nearestDistance = distance;
            nearestIntersection = intersection;
        }
    }
    return nearestIntersection;
}

- (void)didPan:(UIPanGestureRecognizer*)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    CGPoint velocity = [gestureRecognizer velocityInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        kSVPanDirection absolutePanDirection = kSVNoDirection;
        if (abs(velocity.x) > abs(velocity.y)) {
            absolutePanDirection = velocity.x > 0 ? kSVRightDirection : kSVLeftDirection;
        }
        else {
            absolutePanDirection = velocity.y > 0 ? kSVBottomDirection : kSVTopDirection;
        }
        
        self.nearestIntersectionPoint = [self nearestIntersectionToPoint:point];
        self.offset = CGPointMake(self.nearestIntersectionPoint.x - point.x , self.nearestIntersectionPoint.y - point.y);
        self.initialPoint = point;
        self.initialPanDirection = absolutePanDirection;
        if (self.delegate && [self.delegate respondsToSelector:@selector(boardView:didStartPanAt:withDirection:)])
            [self.delegate boardView:self didStartPanAt:self.nearestIntersectionPoint withDirection:self.initialPanDirection];
    }
    
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        kSVPanDirection guidedPanDirection = kSVNoDirection;
        
        if (self.initialPanDirection == kSVLeftDirection ||
            self.initialPanDirection == kSVRightDirection) {
            guidedPanDirection = velocity.x > 0 ? kSVRightDirection : kSVLeftDirection;
        }
        
        else if (self.initialPanDirection == kSVTopDirection ||
                 self.initialPanDirection == kSVBottomDirection) {
            guidedPanDirection = velocity.y > 0 ? kSVBottomDirection : kSVTopDirection;
        }
        
        if (guidedPanDirection == kSVRightDirection ||
            guidedPanDirection == kSVLeftDirection)
            point.y = self.initialPoint.y;
        else
            point.x = self.initialPoint.x;
        
        //If direction changes => new initial point
        BOOL didDirectionChange = NO;
        if (self.initialPanDirection == kSVLeftDirection)
            didDirectionChange = point.x > self.initialPoint.x;
        else if (self.initialPanDirection == kSVRightDirection)
            didDirectionChange = point.x < self.initialPoint.x;
        else if (self.initialPanDirection == kSVTopDirection)
            didDirectionChange = point.y > self.initialPoint.y;
        else
            didDirectionChange = point.y < self.initialPoint.y;
            
        if (didDirectionChange) {
            self.initialPanDirection = guidedPanDirection;
            self.offset = CGPointMake(self.nearestIntersectionPoint.x - point.x , self.nearestIntersectionPoint.y - point.y);
            if (self.delegate && [self.delegate respondsToSelector:@selector(boardView:didEndPanAt:changeOfDirection:)])
                [self.delegate boardView:self didEndPanAt:point changeOfDirection:YES];
            if (self.delegate && [self.delegate respondsToSelector:@selector(boardView:didStartPanAt:withDirection:)])
                [self.delegate boardView:self didStartPanAt:self.nearestIntersectionPoint withDirection:self.initialPanDirection];
        }
            
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(boardView:didChangePanTo:)])
                [self.delegate boardView:self didChangePanTo:CGPointMake(point.x + self.offset.x, point.y + self.offset.y)];
        }
    }
    
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(boardView:didEndPanAt:changeOfDirection:)])
            [self.delegate boardView:self didEndPanAt:point changeOfDirection:NO];
    }
}

- (CGPoint)squareCenterForPosition:(SVPosition *)position {
    SVSquareView* squareView = [self.squareViewForPosition objectForKey:position];
    CGPoint point = CGPointMake(squareView.frame.origin.x + squareView.frame.size.width / 2,
                                squareView.frame.origin.y + squareView.frame.size.height / 2);
    return point;
}

//////////////////////////////////////////////////////
// Buttons targets
//////////////////////////////////////////////////////

- (void)squareViewDidTap:(SVSquareView *)squareView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(boardView:didTapSquare:)]) {
        SVPosition* position = [[self.squareViewForPosition allKeysForObject:squareView] objectAtIndex:0];
        [self.delegate boardView:self didTapSquare:position];
    }
}

//////////////////////////////////////////////////////
// Animations delegate
//////////////////////////////////////////////////////

- (void)hideRowsAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if (self.hideRowsFinishBlock) {
        self.hideRowsFinishBlock();
    }
}

- (void)showRowsAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if (self.showRowsFinishBlock) {
        self.showRowsFinishBlock();
    }
}


@end
