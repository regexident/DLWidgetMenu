//
//  DLWMArcuatedLayout.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMCircularLayout.h"

@interface DLWMArcuatedLayout : DLWMCircularLayout

@property (readwrite, assign, nonatomic) CGFloat angle;
@property (readwrite, assign, nonatomic) CGFloat arc;

- (id)initWithAngle:(CGFloat)angle arc:(CGFloat)arc;
- (id)initWithAngle:(CGFloat)angle arc:(CGFloat)arc radius:(CGFloat)radius;
- (id)initWithAngle:(CGFloat)angle arc:(CGFloat)arc radiusLogic:(DLWMLayoutRadiusLogic)radiusLogic;

@end
