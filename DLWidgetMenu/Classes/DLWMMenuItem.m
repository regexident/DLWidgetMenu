//
//  DLWMMenuItem.m
//  DLWidgetMenu
//
//  Created by Vincent Esche on 05/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLWMMenuItem.h"

@implementation DLWMMenuItem

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.layoutLocation = self.center;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
		self.layoutLocation = self.center;
	}
	return self;
}

- (id)initWithContentView:(UIView *)contentView representedObject:(id)representedObject {
	self = [self initWithFrame:contentView.frame];
	if (self) {
		self.contentView = contentView;
		self.representedObject = representedObject;
	}
	return self;
}

- (void)setContentView:(UIView *)contentView {
	[_contentView removeFromSuperview];
	_contentView = contentView;
	self.bounds = contentView.bounds;
	[self addSubview:contentView];
}

- (void)setLayoutLocation:(CGPoint)layoutLocation {
	_layoutLocation = layoutLocation;
}

- (void)layoutSubviews {
	self.contentView.frame = self.bounds;
}

@end
