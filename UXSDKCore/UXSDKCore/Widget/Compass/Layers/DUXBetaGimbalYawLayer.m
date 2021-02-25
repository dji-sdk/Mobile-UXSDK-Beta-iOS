//
//  DUXBetaGimbalYawLayer.m
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2021 DJI
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
#import "DUXBetaGimbalYawLayer.h"
#import "DUXBetaHeadingLayer.h"

static const CGFloat kDeadAngle = 30.0;
static const CGFloat kHideAngle = 90.0;
static const CGFloat kShowAngle = 190.0;
static const CGFloat kBlinkAngle = 270.0;

@interface DUXBetaGimbalYawLayer ()

@property (nonatomic, strong) DUXBetaHeadingLayer *validLayer;
@property (nonatomic, strong) DUXBetaHeadingLayer *invalidLayer;

@end

@implementation DUXBetaGimbalYawLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.strokeColor = [UIColor clearColor].CGColor;
        
        [self prepareLayers];
    }
    return self;
}

- (void)prepareLayers {
    self.validLayer = [DUXBetaHeadingLayer layer];
    self.validLayer.zPosition = 1019;
    self.validLayer.fillColor = [UIColor clearColor].CGColor;
    [self addSublayer:self.validLayer];
    
    self.invalidLayer = [DUXBetaHeadingLayer layer];
    self.invalidLayer.zPosition = 1019;
    self.invalidLayer.fillColor = [UIColor clearColor].CGColor;
    [self addSublayer:self.invalidLayer];
}

- (void)setYaw:(CGFloat)yaw {
    if (yaw == _yaw) { return; }
    _yaw = yaw;
    
    BOOL beforeShow = NO;
    CGFloat absYaw = 0.0;
    CGFloat yawStartAngle = 0.0;
    CGFloat yawSweepAngle = 0.0;
    CGFloat invalidStartAngle = 0.0;
    CGFloat invalidSweepAngle = kDeadAngle;
    
    absYaw = self.yaw >= 0 ? self.yaw : 0 - self.yaw;
    if (absYaw >= kShowAngle) {
        beforeShow = YES;
    } else if (absYaw < kHideAngle) {
        beforeShow = NO;
    }
    
    if (self.yaw < 0) {
        yawStartAngle = self.yaw;
        yawSweepAngle = 0 - self.yaw;
    } else {
        invalidStartAngle = 0 - kDeadAngle;
        yawSweepAngle = self.yaw;
    }
    
    if (absYaw > kBlinkAngle) {
        [self.invalidLayer animateStartAngle:invalidStartAngle withSweepAngle:invalidSweepAngle];
    } else if (beforeShow) {
        [self.invalidLayer showStartAngle:invalidStartAngle withSweepAngle:invalidSweepAngle];
    }
    
    [self.validLayer showStartAngle:yawStartAngle withSweepAngle:yawSweepAngle];
}

- (void)layoutSublayers {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    [super layoutSublayers];
        
    self.validLayer.frame = self.bounds;
    self.validLayer.lineWidth = self.lineWidth;
    
    self.invalidLayer.frame = self.bounds;
    self.invalidLayer.lineWidth = self.lineWidth;
    
    [CATransaction commit];
}

#pragma mark - Custom Setters and Getters

- (void)setYawColor:(UIColor *)yawColor {
    self.validLayer.mainColor = yawColor;
}

- (UIColor *)yawColor {
    return self.validLayer.mainColor;
}

- (void)setInvalidColor:(UIColor *)invalidColor {
    self.invalidLayer.mainColor = invalidColor;
}

- (UIColor *)invalidColor {
    return self.invalidLayer.mainColor;;
}

- (void)setBlinkColor:(UIColor *)blinkColor {
    self.invalidLayer.secondaryColor = blinkColor;
}

- (UIColor *)blinkColor {
    return self.invalidLayer.secondaryColor;
}

@end
