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


@interface DMSideMenuController ()

@property (strong, nonatomic) UIViewController *containerViewController;

@property (strong, readonly, nonatomic) UIGestureRecognizer *panGestureRecognizer;
@property (strong, readonly, nonatomic) UIGestureRecognizer *tapGestureRecognizer;

@property (nonatomic) CGFloat beginningTranslationX;

@end


@implementation DMSideMenuController

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
	
	_containerViewController = [[UIViewController alloc] init];
	
	_panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	
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
	
	
	[self addChildViewController:self.containerViewController];
	
	self.containerViewController.view.backgroundColor = [UIColor whiteColor];
	
	self.containerViewController.view.frame = self.view.bounds;
	self.containerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	self.containerViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
	self.containerViewController.view.layer.shadowOpacity = 0.7;
	self.containerViewController.view.layer.shadowOffset = CGSizeZero;
	self.containerViewController.view.layer.shadowRadius = 2;
	
	[self.containerViewController.view addGestureRecognizer:self.panGestureRecognizer];
	[self.containerViewController.view addGestureRecognizer:self.tapGestureRecognizer];
	
	[self.view addSubview:self.containerViewController.view];
	
	[self.containerViewController didMoveToParentViewController:self];
}

#pragma mark - Handling gestures

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
	switch (panGestureRecognizer.state) {
		case UIGestureRecognizerStateBegan: {
			self.beginningTranslationX = self.containerViewController.view.transform.tx;
		}
			break;
			
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded: {
			CGFloat vx = [panGestureRecognizer velocityInView:self.containerViewController.view].x;
			
			CGFloat threshold = self.menuWidth / 3;
			
			BOOL menuOpen = (self.containerViewController.view.transform.tx > (self.menuWidth - self.overlapWidth) / 2 && vx > -threshold) || vx > threshold;
			
			[self setMenuOpen:menuOpen animated:YES];
		}
			break;
			
		default: {
			CGFloat tx = [panGestureRecognizer translationInView:self.containerViewController.view].x + self.beginningTranslationX;
			
			if (tx > self.menuWidth) tx = self.menuWidth;
			
			if (tx < 0) tx = 0;
			
			self.containerViewController.view.transform = CGAffineTransformMakeTranslation(tx, 0);
		}
			break;
	}
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer {
	[self setMenuOpen:NO animated:YES];
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
		[self.containerViewController addChildViewController:_mainViewController];
		
		_mainViewController.view.transform = CGAffineTransformIdentity;
		_mainViewController.view.frame = self.containerViewController.view.bounds;
		_mainViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		[self.containerViewController.view addSubview:_mainViewController.view];
		
		[_mainViewController didMoveToParentViewController:self.containerViewController];
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
		
		[self.view insertSubview:_menuViewController.view belowSubview:self.containerViewController.view];
		
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
			self.containerViewController.view.transform = CGAffineTransformMakeTranslation(self.menuWidth - self.overlapWidth, 0);
		} else {
			self.containerViewController.view.transform = CGAffineTransformIdentity;
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
	
	self.panGestureRecognizer.enabled = _gesturesEnabled;
}

@end
