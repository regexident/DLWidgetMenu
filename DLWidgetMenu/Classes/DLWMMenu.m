//
//  DLWMMenu.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMMenu.h"

#import "DLWMMenuItem.h"
#import "DLWMMenuAnimator.h"
#import "DLWMSpringMenuAnimator.h"

const CGFloat DLWMFullCircle = M_PI * 2;

NSString * const DLWMMenuLayoutChangedNotification = @"DLWMMenuLayoutChangedNotification";

@interface DLWMMenu ()

@property (readwrite, assign, nonatomic) CGPoint centerPointWhileOpen;

@property (readwrite, strong, nonatomic) DLWMMenuItem *mainItem;
@property (readwrite, strong, nonatomic) NSArray *items;

@property (readwrite, strong, nonatomic) NSTimer *timer;

@end

@implementation DLWMMenu

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		if (![self commonInit_DLWMMenu]) {
			return nil;
		}
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
		if (![self commonInit_DLWMMenu]) {
			return nil;
		}
	}
	return self;
}

- (BOOL)commonInit_DLWMMenu {
	self.items = [NSMutableArray array];
	
	self.enabled = YES;
	
    DLWMMenuAnimator * openAnimator = nil;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        openAnimator = [DLWMMenuAnimator new];
    } else {
        openAnimator = [DLWMSpringMenuAnimator new];
    }

	self.openAnimator = openAnimator;
	self.closeAnimator = [[DLWMMenuAnimator alloc] init];
	self.openAnimationDelayBetweenItems = 0.025;
	self.closeAnimationDelayBetweenItems = 0.025;
	
	UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receivedSingleTapOutside:)];
	[self addGestureRecognizer:singleTapRecognizer];
	
	return YES;
}

- (id)initWithMainItemView:(UIView *)mainItemView
				dataSource:(id<DLWMMenuDataSource>)dataSource
				itemSource:(id<DLWMMenuItemSource>)itemSource
				  delegate:(id<DLWMMenuDelegate>)delegate
			  itemDelegate:(id<DLWMMenuItemDelegate>)itemDelegate
					layout:(id<DLWMMenuLayout>)layout
		 representedObject:(id)representedObject {
	self = [self initWithFrame:mainItemView.frame];
	if (self) {
		NSAssert(dataSource, @"Method argument 'dataSource' must not be nil.");
		NSAssert(itemSource, @"Method argument 'itemSource' must not be nil.");
		NSAssert(layout, @"Method argument 'layout' must not be nil.");
		self.state = DLWMMenuStateClosed;
		self.representedObject = representedObject;
		self.centerPointWhileOpen = mainItemView.center;
		self.mainItem = [[DLWMMenuItem alloc] initWithContentView:mainItemView representedObject:representedObject];
		self.dataSource = dataSource;
		self.itemSource = itemSource;
		self.delegate = delegate;
		self.itemDelegate = itemDelegate;
		self.layout = layout;
		
		[self reloadData];
        [self adjustGeometryForState:DLWMMenuStateClosed];
	}
	return self;
}

- (void)adjustGeometryForState:(DLWMMenuState)state {
	CGPoint itemLocation;
	if (state == DLWMMenuStateClosed) {
		CGRect itemBounds = self.mainItem.bounds;
		itemLocation = CGPointMake(CGRectGetMidX(itemBounds), CGRectGetMidY(itemBounds));
		CGPoint menuCenter = self.mainItem.center;
		self.bounds = itemBounds;
		self.center = menuCenter;
	} else {
		CGRect menuFrame = self.superview.bounds;
		itemLocation = self.center;
		self.frame = menuFrame;
	}
	self.mainItem.center = itemLocation;
	self.mainItem.layoutLocation = itemLocation;
	self.centerPointWhileOpen = itemLocation;
}

#pragma mark - Custom Accessors

