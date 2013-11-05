//
//  DLWMLinearLayout.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DLWMMenu.h"

@interface DLWMLinearLayout : NSObject <DLWMMenuLayout>

@property (readwrite, assign, nonatomic) CGFloat angle;
@property (readwrite, assign, nonatomic) CGFloat itemSpacing;
@property (readwrite, assign, nonatomic) CGFloat centerSpacing;

- (id)initWithAngle:(CGFloat)angle itemSpacing:(CGFloat)itemSpacing centerSpacing:(CGFloat)centerSpacing;

@end
