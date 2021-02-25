//
//  DUXBetaCompassGyroHorizonLayer.m
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2018-2021 DJI
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

#import "DUXBetaCompassAircraftWorldLayer.h"
#import "DUXBetaCompassGyroHorizonLayer.h"
#import "DUXBetaCompassAircraftYawLayer.h"
#import "DUXBetaCompassLayer.h"

#define DEGREES_TO_RADIANS(degrees) (degrees * M_PI / 180.0)

@interface DUXBetaCompassAircraftWorldLayer ()

@property (strong, nonatomic) CALayer *northLayer;
@property (strong, nonatomic) CALayer *aircraftYawContainer;

@property (nonatomic, readwrite) DUXBetaCompassAircraftYawLayer *aircraftYawLayer;

@property CGFloat deviceHeading;

@end

@implementation DUXBetaCompassAircraftWorldLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareLayer];
    }
    return self;
}

- (void)prepareLayer {
    self.northLayer = [CALayer layer];
    self.northLayer.contentsScale = [UIScreen mainScreen].scale;
    self.northLayer.frame = CGRectMake(0, 0, self.northImage.size.width, self.northImage.size.height);
    self.northLayer.zPosition = 1025;
    [self addSublayer:self.northLayer];

    self.centerLayer = [CALayer layer];
    self.centerLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.centerLayer.contentsScale = [UIScreen mainScreen].scale;
    self.centerLayer.zPosition = 1023;
    [self addSublayer:self.centerLayer];
    
    self.secondLayer = [CALayer layer];
    self.secondLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.secondLayer.contentsScale = [UIScreen mainScreen].scale;
    self.secondLayer.zPosition = 1023;
    [self addSublayer:self.secondLayer];
    
    self.aircraftYawContainer = [CALayer layer];
    self.aircraftYawContainer.zPosition = 1024;
    self.aircraftYawLayer = [DUXBetaCompassAircraftYawLayer layer];
    self.aircraftYawLayer.compassLayer = self.compassLayer;
    self.aircraftYawLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self.aircraftYawContainer addSublayer: self.aircraftYawLayer];
    [self addSublayer:self.aircraftYawContainer];
    
    [self setNeedsDisplay];
}

