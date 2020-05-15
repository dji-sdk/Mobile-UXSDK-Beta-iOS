//
//  DUXBetaRCDistanceWidgetModel.m
//  DJIUXSDK
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

#import "DUXBetaRCDistanceWidgetModel.h"
#import "DUXBetaBaseWidgetModel+Protected.h"
@import DJIUXSDKCore;

@interface DUXBetaRCDistanceWidgetModel() <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (assign, nonatomic) double distanceInMeters;
@property (nonatomic) NSMeasurement *distance;

@property (nonatomic) CLLocation *aircraftLocation;
@property (nonatomic) CLLocation *deviceLocation;
@property (nonatomic) DJIRCGPSData rcGPSData;

@end

@implementation DUXBetaRCDistanceWidgetModel

@synthesize distanceUnits = _distanceUnits;

- (instancetype)init {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _distanceInMeters = 0;
        _aircraftLocation = nil;
        _deviceLocation = nil;
        if (self.unitSystem == DUXBetaUnitSystemMetric) {
            _distance = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.meters];
        } else {
            _distance = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.feet];
        }
    }
    return self;
}

- (void)inSetup {
    self.locationManagerAccuracy = kCLLocationAccuracyBestForNavigation;

    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAircraftLocation], aircraftLocation);
    BindSDKKey([DJIRemoteControllerKey keyWithParam:DJIRemoteControllerParamGPSData], rcGPSData);
    
    BindRKVOModel(self, @selector(updateDistanceInMeters), rcGPSData, aircraftLocation);
    BindRKVOModel(self, @selector(updateDistance), distanceInMeters);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateDistanceInMeters {
    CLLocationCoordinate2D coordinate;
    if (CLLocationCoordinate2DIsValid(self.rcGPSData.location)) {
        coordinate = self.rcGPSData.location;
    } else {
        coordinate = self.deviceLocation.coordinate;
    }
    
    if (self.aircraftLocation == nil ||
        !CLLocationCoordinate2DIsValid(self.aircraftLocation.coordinate) ||
        !CLLocationCoordinate2DIsValid(coordinate)) {
        self.distanceInMeters = 0;
        return;
    }

    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    self.distanceInMeters = [location distanceFromLocation: self.aircraftLocation];
}

- (void)updateDistance {
    NSMeasurement *distance = [[NSMeasurement alloc] initWithDoubleValue:self.distanceInMeters unit: NSUnitLength.meters];
    self.distance = [distance measurementByConvertingToUnit: self.distanceUnits];
}

- (void)dealloc {
    [self.locationManager stopUpdatingLocation];
}

- (void)setLocationManagerAccuracy:(CLLocationAccuracy)locationManagerAccuracy {
    _locationManagerAccuracy = locationManagerAccuracy;
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
        self.locationManager.desiredAccuracy = _locationManagerAccuracy;
        [self.locationManager startUpdatingLocation];
    }
}

- (NSUnitLength *)distanceUnits {
    if (_distanceUnits) {
        return _distanceUnits;
    } else if (self.unitSystem == DUXBetaUnitSystemMetric) {
        return NSUnitLength.meters;
    } else {
        return NSUnitLength.feet;
    }
}

- (void)setDistanceUnits:(NSUnitLength *)distanceUnits {
    _distanceUnits = distanceUnits;
    [self updateDistance];
}

/*********************************************************************************/
#pragma mark - CLLocationManagerDelegate
/*********************************************************************************/

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if ([locations count] > 0) {
        self.deviceLocation = [locations lastObject];
    }
}

@end
