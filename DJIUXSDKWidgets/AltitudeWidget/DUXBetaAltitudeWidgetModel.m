//
//  DUXBetaAltitudeWidgetModel.m
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

#import "DUXBetaAltitudeWidgetModel.h"
#import "DUXBetaBaseWidgetModel+Protected.h"
@import DJIUXSDKCore;

@interface DUXBetaAltitudeWidgetModel()

@property (nonatomic) double altitudeInMeters;
@property (nonatomic, readwrite) NSMeasurement *altitude;

@end

@implementation DUXBetaAltitudeWidgetModel

@synthesize altitudeUnits = _altitudeUnits;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.altitudeInMeters = 0.0;
        if (self.unitSystem == DUXBetaUnitSystemMetric) {
            self.altitude = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.meters];
        } else {
            self.altitude = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.feet];
        }
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAltitudeInMeters], altitudeInMeters);

    BindRKVOModel(self, @selector(updateAltitude), altitudeInMeters);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateAltitude {
    NSMeasurement *altitude = [[NSMeasurement alloc] initWithDoubleValue:self.altitudeInMeters unit: NSUnitLength.meters];
    self.altitude = [altitude measurementByConvertingToUnit: self.altitudeUnits];
}

- (NSUnitLength *)altitudeUnits {
    if (_altitudeUnits) {
        return _altitudeUnits;
    } else if (self.unitSystem == DUXBetaUnitSystemMetric) {
        return NSUnitLength.meters;
    } else {
        return NSUnitLength.feet;
    }
}

- (void)setAltitudeUnits:(NSUnitLength *)altitudeUnits {
    _altitudeUnits = altitudeUnits;
    [self updateAltitude];
}

@end