- (void)setMainItem:(DLWMMenuItem *)mainItem {
	NSAssert(mainItem, @"Method argument 'mainItem' must not be nil.");
	if (_mainItem) {
		[_mainItem removeFromSuperview];
		[self removeGestureRecognizersFromMenuItem:_mainItem];
	}
	_mainItem = mainItem;
	[self addGestureRecognizersToMenuItem:mainItem];
	mainItem.userInteractionEnabled = YES;
	mainItem.center = self.centerPointWhileOpen;
	[self addSubview:mainItem];
}

- (void)setDataSource:(id<DLWMMenuDataSource>)dataSource {
	NSAssert(dataSource, @"Method argument 'dataSource' must not be nil.");
	_dataSource = dataSource;
	[self reloadData];
}

- (void)setItemSource:(id<DLWMMenuItemSource>)itemSource {
	NSAssert(itemSource, @"Method argument 'itemSource' must not be nil.");
	_itemSource = itemSource;
	[self reloadData];
}

- (void)setLayout:(id<DLWMMenuLayout>)layout {
	NSAssert(layout, @"Method argument 'layout' must not be nil.");
	if (_layout) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:DLWMMenuLayoutChangedNotification object:_layout];
	}
	_layout = layout;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutDidChange:) name:DLWMMenuLayoutChangedNotification object:_layout];
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		[self layoutItemsWithCenter:self.centerPointWhileOpen animated:YES];
	} completion:nil];
}

- (void)setEnabled:(BOOL)enabled {
	[self setEnabled:enabled animated:YES];
}

- (void)setEnabled:(BOOL)enabled animated:(BOOL)animated {
	BOOL oldEnabled = _enabled;
	[self willChangeValueForKey:NSStringFromSelector(@selector(enabled))];
	_enabled = enabled;
	[self didChangeValueForKey:NSStringFromSelector(@selector(enabled))];
	
	if (enabled != oldEnabled) {
		NSTimeInterval duration = (animated) ? 0.5 : 0.0;
		[UIView animateWithDuration:duration animations:^{
			self.alpha = (enabled) ? 1.0 : 0.33;
		}];
	}
}

- (void)setDebuggingEnabled:(BOOL)debuggingEnabled {
	_debuggingEnabled = debuggingEnabled;
	self.backgroundColor = (debuggingEnabled) ? [[UIColor redColor] colorWithAlphaComponent:0.5] : nil;
}

#pragma mark - Observing

- (void)layoutDidChange:(NSNotification *)notification {
	[self layoutItemsWithCenter:self.centerPointWhileOpen animated:YES];
}

#pragma mark - Reloading

- (void)reloadData {
	id<DLWMMenuDataSource> dataSource = self.dataSource;
	id<DLWMMenuItemSource> itemSource = self.itemSource;
	NSUInteger itemCount = [dataSource numberOfObjectsInMenu:self];
	NSUInteger currentItemCount = self.items.count;
	NSUInteger minCount = MIN(itemCount, currentItemCount);
	
	// Remove all items not needed any more:
	if (itemCount < currentItemCount) {
		for (NSUInteger i = 0; i < currentItemCount - itemCount; i++) {
			[self removeLastItem];
		}
	}
	
	// Update existing items:
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, minCount)];
	[self.items enumerateObjectsAtIndexes:indexes options:0 usingBlock:^(DLWMMenuItem *item, NSUInteger index, BOOL *stop) {
		id object = [dataSource objectAtIndex:index inMenu:self];
		UIView *contentView = [itemSource viewForObject:object atIndex:index inMenu:self];
		item.contentView = contentView;
		item.representedObject = object;
	}];
	
	// Add all additional items:
	if (itemCount > currentItemCount) {
		for (NSUInteger i = currentItemCount; i < itemCount; i++) {
			id object = [dataSource objectAtIndex:i inMenu:self];
			UIView *contentView = [itemSource viewForObject:object atIndex:i inMenu:self];
			DLWMMenuItem *item = [[DLWMMenuItem alloc] initWithContentView:contentView representedObject:object];
			item.layoutLocation = [self isClosed] ? self.center : self.centerPointWhileOpen;
			[self addItem:item];
		}
	}
	[self layoutItemsWithCenter:self.centerPointWhileOpen animated:YES];
}

