//
//  DLWMArcuatedLayout.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMArcuatedLayout.h"

#import "DLWMMenuItem.h"

@implementation DLWMArcuatedLayout

- (id)init {
	return [self initWithAngle:[[self class] defaultAngle]
						   arc:[[self class] defaultArc]];
}

- (id)initWithAngle:(CGFloat)angle arc:(CGFloat)arc {
	self = [super init];
	if (self) {
		self.angle = angle;
		self.arc = arc;
	}
	return self;
}

+ (CGFloat)defaultAngle {
	return 0.0;
}

+ (CGFloat)defaultArc {
	return M_PI * 2;
}

+ (DLWMArcuatedLayoutRadiusLogic)defaultRadiusLogic {
	return ^(CGFloat arc, DLWMMenu *menu) {
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
	[items enumerateObjectsUsingBlock:^(DLWMMenuItem *item, NSUInteger index, BOOL *stop) {
		[self layoutItem:item atIndex:index forCenterPoint:centerPoint inMenu:menu];
	}];
}

- (void)layoutItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index forCenterPoint:(CGPoint)centerPoint inMenu:(DLWMMenu *)menu {
	DLWMArcuatedLayoutRadiusLogic radiusLogic = self.radiusLogic;
	if (!radiusLogic) {
		radiusLogic = [[self class] defaultRadiusLogic];
	}
	
	CGFloat arc = self.arc;
	CGFloat angle = self.angle - M_PI / 2;
	
	CGFloat radius = radiusLogic(arc, menu);
	
	NSUInteger count = menu.items.count;
	CGFloat fullCircle = M_PI * 2;
	BOOL isFullCircle = (arc == fullCircle);
	NSUInteger divisor = (isFullCircle) ? count : count - 1;
	
	CGFloat itemAngle = angle + (index * (arc / divisor));
	
	CGPoint itemCenter = CGPointMake(centerPoint.x + cosf(itemAngle) * radius,
									 centerPoint.y + sinf(itemAngle) * radius);
	item.layoutLocation = itemCenter;
}

@end
