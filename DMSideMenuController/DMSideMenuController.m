// The MIT License (MIT)
//
// Copyright (c) 2013 Darren Mo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "DMSideMenuController.h"


@interface DMSideMenuContainerView : UIView

@end

@implementation DMSideMenuContainerView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.backgroundColor = [UIColor whiteColor];
		
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOpacity = 0.7;
		self.layer.shadowOffset = CGSizeZero;
		self.layer.shadowRadius = 2;
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGPathRef path = CGPathCreateWithRect(self.layer.bounds, NULL);
	self.layer.shadowPath = path;
	CGPathRelease(path);
}

@end


@interface DMSideMenuController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) DMSideMenuContainerView *containerView;

@property (strong, readonly, nonatomic) UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer;
@property (strong, readonly, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, readonly, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic) CGFloat beginningTranslationX;

@end


@implementation DMSideMenuController

@synthesize screenEdgePanGestureRecognizer = _screenEdgePanGestureRecognizer;
@synthesize panGestureRecognizer = _panGestureRecognizer;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;

#pragma mark - Initialization

- (id)init {
	self = [super init];
	
	if (self) {
		[self performInit];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		[self performInit];
	}
	
	return self;
}

- (void)performInit {
	_menuWidth = 320;
	_overlapWidth = 50;
	_gesturesEnabled = YES;
	_useScreenEdgeInsteadOfNormalPan = NO;
	
	_containerView = [[DMSideMenuContainerView alloc] init];
	
	_screenEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	_screenEdgePanGestureRecognizer.edges = UIRectEdgeLeft;
	_screenEdgePanGestureRecognizer.enabled = _useScreenEdgeInsteadOfNormalPan;
	
	_panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	_panGestureRecognizer.delegate = self;
	
	_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	_tapGestureRecognizer.delaysTouchesBegan = YES;
	_tapGestureRecognizer.enabled = NO;
}

#pragma mark - View life cycle

- (void)loadView {
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
	contentView.backgroundColor = [UIColor whiteColor];
	contentView.opaque = YES;
	self.view = contentView;
	
	
	self.containerView.frame = self.view.bounds;
	self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[self.containerView addGestureRecognizer:self.screenEdgePanGestureRecognizer];
	[self.containerView addGestureRecognizer:self.panGestureRecognizer];
	[self.containerView addGestureRecognizer:self.tapGestureRecognizer];
	
	[self.view addSubview:self.containerView];
}

#pragma mark - Handling gestures

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
	switch (panGestureRecognizer.state) {
		case UIGestureRecognizerStateBegan: {
			self.beginningTranslationX = self.containerView.transform.tx;
		}
			break;
			
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded: {
			CGFloat vx = [panGestureRecognizer velocityInView:self.containerView].x;
			
			CGFloat threshold = self.menuWidth / 3;
			
			BOOL menuOpen = (self.containerView.transform.tx > (self.menuWidth - self.overlapWidth) / 2 && vx > -threshold) || vx > threshold;
			
			[self setMenuOpen:menuOpen animated:YES];
		}
			break;
			
		default: {
			CGFloat tx = [panGestureRecognizer translationInView:self.containerView].x + self.beginningTranslationX;
			
			if (tx > self.menuWidth) tx = self.menuWidth;
			
			if (tx < 0) tx = 0;
			
			self.containerView.transform = CGAffineTransformMakeTranslation(tx, 0);
		}
			break;
	}
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
	[self setMenuOpen:NO animated:YES];
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer == self.panGestureRecognizer) {
		return !self.useScreenEdgeInsteadOfNormalPan || self.menuOpen;
	}
	
	return YES;
}

#pragma mark - Configuring widths

- (void)setMenuWidth:(CGFloat)menuWidth {
	if (menuWidth < 0) menuWidth = 0;
	
	if (menuWidth == _menuWidth || [self isViewLoaded]) return;
	
	_menuWidth = menuWidth;
}

