//
//  DUXBetaBaseWidget.m
//  DJIUXSDK
//
//  MIT License
//  
//  Copyright © 2018-2019 DJI
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

#import "DUXBetaBaseWidget.h"

@interface DUXBetaBaseWidget ()

@end

@implementation DUXBetaBaseWidget

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {CGFLOAT_MAX, CGFLOAT_MIN, CGFLOAT_MIN};
    
    
    NSAssert(NO, @"This method must be overriden");
    
    return hint;
}

- (void)installInViewController:(nullable UIViewController *)viewController {
    [self installInViewController:viewController
                    insideSubview:viewController.view];
}

- (void)installInViewController:(nullable UIViewController *)viewController
                  insideSubview:(nullable UIView *)subview {
    [self willMoveToParentViewController:viewController];
    if (viewController && subview) {
        [viewController addChildViewController:self];
        [viewController.view addSubview:self.view];
    } else {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }
    [self didMoveToParentViewController:viewController];
}

- (void)layoutWidgetInView:(UIView *)view {
    // To be
}

@end
