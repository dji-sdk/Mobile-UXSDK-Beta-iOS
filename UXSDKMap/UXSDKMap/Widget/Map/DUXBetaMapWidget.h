//
//  DUXBetaMapWidget.h
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

#import <MapKit/MapKit.h>
#import <UXSDKCore/DUXBetaBaseWidget.h>
@class DUXBetaMapWidgetModel;

NS_ASSUME_NONNULL_BEGIN
/**
 *  An enum describing the different annotations on the map.
 */
typedef NS_ENUM(NSUInteger, DUXBetaMapAnnotationType) {
    /**
     *  Annotation of the aircraft currently on the map.
     */
    DUXBetaMapAnnotationTypeAircraft,
    /**
     *  Annotation of the home location currently on the map.
     */
    DUXBetaMapAnnotationTypeHome,
    /**
     *  Annotation of a self-unlock fly zone that can be unlocked, currently on the map.
     *  Only visible when tapToUnlockEnabled is set to `YES`.
     */
    DUXBetaMapAnnotationTypeEligibleFlyZones,
    /**
     *  Annotation of a self-unlock fly zone that is unlocked currently. Only visible
     *  when tapToUnlockEnabled is set to `YES`.
     */
    DUXBetaMapAnnotationTypeUnlockedFlyZones,
    /**
     *  Annotation of a custom unlock fly zone. Only visible when
     *  tapToUnlockEnabled is set to `YES`.
     */
    DUXBetaMapAnnotationTypeCustomUnlockedFlyZones,
};
/**
 *  An enum bitmask indicating which fly zones are to be displayed by the map
 *  widget.
 */
typedef NS_OPTIONS(NSUInteger, DUXBetaMapVisibleFlyZones) {
    /**
     *  No fly zones will be visible on the map widget.
     */
    DUXBetaMapVisibleFlyZonesNone = 0,
    /**
     *  Restricted fly zones will be visible on the map widget.
     */
    DUXBetaMapVisibleFlyZonesRestricted = 1 << 0,
    /**
     *  Authorization fly zones will be visible on the map widget.
     */
    DUXBetaMapVisibleFlyZonesAuthorization = 1 << 1,
    /**
     *  Warning fly zones will be visible on the map widget.
     */
    DUXBetaMapVisibleFlyZonesWarning  = 1 << 2,
    /**
     *  Enhanced warning fly zones will be visible on the map widget.
     */
    DUXBetaMapVisibleFlyZonesEnhancedWarning  = 1 << 3,
};

/**
 *  Display:
 *  Widget that displays the aircraft's state and information on the map this
 *  includes aircraft location, home location, aircraft trail path, aircraft
 *  heading, and No Fly Zones.
 *
 *  Usage:
 *  Preferred Aspect Ratio: 1:1
 */
@interface DUXBetaMapWidget : DUXBetaBaseWidget

@property (nonatomic, strong) DUXBetaMapWidgetModel *widgetModel;

/**
 *  Standard iOS Map for manipulating general settings.
 */
@property (nonatomic, strong) MKMapView *mapView;

/**
 *  Shows the fly zone legend. The fly zone legend indicates the color for all zone
 *  categories and self-unlock zones.
 */
@property (nonatomic, assign) BOOL showFlyZoneLegend;

/**
 *  Defaults to `NO`. A Boolean value indicating whether the map displays a line
 *  showing
 *      the direction to home.
 *
 *  @return `YES` if direction to home is visible.
 */
@property (nonatomic, assign) BOOL showDirectionToHome;

/**
 *  Defaults to `NO`. A Boolean value that determines whether the map locks the
 *  camera view on the aircraft.
 */
@property (nonatomic, assign) BOOL isMapCameraLockedOnAircraft;

/**
 *  Boolean property that if enabled will lock map center onto aircraft home
 *  location.
 */
@property (nonatomic, assign) BOOL isMapCameraLockedOnHomePoint;

/**
 *  Sets the types of fly zones to be displayed on the map. Set to
 *  `DUXBetaMapVisibleFlyZonesNone` to hide all fly zone types.
 */
@property (nonatomic, assign) DUXBetaMapVisibleFlyZones visibleFlyZones;

/**
 *  Defaults to `NO`. Shows custom unlock zones if any are available for the
 *  currently connected aircraft.
 */
@property (nonatomic, assign) BOOL showCustomUnlockZones;

/**
 *  Gets whether tap to unlock is enabled.
 *
 *  @return `YES` if tapping to unlock select fly zones is enabled. If this option is enabled, you MUST use `DUXBetaMapViewController` to present the widget via view controller containment.
 */
@property (nonatomic, assign) BOOL tapToUnlockEnabled;

/**
 *  Defaults to `NO`. Show a small indicator displaying the latest DJI account login
 *  state.  Useful if using FlySafe features.
 */
@property (nonatomic, assign) BOOL showDJIAccountLoginIndicator;

/**
 *  `YES` if the flight path is visible. The default value is `NO`
 *
 *  @return A boolean value indicating if the flight path is visible.
 */
@property (nonatomic, assign) BOOL showFlightPath;

/**
 *  `YES` if the map displays the home point of the aircraft. The default value of
 *  this property is `YES`.
 *
 *  @return The icon of the home point marker.
 */
