//
//  DUXBetaCompassWidgetModel.m
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

#import "DUXBetaCompassWidgetModel.h"
#import "DUXBetaBaseWidgetModel+Protected.h"
@import DJIUXSDKCore;

@interface DUXBetaCompassWidgetModel() <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, assign) BOOL stickToNorth;

@property (nonatomic) DJISDKVector3D *aircraftAttitude;
@property (nonatomic) DJIGimbalAttitude gimbalAttitude;
@property (nonatomic) DJIRCGPSData rcGPSData;

@property (nonatomic) CLLocation *homeLocation;
@property (nonatomic) CLLocation *rcLocation;
@property (nonatomic) CLLocation *aircraftLocation;
@property (nonatomic) CLLocation *deviceLocation;

@property (nonatomic, assign, readwrite) CLLocationDirection deviceHeading;

@property (nonatomic, assign) CLLocationDirection aircraftRoll;
@property (nonatomic, assign) CLLocationDirection aircraftPitch;
@property (nonatomic, assign) CLLocationDirection aircraftYaw;

@property (nonatomic, assign) CLLocationDirection gimbalYaw;
@property (nonatomic, assign) CLLocationDirection gimbalYawRelativeToAircraft;

@property (nonatomic, assign) CLLocationDirection droneAngle;
@property (nonatomic, strong) NSMeasurement *droneDistance;

@property (nonatomic, assign) CLLocationDirection homeAngle;
@property (nonatomic, strong) NSMeasurement *homeDistance;

@end

@implementation DUXBetaCompassWidgetModel

@synthesize droneDistanceUnits = _droneDistanceUnits;
@synthesize homeDistanceUnits = _homeDistanceUnits;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupLocationManager];
        
        _homeLocation = nil;
        _rcLocation = nil;
        _aircraftLocation = nil;
        _deviceLocation = nil;
        
        _deviceHeading = 0;
        
        _aircraftRoll = 0;
        _aircraftPitch = 0;
        _aircraftYaw = 0;
        
        _gimbalYaw = 0;
        _gimbalYawRelativeToAircraft = 0;
        
        _droneAngle = 0;
        _homeAngle = 0;
        
        if (self.unitSystem == DUXBetaUnitSystemMetric) {
            _droneDistance = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.meters];
            _homeDistance = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.meters];
        } else {
            _droneDistance = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.feet];
            _homeDistance = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.feet];
        }
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

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAttitude], aircraftAttitude);
    BindSDKKey([DJIGimbalKey keyWithParam:DJIGimbalParamAttitudeInDegrees], gimbalAttitude);
    BindSDKKey([DJIGimbalKey keyWithParam:DJIGimbalParamAttitudeYawRelativeToAircraft], gimbalYawRelativeToAircraft);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamHomeLocation], homeLocation);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAircraftLocation], aircraftLocation);
    BindSDKKey([DJIRemoteControllerKey keyWithParam:DJIRemoteControllerParamGPSData], rcGPSData);

    BindRKVOModel(self, @selector(updateStates), aircraftAttitude, gimbalAttitude, gimbalYawRelativeToAircraft, homeLocation, aircraftLocation, rcGPSData);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateStates {
    self.aircraftYaw = self.aircraftAttitude.z;
    self.aircraftPitch = self.aircraftAttitude.y;
    self.aircraftRoll = self.aircraftAttitude.x;
    self.gimbalYaw = self.gimbalAttitude.yaw;
    
    if (self.rcGPSData.isValid) {
        self.rcLocation = [[CLLocation alloc] initWithLatitude:self.rcGPSData.location.latitude longitude:self.rcGPSData.location.longitude];
    }
    
    self.droneAngle = [self angleOfDrone];
    self.homeAngle = [self angleOfHome];
    
    NSMeasurement *droneDistance = [[NSMeasurement alloc] initWithDoubleValue:[self droneToPilotDistanceInMeters] unit: NSUnitLength.meters];
    NSMeasurement *homeDistance = [[NSMeasurement alloc] initWithDoubleValue:[self homeToPilotDistanceInMeters] unit: NSUnitLength.meters];
    
    self.droneDistance = [droneDistance measurementByConvertingToUnit: self.droneDistanceUnits];
    self.homeDistance = [homeDistance measurementByConvertingToUnit: self.homeDistanceUnits];
}

-(void)dealloc {
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}

-(void)setLocationManagerAccuracy:(CLLocationAccuracy)locationManagerAccuracy {
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
        self.deviceLocation = [locations lastObject];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0) { return; }
    
    if (self.stickToNorth == NO) {
        self.deviceHeading = newHeading.magneticHeading;
    }
    self.deviceHeading = newHeading.magneticHeading;
}

- (void)deviceOrientationDidChange {
    self.locationManager.headingOrientation = (CLDeviceOrientation)[[UIDevice currentDevice] orientation];
}

/*********************************************************************************/
#pragma mark - Calculation Methods
/*********************************************************************************/

#define IsGPSValid(__location__) (CLLocationCoordinate2DIsValid(__location__) && !(fabs(__location__.latitude) < 1e-6 && fabs(__location__.longitude) < 1e-6))

