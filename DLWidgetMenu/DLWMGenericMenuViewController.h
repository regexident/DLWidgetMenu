//
//  DLWMGenericMenuViewController.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLWMMenu;

@interface DLWMGenericMenuViewController : UIViewController

@property (readwrite, weak, nonatomic) IBOutlet UIView *configurationView;
@property (readwrite, strong, nonatomic) DLWMMenu *menu;

@end
