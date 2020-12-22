//
//  DUXBetaCompassAircraftVisionLayer.m
//  UXSDKCore
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

#import "DUXBetaCompassAircraftVisionLayer.h"
#import "DUXBetaCompassLayer.h"

#define DEGREES_TO_RADIANS(degrees) (degrees * M_PI / 180.0)
#define RADIANS_TO_DEGREES(radians) (radians * 180.0 / M_PI)

@interface DUXBetaCompassAircraftVisionLayer ()

@property (nonatomic, strong) CALayer *aircraft;
@property (nonatomic, strong) CALayer *vision;

@property (nonatomic, assign) CGFloat heading;
@property (nonatomic, assign) CGFloat yaw;

@end

@implementation DUXBetaCompassAircraftVisionLayer

@synthesize aircraftImage = _aircraftImage;
@synthesize visionImage = _visionImage;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareLayer];
    }
    return self;
}

- (void)prepareLayer {
    self.aircraft = [CALayer layer];
    self.aircraft.contentsGravity = kCAGravityResizeAspect;
    self.aircraft.frame = CGRectMake(0, 0, self.compassLayer.aircraftSize.width, self.compassLayer.aircraftSize.height);
    self.aircraft.contentsScale = [UIScreen mainScreen].scale;
    self.aircraft.zPosition = 1024;
    [self addSublayer:self.aircraft];
    
    self.vision = [CALayer layer];
    self.vision.frame = CGRectMake(self.aircraft.frame.origin.x, self.aircraft.frame.origin.y, self.compassLayer.visionConeSize.width, self.compassLayer.visionConeSize.height);
    self.vision.contentsScale = [UIScreen mainScreen].scale;
    self.vision.anchorPoint = CGPointMake(0.5, 1);
    self.vision.zPosition = 1023;
    [self addSublayer:self.vision];

    self.frame = self.aircraft.frame;
    
    [self setNeedsDisplay];
}

- (void)layoutSublayers {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    [super layoutSublayers];
    
    [self updateHeading:self.heading];
    [self updateGimbalYaw:self.yaw];

    // Updating Sizes
    CGFloat aircraftAspectRatio = self.compassLayer.aircraftSize.width / self.compassLayer.aircraftSize.height;
    CGFloat aircraftToCompassRatio = self.compassLayer.aircraftSize.width / self.compassLayer.designSize.width;
    CGFloat aircraftWidth = self.compassLayer.frame.size.width * aircraftToCompassRatio;
    CGFloat aircraftHeight = aircraftWidth / aircraftAspectRatio;
    self.aircraft.bounds = CGRectMake(0, 0, aircraftWidth, aircraftHeight);
    
    CGFloat visionAspectRatio = self.compassLayer.visionConeSize.width / self.compassLayer.visionConeSize.height;
    CGFloat visionToCompassRatio = self.compassLayer.visionConeSize.width / self.compassLayer.designSize.width;
    CGFloat visionWidth = self.compassLayer.frame.size.width * visionToCompassRatio;
    CGFloat visionHeight = visionWidth / visionAspectRatio;
    self.vision.bounds = CGRectMake(0, 0, visionWidth, visionHeight);

    self.bounds = CGRectMake(0, 0, self.aircraft.frame.size.width, self.aircraft.frame.size.height);
    self.aircraft.position = CGPointMake(CGRectGetMidX(self.bounds) , CGRectGetMidY(self.bounds));
    self.vision.position = self.aircraft.position;
    
    [CATransaction commit];
}

- (void)updateHeading:(CGFloat)heading {
    self.heading = heading;
    CGFloat radians = DEGREES_TO_RADIANS(heading);
    self.transform = CATransform3DIdentity;
    self.transform = CATransform3DMakeRotation(radians, 0, 0, 1.0);
}

- (void)updateGimbalYaw:(CGFloat)yaw {
    self.yaw = yaw;
    CGFloat radians = DEGREES_TO_RADIANS(yaw);
    self.vision.transform = CATransform3DIdentity;
    self.vision.transform = CATransform3DMakeRotation(radians, 0, 0, 1.0);
}

- (void)setAircraftImage:(UIImage *)aircraftImage {
    _aircraftImage = aircraftImage;
    self.aircraft.contents = (__bridge id _Nullable)(_aircraftImage.CGImage);
    [self setNeedsDisplay];
}

- (UIImage *)aircraftImage {
    return _aircraftImage;
}

- (void)setVisionImage:(UIImage *)visionImage {
    _visionImage = visionImage;
    self.vision.contents = (__bridge id _Nullable)_visionImage.CGImage;
    [self setNeedsDisplay];
}

- (UIImage *)visionImage {
    return _visionImage;
}

@end
