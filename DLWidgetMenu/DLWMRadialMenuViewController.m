//
//  DLWMRadialMenuViewController.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMRadialMenuViewController.h"

#import "DLWMRadialLayout.h"

@interface DLWMRadialMenuViewController ()

@property (readwrite, assign, nonatomic) BOOL layered;

@property (readwrite, assign, nonatomic) NSUInteger items;
@property (readwrite, assign, nonatomic) CGFloat radius;
@property (readwrite, assign, nonatomic) CGFloat arc;
@property (readwrite, assign, nonatomic) CGFloat angle;
@property (readwrite, assign, nonatomic) CGFloat minDistance;
@property (readwrite, assign, nonatomic) BOOL uniformOuterLayer;

@property (weak, nonatomic) IBOutlet UISlider *itemsSlider;
@property (weak, nonatomic) IBOutlet UILabel *itemsLabel;

@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;

@property (weak, nonatomic) IBOutlet UISlider *arcSlider;
@property (weak, nonatomic) IBOutlet UILabel *arcLabel;

@property (weak, nonatomic) IBOutlet UISlider *angleSlider;
@property (weak, nonatomic) IBOutlet UILabel *angleLabel;

@property (weak, nonatomic) IBOutlet UISlider *minDistanceSlider;
@property (weak, nonatomic) IBOutlet UILabel *minDistanceLabel;

@property (weak, nonatomic) IBOutlet UISwitch *uniformOuterLayerSwitch;

@end

@implementation DLWMRadialMenuViewController

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
	self.radius = 60.0; // in pixels
	self.arc = DLWMFullCircle; // in radians
	self.angle = M_PI_2 * 3; // in radians
	self.minDistance = 40.0; // in pixels
    self.uniformOuterLayer = NO;
}

+ (id<DLWMMenuLayout>)layout {
	return [[DLWMRadialLayout alloc] initWithRadius:60.0 arc:DLWMFullCircle angle:0.0 minDistance:0.0];
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

- (IBAction)changeArc:(UISlider *)sender {
	self.arc = sender.value;
}

- (IBAction)changeAngle:(UISlider *)sender {
	self.angle = sender.value;
}

- (IBAction)changeMinDistance:(UISlider *)sender {
	self.minDistance = sender.value;
}

- (IBAction)changeUniformOuterLayer:(UISwitch *)sender {
	self.uniformOuterLayer = sender.on;
    
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
	((DLWMRadialLayout *)self.menu.layout).radius = radius;
	self.radiusSlider.value = radius;
	self.radiusLabel.text = [NSString stringWithFormat:@"%.0fpx", radius];
}

- (void)setArc:(CGFloat)arc {
	_arc = arc;
	((DLWMRadialLayout *)self.menu.layout).arc = arc;
	self.arcSlider.value = arc;
	self.arcLabel.text = [NSString stringWithFormat:@"%.0fº", (arc / M_PI) * 180];
}

- (void)setAngle:(CGFloat)angle {
	_angle = angle;
	((DLWMRadialLayout *)self.menu.layout).angle = angle;
	self.angleSlider.value = angle;
	self.angleLabel.text = [NSString stringWithFormat:@"%.0fº", (angle / M_PI) * 180];
}

- (void)setMinDistance:(CGFloat)minDistance {
	_minDistance = minDistance;
	((DLWMRadialLayout *)self.menu.layout).minDistance = minDistance;
	self.minDistanceSlider.value = minDistance;
	self.minDistanceLabel.text = [NSString stringWithFormat:@"%.0fpx", minDistance];
}

- (void)setUniformOuterLayer:(BOOL)uniformOuterLayer {
    _uniformOuterLayer = uniformOuterLayer;
    ((DLWMRadialLayout *)self.menu.layout).uniformOuterLayer = uniformOuterLayer;
    self.uniformOuterLayerSwitch.on = uniformOuterLayer;
}

@end
