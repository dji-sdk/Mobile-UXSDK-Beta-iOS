//
//  DUXBetaCompassAircraftVisionLayer.m
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

#import "DUXBetaCompassAircraftYawLayer.h"
#import "DUXBetaCompassLayer.h"

#define DEGREES_TO_RADIANS(degrees) (degrees * M_PI / 180.0)

@interface DUXBetaCompassAircraftYawLayer ()

@property (nonatomic, strong) CALayer *aircraftLayer;
@property (nonatomic, strong) CALayer *gimbalYawLayer;
@property (nonatomic, assign) CGFloat gimbalHeading;
@property (nonatomic, assign) CGFloat aircraftHeading;

@end

@implementation DUXBetaCompassAircraftYawLayer

@synthesize aircraftImage = _aircraftImage;
@synthesize gimbalYawImage = _gimbalYawImage;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareLayer];
    }
    return self;
}

- (void)prepareLayer {
    self.aircraftLayer = [CALayer layer];
    self.aircraftLayer.contentsGravity = kCAGravityResizeAspect;
    self.aircraftLayer.frame = CGRectMake(0, 0, self.compassLayer.aircraftSize.width, self.compassLayer.aircraftSize.height);
    self.aircraftLayer.contentsScale = [UIScreen mainScreen].scale;
    self.aircraftLayer.zPosition = 1024;
    [self addSublayer:self.aircraftLayer];
    
    self.gimbalYawLayer = [CALayer layer];
    self.gimbalYawLayer.frame = CGRectMake(self.aircraftLayer.frame.origin.x, self.aircraftLayer.frame.origin.y, self.compassLayer.gimbalYawSize.width, self.compassLayer.gimbalYawSize.height);
    self.gimbalYawLayer.contentsScale = [UIScreen mainScreen].scale;
    self.gimbalYawLayer.anchorPoint = CGPointMake(0.5, 1);
    self.gimbalYawLayer.zPosition = 1023;
    [self addSublayer:self.gimbalYawLayer];

    self.frame = self.aircraftLayer.frame;
    
    [self setNeedsDisplay];
}

- (void)layoutSublayers {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    [super layoutSublayers];
    
    [self updateAircraftHeading:self.aircraftHeading];
    [self updateGimbalHeading:self.gimbalHeading];

    // Updating Sizes
    CGFloat aircraftAspectRatio = self.compassLayer.aircraftSize.width / self.compassLayer.aircraftSize.height;
    CGFloat aircraftToCompassRatio = self.compassLayer.aircraftSize.width / self.compassLayer.designSize.width;
    CGFloat aircraftWidth = self.compassLayer.frame.size.width * aircraftToCompassRatio;
    CGFloat aircraftHeight = aircraftWidth / aircraftAspectRatio;
    self.aircraftLayer.bounds = CGRectMake(0, 0, aircraftWidth, aircraftHeight);
    
    CGFloat gimbalAspectRatio = self.compassLayer.gimbalYawSize.width / self.compassLayer.gimbalYawSize.height;
    CGFloat gimbalToCompassRatio = self.compassLayer.gimbalYawSize.width / self.compassLayer.designSize.width;
    CGFloat gimbalWidth = self.compassLayer.frame.size.width * gimbalToCompassRatio;
    CGFloat gimbalHeight = gimbalWidth / gimbalAspectRatio;
    self.gimbalYawLayer.bounds = CGRectMake(0, 0, gimbalWidth, gimbalHeight);

    self.bounds = CGRectMake(0, 0, self.aircraftLayer.frame.size.width, self.aircraftLayer.frame.size.height);
    self.aircraftLayer.position = CGPointMake(CGRectGetMidX(self.bounds) , CGRectGetMidY(self.bounds));
    self.gimbalYawLayer.position = self.aircraftLayer.position;
    
    [CATransaction commit];
}

- (void)updateAircraftHeading:(CGFloat)heading {
    self.aircraftHeading = heading;
    CGFloat radians = DEGREES_TO_RADIANS(heading);
    self.transform = CATransform3DIdentity;
    self.transform = CATransform3DMakeRotation(radians, 0, 0, 1.0);
}

- (void)updateGimbalHeading:(CGFloat)heading {
    self.gimbalHeading = heading;
    CGFloat radians = DEGREES_TO_RADIANS(heading);
    self.gimbalYawLayer.transform = CATransform3DIdentity;
    self.gimbalYawLayer.transform = CATransform3DMakeRotation(radians, 0, 0, 1.0);
}

#pragma mark - Custom Setters and Getters

- (void)setAircraftImage:(UIImage *)aircraftImage {
    _aircraftImage = aircraftImage;
    self.aircraftLayer.contents = (__bridge id _Nullable)(_aircraftImage.CGImage);
    [self setNeedsDisplay];
}

- (UIImage *)aircraftImage {
    return _aircraftImage;
}

- (void)setGimbalYawImage:(UIImage *)image {
    _gimbalYawImage = image;
    self.gimbalYawLayer.contents = (__bridge id _Nullable)_gimbalYawImage.CGImage;
    [self setNeedsDisplay];
}

- (UIImage *)gimbalYawImage {
    return _gimbalYawImage;
}

- (void)setAircraftBackgroundColor:(UIColor *)aircraftBackgroundColor {
    self.aircraftLayer.backgroundColor = aircraftBackgroundColor.CGColor;
}

- (UIColor *)aircraftBackgroundColor {
    return [UIColor colorWithCGColor:self.aircraftLayer.backgroundColor];
}

- (void)setGimbalYawBackgroundColor:(UIColor *)gimbalYawBackgroundColor {
    self.gimbalYawLayer.backgroundColor = gimbalYawBackgroundColor.CGColor;
}

- (UIColor *)gimbalYawBackgroundColor {
    return [UIColor colorWithCGColor:self.gimbalYawLayer.backgroundColor];
}

@end
