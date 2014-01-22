//
//  DLWMSpiralMenuViewController.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMSpiralMenuViewController.h"

#import "DLWMSpiralLayout.h"

@interface DLWMSpiralMenuViewController ()

@property (readwrite, assign, nonatomic) BOOL layered;

@property (readwrite, assign, nonatomic) NSUInteger items;
@property (readwrite, assign, nonatomic) CGFloat radius;
@property (readwrite, assign, nonatomic) CGFloat angle;
@property (readwrite, assign, nonatomic) CGFloat itemDistance;

@property (weak, nonatomic) IBOutlet UISlider *itemsSlider;
@property (weak, nonatomic) IBOutlet UILabel *itemsLabel;

@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;

@property (weak, nonatomic) IBOutlet UISlider *angleSlider;
@property (weak, nonatomic) IBOutlet UILabel *angleLabel;

@property (weak, nonatomic) IBOutlet UISlider *itemDistanceSlider;
@property (weak, nonatomic) IBOutlet UILabel *itemDistanceLabel;

@end

@implementation DLWMSpiralMenuViewController

#pragma mark - DLWMMenuLayout

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
		
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.items = 8;
	self.radius = 30.0; // in pixels
	self.angle = M_PI_2 * 3; // in radians
	self.itemDistance = 20.0; // in pixels
}

+ (id<DLWMMenuLayout>)layout {
	return [[DLWMSpiralLayout alloc] initWithAngle:0.0 radius:50.0 itemDistance:30.0];
}

#pragma mark - DLWMMenuDataSource Protocol

- (NSUInteger)numberOfObjectsInMenu:(DLWMMenu *)menu {
	return self.items;
}

#pragma mark - IBActions

- (IBAction)changeItems:(UISlider *)sender {
	self.items = sender.value;
}

- (IBAction)changeRadius:(UISlider *)sender {
	self.radius = sender.value;
}

- (IBAction)changeAngle:(UISlider *)sender {
	self.angle = sender.value;
}

- (IBAction)changeItemDistance:(UISlider *)sender {
	self.itemDistance = sender.value;
}

#pragma mark - Accessors

- (void)setItems:(NSUInteger)items {
	_items = items;
	[self.menu reloadData];
	self.itemsSlider.value = items;
	self.itemsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)items];
}

- (void)setRadius:(CGFloat)radius {
	_radius = radius;
	((DLWMSpiralLayout *)self.menu.layout).radius = radius;
	self.radiusSlider.value = radius;
	self.radiusLabel.text = [NSString stringWithFormat:@"%.0fpx", radius];
}

- (void)setAngle:(CGFloat)angle {
	_angle = angle;
	((DLWMSpiralLayout *)self.menu.layout).angle = angle;
	self.angleSlider.value = angle;
	self.angleLabel.text = [NSString stringWithFormat:@"%.0fº", (angle / M_PI) * 180];
}

- (void)setItemDistance:(CGFloat)itemDistance {
	_itemDistance = itemDistance;
	((DLWMSpiralLayout *)self.menu.layout).itemDistance = itemDistance;
	self.itemDistanceSlider.value = itemDistance;
	self.itemDistanceLabel.text = [NSString stringWithFormat:@"%.0fpx", itemDistance];
}

@end
