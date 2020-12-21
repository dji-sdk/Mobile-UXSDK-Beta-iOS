//
//  DUXBetaCompassWidget.m
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

#import "DUXBetaCompassWidget.h"
#import "DUXBetaCompassLayer.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIColor+DUXBetaColors.h"

@interface DUXBetaCompassWidget ()

@property (nonatomic, strong) DUXBetaCompassLayer *compassLayer;

@end

@implementation DUXBetaCompassWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        self.compassLayer = [DUXBetaCompassLayer new];
        
        self.compassBackgroundColor = [UIColor uxsdk_white5];
        self.horizonColor = [UIColor uxsdk_compassWidgetHorizonColor];
        self.borderColor = [UIColor uxsdk_darkGrayColor];
        self.strokeColor = [UIColor uxsdk_whiteAlpha20];
        
        self.designSize = CGSizeMake(87, 87);
        self.innerPadding = 6;
        self.maskPaddingSize = 15;
        self.notchSize = CGSizeMake(8, 6);
        self.aircraftSize = CGSizeMake(15, 20);
        self.visionConeSize = CGSizeMake(35, 50);
        self.northIconSize = CGSizeMake(10, 10);
        self.homeIconSize = CGSizeMake(15, 15);
        
        self.notchImage = [UIImage duxbeta_imageWithAssetNamed:@"Notch"];
        self.aircraftImage = [UIImage duxbeta_imageWithAssetNamed:@"AircraftSymbol"];
        self.visionConeImage = [UIImage duxbeta_imageWithAssetNamed:@"VisionCone"];
        self.northIconImage = [UIImage duxbeta_imageWithAssetNamed:@"North"];
        self.homeIconImage = [UIImage duxbeta_imageWithAssetNamed:@"Home"];
        
        [self.view.layer addSublayer: self.compassLayer];
        self.view.clipsToBounds = NO;
        self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.widgetModel = [[DUXBetaCompassWidgetModel alloc] init];
    [self.widgetModel setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    BindRKVOModel(self.widgetModel, @selector(updateUI), aircraftRoll,
                  aircraftPitch,
                  aircraftYaw,
                  gimbalYawRelativeToAircraft,
                  deviceHeading,
                  droneAngle,
                  droneDistance,
                  homeAngle,
                  homeDistance);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat min = MIN(self.view.frame.size.width, self.view.frame.size.height);
    if (self.view.frame.size.width < self.view.frame.size.height) {
        self.compassLayer.frame = CGRectMake(0, self.view.frame.size.height / 2 - min / 2, min, min);
    } else {
        self.compassLayer.frame = CGRectMake(self.view.frame.size.width / 2 - min / 2, 0, min, min);
    }
    [self updateUI];
}

- (void)updateUI {
    [self.compassLayer updateAircraftPitch:self.widgetModel.aircraftPitch];
    [self.compassLayer updateAircraftRoll:self.widgetModel.aircraftRoll];
    [self.compassLayer updateAircraftYaw:self.widgetModel.aircraftYaw];
    
    if (self.widgetModel.gimbalYawRelativeToAircraft != 0) {
        [self.compassLayer updateGimbalYaw:self.widgetModel.gimbalYawRelativeToAircraft];
    }

    [self.compassLayer updateDeviceHeading:self.widgetModel.deviceHeading];
    
    double droneDistanceInMeters = [self.widgetModel.droneDistance measurementByConvertingToUnit: NSUnitLength.meters].doubleValue;
    double homeDistanceInMeters = [self.widgetModel.homeDistance measurementByConvertingToUnit: NSUnitLength.meters].doubleValue;
    
    [self.compassLayer updateAircraftLocationUsingAngle:self.widgetModel.droneAngle andDistance:droneDistanceInMeters];
    [self.compassLayer updateHomeLocationUsingAngle:self.widgetModel.homeAngle andDistance:homeDistanceInMeters];
    
    [self.view setNeedsDisplay];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {self.designSize.width / self.designSize.height, self.designSize.width, self.designSize.height};
    return hint;
}

/*
 Custom Setters and Getters for Colors
 */

- (void)setCompassBackgroundColor:(UIColor *)compassBackgroundColor {
    self.compassLayer.compassBackgroundColor = compassBackgroundColor;
}

