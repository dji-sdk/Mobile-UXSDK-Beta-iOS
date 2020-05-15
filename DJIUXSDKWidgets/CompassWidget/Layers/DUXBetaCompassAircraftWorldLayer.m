//
//  DUXCompassGyroHorizonLayer.m
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

#import "DUXBetaCompassAircraftWorldLayer.h"
#import "DUXBetaCompassGyroHorizonLayer.h"
#import "DUXBetaCompassAircraftVisionLayer.h"
#import "DUXBetaCompassLayer.h"

#define DEGREES_TO_RADIANS(degrees) (degrees * M_PI / 180.0)
#define RADIANS_TO_DEGREES(radians) (radians * 180.0 / M_PI)

@interface DUXBetaCompassAircraftWorldLayer ()

@property (strong, nonatomic) CALayer *aircraftVisionContainer;
@property (strong, nonatomic) CALayer *northLayer;

@property CGFloat deviceHeading;

@end

@implementation DUXBetaCompassAircraftWorldLayer

@synthesize northImage = _northImage;
@synthesize homeImage = _homeImage;

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

    self.homeLayer = [CALayer layer];
    self.homeLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.homeLayer.contentsScale = [UIScreen mainScreen].scale;
    self.homeLayer.zPosition = 1025;
    [self addSublayer:self.homeLayer];
    
    self.aircraftVisionContainer = [CALayer layer];
    self.aircraftVisionContainer.zPosition = 1024;
    self.aircraftVisionLayer = [DUXBetaCompassAircraftVisionLayer layer];
    self.aircraftVisionLayer.compassLayer = self.compassLayer;
    self.aircraftVisionLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self.aircraftVisionContainer addSublayer: self.aircraftVisionLayer];
    [self addSublayer:self.aircraftVisionContainer];
    
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

    CGFloat homeAspectRatio = self.homeImage.size.width / self.homeImage.size.height;
    CGFloat homeToCompassRatio = self.compassLayer.homeIconSize.width / self.compassLayer.designSize.width;
    CGFloat homeWidth = self.compassLayer.frame.size.width * homeToCompassRatio;
    CGFloat homeHeight = homeWidth / homeAspectRatio;
    self.homeLayer.bounds = CGRectMake(0, 0, homeWidth, homeHeight);
    if (CGPointEqualToPoint(self.homeLayer.position, CGPointZero)) {
        self.homeLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    
    CGFloat aircraftVisionAspectRatio = self.compassLayer.visionConeSize.width / (self.compassLayer.visionConeSize.height + self.compassLayer.aircraftSize.height / 2);
    CGFloat aircraftVisionToCompassRatio = self.compassLayer.visionConeSize.width / self.compassLayer.designSize.width;
    CGFloat aircraftVisionWidth = self.compassLayer.frame.size.width * aircraftVisionToCompassRatio;
    CGFloat aircraftVisionHeight = aircraftVisionWidth / aircraftVisionAspectRatio;
    self.aircraftVisionLayer.bounds = CGRectMake(0, 0, aircraftVisionWidth, aircraftVisionHeight);
    if (CGPointEqualToPoint(self.aircraftVisionLayer.position, CGPointZero)) {
        self.aircraftVisionLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    
    // Adding circular mask
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    CGFloat proportionalPadding = self.compassLayer.maskPaddingSize / self.compassLayer.designSize.width * self.compassLayer.bounds.size.width;
    maskLayer.frame = CGRectMake(0, 0, self.compassLayer.bounds.size.width - proportionalPadding, self.compassLayer.bounds.size.height - proportionalPadding);
    maskLayer.position = CGPointMake(CGRectGetMidX(self.bounds) , CGRectGetMidY(self.bounds));
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.path = [UIBezierPath bezierPathWithOvalInRect:maskLayer.bounds].CGPath;
    self.aircraftVisionContainer.mask = maskLayer;
    
    [CATransaction commit];
}

- (void)applyDeviceHeading:(CGFloat)deviceHeading {
    self.deviceHeading = deviceHeading;
    CGFloat radians = DEGREES_TO_RADIANS(deviceHeading);
    self.transform = CATransform3DMakeRotation(radians, 0, 0, 1.0);
    self.homeLayer.transform = CATransform3DMakeRotation(-radians, 0, 0, 1.0);
    self.northLayer.transform = CATransform3DMakeRotation(-radians, 0, 0, 1.0);
}

- (void)setHomeImage:(UIImage *)homeImage {
    _homeImage = homeImage;
    self.homeLayer.contents = (__bridge id _Nullable)_homeImage.CGImage;
    [self setNeedsDisplay];
}

- (UIImage *)homeImage {
    return _homeImage;
}

- (void)setNorthImage:(UIImage *)northImage {
    _northImage = northImage;
    self.northLayer.contents = (__bridge id _Nullable)_northImage.CGImage;
    [self setNeedsDisplay];
}

- (UIImage *)northImage {
    return _northImage;
}

@end
