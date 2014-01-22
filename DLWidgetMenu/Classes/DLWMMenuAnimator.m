//
//  DLWMMenuAnimator.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 06/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMMenuAnimator.h"

@implementation DLWMMenuAnimator

- (id)init {
	self = [super init];
	if (self) {
		self.duration = 0.4;
		self.options = UIViewAnimationOptionCurveEaseIn;
	}
	return self;
}

- (id)initWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options {
	self = [self init];
	if (self) {
		self.duration = duration;
		self.options = options;
	}
	return self;
}

+ (DLWMMenuAnimator *)sharedInstantAnimator {
	static DLWMMenuAnimator *sharedAnimator = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (!sharedAnimator) {
			sharedAnimator = [[DLWMMenuAnimator alloc] initWithDuration:0.0 options:UIViewAnimationOptionCurveLinear];
		}
	});
	return sharedAnimator;
}

- (void)willAnimateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu {
	if ([menu isOpenedOrOpening]) {
		item.hidden = NO;
		item.alpha = 0.0;
		item.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
		item.center = menu.centerPointWhileOpen;
	}
}

- (void)animateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu {
	item.center = ([menu isOpenedOrOpening]) ? item.layoutLocation : menu.centerPointWhileOpen;
	if ([menu isOpenedOrOpening]) {
		item.alpha = 1.0;
		item.transform = CGAffineTransformIdentity;
	} else {
		item.alpha = 0.0;
		item.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
	}
}

- (void)didAnimateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu finished:(BOOL)finished {
	if (finished && [menu isClosedOrClosing]) {
		item.hidden = YES;
		item.transform = CGAffineTransformIdentity;
	}
}

- (void)animateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu animated:(BOOL)animated completion:(DLWMMenuAnimatorCompletionBlock)completion {
	[self willAnimateItem:item atIndex:index inMenu:menu];
	[UIView animateWithDuration:self.duration delay:0.0 options:self.options animations:^{
		[self animateItem:item atIndex:index inMenu:menu];
	} completion:^(BOOL finished){
		[self didAnimateItem:item atIndex:index inMenu:menu finished:finished];
		if (completion) {
			completion(item, index, menu, finished);
		}
	}];
}

@end
