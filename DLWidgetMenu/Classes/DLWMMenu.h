//
//  DLWMMenu.h
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DLWMMenuItem.h"

extern const CGFloat DLWMFullCircle;

@class DLWMMenuAnimator;

@class DLWMMenu;

@protocol DLWMMenuDataSource <NSObject>

- (NSUInteger)numberOfObjectsInMenu:(DLWMMenu *)menu;
- (id)objectAtIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu;

@end

@protocol DLWMMenuItemSource <NSObject>

- (UIView *)viewForObject:(id)object atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu;

@end

@protocol DLWMMenuItemDelegate <NSObject>

@optional

- (void)willOpenItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration;
- (void)willCloseItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration;

- (void)didOpenItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration;
- (void)didCloseItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration;

@end

@protocol DLWMMenuDelegate <NSObject>

@optional

- (void)receivedSingleTap:(UITapGestureRecognizer *)recognizer onItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu;
- (void)receivedDoubleTap:(UITapGestureRecognizer *)recognizer onItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu;
- (void)receivedLongPress:(UILongPressGestureRecognizer *)recognizer onItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu;
- (void)receivedPinch:(UIPinchGestureRecognizer *)recognizer onItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu;
- (void)receivedPan:(UIPanGestureRecognizer *)recognizer onItem:(DLWMMenuItem *)item inMenu:(DLWMMenu *)menu;

- (void)receivedSingleTap:(UITapGestureRecognizer *)recognizer outsideOfMenu:(DLWMMenu *)menu;

- (void)willOpenMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration;
- (void)didOpenMenu:(DLWMMenu *)menu;

- (void)willCloseMenu:(DLWMMenu *)menu withDuration:(NSTimeInterval)duration;
- (void)didCloseMenu:(DLWMMenu *)menu;

@end

extern NSString * const DLWMMenuLayoutChangedNotification;

@protocol DLWMMenuLayout <NSObject>

- (void)layoutItems:(NSArray *)items forCenterPoint:(CGPoint)centerPoint inMenu:(DLWMMenu *)menu;

@end

typedef void(^DLWMMenuAnimatorAnimationsBlock)(DLWMMenuItem *item, NSUInteger index, DLWMMenu *menu);
typedef void(^DLWMMenuAnimatorCompletionBlock)(DLWMMenuItem *item, NSUInteger index, DLWMMenu *menu, BOOL finished);

@protocol DLWMMenuAnimator <NSObject>

- (void)animateItem:(DLWMMenuItem *)item atIndex:(NSUInteger)index inMenu:(DLWMMenu *)menu animated:(BOOL)animated completion:(DLWMMenuAnimatorCompletionBlock)completion;

@end

typedef NS_OPTIONS(NSUInteger, DLWMMenuState) {
	DLWMMenuStateClosed  = (0x0 << 0),
	DLWMMenuStateClosing = (0x1 << 0),
	DLWMMenuStateOpening = (0x1 << 1),
	DLWMMenuStateOpened  = (0x1 << 2)
};

@interface DLWMMenu : UIView

@property (readonly, assign, nonatomic) CGPoint centerPointWhileOpen;

@property (readonly, strong, nonatomic) DLWMMenuItem *mainItem;
@property (readonly, strong, nonatomic) NSArray *items;

@property (readwrite, weak, nonatomic) id<DLWMMenuDataSource> dataSource;
@property (readwrite, weak, nonatomic) id<DLWMMenuItemSource> itemSource;
@property (readwrite, weak, nonatomic) id<DLWMMenuDelegate> delegate;
@property (readwrite, weak, nonatomic) id<DLWMMenuItemDelegate> itemDelegate;

@property (readwrite, strong, nonatomic) id<DLWMMenuLayout> layout;

@property (readwrite, strong, nonatomic) id<DLWMMenuAnimator> openAnimator;
@property (readwrite, strong, nonatomic) id<DLWMMenuAnimator> closeAnimator;

@property (readwrite, assign, nonatomic) DLWMMenuState state;

@property (readwrite, assign, nonatomic) BOOL enabled;
@property (readwrite, assign, nonatomic) BOOL debuggingEnabled;

@property (readwrite, strong, nonatomic) id representedObject;

@property (readwrite, assign, nonatomic) NSTimeInterval openAnimationDelayBetweenItems;
@property (readwrite, assign, nonatomic) NSTimeInterval closeAnimationDelayBetweenItems;

- (id)initWithMainItemView:(UIView *)mainItemView
				dataSource:(id<DLWMMenuDataSource>)dataSource
				itemSource:(id<DLWMMenuItemSource>)itemSource
				  delegate:(id<DLWMMenuDelegate>)delegate
			  itemDelegate:(id<DLWMMenuItemDelegate>)itemDelegate
					layout:(id<DLWMMenuLayout>)layout
		 representedObject:(id)representedObject;

- (void)reloadData;

- (void)setEnabled:(BOOL)enabled animated:(BOOL)animated;

- (BOOL)isClosed;
- (BOOL)isClosing;
- (BOOL)isClosedOrClosing;

- (BOOL)isOpened;
- (BOOL)isOpening;
- (BOOL)isOpenedOrOpening;

- (BOOL)isAnimating;

- (void)open;
- (void)openAnimated:(BOOL)animated;

- (void)close;
- (void)closeAnimated:(BOOL)animated;

- (void)closeWithSpecialAnimator:(DLWMMenuAnimator *)itemAnimator forItem:(DLWMMenuItem *)item;
- (void)closeWithSpecialAnimator:(DLWMMenuAnimator *)itemAnimator forItem:(DLWMMenuItem *)item animated:(BOOL)animated;

- (void)moveTo:(CGPoint)centerPoint;
- (void)moveTo:(CGPoint)centerPoint animated:(BOOL)animated;

- (NSUInteger)indexOfItem:(DLWMMenuItem *)item;

@end
