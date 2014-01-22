//
//  DLWMRadialLayout.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DLWMMenu.h"

@interface DLWMRadialLayout : NSObject <DLWMMenuLayout>

@property (readwrite, assign, nonatomic) CGFloat radius;
@property (readwrite, assign, nonatomic) CGFloat arc; // negative for counter-clockwise
@property (readwrite, assign, nonatomic) CGFloat angle;
@property (readwrite, assign, nonatomic) CGFloat minDistance; // 0.0 for non-layered
@property (readwrite, assign, nonatomic) BOOL uniformOuterLayer;

- (id)initWithRadius:(CGFloat)radius arc:(CGFloat)arc angle:(CGFloat)angle minDistance:(CGFloat)minDistance;

@end
