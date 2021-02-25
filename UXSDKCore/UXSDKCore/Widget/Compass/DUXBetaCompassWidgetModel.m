//
//  DUXBetaCompassWidgetModel.m
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

#import "DUXBetaCompassWidgetModel.h"
#import <UXSDKCore/UXSDKCore-Swift.h>
#import "DUXBetaLocationUtil.h"

@interface DUXBetaCompassWidgetModel() <CLLocationManagerDelegate>

@property (nonatomic, assign) BOOL stickToNorth;
@property (nonatomic, assign) DJIRCGPSData rcGPSData;
@property (nonatomic, strong) DJISDKVector3D *aircraftAttitude;
@property (nonatomic, assign) DJIGimbalAttitude gimbalAttitude;
@property (nonatomic, assign) CLLocationDirection aircraftYaw;
@property (nonatomic, assign) CLLocationDirection aircraftRoll;
@property (nonatomic, assign) CLLocationDirection deviceHeading;
@property (nonatomic, assign) CLLocationDirection aircraftPitch;
@property (nonatomic, assign) CLLocationDirection gimbalYawRelativeToAircraft;

@property (nonatomic, strong) CLLocation *homeLocation;
@property (nonatomic, strong) CLLocation *rcOrDeviceLocation;
@property (nonatomic, strong) CLLocation *aircraftLocation;

@property (nonatomic, strong, readwrite) DUXBetaCompassState *compassState;

@end

@implementation DUXBetaCompassWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupModelState];
        [self setupLocationManager];
    }
    return self;
}

- (void)setupLocationManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.headingFilter = 1;
    _locationManager.headingOrientation = (CLDeviceOrientation)[[UIDevice currentDevice] orientation];
    
    _stickToNorth = ![CLLocationManager headingAvailable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    if (!(authStatus == kCLAuthorizationStatusRestricted ||
          authStatus == kCLAuthorizationStatusDenied)) {
        if (authStatus == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    self.locationManagerAccuracy = kCLLocationAccuracyBestForNavigation;
}

- (void)setupModelState {
    self.compassState = [[DUXBetaCompassState alloc] init];
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAttitude], aircraftAttitude);
    BindSDKKey([DJIGimbalKey keyWithParam:DJIGimbalParamAttitudeInDegrees], gimbalAttitude);
    BindSDKKey([DJIGimbalKey keyWithParam:DJIGimbalParamAttitudeYawRelativeToAircraft], gimbalYawRelativeToAircraft);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamHomeLocation], homeLocation);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAircraftLocation], aircraftLocation);
    BindSDKKey([DJIRemoteControllerKey keyWithParam:DJIRemoteControllerParamGPSData], rcGPSData);

    BindRKVOModel(self, @selector(updateStates),
                  rcOrDeviceLocation,
                  aircraftAttitude,
                  gimbalAttitude,
                  gimbalYawRelativeToAircraft,
                  homeLocation,
                  aircraftLocation,
                  rcGPSData);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (CLLocation *)centerLocation {
    return (self.compassState.centerType == DUXBetaCompassHomeGPS ? self.homeLocation : self.rcOrDeviceLocation);
}

- (void)updateStates {
    self.compassState.aircraftAttitude.yaw = self.aircraftAttitude.z;
    self.compassState.aircraftAttitude.roll = self.aircraftAttitude.x;
    self.compassState.aircraftAttitude.pitch = self.aircraftAttitude.y;
    
    self.compassState.gimbalHeading = self.gimbalYawRelativeToAircraft;
    
    if (self.rcGPSData.isValid) {
        [self.locationManager stopUpdatingLocation];
        
        self.compassState.centerType = DUXBetaCompassRCMobileGPS;
        _rcOrDeviceLocation = [[CLLocation alloc] initWithLatitude:self.rcGPSData.location.latitude longitude:self.rcGPSData.location.longitude];
    }
    
    // Compute aircraft location
    self.compassState.aircraftState = [DUXBetaLocationState new];
    self.compassState.aircraftState.angle = [DUXBetaLocationUtil angleBetween:self.centerLocation andLocation:self.aircraftLocation];
    self.compassState.aircraftState.distance = [DUXBetaLocationUtil distanceInMeters:self.centerLocation andLocation:self.aircraftLocation];
    
    // Compute home location
    if (self.homeLocation) {
        self.compassState.homeLocationState = [DUXBetaLocationState new];
        self.compassState.homeLocationState.angle = [DUXBetaLocationUtil angleBetween:self.centerLocation andLocation:self.homeLocation];
        self.compassState.homeLocationState.distance = [DUXBetaLocationUtil distanceInMeters:self.centerLocation andLocation:self.homeLocation];
    } else {
        self.compassState.homeLocationState = nil;
    }
    
    // Compute rc/mobileGPS location
    if (self.rcOrDeviceLocation) {
        self.compassState.rcLocationState = [DUXBetaLocationState new];
        self.compassState.rcLocationState.angle = [DUXBetaLocationUtil angleBetween:self.centerLocation andLocation:self.rcOrDeviceLocation];
        self.compassState.rcLocationState.distance = [DUXBetaLocationUtil distanceInMeters:self.centerLocation andLocation:self.rcOrDeviceLocation];
    } else {
        self.compassState.rcLocationState = nil;
    }
}

- (void)dealloc {
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}

- (void)setLocationManagerAccuracy:(CLLocationAccuracy)locationManagerAccuracy {
    _locationManagerAccuracy = locationManagerAccuracy;
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
        self.locationManager.desiredAccuracy = _locationManagerAccuracy;
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
    }
}

/*********************************************************************************/
#pragma mark - CLLocationManagerDelegate
/*********************************************************************************/

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if ([locations count] > 0) {
        self.compassState.centerType = DUXBetaCompassRCMobileGPS;
        self.rcOrDeviceLocation = [locations lastObject];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0) { return; }
    
    if (self.stickToNorth == NO) {
        self.compassState.deviceHeading = newHeading.magneticHeading;
    }
    self.compassState.deviceHeading = newHeading.magneticHeading;
}

- (void)deviceOrientationDidChange {
    self.locationManager.headingOrientation = (CLDeviceOrientation)[[UIDevice currentDevice] orientation];
}

@end


#pragma mark - DUXBetaCompassState

@implementation DUXBetaCompassState

- (instancetype)init {
    self = [super init];
    if (self) {
        self.centerType = DUXBetaCompassHomeGPS;
        self.aircraftAttitude = [DUXBetaAircraftAttitude new];
    }
    return self;
}

@end


#pragma mark - DUXBetaAircraftAttitude

@implementation DUXBetaAircraftAttitude

@end


#pragma mark - DUXBetaLocationState

@implementation DUXBetaLocationState

@end
