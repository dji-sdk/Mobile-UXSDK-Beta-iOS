//
//  DUXBetaCompassWidgetModel.h
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

#import <UXSDKCore/DUXBetaBaseWidgetModel.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  An enum for the center type used in the calculations
 */
typedef NS_ENUM(NSUInteger, DUXBetaCompassCenterType) {
    /**
     * The center is determined by RC location data or mobile device
     * location data
     */
    DUXBetaCompassRCMobileGPS,
    
    /**
     * The center is determined by the home location's data
     */
    DUXBetaCompassHomeGPS
};

/**
 * Class that holds the aircraft's attitude with getters and setters
 * for the roll, pitch and yaw of the aircraft.
 */
@interface DUXBetaAircraftAttitude : NSObject
    
// Rotation around the front-to-back axis.
@property (nonatomic, assign) CLLocationDirection roll;
// Rotation around the side-to-side axis.
@property (nonatomic, assign) CLLocationDirection pitch;
// Rotation around the vertical axis.
@property (nonatomic, assign) CLLocationDirection yaw;

@end

/**
 * Class that holds the angle and distance between the aircraft and the
 * home/RC/Mobile device's location.
 */
@interface DUXBetaLocationState : NSObject

// Angle/Direction as CLLocationDirection.
@property (nonatomic, assign) CLLocationDirection angle;
// Distance as an NSMeasurement.
@property (nonatomic, assign) double distance;

@end

/**
 * Class that defines all the properties processed by the DUXBetaCompassWidgetModel.
 */
@interface DUXBetaCompassState : NSObject

@property (nonatomic, strong) DUXBetaLocationState *aircraftState;
@property (nonatomic, strong, nullable) DUXBetaLocationState *rcLocationState;
@property (nonatomic, strong, nullable) DUXBetaLocationState *homeLocationState;
@property (nonatomic, strong) DUXBetaAircraftAttitude *aircraftAttitude;
@property (nonatomic, assign) DUXBetaCompassCenterType centerType;
@property (nonatomic, assign) CLLocationDirection gimbalHeading;
@property (nonatomic, assign) CLLocationDirection deviceHeading;

@end


/**
 * Widget Model for the DUXBetaCompassWidget used to define
 * the underlying logic and communication.
 */
@interface DUXBetaCompassWidgetModel : DUXBetaBaseWidgetModel

@property (nonatomic, strong, nullable) CLLocationManager *locationManager;
@property (assign, nonatomic) CLLocationAccuracy locationManagerAccuracy;

@property (nonatomic, readonly) DUXBetaCompassState *compassState;

@end

NS_ASSUME_NONNULL_END
