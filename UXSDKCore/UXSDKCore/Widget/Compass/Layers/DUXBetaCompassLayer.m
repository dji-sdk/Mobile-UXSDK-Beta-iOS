//
//  DUXBetaCompassLayer.m
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

#import <UIKit/UIKit.h>

#import "DUXBetaCompassLayer.h"
#import "DUXBetaCompassAircraftVisionLayer.h"
#import "DUXBetaCompassGyroHorizonLayer.h"
#import "DUXBetaCompassAircraftWorldLayer.h"

#define DEGREES_TO_RADIANS(degrees) (degrees * M_PI / 180.0)
#define RADIANS_TO_DEGREES(radians) (radians * 180.0 / M_PI)

static const CGFloat kDefaultRadiusSizeInMeters = 400; // distance in meters
static const CGFloat kDefaultInnerRingInterDistance = 100; // distance in meters
static const CGFloat kDesignInnerRingSpacingInPercentage = 0.25; // in a radius space

@interface DUXBetaCompassLayer ()

@property (strong, nonatomic) DUXBetaCompassGyroHorizonLayer *gyroHorizonLayer;
@property (strong, nonatomic) DUXBetaCompassAircraftWorldLayer *aircraftWorldLayer;
@property (strong, nonatomic) CALayer *notchLayer;
@property (strong, nonatomic) CAShapeLayer *borderLayer;
@property (strong, nonatomic) CAShapeLayer *crossHairsLayer;

/**
 *   The distance in meters represented by the radius of the compass.
 */
@property (nonatomic, assign) CGFloat radiusSize;
@property (nonatomic, assign) CGFloat ringsInterDistance; // interval between lines, default = 100m

@property (nonatomic, assign) CGFloat homeToRCDistance; // in meters
@property (nonatomic, assign) CGFloat aircraftToRCDistance; // in meters

@property CGFloat boundsOffset;
@property CGFloat homeAngle;
@property (strong, nonatomic) NSArray *innerRingDots;

@end

@implementation DUXBetaCompassLayer

@synthesize notchImage = _notchImage;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.homeToRCDistance = 0;
        self.aircraftToRCDistance = 0;
        self.ringsInterDistance = kDefaultInnerRingInterDistance;
        self.radiusSize = kDefaultRadiusSizeInMeters;
        
        self.aircraftWorldLayer = [DUXBetaCompassAircraftWorldLayer layer];
        self.aircraftWorldLayer.zPosition = 1023;
        self.aircraftWorldLayer.compassLayer = self;
        self.aircraftWorldLayer.aircraftVisionLayer.compassLayer = self;
        [self addSublayer:self.aircraftWorldLayer];
        
        self.gyroHorizonLayer = [DUXBetaCompassGyroHorizonLayer layer];
        self.gyroHorizonLayer.zPosition = 1022;
        [self addSublayer:self.gyroHorizonLayer];
        
        self.notchLayer = [CALayer layer];
        self.notchLayer.zPosition = 1022;
        [self addSublayer:self.notchLayer];
        
        self.crossHairsLayer = [CAShapeLayer layer];
        self.crossHairsLayer.zPosition = 1022;
        self.crossHairsLayer.fillColor = [UIColor clearColor].CGColor;
        [self addSublayer:self.crossHairsLayer];
        
        self.borderLayer = [CAShapeLayer layer];
        self.borderLayer.zPosition = 1021;
        self.borderLayer.fillColor = [UIColor clearColor].CGColor;
        [self addSublayer:self.borderLayer];
    }
    return self;
}

- (void)layoutSublayers {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    [super layoutSublayers];
    
    CGFloat notchAspectRatio = self.notchSize.width / self.notchSize.height;
    CGFloat notchToCompassRatio = self.notchSize.width / self.designSize.width;
    CGFloat notchWidth = self.frame.size.width * notchToCompassRatio;
    CGFloat notchHeight = notchWidth / notchAspectRatio;
    self.notchLayer.bounds = CGRectMake(0, 0, notchWidth, notchHeight);
    self.boundsOffset = self.notchLayer.bounds.size.height;
    self.notchLayer.position = CGPointMake(CGRectGetMidX(self.bounds), self.notchLayer.bounds.size.height);
    
    self.borderLayer.frame = self.bounds;
    CGFloat maxSize = MIN(self.bounds.size.width - 2 * self.boundsOffset, self.bounds.size.height - 2 * self.boundsOffset);
    CGFloat radius = maxSize / 2.0;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(center.x - radius, center.y - radius, maxSize, maxSize)];
    self.borderLayer.path = path.CGPath;
    self.borderLayer.lineWidth = 3 * self.frame.size.width / self.designSize.width;
    
    self.aircraftWorldLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    self.aircraftWorldLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.gyroHorizonLayer.frame = CGRectInset(self.bounds, self.boundsOffset * 1.25, self.boundsOffset * 1.25);
    
    self.crossHairsLayer.frame = CGRectMake(self.boundsOffset * 1.25, self.boundsOffset * 1.25, self.bounds.size.width - self.boundsOffset * 2.5, self.bounds.size.height - self.boundsOffset * 2.5);
    self.crossHairsLayer.path = [self pathForCrossHairs].CGPath;

    [CATransaction commit];
}

