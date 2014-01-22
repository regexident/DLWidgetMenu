//
//  DLWMSmartCircularLayout.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMSmartCircularLayout.h"

#import "DLWMMenuItem.h"

typedef NS_OPTIONS(NSUInteger, DLWMClipEdge) {
	DLWMClipEdgeMinX = (0x1 << 0),
	DLWMClipEdgeMinY = (0x1 << 1),
	DLWMClipEdgeMaxX = (0x1 << 2),
	DLWMClipEdgeMaxY = (0x1 << 3)
};

static CGFloat DLWMDistanceToEdgeOfEnclosingRect(CGPoint point, CGRect rect, CGRectEdge edge);
static CGFloat DLWMAngleFromDistanceToEdgeAndRadius(CGFloat distance, CGFloat radius);
static CGFloat DLWMAngleForSplitEdges(DLWMClipEdge clippedEdges);
static CGFloat DLWMAngleForItemAtIndex(CGFloat angle, CGFloat arc, NSUInteger index, NSUInteger count, DLWMClipEdge clippedEdges);

@interface DLWMSmartCircularLayout ()

@end

@implementation DLWMSmartCircularLayout

+ (DLWMClipEdge)getAngle:(CGFloat *)angle arc:(CGFloat *)arc forMenuWithRadius:(CGFloat)radius centeredAt:(CGPoint)centerPoint inRect:(CGRect)rect {
	NSAssert(angle, @"Method argument 'angle' must not be NULL");
	NSAssert(arc, @"Method argument 'arc' must not be NULL");
	
	CGFloat fullCircle = M_PI * 2;
	CGFloat halfCircle = M_PI;
	CGFloat quaterCircle = M_PI / 2;
	
	*angle = 0.0;
	*arc = fullCircle;
	
	CGRectEdge edges[4] = {CGRectMinYEdge, CGRectMaxXEdge, CGRectMaxYEdge, CGRectMinXEdge};
	
	DLWMClipEdge clippedEdges = 0;
	for (NSUInteger i = 0; i < 4; i++) {
		CGRectEdge edgeA = edges[i];
		CGFloat distanceA = DLWMDistanceToEdgeOfEnclosingRect(centerPoint, rect, edgeA);
		BOOL outOfRectA = distanceA < 0.0;
		if (outOfRectA) {
			distanceA = -distanceA;
		}
		if (distanceA <= radius) {
			clippedEdges |= 0x1 << edgeA;
			CGFloat angleA = DLWMAngleFromDistanceToEdgeAndRadius(distanceA, radius);
			if (outOfRectA) {
				angleA = halfCircle - angleA;
			}
			CGRectEdge edgeB = edges[(i + 1) % 4];
			CGFloat distanceB = DLWMDistanceToEdgeOfEnclosingRect(centerPoint, rect, edgeB);
			BOOL outOfRectB = distanceB < 0.0;
			if (outOfRectB) {
				distanceB = -distanceB;
			}
			if (distanceB <= radius) {
				clippedEdges |= 0x1 << edgeB;
				CGFloat angleB = DLWMAngleFromDistanceToEdgeAndRadius(distanceB, radius);
				if (outOfRectB) {
					angleB = halfCircle - angleB;
				}
				*angle = ((i + 1) * quaterCircle) + angleB;
				*arc = fullCircle - (angleA + quaterCircle + angleB);
				break;
			} else {
				*angle = (i * quaterCircle) + angleA;
				*arc = fullCircle - (2 * angleA);
			}
		}
	}
	
	return clippedEdges;
}

- (BOOL)requiresSmartLayoutForRadius:(CGFloat)radius forCenterPoint:(CGPoint)centerPoint inMenu:(DLWMMenu *)menu {
	CGSize itemSize = ((DLWMMenuItem *)menu.items.firstObject).bounds.size;
	CGFloat itemRadius = (itemSize.width + itemSize.height) / 4;
	CGRect layoutRect = CGRectMake(centerPoint.x - radius - itemRadius,
								   centerPoint.y - radius - itemRadius,
								   (radius * 2) + (itemRadius * 2),
								   (radius * 2) + (itemRadius * 2));
	
	CGRect boundingRect = menu.bounds;
	return !CGRectContainsRect(boundingRect, layoutRect);
}

