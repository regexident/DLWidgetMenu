//
//  DLWMLinearMenuViewController.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMLinearMenuViewController.h"

#import "DLWMLinearLayout.h"

@interface DLWMLinearMenuViewController ()

@property (readwrite, assign, nonatomic) BOOL layered;

@property (readwrite, assign, nonatomic) NSUInteger items;
@property (readwrite, assign, nonatomic) CGFloat itemSpacing;
@property (readwrite, assign, nonatomic) CGFloat centerSpacing;
@property (readwrite, assign, nonatomic) CGFloat angle;

@property (weak, nonatomic) IBOutlet UISlider *itemsSlider;
@property (weak, nonatomic) IBOutlet UILabel *itemsLabel;

@property (weak, nonatomic) IBOutlet UISlider *itemSpacingSlider;
@property (weak, nonatomic) IBOutlet UILabel *itemSpacingLabel;

@property (weak, nonatomic) IBOutlet UISlider *centerSpacingSlider;
@property (weak, nonatomic) IBOutlet UILabel *centerSpacingLabel;

@property (weak, nonatomic) IBOutlet UISlider *angleSlider;
@property (weak, nonatomic) IBOutlet UILabel *angleLabel;

@end

@implementation DLWMLinearMenuViewController

#pragma mark - DLWMMenuLayout

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
		
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.items = 3;
	self.itemSpacing = 45.0; // in pixels
	self.centerSpacing = 50.0; // in pixels
	self.angle = M_PI_2 * 3; // in radians
}

+ (id<DLWMMenuLayout>)layout {
	return [[DLWMLinearLayout alloc] initWithAngle:0.0 itemSpacing:45.0 centerSpacing:50.0];
}

#pragma mark - DLWMMenuDataSource Protocol

- (NSUInteger)numberOfObjectsInMenu:(DLWMMenu *)menu {
	return self.items;
}

#pragma mark - IBActions

- (IBAction)changeItems:(UISlider *)sender {
	self.items = sender.value;
}

- (IBAction)changeItemSpacing:(UISlider *)sender {
	self.itemSpacing = sender.value;
}

- (IBAction)changeCenterSpacing:(UISlider *)sender {
	self.centerSpacing = sender.value;
}

- (IBAction)changeAngle:(UISlider *)sender {
	self.angle = sender.value;
}

#pragma mark - Accessors

- (void)setItems:(NSUInteger)items {
	_items = items;
	[self.menu reloadData];
	self.itemsSlider.value = items;
	self.itemsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)items];
}

- (void)setItemSpacing:(CGFloat)itemSpacing {
	_itemSpacing = itemSpacing;
	((DLWMLinearLayout *)self.menu.layout).itemSpacing = itemSpacing;
	self.itemSpacingSlider.value = itemSpacing;
	self.itemSpacingLabel.text = [NSString stringWithFormat:@"%.0fpx", itemSpacing];
}

- (void)setCenterSpacing:(CGFloat)centerSpacing {
	_centerSpacing = centerSpacing;
	((DLWMLinearLayout *)self.menu.layout).centerSpacing = centerSpacing;
	self.centerSpacingSlider.value = centerSpacing;
	self.centerSpacingLabel.text = [NSString stringWithFormat:@"%.0fpx", centerSpacing];
}

- (void)setAngle:(CGFloat)angle {
	_angle = angle;
	((DLWMLinearLayout *)self.menu.layout).angle = angle;
	self.angleSlider.value = angle;
	self.angleLabel.text = [NSString stringWithFormat:@"%.0fº", (angle / M_PI) * 180];
}

@end
