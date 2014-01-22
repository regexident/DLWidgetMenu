//
//  DLWMParticleLayout.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Definite Loop. All rights reserved.
//

#import "DLWMParticleLayout.h"

#import "DLWMMenuItem.h"

#define DLWMRectGetCenter(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
#define DLWMVectorAdd(vectorA, vectorB) CGPointMake(vectorA.x + vectorB.x, vectorA.y + vectorB.y)
#define DLWMVectorMultiply(vector, factor) CGPointMake(vector.x * factor, vector.y * factor)
#define DLWMVectorReverse(vector) CGPointMake(-vector.x, -vector.y)
#define DLWMVectorGetDotProduct(vectorA, vectorB) ((vectorA.x * vectorB.x) + (vectorA.y * vectorB.y))
#define DLWMVectorGetMagnitude(vector) sqrt(DLWMVectorGetDotProduct(vector, vector))
#define DLWMVectorGetDistanceSquared(vectorA, vectorB) ({CGPoint __delta = DLWMVectorSubtract(vectorA, vectorB); DLWMVectorGetDotProduct(__delta, __delta)})
#define DLWMVectorGetDistance(vectorA, vectorB) sqrt(DLWMVectorGetDistanceSquared(DLWMVectorSubtract(vectorA, vectorB)))
#define DLWMVectorSetMagnitude(vector, magnitude) DLWMVectorMultiply(vector, magnitude / (DLWMVectorGetMagnitude(vector) ?: 1.0))

typedef enum {
	DLWMRectCornerLeftBottom = 0,
	DLWMRectCornerLeftTop = 1,
	DLWMRectCornerRightTop = 2,
	DLWMRectCornerRightBottom = 3
} DLWMRectCorner;

BOOL DLWMRoundedRectIntersectsRoundedRect(CGRect rectA, CGFloat cornerRadiusA, CGRect rectB, CGFloat cornerRadiusB);
CGPoint DLWMRoundedRectGetCenterPointOfCornerWithRect(DLWMRectCorner corner, CGRect rect);
void DLWMRoundedRectGetCornerRectsForCornerRadius(CGRect *cornerRects, CGRect rect, CGFloat cornerRadius);

@interface DLWMMenuItemParticle : NSObject {
@public
	DLWMMenuItem *item;
	CGRect frame;
	CGFloat cornerRadius;
	CGPoint velocity;
	BOOL fixed;
}
@end

@implementation DLWMMenuItemParticle

@end

@interface DLWMParticleLayout ()

@end

@implementation DLWMParticleLayout

