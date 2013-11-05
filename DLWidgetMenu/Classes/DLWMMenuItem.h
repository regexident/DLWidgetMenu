//
//  DLWMMenuItem.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLWMMenuItem : UIView

@property (readwrite, strong, nonatomic) UIView *contentView;
@property (readwrite, strong, nonatomic) id representedObject;
@property (readwrite, assign, nonatomic) CGPoint layoutLocation;

- (id)initWithContentView:(UIView *)contentView representedObject:(id)representedObject;

@end