- (void)layoutSublayers {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    [super layoutSublayers];
    
    // Updating Sizes
    CGFloat northAspectRatio = self.northImage.size.width / self.northImage.size.height;
    CGFloat northToCompassRatio = self.compassLayer.northIconSize.width / self.compassLayer.designSize.width;
    CGFloat northWidth = self.compassLayer.frame.size.width * northToCompassRatio;
    CGFloat northHeight = northWidth / northAspectRatio;
    self.northLayer.bounds = CGRectMake(0, 0, northWidth, northHeight);
    self.northLayer.position = CGPointMake(CGRectGetMidX(self.frame), self.northLayer.bounds.size.height/2);
    self.northLayer.cornerRadius = self.bounds.size.width / 2;

    CGFloat centerAspectRatio = self.centerImage.size.width / self.centerImage.size.height;
    CGFloat centerToCompassRatio = self.compassLayer.centerImageSize.width / self.compassLayer.designSize.width;
    CGFloat centerWidth = self.compassLayer.frame.size.width * centerToCompassRatio;
    CGFloat centerHeight = centerWidth / centerAspectRatio;
    self.centerLayer.bounds = CGRectMake(0, 0, centerWidth, centerHeight);
    if (CGPointEqualToPoint(self.centerLayer.position, CGPointZero)) {
        self.centerLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    
    CGFloat secondAspectRatio = self.secondImage.size.width / self.secondImage.size.height;
    CGFloat secondToCompassRatio = self.compassLayer.secondImageSize.width / self.compassLayer.designSize.width;
    CGFloat secondWidth = self.compassLayer.frame.size.width * secondToCompassRatio;
    CGFloat secondHeight = secondWidth / secondAspectRatio;
    self.secondLayer.bounds = CGRectMake(0, 0, secondWidth, secondHeight);
    if (CGPointEqualToPoint(self.secondLayer.position, CGPointZero)) {
        self.secondLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    
    CGFloat aircraftVisionAspectRatio = self.compassLayer.gimbalYawSize.width / (self.compassLayer.gimbalYawSize.height + self.compassLayer.aircraftSize.height / 2);
    CGFloat aircraftVisionToCompassRatio = self.compassLayer.gimbalYawSize.width / self.compassLayer.designSize.width;
    CGFloat aircraftVisionWidth = self.compassLayer.frame.size.width * aircraftVisionToCompassRatio;
    CGFloat aircraftVisionHeight = aircraftVisionWidth / aircraftVisionAspectRatio;
    self.aircraftYawLayer.bounds = CGRectMake(0, 0, aircraftVisionWidth, aircraftVisionHeight);
    if (CGPointEqualToPoint(self.aircraftYawLayer.position, CGPointZero)) {
        self.aircraftYawLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    
    // Adding circular mask
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    CGFloat proportionalPadding = self.compassLayer.maskMargin / self.compassLayer.designSize.width * self.compassLayer.bounds.size.width;
    maskLayer.frame = CGRectMake(0, 0, self.compassLayer.bounds.size.width - proportionalPadding, self.compassLayer.bounds.size.height - proportionalPadding);
    maskLayer.position = CGPointMake(CGRectGetMidX(self.bounds) , CGRectGetMidY(self.bounds));
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.path = [UIBezierPath bezierPathWithOvalInRect:maskLayer.bounds].CGPath;
    self.aircraftYawContainer.mask = maskLayer;
    
    [CATransaction commit];
}

- (void)applyDeviceHeading:(CGFloat)deviceHeading {
    self.deviceHeading = deviceHeading;
    CGFloat radians = DEGREES_TO_RADIANS(deviceHeading);
    self.transform = CATransform3DMakeRotation(radians, 0, 0, 1.0);
    self.northLayer.transform = CATransform3DMakeRotation(-radians, 0, 0, 1.0);
    self.centerLayer.transform = CATransform3DMakeRotation(-radians, 0, 0, 1.0);
    self.secondLayer.transform = CATransform3DMakeRotation(-radians, 0, 0, 1.0);
}

#pragma mark - Custom Setters and Getters

- (void)setNorthImage:(UIImage *)northImage {
    _northImage = northImage;
    self.northLayer.contents = (__bridge id _Nullable)_northImage.CGImage;
    [self setNeedsDisplay];
}

- (void)setCenterImage:(UIImage *)centerImage {
    _centerImage = centerImage;
    self.centerLayer.contents = (__bridge id _Nullable)_centerImage.CGImage;
    [self setNeedsDisplay];
}

- (void)setSecondImage:(UIImage *)secondImage {
    _secondImage = secondImage;
    self.secondLayer.contents = (__bridge id _Nullable)_secondImage.CGImage;
    [self setNeedsDisplay];
}

- (void)setNorthBackgroundColor:(UIColor *)northBackgroundColor {
    self.northLayer.backgroundColor = northBackgroundColor.CGColor;
}

- (UIColor *)northBackgroundColor {
    return [UIColor colorWithCGColor:self.northLayer.backgroundColor];
}

- (void)setCenterBackgroundColor:(UIColor *)centerBackgroundColor {
    self.centerLayer.backgroundColor = centerBackgroundColor.CGColor;
}

- (UIColor *)centerBackgroundColor {
    return [UIColor colorWithCGColor:self.centerLayer.backgroundColor];
}

- (void)setSecondBackgroundColor:(UIColor *)secondBackgroundColor {
    self.secondLayer.backgroundColor = secondBackgroundColor.CGColor;
}

- (UIColor *)secondBackgroundColor {
    return [UIColor colorWithCGColor:self.secondLayer.backgroundColor];
}

@end
