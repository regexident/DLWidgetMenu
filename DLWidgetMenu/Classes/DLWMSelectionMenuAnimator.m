//
//  DLWMSelectionMenuAnimator.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMSelectionMenuAnimator.h"

@interface DLWMMenuAnimator ()

- (void)willAnimateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu;
- (void)animateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu;
- (void)didAnimateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu finished:(BOOL)finished;

@end

@implementation DLWMSelectionMenuAnimator

- (void)didAnimateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu finished:(BOOL)finished {
	[super didAnimateItem:item atIndex:index inMenu:menu finished:finished];
	if (finished) {
		item.alpha = 1.0;
		item.transform = CGAffineTransformIdentity;
	}
}

- (void)animateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu {
	item.alpha = 0.0;
	item.transform = CGAffineTransformConcat(item.transform, CGAffineTransformMakeScale(2.0, 2.0));
}

@end