#pragma mark - Opening/Closing

- (void)open {
	[self openAnimated:YES];
}

- (void)openAnimated:(BOOL)animated {
	if ([self isOpenedOrOpening]) {
		return;
	}
	[self.timer invalidate];
	self.timer = nil;
	
	self.state = DLWMMenuStateOpening;
	[self adjustGeometryForState:self.state];
	
	NSArray *items = self.items;
	DLWMMenuAnimator *animator = self.openAnimator ?: [DLWMMenuAnimator sharedInstantAnimator];
	NSTimeInterval openAnimationDelayBetweenItems = self.openAnimationDelayBetweenItems;
	NSTimeInterval totalDuration = (items.count - 1) * openAnimationDelayBetweenItems + animator.duration;
	if ([self.delegate respondsToSelector:@selector(willOpenMenu:withDuration:)]) {
		[self.delegate willOpenMenu:self withDuration:totalDuration];
	}
	[self.layout layoutItems:items forCenterPoint:self.centerPointWhileOpen inMenu:self];
	[items enumerateObjectsUsingBlock:^(DLWMMenuItem *item, NSUInteger index, BOOL *stop) {
		double delayInSeconds = openAnimationDelayBetweenItems * index;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			if ([self.itemDelegate respondsToSelector:@selector(willOpenItem:inMenu:withDuration:)]) {
				[self.itemDelegate willOpenItem:item inMenu:self withDuration:animator.duration];
			}
			[animator animateItem:item atIndex:index inMenu:self animated:animated completion:^(DLWMMenuItem *menuItem, NSUInteger itemIndex, DLWMMenu *menu, BOOL finished) {
                if ([self.itemDelegate respondsToSelector:@selector(didOpenItem:inMenu:withDuration:)]) {
                    [self.itemDelegate didOpenItem:menuItem inMenu:self withDuration:animator.duration];
                }
            }];
		});
	}];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:totalDuration
												  target:self
												selector:@selector(handleDidOpenMenu:)
												userInfo:nil
												 repeats:NO];
}

- (void)handleDidOpenMenu:(NSTimer *)timer {
	self.timer = nil;
	self.state = DLWMMenuStateOpened;
	if ([self.delegate respondsToSelector:@selector(didOpenMenu:)]) {
		[self.delegate didOpenMenu:self];
	}
}

- (void)close {
	[self closeAnimated:YES];
}

- (void)closeAnimated:(BOOL)animated {
	[self closeWithSpecialAnimator:nil forItem:nil animated:animated];
}

- (void)closeWithSpecialAnimator:(DLWMMenuAnimator *)itemAnimator forItem:(DLWMMenuItem *)item {
	[self closeWithSpecialAnimator:itemAnimator forItem:item animated:YES];
}

