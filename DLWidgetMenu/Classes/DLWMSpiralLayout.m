//
//  DLWMSpiralLayout.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMSpiralLayout.h"

#import "DLWMMenuItem.h"

@interface DLWMSpiralLayout ()

@property (readwrite, assign, nonatomic) CGFloat arc;

@end

@implementation DLWMSpiralLayout

- (id)init {
	return [self initWithAngle:[[self class] defaultAngle] radius:[[self class] defaultRadius] itemDistance:[[self class] defaultItemDistance]];
}

- (id)initWithAngle:(CGFloat)angle radius:(CGFloat)radius itemDistance:(CGFloat)itemDistance {
	self = [super init];
	if (self) {
		self.radius = radius;
		self.angle = angle;
		self.clockwise = YES;
		self.itemDistance = itemDistance;
	}
	return self;
}

+ (CGFloat)defaultAngle {
	return - M_PI_2;
}

+ (CGFloat)defaultRadius {
	return 30.0;
}

+ (CGFloat)defaultItemDistance {
	return 20.0;
}

- (void)layoutItems:(NSArray *)items forCenterPoint:(CGPoint)centerPoint inMenu:(DLWMMenu *)menu {
	BOOL clockwise = self.clockwise;
	CGFloat itemDistance = self.itemDistance;
	
	CGFloat scale = itemDistance;
	
	CGFloat angle = self.angle;
	CGFloat radius = self.radius / scale;
	
    CGFloat angleScale = 2.0;
    CGFloat radiusScale = 1.5;
    
	__block CGFloat angleSum = 0.0;
	__block CGFloat radiusSum = 0.0;
	
	NSUInteger indexOffset = 0;
	while (radiusSum < radius) {
		radiusSum += sqrt(indexOffset + 2) - sqrt(indexOffset + 1);
		indexOffset++;
	}
	
	__block CGFloat squareRootOfCurrentIndex = sqrt(indexOffset + 1);
	__block CGFloat squareRootOfNextIndex = sqrt(indexOffset + 2);
	
	[items enumerateObjectsUsingBlock:^(DLWMMenuItem *item, NSUInteger index, BOOL *stop) {
		if (index) {
			CGFloat angleDelta = atan(1.0 / squareRootOfCurrentIndex);
			angleSum += (clockwise) ? angleDelta : -angleDelta;
			
			CGFloat radiusDelta = squareRootOfNextIndex - squareRootOfCurrentIndex;
			radiusSum += radiusDelta;
			
			squareRootOfCurrentIndex = squareRootOfNextIndex;
			squareRootOfNextIndex = sqrt(indexOffset + index + 2.0);
		}
		CGFloat itemAngle = ((clockwise) ? angleSum : -angleSum);
		CGFloat itemRadius = radiusSum;
		itemAngle *= angleScale;
		itemRadius *= radiusScale;
		CGPoint unitItemCenter = CGPointMake(cos(angle + itemAngle) * itemRadius,
											 sin(angle + itemAngle) * itemRadius);
		CGPoint itemCenter = CGPointApplyAffineTransform(unitItemCenter, CGAffineTransformMakeScale(scale, scale));
		itemCenter = CGPointApplyAffineTransform(itemCenter, CGAffineTransformMakeTranslation(centerPoint.x, centerPoint.y));
		item.layoutLocation = itemCenter;
	}];
}

- (void)setRadius:(CGFloat)radius {
	_radius = radius;
	[self announceChange];
}

- (void)setItemDistance:(CGFloat)itemDistance {
	_itemDistance = itemDistance;
	[self announceChange];
}

- (void)setAngle:(CGFloat)angle {
	_angle = fmod(angle, DLWMFullCircle);
	[self announceChange];
}

- (void)setClockwise:(BOOL)clockwise {
	_clockwise = clockwise;
	[self announceChange];
}

- (void)announceChange {
	[[NSNotificationCenter defaultCenter] postNotificationName:DLWMMenuLayoutChangedNotification object:self];
}

@end
