//
//  DUXBetaBaseWidget.m
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

#import "DUXBetaBaseWidget.h"

@interface DUXBetaBaseWidget ()

@property (nonatomic, strong) DUXBetaTheme *perWidgetTheme;
@property (nonatomic, strong) NSString *widgetID;

@end

@implementation DUXBetaBaseWidget

- (instancetype) init {
    self = [super init];
    [self setIdentifier:NSStringFromClass([self class])]; // Dispatch in case somebody overrides the setWidgetIdentifier in a subclass
    return self;
}

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
        [subview addSubview:self.view];
    } else {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }
    [self didMoveToParentViewController:viewController];
}

- (void)layoutWidgetInView:(UIView *)view {
    // TODO 
}

- (NSString*)widgetTitle {
    return nil;
}

- (UIImage*)widgetIcon {
    return nil;
}

#pragma mark - Identification Methods

- (void)setIdentifier:(NSString*) identifier {
    _widgetID = identifier;
}

- (NSString*)identifier {
    return _widgetID;
}

#pragma mark - Utility Methods

- (CGSize)maxSizeInImageArray:(NSArray *)inputArray{
    CGSize containingSize = CGSizeZero;
    for (UIImage *anImage in inputArray) {
        if (anImage.size.width > containingSize.width) {
            containingSize.width = anImage.size.width;
        }
        if (anImage.size.height > containingSize.height) {
            containingSize.height = anImage.size.height;
        }
    }
    return containingSize;
}

@end
