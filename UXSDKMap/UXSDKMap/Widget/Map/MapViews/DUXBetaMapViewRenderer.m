//
//  DUXBetaMapViewRenderer.m
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

#import "DUXBetaMapViewRenderer.h"
#import "DUXBetaMapView.h"
#import "DUXBetaMapWidget_Protected.h"

#import "DUXBetaMapPolylineOverlay.h"
#import "DUXBetaMapFlyZoneCircleOverlay.h"
#import "DUXBetaMapSubFlyZonePolygonOverlay.h"

#import "DUXBetaMapAircraftAnnotationView.h"
#import "DUXBetaMapHomeAnnotationView.h"
#import "DUXBetaFlyZoneAnnotationView.h"
#import "DUXBetaMapTriangleView.h"

#import "DUXBetaMapSubFlyZoneAnnotation.h"
#import "DUXBetaMapNoFlyZoneAnnotation.h"
#import "DUXBetaMapAircraftAnnotation.h"
#import "DUXBetaMapHomeAnnotation.h"
#import "DUXBetaMapAircraftAnnotation.h"
#import "DUXBetaMapGeoZoneAnnotation.h"
#import <UXSDKCore/UIColor+DUXBetaColors.h>

@interface DUXBetaMapViewRenderer ()

@property (nonatomic, weak) DUXBetaMapView *mapView;

@property (nonatomic, strong, nonnull) NSMutableDictionary <NSNumber*, UIColor*> *flyZoneColorByCategory;
@property (nonatomic, strong, nonnull) NSMutableDictionary <NSNumber*, NSNumber*> *flyZoneAlphaByCategory;

@end

CGFloat DUXBetaMapViewRendererStandardStrokeWidth = 3.0;
CGFloat DUXBetaMapViewRendererStandardFillAlpha = 0.1;

static NSString * const DUXBetaMapViewRendererAircraftAnnotationReuseIdentifier = @"AircraftAnnotationReuseIdentifier";
static NSString * const DUXBetaMapViewRendererHomeAnnotationReuseIdentifier = @"HomeAnnotationReuseIdentifier";
static NSString * const DUXBetaMapViewRendererNFZAnnotationReuseIdentifier = @"NFZAnnotationReuseIdentifier";
static NSString * const DUXBetaMapViewRendererSubNFZFlyZoneAnnotationReuseIdentifier = @"SubNFZFlyZoneAnnotationReuseIdentifier";
static NSString * const DUXBetaMapViewRendererGeoZoneAnnotationReuseIdentifier = @"GeoZoneAnnotationReuseIdentifier";

@implementation DUXBetaMapViewRenderer: NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDefaultValues];
    }
    return self;
}

- (instancetype)initWithMapView:(DUXBetaMapView *)mapView {
    self = [super init];
    if (self) {
        _mapView = mapView;
        [self setupDefaultValues];
    }
    return self;
}