- (void)closeWithSpecialAnimator:(DLWMMenuAnimator *)specialAnimator forItem:(DLWMMenuItem *)specialItem animated:(BOOL)animated {
	if ([self isClosedOrClosing]) {
		return;
	}
	[self.timer invalidate];
	self.timer = nil;
	if (specialItem == self.mainItem) {
		specialItem = nil;
	}
	NSArray *items = self.items;
	__block DLWMMenuAnimator *animator = self.closeAnimator ?: [DLWMMenuAnimator sharedInstantAnimator];
	NSTimeInterval closeAnimationDelayBetweenItems = self.closeAnimationDelayBetweenItems;
	NSTimeInterval totalDuration = (items.count - 1) * closeAnimationDelayBetweenItems + animator.duration;
	if ([self.delegate respondsToSelector:@selector(willCloseMenu:withDuration:)]) {
		[self.delegate willCloseMenu:self withDuration:totalDuration];
	}
	self.state = DLWMMenuStateClosing;
	if (specialItem) {
		// make sure special items is the first one being animated
		items = [@[specialItem] arrayByAddingObjectsFromArray:[self itemsWithoutItem:specialItem]];
	}
	[items enumerateObjectsUsingBlock:^(DLWMMenuItem *item, NSUInteger index, BOOL *stop) {
		DLWMMenuAnimator *itemAnimator = animator;
		if (item == specialItem) {
			itemAnimator = specialAnimator ?: [DLWMMenuAnimator sharedInstantAnimator];
		}
		double delayInSeconds = closeAnimationDelayBetweenItems * index;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			if ([self.itemDelegate respondsToSelector:@selector(willCloseItem:inMenu:withDuration:)]) {
				[self.itemDelegate willCloseItem:item inMenu:self withDuration:itemAnimator.duration];
			}
			[itemAnimator animateItem:item atIndex:index inMenu:self animated:animated completion:^(DLWMMenuItem *menuItem, NSUInteger itemIndex, DLWMMenu *menu, BOOL finished) {
                if ([self.itemDelegate respondsToSelector:@selector(didCloseItem:inMenu:withDuration:)]) {
                    [self.itemDelegate didCloseItem:menuItem inMenu:self withDuration:itemAnimator.duration];
                }
            }];
		});
	}];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:totalDuration
												  target:self
												selector:@selector(handleDidCloseMenu:)
												userInfo:nil
												 repeats:NO];
}

- (void)handleDidCloseMenu:(NSTimer *)timer {
	self.timer = nil;

	self.state = DLWMMenuStateClosed;
	[self adjustGeometryForState:self.state];
	
	if ([self.delegate respondsToSelector:@selector(didCloseMenu:)]) {
		[self.delegate didCloseMenu:self];
	}
}

- (NSArray *)itemsWithoutItem:(DLWMMenuItem *)item {
	NSArray *items = self.items;
	if (item) {
		items = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(DLWMMenuItem *menuItem, NSDictionary *bindings) {
			return menuItem != item;
		}]];
	}
	return items;
}

#pragma mark - UIGestureRecognizer Handlers

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	return self.enabled;
}

- (void)receivedPinch:(UIPinchGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedPinch:onItem:inMenu:)]) {
		[self.delegate receivedPinch:recognizer onItem:(DLWMMenuItem *)recognizer.view inMenu:self];
	}
}

- (void)receivedPan:(UIPanGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedPan:onItem:inMenu:)]) {
		[self.delegate receivedPan:recognizer onItem:(DLWMMenuItem *)recognizer.view inMenu:self];
	}
}

- (void)receivedLongPress:(UILongPressGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedLongPress:onItem:inMenu:)]) {
		[self.delegate receivedLongPress:recognizer onItem:(DLWMMenuItem *)recognizer.view inMenu:self];
	}
}

- (void)receivedDoubleTap:(UITapGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedDoubleTap:onItem:inMenu:)]) {
		[self.delegate receivedDoubleTap:recognizer onItem:(DLWMMenuItem *)recognizer.view inMenu:self];
	}
}

- (void)receivedSingleTap:(UITapGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedSingleTap:onItem:inMenu:)]) {
		[self.delegate receivedSingleTap:recognizer onItem:(DLWMMenuItem *)recognizer.view inMenu:self];
	}
}

- (void)receivedSingleTapOutside:(UITapGestureRecognizer *)recognizer {
	if (!self.enabled) {
		return;
	}
	if ([self.delegate respondsToSelector:@selector(receivedSingleTap:outsideOfMenu:)]) {
		[self.delegate receivedSingleTap:recognizer outsideOfMenu:self];
	}
}

#pragma mark - States

- (BOOL)isClosed {
	return self.state == DLWMMenuStateClosed;
}

- (BOOL)isClosing {
	return self.state == DLWMMenuStateClosing;
}

- (BOOL)isClosedOrClosing {
	return self.state == DLWMMenuStateClosed || self.state == DLWMMenuStateClosing;
}

- (BOOL)isOpened {
	return self.state == DLWMMenuStateOpened;
}

- (BOOL)isOpening {
	return self.state == DLWMMenuStateOpening;
}

