//
//  DUXBetaHeadingLayer.m
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
#import "DUXBetaHeadingLayer.h"

#define DEGREES_TO_RADIANS(degrees) (degrees * M_PI / 180.0)

static const CGFloat kDurationBlink = 0.2;

@interface DUXBetaHeadingLayer ()

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat sweepAngle;

@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation DUXBetaHeadingLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.opaque = NO;
    }
    return self;
}

- (void)dealloc {
    [self invalidateAnimationTimer];
}

#pragma Public methods

- (void)showStartAngle:(CGFloat)startAngle withSweepAngle:(CGFloat)sweepAngle {
    self.startAngle = startAngle;
    self.sweepAngle = sweepAngle;
    self.currentColor = self.mainColor;
    
    [self invalidateAnimationTimer];
    
    [self setNeedsLayout];
}

- (void)animateStartAngle:(CGFloat)startAngle withSweepAngle:(CGFloat)sweepAngle {
    self.startAngle = startAngle;
    self.sweepAngle = sweepAngle;
    self.currentColor = self.mainColor;
    
    [self startAnimationTimer];
    
    [self setNeedsLayout];
}

#pragma Public methods

- (void)layoutSublayers {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    [super layoutSublayers];
        
    self.strokeColor = self.currentColor.CGColor;
    
    CGFloat radius = self.bounds.size.width / 2.0;
    CGPoint center = CGPointMake(radius, radius);

    CGFloat rotation = (- 1) * 90;
    CGFloat startingDegree = rotation + self.startAngle;
    CGFloat endingDegree = startingDegree + self.sweepAngle;

    CGFloat startAngle = DEGREES_TO_RADIANS(startingDegree);
    CGFloat endAngle = DEGREES_TO_RADIANS(endingDegree);
    
    BOOL clockwise = startAngle <= endAngle;

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:startAngle
                                                      endAngle:endAngle
                                                     clockwise:clockwise];
    self.path = path.CGPath;
    
    [CATransaction commit];
}

#pragma Amimation related methods

- (NSTimer * _Nonnull)startAnimationTimer {
    return self.timer = [NSTimer scheduledTimerWithTimeInterval:kDurationBlink
                                                         target:self
                                                       selector:@selector(resetAnimation)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)resetAnimation {
    self.currentColor = (self.currentColor == self.mainColor) ? self.secondaryColor : self.mainColor;
    
    [self setNeedsLayout];
}

- (void)invalidateAnimationTimer {
    [self.timer invalidate];
    self.timer = nil;
}

@end
