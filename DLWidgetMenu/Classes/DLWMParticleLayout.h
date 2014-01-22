//
//  DLWMParticleLayout.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Definite Loop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DLWMMenu.h"

typedef CGFloat(^DLWMParticleLayoutRadiusLogic)(DLWMMenu *menu);
typedef CGFloat(^DLWMParticleLayoutItemCornerRadiusLogic)(DLWMMenuItem *item);

@interface DLWMParticleLayout : NSObject <DLWMMenuLayout>

@property (readwrite, copy, nonatomic) DLWMParticleLayoutRadiusLogic radiusLogic;
@property (readwrite, copy, nonatomic) DLWMParticleLayoutItemCornerRadiusLogic itemCornerRadiusLogic;

+ (DLWMParticleLayoutRadiusLogic)defaultRadiusLogic;
+ (DLWMParticleLayoutItemCornerRadiusLogic)defaultItemCornerRadiusLogic;

@end
