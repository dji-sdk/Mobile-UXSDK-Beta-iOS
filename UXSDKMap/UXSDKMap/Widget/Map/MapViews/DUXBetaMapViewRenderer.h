//
//  DUXBetaMapViewRenderer.h
//  UXSDKMap
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

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <DJISDK/DJISDK.h>

@class DUXBetaMapPolylineOverlay;
@class DUXBetaMapFlyZoneCircleOverlay;
@class DUXBetaMapSubFlyZonePolygonOverlay;

@class DUXBetaMapAircraftAnnotationView;
@class DUXBetaMapHomeAnnotationView;
@class DUXBetaFlyZoneAnnotationView;
@class DUXBetaMapTriangleView;

@class DUXBetaMapSubFlyZoneAnnotation;
@class DUXBetaMapNoFlyZoneAnnotation;
@class DUXBetaMapAircraftAnnotation;
@class DUXBetaMapHomeAnnotation;
@class DUXBetaMapAircraftAnnotation;
@class DUXBetaMapGeoZoneAnnotation;

@class DUXBetaMapView;

@interface DUXBetaMapViewRenderer : NSObject<MKMapViewDelegate, CLLocationManagerDelegate>

- (instancetype)init;
- (instancetype)initWithMapView: (DUXBetaMapView *)mapView;
- (void)updateUserLocationHeading:(double)heading;

@property (nonatomic, strong) UIView *userLocationView;
@property (nonatomic, strong) DUXBetaMapTriangleView *headingTriangleView;

@property (nonatomic, strong) DUXBetaMapAircraftAnnotationView *aircraftAnnotationView;
@property (nonatomic, strong) DUXBetaMapHomeAnnotationView *homeAnnotationView;

@property (nonatomic, strong) UIImage *aircraftAnnotationImage;
@property (nonatomic, strong) UIImage *homeAnnotationImage;
@property (nonatomic, strong) UIImage *eligibleFlyZoneImage;
@property (nonatomic, strong) UIImage *unlockedFlyZoneImage;
@property (nonatomic, strong) UIImage *customUnlockedFlyZoneImage;

@property (nonatomic, assign) CGPoint aircraftAnnotationImageCenterOffset;
@property (nonatomic, assign) CGPoint homeAnnotationImageCenterOffset;
@property (nonatomic, assign) CGPoint eligibleFlyZoneImageCenterOffset;
@property (nonatomic, assign) CGPoint unlockedFlyZoneImageCenterOffset;
@property (nonatomic, assign) CGPoint customUnlockedFlyZoneImageCenterOffset;

- (void)setFlyZoneOverlayColor:(nullable UIColor *)color
            forFlyZoneCategory:(DJIFlyZoneCategory)category;
- (nonnull UIColor *)flyZoneOverlayColorForFlyZoneCategory:(DJIFlyZoneCategory)category;

- (void)setFlyZoneOverlayAlpha:(CGFloat)alpha
            forFlyZoneCategory:(DJIFlyZoneCategory)category;
- (CGFloat)flyZoneOverlayAlphaForFlyZoneCategory:(DJIFlyZoneCategory)category;

@property (nonatomic, strong, nonnull) UIColor *unlockedFlyZoneOverlayColor;
@property (nonatomic, assign) CGFloat unlockedFlyZoneOverlayAlpha;
@property (nonatomic, strong, nonnull) UIColor *maximumHeightFlyZoneOverlayColor;
@property (nonatomic, assign) CGFloat maximumHeightFlyZoneOverlayAlpha;
@property (nonatomic, strong, nonnull) UIColor *customUnlockFlyZoneOverlayColor;
@property (nonatomic, assign) CGFloat customUnlockFlyZoneOverlayAlpha;
@property (nonatomic, strong, nonnull) UIColor *customUnlockFlyZoneSentToAircraftOverlayColor;
@property (nonatomic, assign) CGFloat customUnlockFlyZoneSentToAircraftOverlayAlpha;
@property (nonatomic, strong, nonnull) UIColor *customUnlockFlyZoneEnabledOverlayColor;
@property (nonatomic, assign) CGFloat customUnlockFlyZoneEnabledOverlayAlpha;

@property (nonatomic, assign) CGFloat flyZoneOverlayBorderWidth;
@property (nonatomic, strong, nonnull) UIColor *flightPathStrokeColor;
@property (nonatomic, assign) CGFloat flightPathStrokeWidth;
@property (nonatomic, strong, nonnull) UIColor *directionToHomeStrokeColor;
@property (nonatomic, assign) CGFloat directionToHomeStrokeWidth;

@property CLLocationManager *headingManager;

@end