- (BOOL)isOpenedOrOpening {
	return self.state == DLWMMenuStateOpened || self.state == DLWMMenuStateOpening;
}

- (BOOL)isAnimating {
	return self.state == DLWMMenuStateOpening || self.state == DLWMMenuStateClosing;
}

#pragma mark - Add/Remove Items

- (void)addGestureRecognizersToMenuItem:(DLWMMenuItem *)menuItem {
	NSAssert(menuItem, @"Method argument 'menuItem' must not be nil.");
	
	UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(receivedPinch:)];
	[menuItem addGestureRecognizer:pinchRecognizer];
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(receivedPan:)];
	[menuItem addGestureRecognizer:panRecognizer];
	
	UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(receivedLongPress:)];
	[menuItem addGestureRecognizer:longPressRecognizer];
	
	UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receivedDoubleTap:)];
	[doubleTapRecognizer setNumberOfTapsRequired:2];
	[menuItem addGestureRecognizer:doubleTapRecognizer];
	
	UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receivedSingleTap:)];
	[singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
	[menuItem addGestureRecognizer:singleTapRecognizer];
}

- (void)removeGestureRecognizersFromMenuItem:(DLWMMenuItem *)menuItem {
	for (UIGestureRecognizer *recognizer in menuItem.gestureRecognizers) {
		[menuItem removeGestureRecognizer:recognizer];
	}
}

- (void)addItem:(DLWMMenuItem *)item {
	NSAssert(item, @"Method argument 'menuItem' must not be nil.");
	[((NSMutableArray *)self.items) addObject:item];
	[self addGestureRecognizersToMenuItem:item];
	item.userInteractionEnabled = YES;
	BOOL hidden = [self isClosed];
	item.hidden = hidden;
	if (!hidden) {
		item.alpha = 0.0;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			item.alpha = 1.0;
		} completion:nil];
	}
	item.center = self.centerPointWhileOpen;
	[self insertSubview:item belowSubview:self.mainItem];
}

- (void)removeItem:(DLWMMenuItem *)item {
	NSAssert(item, @"Method argument 'menuItem' must not be nil.");
	NSAssert(item.superview == self, @"Method argument 'menuItem' must be member of menu.");
	[item removeFromSuperview];
	[self removeGestureRecognizersFromMenuItem:item];
	[((NSMutableArray *)self.items) removeObject:item];
}

- (void)removeLastItem {
	DLWMMenuItem *item = [self.items lastObject];
	if (item) {
		[self removeItem:item];
	}
}

- (void)moveTo:(CGPoint)centerPoint {
	[self moveTo:centerPoint animated:YES];
}

- (void)moveTo:(CGPoint)centerPoint animated:(BOOL)animated {
	// Moving the items' layoutLocation so that layouts which
	// rely on an item's previous location can be supported.
	// A potential candidate would be a force-directed layout.
	[self layoutItemsWithCenter:centerPoint animated:animated];
    if ([self isClosed]) {
        NSTimeInterval duration = (animated) ? 0.5 : 0.0;
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.center = centerPoint;
        } completion:nil];
    } else {
        self.centerPointWhileOpen = centerPoint;
    }
}

- (void)layoutItemsWithCenter:(CGPoint)centerPoint animated:(BOOL)animated {
	NSArray *items = self.items;
	if (!items.count) {
		return;
	}
	[self.layout layoutItems:items forCenterPoint:centerPoint inMenu:self];
	if ([self isOpenedOrOpening]) {
        NSTimeInterval duration = (animated) ? 0.5 : 0.0;
		[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.mainItem.center = centerPoint;
            [items enumerateObjectsUsingBlock:^(DLWMMenuItem *item, NSUInteger index, BOOL *stop) {
                item.center = item.layoutLocation;
            }];
        } completion:nil];
	}
}

- (NSUInteger)indexOfItem:(DLWMMenuItem *)item {
	return [self.items indexOfObjectIdenticalTo:item];
}

@end
