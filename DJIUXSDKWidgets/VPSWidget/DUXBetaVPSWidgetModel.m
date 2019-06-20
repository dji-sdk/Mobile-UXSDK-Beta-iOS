//
//  DUXBetaVPSWidgetModel.m
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

#import "DUXBetaVPSWidgetModel.h"
#import "DUXBetaBaseWidgetModel+Protected.h"
@import DJIUXSDKCore;

@interface DUXBetaVPSWidgetModel()

@property (assign, nonatomic) BOOL isEnabled;
@property (assign, nonatomic) BOOL isBeingUsed;
@property (assign, nonatomic, readwrite) double vpsHeightInMeters;
@property (nonatomic, readwrite) NSMeasurement *vpsHeight;
@property (nonatomic, readwrite) NSMeasurement *vpsDangerHeight;
@property (nonatomic, readwrite) DUXBetaVPSStatus vpsStatus;

@end

@implementation DUXBetaVPSWidgetModel

@synthesize vpsUnits = _vpsUnits;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isEnabled = NO;
        self.isBeingUsed = NO;
        self.vpsHeightInMeters = 0;
        self.vpsStatus = DUXBetaVPSStatusUnknown;
        if (self.unitSystem == DUXBetaUnitSystemMetric) {
            self.vpsHeight = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.meters];
            self.vpsDangerHeight = [[NSMeasurement alloc] initWithDoubleValue:1.2 unit: NSUnitLength.meters];
        } else {
            self.vpsHeight = [[NSMeasurement alloc] initWithDoubleValue:0 unit: NSUnitLength.feet];
            self.vpsDangerHeight = [[[NSMeasurement alloc] initWithDoubleValue:1.2 unit: NSUnitLength.meters]
                                    measurementByConvertingToUnit:NSUnitLength.feet];
        }
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamVisionAssistedPositioningEnabled], isEnabled);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamIsUltrasonicBeingUsed], isBeingUsed);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamUltrasonicHeightInMeters], vpsHeightInMeters);

    BindRKVOModel(self, @selector(updateVPSHeight), vpsHeightInMeters);
    BindRKVOModel(self, @selector(updateStates), isBeingUsed, isEnabled);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateStates {
    if (self.isBeingUsed) {
        self.vpsStatus = DUXBetaVPSStatusBeingUsed;
    } else if (self.isEnabled) {
        self.vpsStatus = DUXBetaVPSStatusEnabled;
    } else {
        self.vpsStatus = DUXBetaVPSStatusUnknown;
    }
}

- (void)updateVPSHeight {
    NSMeasurement *vpsHeight = [[NSMeasurement alloc] initWithDoubleValue:self.vpsHeightInMeters unit: NSUnitLength.meters];
    self.vpsHeight = [vpsHeight measurementByConvertingToUnit: self.vpsUnits];
    self.vpsDangerHeight = [self.vpsDangerHeight measurementByConvertingToUnit: self.vpsUnits];
}

- (NSUnitLength *)vpsUnits {
    if (_vpsUnits) {
        return _vpsUnits;
    } else if (self.unitSystem == DUXBetaUnitSystemMetric) {
        return NSUnitLength.meters;
    } else {
        return NSUnitLength.feet;
    }
}

- (void)setVpsUnits:(NSUnitLength *)vpsUnits {
    _vpsUnits = vpsUnits;
    [self updateVPSHeight];
}

@end
