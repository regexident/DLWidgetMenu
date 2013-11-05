//
//  DLWMCircularLayout.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMCircularLayout.h"

#import "DLWMMenuItem.h"

typedef NS_OPTIONS(NSUInteger, DLWMClipEdge) {
	DLWMClipEdgeMinX = (0x1 << 0),
	DLWMClipEdgeMinY = (0x1 << 1),
	DLWMClipEdgeMaxX = (0x1 << 2),
	DLWMClipEdgeMaxY = (0x1 << 3)
};

@interface DLWMCircularLayout ()

@end

@implementation DLWMCircularLayout

+ (DLWMCircularLayoutRadiusLogic)defaultRadiusLogic {
	return ^(DLWMMenu *menu) {
		CGSize mainSize = menu.mainItem.bounds.size;
		CGSize itemSize = ((DLWMMenuItem *)menu.items.firstObject).bounds.size;
		CGFloat mainRadius = sqrt(pow(mainSize.width, 2) + pow(mainSize.height, 2)) / 2;
		CGFloat itemRadius = sqrt(pow(itemSize.width, 2) + pow(itemSize.height, 2)) / 2;
		
		CGFloat minRadius = (CGFloat)(mainRadius + itemRadius);
		CGFloat maxRadius = ((itemRadius * ((CGFloat)menu.items.count * 1.75)) / (M_PI * 2));
		
		return MAX(minRadius, maxRadius);
	};
}

- (void)layoutItems:(NSArray *)items forCenterPoint:(CGPoint)centerPoint inMenu:(DLWMMenu *)menu {
	
	DLWMCircularLayoutRadiusLogic radiusLogic = self.radiusLogic;
	if (!radiusLogic) {
		radiusLogic = [[self class] defaultRadiusLogic];
	}
	
	CGFloat radius = radiusLogic(menu);
	
	NSUInteger count = items.count;
	
	CGFloat arc = M_PI * 2;
	CGFloat angle = - (M_PI / 2);
	[items enumerateObjectsUsingBlock:^(DLWMMenuItem *item, NSUInteger index, BOOL *stop) {
		CGFloat itemAngle = [[self class] angleForLocation:((CGFloat)index / count) inArc:arc startintAt:angle];
		CGPoint itemCenter = CGPointMake(centerPoint.x + cosf(itemAngle) * radius,
										 centerPoint.y + sinf(itemAngle) * radius);
		item.layoutLocation = itemCenter;
	}];
}

+ (CGFloat)angleForLocation:(CGFloat)location inArc:(CGFloat)arc startintAt:(CGFloat)angle {
	return angle + (arc * location);
}

@end
