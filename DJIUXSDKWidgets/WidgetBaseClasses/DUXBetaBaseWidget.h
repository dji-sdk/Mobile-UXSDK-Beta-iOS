//
//  DUXBetaBaseWidget.h
//  DJIUXSDK
//
//  MIT License
//
//  Copyright © 2018-2020 DJI
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

NS_ASSUME_NONNULL_BEGIN
@class DUXBetaTheme;

typedef struct {
// Use this aspect ratio for best appearance, we plan on images being resizable
    CGFloat preferredAspectRatio;
    CGFloat minimumWidth;
    CGFloat minimumHeight;
} DUXBetaWidgetSizeHint;

@interface DUXBetaBaseWidget : UIViewController

// Base class returns {CGFLOAT_MAX, CGFLOAT_MIN, CGFLOAT_MIN}, override this based
// on your widgets specific sizing needs
// This is NOT used by the widget's internal implementation, but is instead offered as an aid to developers who want to ensure acceptable appearance
// We may decide to include an assert to force developers, both internal and external to DJI, to provide a proper implementation for this method
// This property is now now required to be implemented properly for use of widgets in a Panel
@property (assign, nonatomic) DUXBetaWidgetSizeHint widgetSizeHint;

- (void)installInViewController:(nullable UIViewController *)viewController;

// The default implementation of this method does nothing
// For custom widgets this will be called by the parent widget to allow you to specify layout
- (void)layoutWidgetInView:(UIView *)view;

- (void)installInViewController:(nullable UIViewController *)viewController
                  insideSubview:(nullable UIView *)subview;

// Two methods which are used for Panels. If the widget is used in a HorizontalNamedBar or a VerticalNameBar,
// one of these MUST return a non-nil result. DUXBetaBaseWidget implements a nil result for both.
- (NSString* _Nullable)widgetTitle;
- (UIImage* _Nullable)widgetIcon;

// Identification methods for widgets. Default value is the class name
- (void)setIdentifier:(NSString*) identifier;
- (NSString*)identifier;

// Utility methods for widgets
- (CGSize)maxSizeInImageArray:(NSArray *)inputArray;

@end

NS_ASSUME_NONNULL_END