- (void)drawInContext:(CGContextRef)context {
    CGFloat maxSize = MIN(self.bounds.size.width - 2 * self.boundsOffset, self.bounds.size.height - 2 * self.boundsOffset);
    CGFloat radius = maxSize / 2.0;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // background circle
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(center.x - radius, center.y - radius, maxSize, maxSize)];
    
    CGFloat numberRingsNeeded = self.radiusSize / self.ringsInterDistance;
    CGFloat decimalPart = numberRingsNeeded - floor(numberRingsNeeded);
    CGFloat ringInterSpace = radius * kDesignInnerRingSpacingInPercentage;
    CGFloat innerRadius = radius - ringInterSpace * decimalPart;

    while (innerRadius >= 0) {
        UIBezierPath *innerCircle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(center.x - innerRadius, center.y - innerRadius, innerRadius * 2, innerRadius * 2)];
        [path appendPath:innerCircle];
        innerRadius -= ringInterSpace;
    }
    self.path = path.CGPath;
    self.lineWidth = self.frame.size.width / (self.designSize.width * 1.5);
    self.lineDashPattern = @[@(self.lineWidth * 3),@(self.lineWidth * 3),@(self.lineWidth * 3),@(self.lineWidth * 3)];
    self.crossHairsLayer.lineWidth = self.frame.size.width / (self.designSize.width * 1.5);
}

- (UIBezierPath *)pathForCrossHairs {
    UIBezierPath *crossPath = [UIBezierPath bezierPath];
    [crossPath moveToPoint:CGPointMake(CGRectGetMidX(self.crossHairsLayer.bounds), 0)];
    [crossPath addLineToPoint:CGPointMake(CGRectGetMidX(self.crossHairsLayer.bounds), CGRectGetMaxY(self.crossHairsLayer.bounds))];
    [crossPath moveToPoint:CGPointMake(0, CGRectGetMidY(self.crossHairsLayer.bounds))];
    [crossPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.crossHairsLayer.bounds), CGRectGetMidY(self.crossHairsLayer.bounds))];
    return crossPath;
}

/*********************************************************************************/
#pragma mark - Update methods
/*********************************************************************************/
- (void)updateHomeLocationUsingAngle:(CGFloat)angle andDistance:(CGFloat)distance {
    self.homeToRCDistance = distance;
    self.homeAngle = angle;
    
    // This is the scaling of the relative distance in the compass.
    CGFloat distancePercentage = distance / self.radiusSize; //
    if (distancePercentage > 1.0) {
        self.radiusSize *= distancePercentage;
        distancePercentage = 1.0;
    } else if (distancePercentage < 1.0 &&
               self.radiusSize > kDefaultRadiusSizeInMeters &&
               self.aircraftToRCDistance < kDefaultRadiusSizeInMeters) {
        self.radiusSize *= distancePercentage;
        
        if (self.radiusSize < kDefaultRadiusSizeInMeters) {
            self.radiusSize = kDefaultRadiusSizeInMeters;
        }
        
        distancePercentage = distance / self.radiusSize;
    }
    
    CGFloat proportionalEdgePadding = self.frame.size.width * (self.innerPadding / 2) / self.designSize.width;
    CGFloat distancePixels = distancePercentage * ((self.frame.size.width / 2) - proportionalEdgePadding);
    CGFloat adjustedAngle = angle - 90;
    
    CGFloat diameter = self.frame.size.width;
    CGFloat radius = diameter / 2.0;
    
    float droneToCenterX = distancePixels * cos(DEGREES_TO_RADIANS(adjustedAngle));
    float droneToCenterY = distancePixels * sin(DEGREES_TO_RADIANS(adjustedAngle));
    float drone_cx = radius + droneToCenterX;
    float drone_cy = droneToCenterY + diameter - radius;

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.aircraftWorldLayer.homeLayer.position = CGPointMake(drone_cx, drone_cy);
    [CATransaction commit];
    
    [self setNeedsDisplay];
}