- (void)layoutItems:(NSArray *)items forCenterPoint:(CGPoint)centerPoint inMenu:(DLWMMenu *)menu {
	DLWMCircularLayoutRadiusLogic radiusLogic = self.radiusLogic;
	if (!radiusLogic) {
		radiusLogic = [[self class] defaultRadiusLogic];
	}
	
	CGFloat radius = radiusLogic(menu);
	
	CGSize itemSize = ((DLWMMenuItem *)items.firstObject).bounds.size;
	CGFloat itemRadius = (itemSize.width + itemSize.height) / 4;

	if (![self requiresSmartLayoutForRadius:radius forCenterPoint:centerPoint inMenu:menu]) {
		[super layoutItems:items forCenterPoint:centerPoint inMenu:menu];
		return;
	}
	
	CGFloat fullCircle = M_PI * 2;
	
	CGFloat angle = 0.0;
	CGFloat arc = fullCircle;
	
	NSUInteger itemCount = items.count;
	
	DLWMClipEdge clippedEdges = 0;
	
	CGFloat margin = itemRadius;
	CGRect rect = rect = CGRectInset(menu.bounds, margin, margin);
	
	CGFloat adjustedRadius = radius;
	
	CGFloat itemArc = fullCircle / itemCount;
	
	CGFloat requiredCircumfence = ((fullCircle / itemCount) * (itemCount - 1)) * radius;
	CGFloat lowerBound = CGFLOAT_MIN;
	CGFloat upperBound = CGFLOAT_MAX;
	CGFloat epsilon = 2.0;
	BOOL firstSeek = YES;
	
	// Use binary search for finding optimal radius:
	do {
		clippedEdges = [[self class] getAngle:&angle
										  arc:&arc
							forMenuWithRadius:adjustedRadius
								   centeredAt:centerPoint
									   inRect:rect];
		
		// prevent overlapping:
		if (clippedEdges && arc > itemArc * (itemCount - 1)) {
			CGFloat oldArc = arc;
			arc = itemArc * (itemCount - 1);
			angle += (oldArc - arc) / 2;
		}
		
		if (!clippedEdges) {
			break;
		}
		
		CGFloat currentCircumfence = arc * adjustedRadius;
		if (firstSeek) {
			if (currentCircumfence < requiredCircumfence) {
				lowerBound = adjustedRadius;
				adjustedRadius *= 1.25;
				upperBound = adjustedRadius;
			} else {
				firstSeek = NO;
			}
		} else {
			CGFloat delta = currentCircumfence - requiredCircumfence;
			if (ABS(delta) < epsilon) {
				break;
			} else if (lowerBound == upperBound) {
				break;
			} else if (delta < 0.0) {
				lowerBound += (upperBound - lowerBound) / 2;
			} else if (delta > 0.0) {
				upperBound -= (upperBound - lowerBound) / 2;
			}
			adjustedRadius = lowerBound + (upperBound - lowerBound) / 2;
		}
	} while (clippedEdges);
	
	if (clippedEdges) { // has clipping. Figure out best splitting index/offset:
		CGFloat splitAngle = 0.0;
		if (clippedEdges) {
			splitAngle = DLWMAngleForSplitEdges(clippedEdges);
		} else {
			angle = 0.0;
		}
		NSUInteger splitOffset = round(((CGFloat)itemCount / fullCircle) * splitAngle);
		angle -= (M_PI / 2);
		for (NSUInteger index = 0; index < itemCount; index++) {
			CGFloat itemAngle = DLWMAngleForItemAtIndex(angle, arc, index, itemCount, clippedEdges);
			CGPoint itemCenter = CGPointMake(centerPoint.x + cosf(itemAngle) * adjustedRadius,
											 centerPoint.y + sinf(itemAngle) * adjustedRadius);
			DLWMMenuItem *item = items[(index + splitOffset) % itemCount];
			item.layoutLocation = itemCenter;
		}
	} else {
		[super layoutItems:items forCenterPoint:centerPoint inMenu:menu];
	}
}

@end

static CGFloat DLWMDistanceToEdgeOfEnclosingRect(CGPoint point, CGRect rect, CGRectEdge edge) {
	CGFloat distance = 0.0;
	switch (edge) {
		case CGRectMinYEdge: distance = point.y - CGRectGetMinY(rect); break; // top
		case CGRectMaxYEdge: distance = CGRectGetMaxY(rect) - point.y; break; // bottom
		case CGRectMinXEdge: distance = point.x - CGRectGetMinX(rect); break; // left
		case CGRectMaxXEdge: distance = CGRectGetMaxX(rect) - point.x; break; // right
		default: break;
	}
	return distance;
}

static CGFloat DLWMAngleFromDistanceToEdgeAndRadius(CGFloat distance, CGFloat radius) {
	return asin(sqrt(pow(radius, 2) - pow(distance, 2)) / radius);
}

static CGFloat DLWMAngleForSplitEdges(DLWMClipEdge clippedEdges) {
	CGFloat quarterCircle = M_PI / 2;
	CGFloat splitAngle = 0.0;
	
	if ((clippedEdges & DLWMClipEdgeMinX) != 0x0) {
		splitAngle = quarterCircle * 3;
		if ((clippedEdges & DLWMClipEdgeMinY) != 0x0) {
			splitAngle = quarterCircle * 2;
		}
	} else if ((clippedEdges & DLWMClipEdgeMinY) != 0x0) {
		splitAngle = quarterCircle * 0;
		if ((clippedEdges & DLWMClipEdgeMaxX) != 0x0) {
			splitAngle = quarterCircle * 7;
		}
	} else if ((clippedEdges & DLWMClipEdgeMaxX) != 0x0) {
		splitAngle = quarterCircle * 1;
		if ((clippedEdges & DLWMClipEdgeMaxY) != 0x0) {
			splitAngle = quarterCircle * 0;
		}
	} else if ((clippedEdges & DLWMClipEdgeMaxY) != 0x0) {
		splitAngle = quarterCircle * 2;
		if ((clippedEdges & DLWMClipEdgeMinX) != 0x0) {
			splitAngle = quarterCircle * 1;
		}
	}
	return splitAngle;
}

static CGFloat DLWMAngleForItemAtIndex(CGFloat angle, CGFloat arc, NSUInteger index, NSUInteger count, DLWMClipEdge clippedEdges) {
	NSUInteger divisor = (!clippedEdges) ? count : count - 1;
	return angle + (index * (arc / divisor));
}
