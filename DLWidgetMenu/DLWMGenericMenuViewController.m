//
//  DLWMGenericMenuViewController.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMGenericMenuViewController.h"

#import "DLWMMenu.h"
#import "DLWMMenuAnimator.h"
#import "DLWMSpringMenuAnimator.h"
#import "DLWMSelectionMenuAnimator.h"

@interface DLWMGenericMenuViewController () <DLWMMenuDataSource, DLWMMenuItemSource, DLWMMenuDelegate, DLWMMenuItemDelegate>

@end

@implementation DLWMGenericMenuViewController

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
		
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
	self.view.backgroundColor = [UIColor darkGrayColor];
	
	id<DLWMMenuLayout> layout = [[self class] layout];
	
	CGRect frame = self.view.bounds;
	
	DLWMMenu *menu = [[DLWMMenu alloc] initWithMainItemView:[self viewForMainItemInMenu:nil]
												 dataSource:self
												 itemSource:self
												   delegate:self
											   itemDelegate:self
													 layout:layout
										  representedObject:self];
	menu.openAnimationDelayBetweenItems = 0.01;
	menu.closeAnimationDelayBetweenItems = 0.01;
	
	menu.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame) * 0.66);
	self.menu = menu;
	
	[self.view insertSubview:self.menu atIndex:0];
	
	self.configurationView.backgroundColor = [UIColor clearColor];
    
    for (UIView *subview in self.configurationView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            ((UILabel *)subview).textColor = [UIColor whiteColor];
        }
    }
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self.menu openAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self.menu closeAnimated:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - DLWMMenuLayout

+ (id<DLWMMenuLayout>)layout {
	return nil;
}

#pragma mark - DLWMMenuDataSource Protocol

- (NSUInteger)numberOfObjectsInMenu:(DLWMMenu *)menu {
	return 50;
}

- (id)objectAtIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu {
	return @(index);
}

#pragma mark - DLWMMenuItemSource Protocol

+ (UIView *)menuItemView {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
	view.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.75].CGColor;
	view.layer.borderWidth = 1.5;
	view.layer.shadowColor = [UIColor blackColor].CGColor;
	view.layer.shadowOffset = CGSizeMake(0.0, 1.5);
	view.layer.shadowOpacity = 0.5;
	
	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.frame = view.layer.bounds;
	gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:1.0 alpha:0.5].CGColor,
					 (__bridge id)[UIColor colorWithWhite:1.0 alpha:0.1].CGColor,
					 (__bridge id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
					 (__bridge id)[UIColor colorWithWhite:1.0 alpha:0.2].CGColor];
	gradientLayer.locations = @[@0.0, @0.49, @0.5, @1.0];
	[view.layer addSublayer:gradientLayer];
	return view;
}

- (UIView *)viewForMainItemInMenu:(DLWMMenu *)menu {
	UIView *view = [[self class] menuItemView];
	view.bounds = CGRectMake(0.0, 0.0, 50.0, 50.0);
	view.backgroundColor = [UIColor lightGrayColor];
	view.layer.cornerRadius = 25.0;
	CAGradientLayer *gradientLayer = (CAGradientLayer *)view.layer.sublayers[0];
	gradientLayer.cornerRadius = view.layer.cornerRadius;
	gradientLayer.frame = view.layer.bounds;
	return view;
}

- (UIView *)viewForObject:(id)object atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu {
	UIView *view = [[self class] menuItemView];
	view.bounds = CGRectMake(0.0, 0.0, 40.0, 40.0);
	CGFloat hue = ((1.0 / [self numberOfObjectsInMenu:menu]) * index);
	view.backgroundColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
	view.layer.cornerRadius = 20.0;
	CAGradientLayer *gradientLayer = (CAGradientLayer *)view.layer.sublayers[0];
	gradientLayer.cornerRadius = view.layer.cornerRadius;
	gradientLayer.frame = view.layer.bounds;
	return view;
}

#pragma mark - DLWMMenuItemDelegate Protocol

- (void)willOpenItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration {
	NSLog(@"%s", __FUNCTION__);
}

- (void)willCloseItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration {
	NSLog(@"%s", __FUNCTION__);
}

- (void)didOpenItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration {
	NSLog(@"%s", __FUNCTION__);
}

- (void)didCloseItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration {
	NSLog(@"%s", __FUNCTION__);
}

#pragma mark - DLWMMenuDelegate Protocol

- (void)receivedSingleTap:(UITapGestureRecognizer *)recognizer onItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"recognizer: %@", recognizer);
	if ([menu isClosedOrClosing]) {
		[menu open];
	} else if ([menu isOpenedOrOpening]) {
		if (item == menu.mainItem) {
			[menu close];
		} else {
			[menu closeWithSpecialAnimator:[[DLWMSelectionMenuAnimator alloc] init] forItem:item];
		}
	}
}

- (void)receivedDoubleTap:(UITapGestureRecognizer *)recognizer onItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"recognizer: %@", recognizer);
}

- (void)receivedLongPress:(UILongPressGestureRecognizer *)recognizer onItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"recognizer: %@", recognizer);
}

- (void)receivedPinch:(UIPinchGestureRecognizer *)recognizer onItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"recognizer: %@", recognizer);
}

- (void)receivedPan:(UIPanGestureRecognizer *)recognizer onItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu {
	NSLog(@"%s", __FUNCTION__);
	NSLog(@"recognizer: %@", recognizer);
	if (item == menu.mainItem) {
		[menu moveTo:[recognizer locationInView:menu.superview] animated:NO];
	}
}

- (void)receivedSingleTap:(UITapGestureRecognizer *)recognizer outsideOfMenu:(DLWMMenu *)menu {
	NSLog(@"recognizer: %@", recognizer);
	[menu close];
}

- (void)willOpenMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration {
	NSLog(@"%s", __FUNCTION__);
}

- (void)didOpenMenu:(DLWMMenu *)menu {
	NSLog(@"%s", __FUNCTION__);
}

- (void)willCloseMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration {
	NSLog(@"%s", __FUNCTION__);
}

- (void)didCloseMenu:(DLWMMenu *)menu {
	NSLog(@"%s", __FUNCTION__);
}

@end
