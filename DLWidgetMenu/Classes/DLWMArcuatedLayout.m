//
//  DLWMArcuatedLayout.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMArcuatedLayout.h"

#import "DLWMMenuItem.h"

@interface DLWMCircularLayout ()

- (id)initWithAngle:(CGFloat)angle arc:(CGFloat)arc;

+ (CGFloat)angleForItemAtIndex:(NSUInteger)itemIndex ofCount:(NSUInteger)itemCount inArc:(CGFloat)arc startintAtAngle:(CGFloat)angle;

@end

@implementation DLWMArcuatedLayout

- (id)init {
	return [self initWithAngle:[[self class] defaultAngle] arc:[[self class] defaultArc]];
}

- (id)initWithAngle:(CGFloat)angle arc:(CGFloat)arc {
	return [self initWithAngle:angle arc:arc radiusLogic:[[self class] defaultRadiusLogic]];
}

- (id)initWithAngle:(CGFloat)angle arc:(CGFloat)arc radius:(CGFloat)radius {
	return [self initWithAngle:angle arc:arc radiusLogic:^(DLWMMenu *menu, CGFloat arc) {
		return radius;
	}];
}

- (id)initWithAngle:(CGFloat)angle arc:(CGFloat)arc radiusLogic:(DLWMLayoutRadiusLogic)radiusLogic {
	self = [super initWithAngle:angle radiusLogic:radiusLogic];
	if (self) {
		self.arc = arc;
	}
	return self;
}

+ (CGFloat)defaultAngle {
	return 0.0;
}

+ (CGFloat)defaultArc {
	return M_PI_2;
}

+ (CGFloat)angleForItemAtIndex:(NSUInteger)itemIndex ofCount:(NSUInteger)itemCount inArc:(CGFloat)arc startintAtAngle:(CGFloat)angle {
	return [super angleForItemAtIndex:itemIndex ofCount:(itemCount - 1) inArc:arc startintAtAngle:angle];
}

@end
