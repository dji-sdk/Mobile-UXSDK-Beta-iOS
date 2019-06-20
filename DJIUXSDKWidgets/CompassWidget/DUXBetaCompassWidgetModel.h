//
//  DUXBetaCompassWidgetModel.h
//  DJIUXSDK
//
//  MIT License
//  
//  Copyright © 2018-2019 DJI
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidgetModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaCompassWidgetModel : DUXBetaBaseWidgetModel

@property (assign, nonatomic) CLLocationAccuracy locationManagerAccuracy;

// Rotation around the front-to-back axis.
@property (nonatomic, assign, readonly) CLLocationDirection aircraftRoll;
// Rotation around the side-to-side axis.
@property (nonatomic, assign, readonly) CLLocationDirection aircraftPitch;
// Rotation around the vertical axis.
@property (nonatomic, assign, readonly) CLLocationDirection aircraftYaw;
// Rotation of gimbal relative to the aircraft.
@property (nonatomic, assign, readonly) CLLocationDirection gimbalYawRelativeToAircraft;
// Direction device is heading.
@property (nonatomic, assign, readonly) CLLocationDirection deviceHeading;
// Angle/Direction of drone.
@property (nonatomic, assign, readonly) CLLocationDirection droneAngle;
// Distance of drone.
@property (nonatomic, readonly) NSMeasurement *droneDistance;
// Angle/Direction of home.
@property (nonatomic, assign, readonly) CLLocationDirection homeAngle;
// Distance of home.
@property (nonatomic, readonly) NSMeasurement *homeDistance;
// Units for drone distance
@property (nonatomic, strong) NSUnitLength *droneDistanceUnits;
// Units for home distance
@property (nonatomic, strong) NSUnitLength *homeDistanceUnits;

@end

NS_ASSUME_NONNULL_END
