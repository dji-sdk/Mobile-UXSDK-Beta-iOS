//
//  UISwitch+BackgroundHelper.m
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2020 DJI
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

#import "UISwitch+DUXBetaBackgroundHelper.h"
#import <objc/runtime.h>

/**
 * The class DUXBetaSwitchControlAdaptorView is a custom UIView used internally to support the iOS13Backgrounds category for
 * the UX SDK 5. It is used to contain a UISwitch and allow the placement of a background ring around the switch which can
 * be colorized to match the standard interface used in UX SDK 4 and UX SDK 5.
 * This class
 */
@interface DUXBetaSwitchControlAdaptorView : UIView
@end

@implementation DUXBetaSwitchControlAdaptorView
@end

@implementation UISwitch (iOS13Backgrounds)

- (UIView*)setupOutlineViewForUISwitch {
    if (@available(iOS 13, *)) {
        UIView *aView = [[UIView alloc] initWithFrame:self.bounds];
        aView.translatesAutoresizingMaskIntoConstraints = NO;

        DUXBetaSwitchControlAdaptorView *switchBackingView = [[DUXBetaSwitchControlAdaptorView alloc] initWithFrame:self.bounds];
        switchBackingView.translatesAutoresizingMaskIntoConstraints = NO;
        [aView addSubview:self];
        [aView insertSubview:switchBackingView belowSubview:self];
        
        [aView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [aView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [aView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        [aView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;

        [switchBackingView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [switchBackingView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [switchBackingView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        [switchBackingView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;

        switchBackingView.layer.cornerRadius = switchBackingView.bounds.size.height / 2;
        switchBackingView.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.3] CGColor];   // This matches the default iOS 13 coloration.
        switchBackingView.layer.borderWidth = 2.0;
        
        return aView;
    } else {
        return self;

    }
}

- (void)setupCustomSwitchColorsOnTint:(UIColor*)onTint offTint:(UIColor*)offTint trackColor:(UIColor*)trackColor {
    if (@available(iOS 13, *)) {
        DUXBetaSwitchControlAdaptorView *backingView = nil;
        for (UIView *v in self.superview.subviews) {
            if ([v isMemberOfClass: [DUXBetaSwitchControlAdaptorView class]]) {
                backingView = (DUXBetaSwitchControlAdaptorView*)v;
                break;
            }
        }

        if (backingView) {
            backingView.layer.borderColor = [trackColor CGColor];
            backingView.layer.borderWidth = 2.0;
            backingView.layer.cornerRadius = backingView.bounds.size.height / 2;
            backingView.backgroundColor = offTint ? offTint : [UIColor clearColor];
        }
    } else {
        self.layer.cornerRadius = self.bounds.size.height / 2;
        self.backgroundColor = offTint;
    }
    
    self.onTintColor = onTint;
}

- (UIView*)viewForLayout {
    DUXBetaSwitchControlAdaptorView *backingView = nil;
    if (@available(iOS 13, *)) {
        DUXBetaSwitchControlAdaptorView *backingView = nil;
        for (UIView *v in self.superview.subviews) {
            if ([v isMemberOfClass: [DUXBetaSwitchControlAdaptorView class]]) {
                backingView = (DUXBetaSwitchControlAdaptorView*)v;
                break;
            }
        }
    }
    return backingView ? backingView : self;
}

@end
