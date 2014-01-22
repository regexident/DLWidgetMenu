//
//  DLWMSpringMenuAnimator.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMMenuAnimator.h"

@interface DLWMSpringMenuAnimator : DLWMMenuAnimator

@property (readwrite, assign, nonatomic) CGFloat damping;
@property (readwrite, assign, nonatomic) CGFloat velocity;

- (id)initWithDamping:(CGFloat)damping velocity:(CGFloat)velocity;
- (id)initWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options damping:(CGFloat)damping velocity:(CGFloat)velocity;

@end
