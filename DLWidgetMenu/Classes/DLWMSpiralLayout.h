//
//  DLWMSpiralLayout.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DLWMMenu.h"

typedef CGFloat(^DLWMLayoutRadiusLogic)(DLWMMenu *menu, NSArray *items, CGFloat arc);

@interface DLWMSpiralLayout : NSObject <DLWMMenuLayout>

@property (readwrite, assign, nonatomic) CGFloat angle;
@property (readwrite, assign, nonatomic) CGFloat radius;
@property (readwrite, assign, nonatomic) CGFloat itemDistance;
@property (readwrite, assign, nonatomic, getter = isClockwise) BOOL clockwise;

- (id)initWithAngle:(CGFloat)angle radius:(CGFloat)radius itemDistance:(CGFloat)itemDistance;

@end
