//
//  DLWMCircularLayout.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DLWMMenu.h"

typedef CGFloat(^DLWMLayoutRadiusLogic)(DLWMMenu *menu, CGFloat arc);

@interface DLWMCircularLayout : NSObject <DLWMMenuLayout>

@property (readwrite, assign, nonatomic) CGFloat angle;
@property (readwrite, copy, nonatomic) DLWMLayoutRadiusLogic radiusLogic;
@property (readwrite, assign, nonatomic, getter = isClockwise) BOOL clockwise;

- (id)init;
- (id)initWithAngle:(CGFloat)angle;
- (id)initWithAngle:(CGFloat)angle radius:(CGFloat)radius;
- (id)initWithAngle:(CGFloat)angle radiusLogic:(DLWMLayoutRadiusLogic)radiusLogic;

+ (DLWMLayoutRadiusLogic)defaultRadiusLogic;

@end