+ (DLWMParticleLayoutRadiusLogic)defaultRadiusLogic {
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

+ (DLWMParticleLayoutItemCornerRadiusLogic)defaultItemCornerRadiusLogic {
	return ^(DLWMMenuItem *item) {
		return item.layer.cornerRadius;
	};
}

- (void)layoutItems:(NSArray *)items forCenterPoint:(CGPoint)centerPoint inMenu:(DLWMMenu *)menu {
	NSUInteger count = items.count;
	
	if (!count) {
		return;
	}
	
	DLWMParticleLayoutRadiusLogic radiusLogic = self.radiusLogic;
	if (!radiusLogic) {
		radiusLogic = [[self class] defaultRadiusLogic];
	}
	
	CGFloat radius = radiusLogic(menu);
	
	items = [items copy];
	
	__block NSMutableArray *particles = [NSMutableArray array];
	[items enumerateObjectsUsingBlock:^(DLWMMenuItem *item, NSUInteger index, BOOL *stop) {
		DLWMMenuItemParticle *particle = [[DLWMMenuItemParticle alloc] init];
		particle->item = item;
		CGPoint particlePoint = item.layoutLocation;
		if (CGPointEqualToPoint(particlePoint, CGPointZero)) {
			CGFloat itemAngle = (M_PI * 2 * ((CGFloat)index / count));
			particlePoint = CGPointMake(centerPoint.x + cosf(itemAngle) * radius, centerPoint.y + sinf(itemAngle) * radius);
		}
		CGSize particleSize = item.frame.size;
		particle->frame = CGRectMake(particlePoint.x - (particleSize.width / 2),
									 particlePoint.y - (particleSize.height / 2),
									 particleSize.width,
									 particleSize.height);
		particle->cornerRadius = item.layer.cornerRadius;
		[particles addObject:particle];
	}];
	
	DLWMMenuItemParticle *radiusParticle = [[DLWMMenuItemParticle alloc] init];
	radiusParticle->frame = CGRectMake(centerPoint.x - radius, centerPoint.y - radius, radius * 2, radius * 2);
	radiusParticle->cornerRadius = radius;
	radiusParticle->fixed = YES;
	
	NSUInteger stepCount = 0;
	
	CGFloat dampingFactor = 0.9;
	__block CGFloat energy = CGFLOAT_MAX;
	CGFloat energyThreshold = 1.0;
	
	BOOL foundCollisions = YES;
	
//	while (energy >= energyThreshold) {
	while (foundCollisions) {
		// Reset energy:
		energy = 0.0;
		
		// Apply gravity:
		for (DLWMMenuItemParticle *particle in particles) {
			CGRect particleRect = particle->frame;
			CGPoint particleCenterPoint = DLWMRectGetCenter(particleRect);
			CGPoint delta = DLWMVectorAdd(centerPoint, DLWMVectorReverse(particleCenterPoint));
			CGPoint gravity = DLWMVectorMultiply(delta, 0.25);
			particle->velocity = gravity;
		}
		
		// Resolve collisions:
		@autoreleasepool {
			foundCollisions = NO;
			for (DLWMMenuItemParticle *particleA in particles) {
				for (DLWMMenuItemParticle *particleB in particles) {
					foundCollisions |= [self resolveCollisionBetween:particleA and:particleB];
				}
				foundCollisions |= [self resolveCollisionBetween:particleA and:radiusParticle];
			}
		}
		
		// Move particles:
		[particles enumerateObjectsUsingBlock:^(DLWMMenuItemParticle *particle, NSUInteger index, BOOL *stop) {
			if (!particle->fixed) {
				particle->velocity = DLWMVectorMultiply(particle->velocity, dampingFactor);
				particle->frame = CGRectApplyAffineTransform(particle->frame, CGAffineTransformMakeTranslation(particle->velocity.x, particle->velocity.y));
				energy += sqrt((particle->velocity.x * particle->velocity.x) + (particle->velocity.y * particle->velocity.y)) / count;
			}
		}];
		printf("energy after step %lu: %.2f\n", (unsigned long)stepCount + 1, energy);
		stepCount++;
		foundCollisions = NO;
	}
	
	[particles enumerateObjectsUsingBlock:^(DLWMMenuItemParticle *particle, NSUInteger index, BOOL *stop) {
		CGPoint oldLocation = particle->item.layoutLocation;
		CGPoint newLocation = DLWMRectGetCenter(particle->frame);
//		NSLog(@"Moving item %lu from %@ to %@", (unsigned long)index, NSStringFromCGPoint(oldLocation), NSStringFromCGPoint(newLocation));
		particle->item.layoutLocation = newLocation;
	}];
}

- (BOOL)resolveCollisionBetween:(DLWMMenuItemParticle *)particleA and:(DLWMMenuItemParticle *)particleB {
	if (particleA == particleB) {
		return NO;
	}
	
	if (!DLWMRoundedRectIntersectsRoundedRect(particleA->frame, particleA->cornerRadius, particleB->frame, particleB->cornerRadius)) {
		return NO;
	}
	
	CGRect rectA = particleA->frame;
	CGRect rectB = particleB->frame;
	
	CGFloat radiusA = MAX(rectA.size.width, rectA.size.height) / 2;
	CGFloat radiusB = MAX(rectB.size.width, rectB.size.height) / 2;
	
	CGFloat minDistance = radiusA - radiusB;
	
	CGPoint pointA = CGPointMake(CGRectGetMidX(rectA), CGRectGetMidY(rectA));
	CGPoint pointB = CGPointMake(CGRectGetMidX(rectB), CGRectGetMidY(rectB));
	
	CGPoint velocityA = particleA->velocity;
	CGPoint velocityB = particleB->velocity;
	
	CGPoint collision = CGPointMake(pointA.x - pointB.x, pointA.y - pointB.y);
	if (collision.x == 0.0 && collision.y == 0.0) {
		collision.x = rectA.size.width + rectB.size.width;
		collision.y = rectA.size.height + rectB.size.height;
		
		velocityA.x = rectB.size.width;
		velocityA.y = rectB.size.height;
		
		velocityB.x = -rectA.size.width;
		velocityB.y = -rectA.size.height;
	}
	CGFloat distanceSquared = (collision.x * collision.x) + (collision.y * collision.y);
	CGFloat distance = sqrt(distanceSquared);
	
	// Get the components of the velocity vectors which are parallel to the collision.
	// The perpendicular component remains the same for both fish
	collision = CGPointMake(collision.x / distance, collision.y / distance);
	CGFloat aci = (velocityA.x * collision.x) + (velocityA.y * collision.y);
	CGFloat bci = (velocityB.x * collision.x) + (velocityB.y * collision.y);
	
	// Solve for the new velocities using the 1-dimensional elastic collision equations.
	// Turns out it's really simple when the masses are the same.
	CGFloat acf = bci;
	CGFloat bcf = aci;
	
	// Replace the collision velocity components with the new ones
	if (particleA->fixed) {
		particleA->velocity = CGPointZero;
	} else {
		velocityA.x += (acf - aci) * collision.x;
		velocityA.y += (acf - aci) * collision.y;
		
		CGFloat magnitude = MIN(DLWMVectorGetMagnitude(velocityB), MAX(distance, minDistance));
		velocityA = DLWMVectorSetMagnitude(velocityA, magnitude);
		
		particleA->velocity = velocityA;
	}
	if (particleB->fixed) {
		particleB->velocity = CGPointZero;
	} else {
		velocityB.x += (bcf - bci) * collision.x;
		velocityB.y += (bcf - bci) * collision.y;
		
		CGFloat magnitude = MIN(DLWMVectorGetMagnitude(velocityB), MAX(distance, minDistance));
		velocityB = DLWMVectorSetMagnitude(velocityB, magnitude);
		
		particleB->velocity = velocityB;
	}
	return YES;
}

@end

BOOL DLWMRoundedRectIntersectsRoundedRect(CGRect rectA, CGFloat cornerRadiusA, CGRect rectB, CGFloat cornerRadiusB) {
	// If the bounding rects don't intersect, then neither will the potentially rounded rects:
	if (!CGRectIntersectsRect(rectA, rectB)) {
		return NO;
	}
	
	// If we have no rounded corners, then we found a collision:
	if (cornerRadiusA == 0.0 && cornerRadiusB == 0.0) {
		return YES;
	}
	
	// Split up the rounded rect into two sub rects covering everything but the rounded corners:
	CGRect horizontalRectA = CGRectInset(rectA, 0.0, cornerRadiusA);
	CGRect verticalRectA = CGRectInset(rectA, cornerRadiusA, 0.0);
	
	CGRect horizontalRectB = CGRectInset(rectB, 0.0, cornerRadiusB);
	CGRect verticalRectB = CGRectInset(rectB, cornerRadiusB, 0.0);
	
	// If any of these subrects intersect, then we found a collision:
	if (CGRectIntersectsRect(horizontalRectA, horizontalRectB)) {
		return YES;
	} else if (CGRectIntersectsRect(horizontalRectA, verticalRectB)) {
		return YES;
	} else if (CGRectIntersectsRect(verticalRectA, verticalRectB)) {
		return YES;
	} else if (CGRectIntersectsRect(verticalRectA, horizontalRectB)) {
		return YES;
	}
	
	// Now the only possible intersection could take place at one of the corners:
	CGRect cornerRectsA[4];
	CGRect cornerRectsB[4];
	DLWMRoundedRectGetCornerRectsForCornerRadius(cornerRectsA, rectA, cornerRadiusA);
	DLWMRoundedRectGetCornerRectsForCornerRadius(cornerRectsB, rectB, cornerRadiusB);
	
	// Find the pair of intersecting corner rects:
	DLWMRectCorner cornerA;
	DLWMRectCorner cornerB;
	if (CGRectIntersectsRect(cornerRectsA[DLWMRectCornerLeftBottom], cornerRectsB[DLWMRectCornerRightTop])) {
		cornerA = DLWMRectCornerLeftBottom;
		cornerB = DLWMRectCornerRightTop;
	} else if (CGRectIntersectsRect(cornerRectsA[DLWMRectCornerLeftTop], cornerRectsB[DLWMRectCornerRightBottom])) {
		cornerA = DLWMRectCornerLeftTop;
		cornerB = DLWMRectCornerRightBottom;
	} else if (CGRectIntersectsRect(cornerRectsA[DLWMRectCornerRightTop], cornerRectsB[DLWMRectCornerLeftBottom])) {
		cornerA = DLWMRectCornerRightTop;
		cornerB = DLWMRectCornerLeftBottom;
	} else if (CGRectIntersectsRect(cornerRectsA[DLWMRectCornerRightBottom], cornerRectsB[DLWMRectCornerLeftTop])) {
		cornerA = DLWMRectCornerRightBottom;
		cornerB = DLWMRectCornerLeftTop;
	} else {
		[NSException raise:@"This should not be possible." format:@""];
	}
	
	// Calculate circle center points for rounded corners:
	CGPoint pointA = DLWMRoundedRectGetCenterPointOfCornerWithRect(cornerA, cornerRectsA[cornerA]);
	CGPoint pointB = DLWMRoundedRectGetCenterPointOfCornerWithRect(cornerB, cornerRectsB[cornerB]);
	
	// Check if corner circles intersect:
	CGPoint delta = CGPointMake(pointA.x - pointB.x, pointA.y - pointB.y);
	CGFloat distanceSquared = (delta.x * delta.x) + (delta.y * delta.y);
	
	CGFloat radii = cornerRadiusA + cornerRadiusB;
	CGFloat radiiSquared = radii * radii;
	return distanceSquared <= radiiSquared;
}

void DLWMRoundedRectGetCornerRectsForCornerRadius(CGRect *cornerRects, CGRect rect, CGFloat cornerRadius) {
	NSCAssert(cornerRects, @"Method argument 'cornerRects' must not be NULL.");
	cornerRects[DLWMRectCornerLeftBottom] = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), cornerRadius, cornerRadius);
	cornerRects[DLWMRectCornerLeftTop] = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - cornerRadius, cornerRadius, cornerRadius);
	cornerRects[DLWMRectCornerRightTop] = CGRectMake(CGRectGetMaxX(rect) - cornerRadius, CGRectGetMaxY(rect) - cornerRadius, cornerRadius, cornerRadius);
	cornerRects[DLWMRectCornerRightBottom] = CGRectMake(CGRectGetMaxX(rect) - cornerRadius, CGRectGetMinY(rect), cornerRadius, cornerRadius);
}

CGPoint DLWMRoundedRectGetCenterPointOfCornerWithRect(DLWMRectCorner corner, CGRect rect) {
	CGPoint centerPoint;
	switch (corner) {
		case DLWMRectCornerLeftBottom: {
			centerPoint =CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
		}
		case DLWMRectCornerLeftTop: {
			centerPoint =CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
		}
		case DLWMRectCornerRightTop: {
			centerPoint =CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
		}
		case DLWMRectCornerRightBottom: {
			centerPoint =CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
		}
		default: {
			centerPoint =CGPointZero;
		}
	}
	return centerPoint;
}