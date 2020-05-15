//
//  DUXBetaCompassGyroHorizonLayer.m
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

#import "DUXBetaCompassGyroHorizonLayer.h"

#define DEGREES_TO_RADIANS(degrees) (degrees * M_PI / 180.0)
#define RADIANS_TO_DEGREES(radians) (radians * 180.0 / M_PI)

@implementation DUXBetaCompassGyroHorizonLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.roll = 0;
        self.pitch = 0;
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.strokeColor = [UIColor clearColor].CGColor;
        self.opaque = NO;
    }
    return self;
}

- (void)updatePitch:(CGFloat)pitch roll:(CGFloat)roll {
    self.pitch = pitch;
    self.roll = roll;
    [self setNeedsDisplay];
}

- (void)setPitch:(CGFloat)pitch {
    _pitch = pitch;
    [self setNeedsDisplay];
}

- (void)setRoll:(CGFloat)roll {
    _roll = roll;
    [self setNeedsDisplay];
}

- (CGPoint)center {
    return CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
}

- (void)drawInContext:(CGContextRef)context {
    CGFloat radius = self.bounds.size.width / 2.0;
    CGPoint center = CGPointMake(radius, radius);
    
    CGFloat startingDegree = 360 + self.pitch + self.roll;
    CGFloat endingDegree = 180 - self.pitch + self.roll;
    
    CGFloat startAngle = DEGREES_TO_RADIANS(startingDegree);
    CGFloat endAngle = DEGREES_TO_RADIANS(endingDegree);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.path = path.CGPath;
}

@end