- (void)setOverlapWidth:(CGFloat)overlapWidth {
	if (self.menuWidth - overlapWidth < 0) overlapWidth = self.menuWidth;
	
	if (overlapWidth == _overlapWidth || [self isViewLoaded]) return;
	
	_overlapWidth = overlapWidth;
}

#pragma mark - Configuring child view controllers

- (void)setMainViewController:(UIViewController *)mainViewController {
	if (mainViewController == _mainViewController) return;
	
	
	if (_mainViewController) {
		[_mainViewController willMoveToParentViewController:nil];
		[_mainViewController.view removeFromSuperview];
		[_mainViewController removeFromParentViewController];
		
		_mainViewController.view.userInteractionEnabled = YES;
	}
	
	
	_mainViewController = mainViewController;
	
	if (_mainViewController) {
		[self addChildViewController:_mainViewController];
		
		_mainViewController.view.transform = CGAffineTransformIdentity;
		_mainViewController.view.frame = self.containerView.bounds;
		_mainViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		[self.containerView addSubview:_mainViewController.view];
		
		[_mainViewController didMoveToParentViewController:self];
	}
}

- (void)setMenuViewController:(UIViewController *)menuViewController {
	if (menuViewController == _menuViewController) return;
	
	
	if (_menuViewController) {
		[_menuViewController willMoveToParentViewController:nil];
		[_menuViewController.view removeFromSuperview];
		[_menuViewController removeFromParentViewController];
	}
	
	
	_menuViewController = menuViewController;
	
	if (_menuViewController) {
		[self addChildViewController:_menuViewController];
		
		_menuViewController.view.transform = CGAffineTransformIdentity;
		_menuViewController.view.frame = CGRectMake(0, 0, self.menuWidth, CGRectGetHeight(self.view.bounds));
		_menuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
		[self.view insertSubview:_menuViewController.view belowSubview:self.containerView];
		
		[_menuViewController didMoveToParentViewController:self];
	}
}

#pragma mark - Configuring menu visibility

- (void)setMenuOpen:(BOOL)menuOpen {
	[self setMenuOpen:menuOpen animated:NO];
}

- (void)setMenuOpen:(BOOL)menuOpen animated:(BOOL)animated {
	_menuOpen = menuOpen;
	
	self.tapGestureRecognizer.enabled = _menuOpen ? self.gesturesEnabled : NO;
	self.mainViewController.view.userInteractionEnabled = !_menuOpen;
	
	void (^animationBlock)() = ^{
		if (_menuOpen) {
			self.containerView.transform = CGAffineTransformMakeTranslation(self.menuWidth - self.overlapWidth, 0);
		} else {
			self.containerView.transform = CGAffineTransformIdentity;
		}
	};
	
	if (animated) {
		[UIView animateWithDuration:0.3 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut) animations:animationBlock completion:nil];
	} else {
		animationBlock();
	}
}

#pragma mark - Configuring gestures

- (void)setGesturesEnabled:(BOOL)gesturesEnabled {
	if (gesturesEnabled == _gesturesEnabled) return;
	
	_gesturesEnabled = gesturesEnabled;
	
	self.screenEdgePanGestureRecognizer.enabled = _gesturesEnabled && self.useScreenEdgeInsteadOfNormalPan;
	self.panGestureRecognizer.enabled = _gesturesEnabled;
}

- (void)setUseScreenEdgeInsteadOfNormalPan:(BOOL)useScreenEdgeInsteadOfNormalPan {
	if (useScreenEdgeInsteadOfNormalPan == _useScreenEdgeInsteadOfNormalPan) return;
	
	_useScreenEdgeInsteadOfNormalPan = useScreenEdgeInsteadOfNormalPan;
	
	self.screenEdgePanGestureRecognizer.enabled = _useScreenEdgeInsteadOfNormalPan && self.gesturesEnabled;
}

@end