- (UIColor *)compassBackgroundColor {
    return self.compassLayer.compassBackgroundColor;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    self.compassLayer.compassStrokeColor = strokeColor;
}

- (UIColor *)strokeColor {
    return self.compassLayer.compassStrokeColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.compassLayer.compassBorderColor = borderColor;
}

- (UIColor *)borderColor {
    return self.compassLayer.compassBorderColor;
}

- (void)setHorizonColor:(UIColor *)horizonColor {
    self.compassLayer.horizonColor = horizonColor;
}

- (UIColor *)horizonColor {
    return self.compassLayer.horizonColor;
}

/*
 Custom Setters and Getters for Images
 */
- (void)setNotchImage:(UIImage *)notchImage {
    self.compassLayer.notchImage = notchImage;
    [self.compassLayer setNeedsDisplay];
}

- (UIImage *)notchImage {
    return self.compassLayer.notchImage;
}

- (void)setAircraftImage:(UIImage *)aircraftImage {
    self.compassLayer.aircraftImage = aircraftImage;
    [self.compassLayer setNeedsDisplay];
}

- (UIImage *)aircraftImage {
    return self.compassLayer.aircraftImage;
}

- (void)setVisionConeImage:(UIImage *)visionConeImage {
    self.compassLayer.visionConeImage = visionConeImage;
    [self.compassLayer setNeedsDisplay];
}

- (UIImage *)visionConeImage {
    return self.compassLayer.visionConeImage;
}

- (void)setNorthIconImage:(UIImage *)northIconImage {
    self.compassLayer.northIconImage = northIconImage;
    [self.compassLayer setNeedsDisplay];
}

- (UIImage *)northIconImage {
    return self.compassLayer.northIconImage;
}

- (void)setHomeIconImage:(UIImage *)homeIconImage {
    self.compassLayer.homeIconImage = homeIconImage;
    [self.compassLayer setNeedsDisplay];
}

- (UIImage *)homeIconImage {
    return self.compassLayer.homeIconImage;
}

/*
 Custom Setters and Getters for Sizes
 */

- (void)setDesignSize:(CGSize)designSize {
    self.compassLayer.designSize = designSize;
    [self.compassLayer setNeedsDisplay];
}

- (CGSize)designSize {
    return self.compassLayer.designSize;
}

- (void)setInnerPadding:(CGFloat)innerPadding {
    self.compassLayer.innerPadding = innerPadding;
    [self.compassLayer setNeedsDisplay];
}

- (CGFloat)innerPadding {
    return self.compassLayer.innerPadding;
}

- (void)setMaskPaddingSize:(CGFloat)maskPaddingSize {
    self.compassLayer.maskPaddingSize = maskPaddingSize;
    [self.compassLayer setNeedsDisplay];
}

- (CGFloat)maskPaddingSize {
    return self.compassLayer.maskPaddingSize;
}

- (void)setNotchSize:(CGSize)notchSize {
    self.compassLayer.notchSize = notchSize;
    [self.compassLayer setNeedsDisplay];
}

- (CGSize)notchSize {
    return self.compassLayer.notchSize;
}

- (void)setAircraftSize:(CGSize)aircraftSize {
    self.compassLayer.aircraftSize = aircraftSize;
    [self.compassLayer setNeedsDisplay];
}

- (CGSize)aircraftSize {
    return self.compassLayer.aircraftSize;
}

- (void)setVisionConeSize:(CGSize)visionConeSize {
    self.compassLayer.visionConeSize = visionConeSize;
    [self.compassLayer setNeedsDisplay];
}

- (CGSize)visionConeSize {
    return self.compassLayer.visionConeSize;
}

- (void)setNorthIconSize:(CGSize)northIconSize {
    self.compassLayer.northIconSize = northIconSize;
    [self.compassLayer setNeedsDisplay];
}

- (CGSize)northIconSize {
    return self.compassLayer.northIconSize;
}

- (void)setHomeIconSize:(CGSize)homeIconSize {
    self.compassLayer.homeIconSize = homeIconSize;
    [self.compassLayer setNeedsDisplay];
}

- (CGSize)homeIconSize {
    return self.compassLayer.homeIconSize;
}

@end