@property (nonatomic, assign) BOOL showHomeAnnotation;

/**
 *  Replaces current annotation type with given image. The default image for all
 *  annotation types are set.
 *
 *  @param annotationType An enum value of `DUXBetaMapAnnotationType`.
 *  @param image Image used to represent the annotation.
 */
- (void)changeAnnotation:(DUXBetaMapAnnotationType)annotationType withImage:(UIImage *)image DEPRECATED_ATTRIBUTE;

/**
 *  Change the annotation type of the map widget.
 *
 *  @param annotationType An enum value of `DUXBetaMapAnnotationType`.
 *  @param image Image used to represent the annotation.
 *  @param centerOffset A CGPoint struct for the center offset.
 */
- (void)changeAnnotationOfType:(DUXBetaMapAnnotationType)annotationType toCustomImage:(nonnull UIImage *)image withCenterOffset:(CGPoint)centerOffset;

/**
 *  Clears the flight path up to the current location. The flight path is removed
 *  even if it is hidden.
 */
- (void)clearCurrentFlightPath;

/**
 *  Call this to sync currently shown custom unlock zones to aircraft. They will
 *  still need to be manually enabled.
 */
- (void)syncCustomUnlockZones;

#pragma mark - Customization
/**
 *  Change the rendered color for a given fly zone category.
 *
 *  @param color The desired color.
 *  @param category The fly zone category for which the color would apply.
 */
- (void)setFlyZoneOverlayColor:(nullable UIColor *)color
            forFlyZoneCategory:(DJIFlyZoneCategory)category;

/**
 *  Returns the currently used color for a given fly zone category. This does not
 *  include unlocked zones.
 *
 *  @param category The fly zone category associated with the returned color.
 *
 *  @return A UIColor object.
 */
- (nonnull UIColor *)flyZoneOverlayColorForFlyZoneCategory:(DJIFlyZoneCategory)category;

/**
 *  Change the rendered alpha for a given fly zone category.
 *
 *  @param alpha The desired alpha.
 *  @param category The fly zone category for which the alpha would apply.
 */
- (void)setFlyZoneOverlayAlpha:(CGFloat)alpha
            forFlyZoneCategory:(DJIFlyZoneCategory)category;

/**
 *  Returns the currently used alpha for a given fly zone category. This does not
 *  include unlocked zones.
 *
 *  @param category The fly zone category associated with the returned alpha.
 *
 *  @return A CGFloat value.
 */
- (CGFloat)flyZoneOverlayAlphaForFlyZoneCategory:(DJIFlyZoneCategory)category;

/**
 *  Current color of a self-unlock fly zone overlay.
 */
@property (nonatomic, strong, nonnull) UIColor *unlockedFlyZoneOverlayColor;

/**
 *  Current alpha of a self-unlock fly zone overlay.
 */
@property (nonatomic, assign) CGFloat unlockedFlyZoneOverlayAlpha;

/**
 *  Current color of a custom unlock fly zone overlay.
 */
@property (nonatomic, strong, nonnull) UIColor *customUnlockFlyZoneOverlayColor;

/**
 *  Current alpha of a custom unlock fly zone overlay.
 */
@property (nonatomic, assign) CGFloat customUnlockFlyZoneOverlayAlpha;

/**
 *  Current color of a custom unlock fly zone overlay that has been sent to
 *  aircraft.
 */
@property (nonatomic, strong, nonnull) UIColor *customUnlockFlyZoneSentToAircraftOverlayColor;

/**
 *  Current alpha of a custom unlock fly zone overlay that has been sent to the
 *  aircraft.
 */
@property (nonatomic, assign) CGFloat customUnlockFlyZoneSentToAircraftOverlayAlpha;

/**
 *  Current color of a custom unlock fly zone overlay that has been sent to aircraft
 *  and enabled.
 */
@property (nonatomic, strong, nonnull) UIColor *customUnlockFlyZoneEnabledOverlayColor;

/**
 *  Current alpha of a custom unlock fly zone overlay that has been sent to aircraft
 *  and enabled.
 */
@property (nonatomic, assign) CGFloat customUnlockFlyZoneEnabledOverlayAlpha;

/**
 *  Current color of a fly zone with maximum height.
 */
@property (nonatomic, strong, nonnull) UIColor *maximumHeightFlyZoneOverlayColor;

/**
 *  Current alpha of a fly zone with maximum height.
 */

@property (nonatomic, assign) CGFloat maximumHeightFlyZoneOverlayAlpha;

/**
 *  Width of the solid colored border of all fly zone overlays.
 */
@property (nonatomic, assign) CGFloat flyZoneOverlayBorderWidth;

/**
 *  Current color of the rendered flight path.
 */
@property (nonatomic, strong, nonnull) UIColor *flightPathStrokeColor;

/**
 *  Current stroke width of the rendered flight path.
 */
@property (nonatomic, assign) CGFloat flightPathStrokeWidth;

/**
 *  Current color of the rendered direction to home line.
 */
@property (nonatomic, strong, nonnull) UIColor *directionToHomeStrokeColor;

/**
 *  Current stroke width of the rendered direction to home line.
 */

@property (nonatomic, assign) CGFloat directionToHomeStrokeWidth;

@end

NS_ASSUME_NONNULL_END
