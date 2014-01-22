//
//  DLWMMenuAnimator.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 06/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DLWMMenu.h"

@interface DLWMMenuAnimator : NSObject <DLWMMenuAnimator>

@property (readwrite, assign, nonatomic) NSTimeInterval duration;
@property (readwrite, assign, nonatomic) UIViewAnimationOptions options;

- (id)init;
- (id)initWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options;

+ (DLWMMenuAnimator *)sharedInstantAnimator;

- (void)animateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu animated:(BOOL)animated completion:(DLWMMenuAnimatorCompletionBlock)completion;

@end
