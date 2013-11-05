//
//  DLWMArcuatedLayout.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DLWMMenu.h"

typedef CGFloat(^DLWMArcuatedLayoutRadiusLogic)(CGFloat arc, DLWMMenu *menu);

@interface DLWMArcuatedLayout : NSObject <DLWMMenuLayout>

@property (readwrite, assign, nonatomic) CGFloat angle;
@property (readwrite, assign, nonatomic) CGFloat arc;
@property (readwrite, copy, nonatomic) DLWMArcuatedLayoutRadiusLogic radiusLogic;

- (id)init;
- (id)initWithAngle:(CGFloat)angle arc:(CGFloat)arc;

+ (CGFloat)defaultAngle;
+ (CGFloat)defaultArc;
+ (DLWMArcuatedLayoutRadiusLogic)defaultRadiusLogic;

@end
