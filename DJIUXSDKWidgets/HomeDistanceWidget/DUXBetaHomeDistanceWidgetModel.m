//
//  DUXBetaHomeDistanceWidgetModel.m
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

#import "DUXBetaHomeDistanceWidgetModel.h"
#import "DUXBetaBaseWidgetModel+Protected.h"
@import DJIUXSDKCore;

@interface DUXBetaHomeDistanceWidgetModel()

@property (assign, nonatomic) double distanceInMeters;
@property (nonatomic) NSMeasurement *distance;
@property (nonatomic) CLLocation *homeLocation;
@property (nonatomic) CLLocation *aircraftLocation;

@end

@implementation DUXBetaHomeDistanceWidgetModel

@synthesize distanceUnits = _distanceUnits;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.distanceInMeters = 0;
        self.homeLocation = nil;
        self.aircraftLocation = nil;
        if (self.unitSystem == DUXBetaUnitSystemMetric) {
            self.distance = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.meters];
        } else {
            self.distance = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.feet];
        }
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamHomeLocation], homeLocation);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAircraftLocation], aircraftLocation);
    
    BindRKVOModel(self, @selector(updateDistanceInMeters), homeLocation, aircraftLocation);
    BindRKVOModel(self, @selector(updateDistance), distanceInMeters);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void) updateDistanceInMeters {
    if (self.aircraftLocation == nil ||
        self.homeLocation == nil ||
        !CLLocationCoordinate2DIsValid(self.aircraftLocation.coordinate) ||
        !CLLocationCoordinate2DIsValid(self.homeLocation.coordinate)) {
        self.distanceInMeters = 0;
        return;
    }
    self.distanceInMeters = [self.aircraftLocation distanceFromLocation:self.homeLocation];
}

- (void)updateDistance {
    NSMeasurement *distance = [[NSMeasurement alloc] initWithDoubleValue:self.distanceInMeters unit: NSUnitLength.meters];
    self.distance = [distance measurementByConvertingToUnit: self.distanceUnits];
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

@end