- (void)updateAircraftLocationUsingAngle:(CGFloat)angle andDistance:(CGFloat)distance {
    self.aircraftToRCDistance = distance;
    
    // This is the scaling of the relative distance in the compass.
    CGFloat distancePercentage = distance / self.radiusSize;
    if (distancePercentage > 1.0) {
        self.radiusSize *= distancePercentage;
        [self updateHomeLocationUsingAngle:self.homeAngle andDistance:self.homeToRCDistance];
        distancePercentage = 1.0;
    } else if (distancePercentage < 1.0 &&
               self.radiusSize > kDefaultRadiusSizeInMeters &&
               self.homeToRCDistance < kDefaultRadiusSizeInMeters) {
        self.radiusSize *= distancePercentage;
        
        if (self.radiusSize < kDefaultRadiusSizeInMeters) {
            self.radiusSize = kDefaultRadiusSizeInMeters;
        }
        [self updateHomeLocationUsingAngle:self.homeAngle andDistance:self.homeToRCDistance];
        
        distancePercentage = distance / self.radiusSize;
    }
    
    CGFloat proportionalEdgePadding = self.frame.size.width * self.innerPadding / self.designSize.width;
    CGFloat distancePixels = distancePercentage * ((self.frame.size.width / 2) - proportionalEdgePadding);
    CGFloat adjustedAngle = angle - 90;
    
    CGFloat diameter = self.frame.size.width;
    CGFloat radius = diameter / 2.0;
    
    float droneToCenterX = distancePixels * cos(DEGREES_TO_RADIANS(adjustedAngle));
    float droneToCenterY = distancePixels * sin(DEGREES_TO_RADIANS(adjustedAngle));
    float drone_cx = radius + droneToCenterX;
    float drone_cy = droneToCenterY + diameter - radius;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.aircraftWorldLayer.aircraftVisionLayer.position = CGPointMake(drone_cx, drone_cy);
    [CATransaction commit];
    
    [self setNeedsDisplay];
}

- (void)updateAircraftRoll:(CGFloat)roll {
    [self.gyroHorizonLayer setRoll:roll];
    [self setNeedsDisplay];
}

- (void)updateAircraftPitch:(CGFloat)pitch {
    [self.gyroHorizonLayer setPitch:pitch];
    [self setNeedsDisplay];
}

- (void)updateAircraftYaw:(CGFloat)yaw {
    [self.aircraftWorldLayer.aircraftVisionLayer updateHeading:yaw];
    [self setNeedsDisplay];
}

- (void)updateGimbalYaw:(CGFloat)yaw {
    [self.aircraftWorldLayer.aircraftVisionLayer updateGimbalYaw:yaw];
    [self setNeedsDisplay];
}

- (void)updateDeviceHeading:(CGFloat)deviceHeading {
    [self.aircraftWorldLayer applyDeviceHeading:-deviceHeading];
    [self setNeedsDisplay];
}

/*
 Custom Setters and Getters for Colors
 */

- (void)setCompassBackgroundColor:(UIColor *)compassBackgroundColor {
    self.fillColor = compassBackgroundColor.CGColor;
}

- (UIColor *)compassBackgroundColor {
    return [UIColor colorWithCGColor:self.fillColor];
}

- (void)setCompassStrokeColor:(UIColor *)compassStrokeColor {
    self.strokeColor = compassStrokeColor.CGColor;
    self.crossHairsLayer.strokeColor = compassStrokeColor.CGColor;
}

- (UIColor *)compassStrokeColor {
    return [UIColor colorWithCGColor:self.strokeColor];
}

- (void)setCompassBorderColor:(UIColor *)compassBorderColor {
    self.borderLayer.strokeColor = compassBorderColor.CGColor;
}

- (UIColor *)compassBorderColor {
    return [UIColor colorWithCGColor:self.borderLayer.strokeColor];
}

- (void)setHorizonColor:(UIColor *)horizonColor {
    self.gyroHorizonLayer.fillColor = horizonColor.CGColor;
}

- (UIColor *)horizonColor {
    return [UIColor colorWithCGColor:self.gyroHorizonLayer.fillColor];
}

/*
 Custom Setters and Getters for Images
 */
- (void)setNotchImage:(UIImage *)notchImage {
    _notchImage = notchImage;
    self.notchLayer.contents = (__bridge id _Nullable)notchImage.CGImage;
    self.boundsOffset = self.notchLayer.bounds.size.height / 2;
    [self setNeedsDisplay];
}

- (UIImage *)notchImage {
    return _notchImage;
}

- (void)setAircraftImage:(UIImage *)aircraftImage {
    self.aircraftWorldLayer.aircraftVisionLayer.aircraftImage = aircraftImage;
}

- (UIImage *)aircraftImage {
    return self.aircraftWorldLayer.aircraftVisionLayer.aircraftImage;
}

- (void)setVisionConeImage:(UIImage *)visionConeImage {
    self.aircraftWorldLayer.aircraftVisionLayer.visionImage = visionConeImage;
}

- (UIImage *)visionConeImage {
    return self.aircraftWorldLayer.aircraftVisionLayer.visionImage;
}

- (void)setNorthIconImage:(UIImage *)northIconImage {
    self.aircraftWorldLayer.northImage = northIconImage;
}

- (UIImage *)northIconImage {
    return self.aircraftWorldLayer.northImage;
}

- (void)setHomeIconImage:(UIImage *)homeIconImage {
    self.aircraftWorldLayer.homeImage = homeIconImage;
}

- (UIImage *)homeIconImage {
    return self.aircraftWorldLayer.homeImage;
}

@end
