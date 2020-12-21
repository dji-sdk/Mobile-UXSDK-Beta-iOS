//
//  DUXBetaRemainingFlightTimeWidgetModel.m
//  UXSDKCore
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

#import "DUXBetaRemainingFlightTimeWidgetModel.h"


@interface DUXBetaRemainingFlightTimeWidgetModel ()

// Private Properties
@property BOOL isFlying;
@property float batteryChargeRemainingInPercent;
@property float batteryPercentNeededToLand;
@property float batteryPercentNeededToGoHome;
@property float seriouslyLowBatteryWarningThreshold;
@property float lowBatteryWarningThreshold;
@property NSTimeInterval remainingFlightTime;

// Public Properties
@property (nonatomic, readwrite) DUXBetaRemainingFlightTimeData *flightTimeData;

@end

@implementation DUXBetaRemainingFlightTimeWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _flightTimeData = [[DUXBetaRemainingFlightTimeData alloc] initWithCharge:0.0 batteryNeededToLand:0.0 batteryNeededToGoHome:0.0 seriousLowBatteryThreshold:0.0 lowBatteryThreshold:0.0 andFlightTime:0.0];
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIBatteryKey keyWithParam: DJIBatteryParamChargeRemainingInPercent], batteryChargeRemainingInPercent);
    BindSDKKey([DJIFlightControllerKey keyWithParam: DJIFlightControllerParamBatteryPercentageNeededToLandFromCurrentHeight], batteryPercentNeededToLand);
    BindSDKKey([DJIFlightControllerKey keyWithParam: DJIFlightControllerParamBatteryPercentageNeededToGoHome], batteryPercentNeededToGoHome);
    BindSDKKey([DJIFlightControllerKey keyWithParam: DJIFlightControllerParamSeriousLowBatteryWarningThreshold], seriouslyLowBatteryWarningThreshold);
    BindSDKKey([DJIFlightControllerKey keyWithParam: DJIFlightControllerParamLowBatteryWarningThreshold], lowBatteryWarningThreshold);
    BindSDKKey([DJIFlightControllerKey keyWithParam: DJIFlightControllerParamRemainingFlightTime], remainingFlightTime);
    BindSDKKey([DJIFlightControllerKey keyWithParam: DJIFlightControllerParamIsFlying], isFlying);

    BindRKVOModel(self, @selector(updateStates), isProductConnected, batteryChargeRemainingInPercent, batteryPercentNeededToGoHome, batteryPercentNeededToLand, seriouslyLowBatteryWarningThreshold, lowBatteryWarningThreshold, remainingFlightTime);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateStates {
    if (!self.isProductConnected) {
        self.batteryChargeRemainingInPercent = 0;
        self.batteryPercentNeededToLand = 0;
        self.batteryPercentNeededToGoHome = 0;
        self.seriouslyLowBatteryWarningThreshold = 0;
        self.lowBatteryWarningThreshold = 0;
        self.remainingFlightTime = 0;
    }
    
    self.flightTimeData = [[DUXBetaRemainingFlightTimeData alloc] initWithCharge:self.batteryChargeRemainingInPercent
                                                         batteryNeededToLand:self.batteryPercentNeededToLand
                                                       batteryNeededToGoHome:self.batteryPercentNeededToGoHome
                                                  seriousLowBatteryThreshold:self.seriouslyLowBatteryWarningThreshold
                                                         lowBatteryThreshold:self.lowBatteryWarningThreshold
                                                               andFlightTime:self.remainingFlightTime];
}

@end