- (CLLocationDirection)angleOfDrone {
    CLLocation *myLocation = self.rcLocation != nil ? self.rcLocation : self.deviceLocation;
    
    if (myLocation == nil) { return 0; }
    
    CLLocationCoordinate2D myCoordinate = myLocation.coordinate;
    CLLocationCoordinate2D droneCoordinate = self.aircraftLocation.coordinate;
    
    if (CLLocationCoordinate2DIsValid(myCoordinate) && CLLocationCoordinate2DIsValid(droneCoordinate)) {
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:myCoordinate.latitude longitude:myCoordinate.longitude];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:droneCoordinate.latitude longitude:droneCoordinate.longitude];
        CLLocation *location3 = [[CLLocation alloc] initWithLatitude:droneCoordinate.latitude longitude:myCoordinate.longitude];
        
        double dist1 = [location1 distanceFromLocation:location2];
        double dist2 = [location1 distanceFromLocation:location3];
        
        if (dist1 == 0) { return 0; }
        
        double ans = acos(dist2/dist1);
        if (myCoordinate.latitude <= droneCoordinate.latitude) {
            if (myCoordinate.longitude > droneCoordinate.longitude) {
                ans = 2 * M_PI - ans;
            }
        } else {
            ans = myCoordinate.longitude >= droneCoordinate.longitude ? M_PI + ans: M_PI - ans;
        }
        return ans*180.0/M_PI;
    }
    return 0;
}

- (CLLocationDirection)angleOfHome {
    CLLocation *myLocation = self.rcLocation != nil ? self.rcLocation : self.deviceLocation;
    
    if (myLocation == nil) { return 0; }
    
    CLLocationCoordinate2D myCoordinate = myLocation.coordinate;
    CLLocationCoordinate2D homeCoordinate = self.homeLocation.coordinate;
    
    if (CLLocationCoordinate2DIsValid(myCoordinate) && CLLocationCoordinate2DIsValid(homeCoordinate)) {
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:myCoordinate.latitude longitude:myCoordinate.longitude];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:homeCoordinate.latitude longitude:homeCoordinate.longitude];
        CLLocation *location3 = [[CLLocation alloc] initWithLatitude:homeCoordinate.latitude longitude:myCoordinate.longitude];
        
        double dist1 = [location1 distanceFromLocation:location2];
        double dist2 = [location1 distanceFromLocation:location3];
        
        if (dist1 == 0) { return 0; }
        
        double ans = acos(dist2/dist1);
        if (myCoordinate.latitude <= homeCoordinate.latitude) {
            if (myCoordinate.longitude > homeCoordinate.longitude)  {
                ans = 2 * M_PI - ans;
            }
        } else {
            ans = myCoordinate.longitude >= homeCoordinate.longitude ? M_PI + ans: M_PI - ans;
        }
        return ans * 180.0 / M_PI;
    }
    return 0;
}

- (double)droneToPilotDistanceInMeters {
    CLLocation *myLocation = self.rcLocation != nil ? self.rcLocation : self.deviceLocation;
    
    if (myLocation == nil) { return 0; }
    
    CGFloat distance = 0;
    if (self.aircraftLocation) {
        if (IsGPSValid(myLocation.coordinate)) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:myLocation.coordinate.latitude longitude:myLocation.coordinate.longitude];
            distance = [location distanceFromLocation:self.aircraftLocation];
        }
    }
    return distance;
}

- (double)homeToPilotDistanceInMeters {
    CLLocation *myLocation = self.rcLocation != nil ? self.rcLocation : self.deviceLocation;
    
    if (myLocation == nil) { return 0; }
    
    CLLocationCoordinate2D myCoordinate = myLocation.coordinate;
    if (CLLocationCoordinate2DIsValid(myCoordinate) && CLLocationCoordinate2DIsValid(self.homeLocation.coordinate)) {
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:myCoordinate.latitude longitude:myCoordinate.longitude];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:self.homeLocation.coordinate.latitude longitude:self.homeLocation.coordinate.longitude];
        return [location1 distanceFromLocation:location2];
    }
    return 0;
}

- (NSUnitLength *)droneDistanceUnits {
    if (_droneDistanceUnits) {
        return _droneDistanceUnits;
    } else if (self.unitSystem == DUXBetaUnitSystemMetric) {
        return NSUnitLength.meters;
    } else {
        return NSUnitLength.feet;
    }
}

- (NSUnitLength *)homeDistanceUnits {
    if (_homeDistanceUnits) {
        return _homeDistanceUnits;
    } else if (self.unitSystem == DUXBetaUnitSystemMetric) {
        return NSUnitLength.meters;
    } else {
        return NSUnitLength.feet;
    }
}

- (void)setDroneDistanceUnits:(NSUnitLength *)droneDistanceUnits {
    _droneDistanceUnits = droneDistanceUnits;
    [self updateStates];
}

- (void)setHomeDistanceUnits:(NSUnitLength *)homeDistanceUnits {
    _homeDistanceUnits = homeDistanceUnits;
    [self updateStates];
}

@end