- (void)setupDefaultValues {
    _headingTriangleView = [[DUXBetaMapTriangleView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 7.0) withCurve:YES];
    _headingManager = [[CLLocationManager alloc] init];
    [self setupHeadingManager];

    _aircraftAnnotationImageCenterOffset = CGPointZero;
    _homeAnnotationImageCenterOffset = CGPointZero;
    _eligibleFlyZoneImageCenterOffset = CGPointZero;
    _unlockedFlyZoneImageCenterOffset = CGPointZero;
    _customUnlockedFlyZoneImageCenterOffset = CGPointZero;

    _flyZoneOverlayBorderWidth = DUXBetaMapViewRendererStandardStrokeWidth;
    _flightPathStrokeWidth = DUXBetaMapViewRendererStandardStrokeWidth;
    _directionToHomeStrokeWidth = DUXBetaMapViewRendererStandardStrokeWidth;
    
    _unlockedFlyZoneOverlayAlpha = DUXBetaMapViewRendererStandardFillAlpha;
    _customUnlockFlyZoneOverlayAlpha = DUXBetaMapViewRendererStandardFillAlpha;
    _customUnlockFlyZoneSentToAircraftOverlayAlpha = DUXBetaMapViewRendererStandardFillAlpha;
    _maximumHeightFlyZoneOverlayAlpha = DUXBetaMapViewRendererStandardFillAlpha;
    _customUnlockFlyZoneEnabledOverlayAlpha = DUXBetaMapViewRendererStandardFillAlpha;

    _flyZoneColorByCategory = [@{
        @(DJIFlyZoneCategoryRestricted) : [UIColor colorWithRed:0.87 green:0.26 blue:0.16 alpha:1.0],
        @(DJIFlyZoneCategoryAuthorization) : [UIColor colorWithRed:0.06 green:0.53 blue:0.95 alpha:1.0],
        @(DJIFlyZoneCategoryEnhancedWarning) : [UIColor colorWithRed:0.93 green:0.53 blue:0.08 alpha:1.0],
        @(DJIFlyZoneCategoryWarning) : [UIColor colorWithRed:1.00 green:0.80 blue:0.00 alpha:1.0],
    } mutableCopy];

    _flyZoneAlphaByCategory = [@{
        @(DJIFlyZoneCategoryRestricted) : @(DUXBetaMapViewRendererStandardFillAlpha),
        @(DJIFlyZoneCategoryAuthorization) : @(DUXBetaMapViewRendererStandardFillAlpha),
        @(DJIFlyZoneCategoryEnhancedWarning) : @(DUXBetaMapViewRendererStandardFillAlpha),
        @(DJIFlyZoneCategoryWarning) : @(DUXBetaMapViewRendererStandardFillAlpha),
    } mutableCopy];
}

- (void)setAircraftAnnotationImage:(UIImage *)aircraftAnnotationImage {
    _aircraftAnnotationImage = aircraftAnnotationImage;
    self.aircraftAnnotationView.image = aircraftAnnotationImage;
}

- (void)setHomeAnnotationImage:(UIImage *)homeAnnotationImage {
    _homeAnnotationImage = homeAnnotationImage;
    self.homeAnnotationView.image = homeAnnotationImage;
}

- (void)setEligibleFlyZoneImage:(UIImage *)eligibleFlyZoneImage {
    _eligibleFlyZoneImage = eligibleFlyZoneImage;
}

- (void)setUnlockedFlyZoneImage:(UIImage *)unlockedFlyZoneImage {
    _unlockedFlyZoneImage = unlockedFlyZoneImage;
}

- (void)setCustomUnlockedFlyZoneImage:(UIImage *)customUnlockedFlyZoneImage {
    _customUnlockedFlyZoneImage = customUnlockedFlyZoneImage;
}

#pragma mark - Customization

- (void)setFlyZoneOverlayColor:(nullable UIColor *)color
            forFlyZoneCategory:(DJIFlyZoneCategory)category {
    self.flyZoneColorByCategory[@(category)] = color;
}

- (nonnull UIColor *)flyZoneOverlayColorForFlyZoneCategory:(DJIFlyZoneCategory)category {
    return self.flyZoneColorByCategory[@(category)];
}

- (void)setFlyZoneOverlayAlpha:(CGFloat)alpha
            forFlyZoneCategory:(DJIFlyZoneCategory)category {
    self.flyZoneAlphaByCategory[@(category)] = @(alpha);
}

- (CGFloat)flyZoneOverlayAlphaForFlyZoneCategory:(DJIFlyZoneCategory)category {
    return [self.flyZoneAlphaByCategory[@(category)] floatValue];
}

- (nonnull UIColor *)unlockedFlyZoneOverlayColor {
    if (!_unlockedFlyZoneOverlayColor) {
        _unlockedFlyZoneOverlayColor = [UIColor colorWithRed:0.00 green:0.50 blue:0.00 alpha:1.0];
    }
    return _unlockedFlyZoneOverlayColor;
}

