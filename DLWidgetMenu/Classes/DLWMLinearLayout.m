//
//  DLWMLinearLayout.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMLinearLayout.h"

#import "DLWMMenuItem.h"

@implementation DLWMLinearLayout

- (id)init {
	self = [super init];
	if (self) {
		self.angle = 0.0;
		self.itemSpacing = 40.0;
		self.centerSpacing = 40.0;
	}
	return self;
}

- (id)initWithAngle:(CGFloat)angle itemSpacing:(CGFloat)itemSpacing centerSpacing:(CGFloat)centerSpacing {
	self = [self init];
	if (self) {
		self.angle = angle;
		self.itemSpacing = itemSpacing;
		self.centerSpacing = centerSpacing;
	}
	return self;
}

- (void)layoutItems:(NSArray *)items forCenterPoint:(CGPoint)centerPoint inMenu:(DLWMMenu *)menu {
	CGFloat centerSpacing = self.centerSpacing;
	CGFloat itemSpacing = self.itemSpacing;
	CGFloat angle = self.angle;
	
	[items enumerateObjectsUsingBlock:^(DLWMMenuItem *item, NSUInteger index, BOOL *stop) {
		CGFloat offset = centerSpacing + itemSpacing * index;
		CGFloat x = centerPoint.x + (offset * cosf(angle));
		CGFloat y = centerPoint.y + (offset * sinf(angle));
		CGPoint itemCenter = CGPointMake(x, y);
		item.layoutLocation = itemCenter;
	}];
}

- (void)setAngle:(CGFloat)angle {
	_angle = angle;
	[self announceChange];
}

- (void)setItemSpacing:(CGFloat)itemSpacing {
	_itemSpacing = itemSpacing;
	[self announceChange];
}

- (void)setCenterSpacing:(CGFloat)centerSpacing {
	_centerSpacing = centerSpacing;
	[self announceChange];
}

- (void)announceChange {
	[[NSNotificationCenter defaultCenter] postNotificationName:DLWMMenuLayoutChangedNotification object:self];
}

@end
