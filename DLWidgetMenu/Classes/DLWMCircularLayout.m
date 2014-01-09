//
//  DLWMCircularLayout.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMCircularLayout.h"

#import "DLWMMenuItem.h"

#define DLWMRadiansToDegrees(radians) ((CGFloat)radians * (180.0 / M_PI))
#define DLWMDegreesToRadians(degrees) ((CGFloat)degrees / (180.0 / M_PI))

@interface DLWMCircularLayout ()

@property (readwrite, assign, nonatomic) CGFloat arc;

@end

@implementation DLWMCircularLayout

- (id)init {
	return [self initWithAngle:[[self class] defaultAngle]];
}

- (id)initWithAngle:(CGFloat)angle {
	return [self initWithAngle:angle radiusLogic:[[self class] defaultRadiusLogic]];
}

- (id)initWithAngle:(CGFloat)angle radius:(CGFloat)radius {
	return [self initWithAngle:angle radiusLogic:^(DLWMMenu *menu, CGFloat arc) {
		return radius;
	}];
}

- (id)initWithAngle:(CGFloat)angle radiusLogic:(DLWMLayoutRadiusLogic)radiusLogic {
	self = [super init];
	if (self) {
		self.angle = angle;
		self.arc = [[self class] defaultArc];
		self.radiusLogic = radiusLogic;
	}
	return self;
}

+ (CGFloat)defaultAngle {
	return 0.0;
}

+ (CGFloat)defaultArc {
	return M_PI * 2;
}

+ (DLWMLayoutRadiusLogic)defaultRadiusLogic {
	return ^(DLWMMenu *menu, CGFloat arc) {
		CGSize mainSize = menu.mainItem.bounds.size;
		CGSize itemSize = ((DLWMMenuItem *)menu.items.firstObject).bounds.size;
		CGFloat mainRadius = sqrt(pow(mainSize.width, 2) + pow(mainSize.height, 2)) / 2;
		CGFloat itemRadius = sqrt(pow(itemSize.width, 2) + pow(itemSize.height, 2)) / 2;
		
		CGFloat minRadius = (CGFloat)(mainRadius + itemRadius);
		CGFloat maxRadius = ((itemRadius * menu.items.count) / arc) * 1.5;
		
		return MAX(minRadius, maxRadius);
	};
}

- (void)layoutItems:(NSArray *)items forCenterPoint:(CGPoint)centerPoint inMenu:(DLWMMenu *)menu {
	CGFloat arc = self.arc;
	CGFloat angle = self.angle;
	CGFloat radius = [self radiusForMenu:menu withArc:arc];
	[self layoutItems:items inArc:arc fromAngle:(angle - M_PI_2) radius:radius centerPoint:centerPoint inMenu:menu];
}

- (CGFloat)radiusForMenu:(DLWMMenu *)menu withArc:(CGFloat)arc {
	DLWMLayoutRadiusLogic radiusLogic = self.radiusLogic;
	if (!radiusLogic) {
		radiusLogic = [[self class] defaultRadiusLogic];
	}
	return radiusLogic(menu, arc);
}

- (void)layoutItems:(NSArray *)items inArc:(CGFloat)arc fromAngle:(CGFloat)angle radius:(CGFloat)radius centerPoint:(CGPoint)centerPoint inMenu:(DLWMMenu *)menu {
	NSUInteger count = menu.items.count;
	[items enumerateObjectsUsingBlock:^(DLWMMenuItem *item, NSUInteger index, BOOL *stop) {
		[[self class] layoutItem:item atIndex:index ofCount:count relativeToAngle:angle inArc:arc radius:radius centerPoint:centerPoint inMenu:menu];
	}];
}

+ (void)layoutItem:(DLWMMenuItem *)item atIndex:(NSUInteger)itemIndex ofCount:(NSUInteger)itemCount relativeToAngle:(CGFloat)angle inArc:(CGFloat)arc radius:(CGFloat)radius centerPoint:(CGPoint)centerPoint inMenu:(DLWMMenu *)menu {
	CGFloat itemAngle = [self angleForItemAtIndex:itemIndex ofCount:itemCount inArc:arc startintAtAngle:angle];
	CGPoint itemCenter = CGPointMake(centerPoint.x + cosf(itemAngle) * radius,
									 centerPoint.y + sinf(itemAngle) * radius);
	item.layoutLocation = itemCenter;
}

+ (CGFloat)angleForItemAtIndex:(NSUInteger)itemIndex ofCount:(NSUInteger)itemCount inArc:(CGFloat)arc startintAtAngle:(CGFloat)angle {
	return angle + ((CGFloat)itemIndex * (arc / itemCount));
}

@end