- (nonnull UIColor *)customUnlockFlyZoneOverlayColor {
    if (!_customUnlockFlyZoneOverlayColor) {
        _customUnlockFlyZoneOverlayColor = [UIColor colorWithRed:0.22 green:0.29 blue:0.67 alpha:1.0];
    }
    return _customUnlockFlyZoneOverlayColor;
}

- (nonnull UIColor *)customUnlockFlyZoneSentToAircraftOverlayColor {
    if (!_customUnlockFlyZoneSentToAircraftOverlayColor) {
        _customUnlockFlyZoneSentToAircraftOverlayColor = [UIColor colorWithRed:0.00 green:0.75 blue:0.00 alpha:1.0];
    }
    return _customUnlockFlyZoneSentToAircraftOverlayColor;
}

- (nonnull UIColor *)customUnlockFlyZoneEnabledOverlayColor {
    if (!_customUnlockFlyZoneEnabledOverlayColor) {
        _customUnlockFlyZoneEnabledOverlayColor = [UIColor colorWithRed:0.00 green:1.00 blue:0.00 alpha:1.0];
    }
    return _customUnlockFlyZoneEnabledOverlayColor;
}

- (nonnull UIColor *)maximumHeightFlyZoneOverlayColor {
    if (!_maximumHeightFlyZoneOverlayColor) {
        _maximumHeightFlyZoneOverlayColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0];
    }
    return  _maximumHeightFlyZoneOverlayColor;
}

- (nonnull UIColor *)flightPathStrokeColor {
    if (!_flightPathStrokeColor) {
        _flightPathStrokeColor = [UIColor whiteColor];
    }
    return _flightPathStrokeColor;
}

- (nonnull UIColor *)directionToHomeStrokeColor {
    if (!_directionToHomeStrokeColor) {
        _directionToHomeStrokeColor = [UIColor greenColor];
    }
    return _directionToHomeStrokeColor;
}

