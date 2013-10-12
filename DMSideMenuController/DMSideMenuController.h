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


@import UIKit;


@interface DMSideMenuController : UIViewController

// These values can't be changed after the view is loaded
@property (nonatomic) CGFloat menuWidth;  // default is 320
@property (nonatomic) CGFloat overlapWidth;  // default is 50

@property (nonatomic, getter = isMenuOpen) BOOL menuOpen;  // default is NO
- (void)setMenuOpen:(BOOL)menuOpen animated:(BOOL)animated;

@property (strong, nonatomic) UIViewController *mainViewController;  // default is nil
@property (strong, nonatomic) UIViewController *menuViewController;  // default is nil

@property (nonatomic) BOOL gesturesEnabled;                  // default is YES
@property (nonatomic) BOOL useScreenEdgeInsteadOfNormalPan;  // default is NO

@end
