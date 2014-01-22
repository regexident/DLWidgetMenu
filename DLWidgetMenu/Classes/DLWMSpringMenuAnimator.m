//
//  DLWMSpringMenuAnimator.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMSpringMenuAnimator.h"

@interface DLWMMenuAnimator ()

- (void)willAnimateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu;
- (void)animateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu;
- (void)didAnimateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu finished:(BOOL)finished;

@end

@implementation DLWMSpringMenuAnimator

- (id)init {
	self = [super init];
	if (self) {
		self.duration = 0.5;
		self.damping = 0.45;
		self.velocity = 7.5;
	}
	return self;
}

- (id)initWithDamping:(CGFloat)damping velocity:(CGFloat)velocity {
	self = [self init];
	if (self) {
		self.damping = damping;
		self.velocity = velocity;
	}
	return self;
}

- (id)initWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options damping:(CGFloat)damping velocity:(CGFloat)velocity {
	self = [super initWithDuration:duration options:options];
	if (self) {
		self.damping = damping;
		self.velocity = velocity;
	}
	return self;
}

- (void)animateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu animated:(BOOL)animated completion:(DLWMMenuAnimatorCompletionBlock)completion {
	[self willAnimateItem:item atIndex:index inMenu:menu];
	[UIView animateWithDuration:self.duration
						  delay:0.0
		 usingSpringWithDamping:self.damping
		  initialSpringVelocity:self.velocity
						options:self.options
					 animations:^{
						 [self animateItem:item atIndex:index inMenu:menu];
					 }
					 completion:^(BOOL finished){
						 [self didAnimateItem:item atIndex:index inMenu:menu finished:finished];
						 if (completion) {
							 completion(item, index, menu, finished);
						 }
					 }];
}

@end