#pragma mark - MKMapViewDelegate Methods

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
    MKAnnotationView *usersView = views.lastObject;
    id<MKAnnotation> usersAnnotation = usersView.annotation;
    
    // Check that the last annotation in the views array is
    // Actually the user's location annotation
    if ([usersAnnotation isKindOfClass:[MKUserLocation class]]) {
        // Only assign heading view when you first create the userview
        if(self.userLocationView == nil) {
            self.userLocationView = usersView;
            
            float middleOfUserView = usersView.frame.size.width / 2;
            float topOfUserView = 0.0;
            self.headingTriangleView.center = CGPointMake(middleOfUserView, topOfUserView + 11);
            
            UIColor *blueColor = [[UIColor alloc] initWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
            self.headingTriangleView.backgroundColor = blueColor;
            // Add heading triangle view for user's location only
            [usersView addSubview:self.headingTriangleView];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // Setup for drone annotation
    if ([annotation isKindOfClass: [DUXBetaMapAircraftAnnotation class]]) {
        self.aircraftAnnotationView = (DUXBetaMapAircraftAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:DUXBetaMapViewRendererAircraftAnnotationReuseIdentifier];
        if (self.aircraftAnnotationView == nil) {
            self.aircraftAnnotationView = [[DUXBetaMapAircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:DUXBetaMapViewRendererAircraftAnnotationReuseIdentifier];
            // Set image, if image was given
            if (self.aircraftAnnotationImage != nil) {
                self.aircraftAnnotationView.image = self.aircraftAnnotationImage;
            } else {
                [self.aircraftAnnotationView setYawInRadians:self.mapView.yaw];
            }
            self.aircraftAnnotationView.canShowCallout = NO;
            return self.aircraftAnnotationView;
        } else {
            return self.aircraftAnnotationView;
        }
    }
    // Setup for home annotation
    if ([annotation isKindOfClass: [DUXBetaMapHomeAnnotation class]]) {
        self.homeAnnotationView = (DUXBetaMapHomeAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:DUXBetaMapViewRendererHomeAnnotationReuseIdentifier];
        if (self.homeAnnotationView == nil) {
            self.homeAnnotationView = [[DUXBetaMapHomeAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:DUXBetaMapViewRendererHomeAnnotationReuseIdentifier];
            // Set image, if image was given
            if (self.homeAnnotationImage != nil) {
                self.homeAnnotationView.image = self.homeAnnotationImage;
            }
            return self.homeAnnotationView;
        } else {
            return self.homeAnnotationView;
        }
    }
    
    if ([annotation isKindOfClass: [DUXBetaMapNoFlyZoneAnnotation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:DUXBetaMapViewRendererNFZAnnotationReuseIdentifier];
        // Need to account for potential changed status of the custom annotation image
        // If custom image is set, then class should be DUXBetaFlyZoneAnnotationView, otherwise if the custom image is nil it is MKPinAnnotationView
        
        DUXBetaMapNoFlyZoneAnnotation *noFlyZoneAnnotation = (DUXBetaMapNoFlyZoneAnnotation *)annotation;
        if (noFlyZoneAnnotation.isUnlocked) {
            if (self.unlockedFlyZoneImage) {
                if ([annotationView isKindOfClass:[DUXBetaFlyZoneAnnotationView class]]) {
                    return annotationView;
                } else {
                    DUXBetaFlyZoneAnnotationView *flyZoneAnnotationView = [[DUXBetaFlyZoneAnnotationView alloc] initWithAnnotation:annotation
                                                                                                           reuseIdentifier:DUXBetaMapViewRendererNFZAnnotationReuseIdentifier];
                    flyZoneAnnotationView.noFlyZoneAnnotationImage = self.unlockedFlyZoneImage;
                    flyZoneAnnotationView.centerOffset = self.unlockedFlyZoneImageCenterOffset;
                    return flyZoneAnnotationView;
                }
            } else {
                if ([annotationView isKindOfClass:[MKPinAnnotationView class]]) {
                    return annotationView;
                } else {
                    return [self genericNoFlyZonePinAnnotationViewWithAnnotation:annotation
                                                                        pinColor:[UIColor uxsdk_errorDangerColor]
                                                                 reuseIdentifier:DUXBetaMapViewRendererNFZAnnotationReuseIdentifier];
                }
            }
        } else if (noFlyZoneAnnotation.isUnlockable) {
            if (self.eligibleFlyZoneImage) {
                if ([annotationView isKindOfClass:[DUXBetaFlyZoneAnnotationView class]]) {
                    return annotationView;
                } else {
                    DUXBetaFlyZoneAnnotationView *flyZoneAnnotationView = [[DUXBetaFlyZoneAnnotationView alloc] initWithAnnotation:annotation
                                                                                                           reuseIdentifier:DUXBetaMapViewRendererNFZAnnotationReuseIdentifier];
                    flyZoneAnnotationView.noFlyZoneAnnotationImage = self.eligibleFlyZoneImage;
                    flyZoneAnnotationView.centerOffset = self.eligibleFlyZoneImageCenterOffset;
                    return flyZoneAnnotationView;
                }
            } else {
                if ([annotationView isKindOfClass:[MKPinAnnotationView class]]) {
                    return annotationView;
                } else {
                    return [self genericNoFlyZonePinAnnotationViewWithAnnotation:annotation
                                                                        pinColor:[UIColor uxsdk_errorDangerColor]
                                                                 reuseIdentifier:DUXBetaMapViewRendererNFZAnnotationReuseIdentifier];
                }
            }
        } else if (noFlyZoneAnnotation.isCustomUnlockZone) {
            if ([annotationView isKindOfClass:[MKPinAnnotationView class]]) {
                return annotationView;
            } else {
                return [self genericNoFlyZonePinAnnotationViewWithAnnotation:annotation
                                                                    pinColor:[UIColor uxsdk_errorDangerColor]
                                                             reuseIdentifier:DUXBetaMapViewRendererNFZAnnotationReuseIdentifier];
            }
        } else {
            if (annotationView == nil) {
                return [self genericNoFlyZonePinAnnotationViewWithAnnotation:annotation
                                                                    pinColor:[UIColor uxsdk_errorDangerColor]
                                                             reuseIdentifier:DUXBetaMapViewRendererNFZAnnotationReuseIdentifier];
            } else {
                return annotationView;
            }
        }
    }
    // Setup for Sub - NFZ annotation
    if ([annotation isKindOfClass: [DUXBetaMapSubFlyZoneAnnotation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:DUXBetaMapViewRendererSubNFZFlyZoneAnnotationReuseIdentifier];
        if (annotationView == nil) {
            DUXBetaMapSubFlyZoneAnnotation *subFlyZoneAnnotation = (DUXBetaMapSubFlyZoneAnnotation *) annotation;
            return [self genericNoFlyZonePinAnnotationViewWithAnnotation:annotation
                                                                pinColor:subFlyZoneAnnotation.height == 0.0 ? [UIColor uxsdk_warningColor] : [UIColor cyanColor]
                                                         reuseIdentifier:DUXBetaMapViewRendererSubNFZFlyZoneAnnotationReuseIdentifier];
        } else {
            annotationView.annotation = annotation;
            return annotationView;
        }
    }
    
    // Setup for Geo Zone annotation
    if ([annotation isKindOfClass: [DUXBetaMapGeoZoneAnnotation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:DUXBetaMapViewRendererGeoZoneAnnotationReuseIdentifier];
        if (annotationView == nil) {
            return [self genericNoFlyZonePinAnnotationViewWithAnnotation:annotation
                                                                pinColor:[UIColor greenColor]
                                                         reuseIdentifier:DUXBetaMapViewRendererGeoZoneAnnotationReuseIdentifier];
        } else {
            return annotationView;
        }
    }
    
    return nil;
}

- (MKPinAnnotationView *)genericNoFlyZonePinAnnotationViewWithAnnotation:(id<MKAnnotation>)annotation
                                                                pinColor:(UIColor *)pinColor
                                                         reuseIdentifier:(NSString *)reuseIdentifier {
    MKPinAnnotationView *pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:reuseIdentifier];
    pinAnnotationView.pinTintColor = pinColor;
    pinAnnotationView.canShowCallout = YES;
    return pinAnnotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    // Setup properties for line
    if ([overlay isKindOfClass:[DUXBetaMapPolylineOverlay class]]) {
        return [self polylineRenderer:overlay];
    }
    // Setup properties for no fly zone, sub flyzones, and geo zones
    if ([overlay isKindOfClass:[DUXBetaMapFlyZoneCircleOverlay class]]) {
        DUXBetaMapFlyZoneCircleOverlay *noFlyZoneCircle = (DUXBetaMapFlyZoneCircleOverlay *)overlay;
        switch (noFlyZoneCircle.flyZoneType) {
            case DJIFlyZoneTypeCircle:
                return [self geoZoneRenderer:overlay];
            case DJIFlyZoneTypePoly:
                return [self subFlyZoneRenderer:overlay];
                break;
            default:
                break;
        }
    }
    // Setup properties for sub fly zone polygon
    if ([overlay isKindOfClass:[DUXBetaMapSubFlyZonePolygonOverlay class]]) {
        DUXBetaMapSubFlyZonePolygonOverlay *polygonFlyZone = (DUXBetaMapSubFlyZonePolygonOverlay *)overlay;
        UIColor *flyZoneColor = (polygonFlyZone.maxFlightHeight == 0) ? self.flyZoneColorByCategory[@(polygonFlyZone.category)] : self.maximumHeightFlyZoneOverlayColor;
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
        CGFloat alphaComponent = [self.flyZoneAlphaByCategory[@(polygonFlyZone.category)] floatValue];
        polygonRenderer.fillColor = [flyZoneColor colorWithAlphaComponent:alphaComponent];
        polygonRenderer.lineWidth = self.flyZoneOverlayBorderWidth;
        polygonRenderer.strokeColor = flyZoneColor;
        return polygonRenderer;
    }
    return [[MKOverlayRenderer alloc] initWithOverlay:overlay];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // Check if user location annotation was tapped
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        [self configUserLocationView:YES];
    } else if ([view.annotation isKindOfClass:[DUXBetaMapNoFlyZoneAnnotation class]]) {
        DUXBetaMapNoFlyZoneAnnotation *noFlyZoneAnnotation = (DUXBetaMapNoFlyZoneAnnotation *)view.annotation;
        if (noFlyZoneAnnotation.isUnlockable) {
            NSString *key = [NSString stringWithFormat:@"%ld", [noFlyZoneAnnotation.noFlyZoneID integerValue]];
            if (self.mapView.mapWidget.flyZones[key]) {
                [mapView deselectAnnotation:view.annotation animated:YES];
                if (noFlyZoneAnnotation.isUnlocked) {
                    [self.mapView.mapWidget presentConfirmationAlertForSelfUnlockRequestOnUnlockedFlyZone:noFlyZoneAnnotation.subtitle];
                } else {
                    [self.mapView.mapWidget presentConfirmationAlertForSelfUnlockingWithFlyZoneIDs:@[noFlyZoneAnnotation.noFlyZoneID]];
                }
            }
        } else if (noFlyZoneAnnotation.isCustomUnlockZone && noFlyZoneAnnotation.isCustomUnlockZoneSentToAircraft) {
            if (noFlyZoneAnnotation.isCustomUnlockZoneEnabled) {
                [self.mapView.mapWidget presentConfirmationAlertForDisablingCustomUnlockZone:self.mapView.mapWidget.customUnlockedFlyZones[noFlyZoneAnnotation.noFlyZoneID]];
            } else {
                [self.mapView.mapWidget presentConfirmationAlertForEnablingCustomUnlockZone:self.mapView.mapWidget.customUnlockedFlyZones[noFlyZoneAnnotation.noFlyZoneID]];
            }
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    // Check if user location annotation was deselected
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        [self configUserLocationView:NO];
    }
}

#pragma mark - Rendering Helper Methods

- (void)configUserLocationView:(BOOL)selected {
    selected ? [self.headingManager stopUpdatingHeading] : [self.headingManager startUpdatingHeading];
    double alpha = selected ? 0.0 : 1.0;
    [UIView animateWithDuration:0.1 animations:^{
        self.headingTriangleView.alpha = alpha;
        if (selected) {
            self.userLocationView.transform = CGAffineTransformIdentity;
        }
    }];
}

- (MKPolylineRenderer *)polylineRenderer:(id<MKOverlay>)overlay {
    DUXBetaMapPolylineOverlay *polyline = (DUXBetaMapPolylineOverlay *)overlay;
    MKPolylineRenderer *trailPathRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    trailPathRenderer.lineJoin = kCGLineJoinRound;
    if (polyline.polylineType == DUXBetaMapPolylineFlightPath) {
        trailPathRenderer.strokeColor = self.flightPathStrokeColor;
        trailPathRenderer.lineWidth = self.flightPathStrokeWidth;
    } else if (polyline.polylineType == DUXBetaMapPolylineDirectionToHome) {
        trailPathRenderer.strokeColor = self.directionToHomeStrokeColor;
        trailPathRenderer.lineWidth = self.directionToHomeStrokeWidth;
    }
    return trailPathRenderer;
}

- (MKCircleRenderer *)subFlyZoneRenderer:(id<MKOverlay>)overlay {
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
    DUXBetaMapFlyZoneCircleOverlay *subFlyZoneCircle = (DUXBetaMapFlyZoneCircleOverlay *)overlay;
    UIColor *flyZoneColor = subFlyZoneCircle.height == 0.0 ? self.flyZoneColorByCategory[@(subFlyZoneCircle.category)] : self.maximumHeightFlyZoneOverlayColor;
    CGFloat alphaComponent = [self.flyZoneAlphaByCategory[@(subFlyZoneCircle.category)] floatValue];
    circleRenderer.fillColor = [flyZoneColor colorWithAlphaComponent:alphaComponent];
    circleRenderer.strokeColor = subFlyZoneCircle.height == 0.0 ?[UIColor uxsdk_warningColor] : [UIColor cyanColor];
    circleRenderer.lineWidth = self.flyZoneOverlayBorderWidth;
    
    return circleRenderer;
}

- (MKCircleRenderer *)geoZoneRenderer:(id<MKOverlay>)overlay {
    // Setup properties for geo fly zone
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
    DUXBetaMapFlyZoneCircleOverlay *subFlyZoneCircle = (DUXBetaMapFlyZoneCircleOverlay *)overlay;
    UIColor *flyZoneColor = [self flyZoneColorForOverlay:subFlyZoneCircle];
    CGFloat flyzoneOverlayAlpha = [self flyZoneAlphaForOverlay:subFlyZoneCircle];
    circleRenderer.fillColor = [flyZoneColor colorWithAlphaComponent:flyzoneOverlayAlpha];
    circleRenderer.strokeColor = flyZoneColor;
    circleRenderer.lineWidth = self.flyZoneOverlayBorderWidth;
    
    return circleRenderer;
}

- (UIColor *)flyZoneColorForOverlay:(DUXBetaMapFlyZoneCircleOverlay *)overlay {
    if (overlay.isCustomUnlockZoneEnabled && overlay.isCustomUnlockZoneSentToAircraft && overlay.isCustomUnlockZone) {
        return self.customUnlockFlyZoneEnabledOverlayColor;
    } else if (overlay.isCustomUnlockZoneSentToAircraft && overlay.isCustomUnlockZone) {
        return self.customUnlockFlyZoneSentToAircraftOverlayColor;
    } else if (overlay.isCustomUnlockZone) {
        return self.customUnlockFlyZoneOverlayColor;
    } else {
        if (overlay.isUnlocked) {
            return self.unlockedFlyZoneOverlayColor;
        } else {
            return self.flyZoneColorByCategory[@(overlay.category)];
        }
    }
}

- (CGFloat)flyZoneAlphaForOverlay:(DUXBetaMapFlyZoneCircleOverlay *)overlay {
    if (overlay.isCustomUnlockZoneEnabled && overlay.isCustomUnlockZoneSentToAircraft && overlay.isCustomUnlockZone) {
        return self.customUnlockFlyZoneEnabledOverlayAlpha;
    } else if (overlay.isCustomUnlockZoneSentToAircraft && overlay.isCustomUnlockZone) {
        return self.customUnlockFlyZoneSentToAircraftOverlayAlpha;
    } else if (overlay.isCustomUnlockZone) {
        return self.customUnlockFlyZoneOverlayAlpha;
    } else {
        if (overlay.isUnlocked) {
            return self.unlockedFlyZoneOverlayAlpha;
        } else {
            return [self.flyZoneAlphaByCategory[@(overlay.category)] floatValue];
        }
    }
}

#pragma mark - Device Heading Methods

- (void)updateUserLocationHeading:(double)heading {
    [UIView animateWithDuration:0.1 animations:^{
        self.userLocationView.transform = CGAffineTransformMakeRotation(heading);
    }];
}

- (void)setupHeadingManager {
    // Setup location tracking for the iOS Device
    self.headingManager.delegate = self;
    [self.headingManager requestAlwaysAuthorization];
    // Every time degree of heading changes by 5, updateHeading delegate method is called
    self.headingManager.headingFilter = 5;
    [self.headingManager startUpdatingHeading];
}

#pragma mark - CLLocationManagerDelegate Methods

// When iOS Device changes heading, it is reflected on the map
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    float rotation = (newHeading.magneticHeading / 180) * M_PI;
    [self updateUserLocationHeading:rotation];
}

@end
