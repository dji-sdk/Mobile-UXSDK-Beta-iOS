//
//  DUXBetaBatteryWidgetModel.m
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

#import "DUXBetaBatteryWidgetModel.h"
#import <DJISDK/DJISDK.h>

#import "DUXBetaBaseWidgetModel+Protected.h"
@import DJIUXSDKCore;

@interface DUXBetaBatteryWidgetModel ()

@property (assign, nonatomic) float battery1Percentage;
@property (assign, nonatomic) float battery2Percentage;

@property (assign, nonatomic) DJIBatteryThresholdBehavior overallBatterySystemStatus;

@property (strong, nonatomic) NSArray *battery1Voltages;
@property (strong, nonatomic) NSArray *battery2Voltages;

@property (assign, nonatomic) float battery1MinimumVoltage;
@property (assign, nonatomic) float battery2MinimumVoltage;

@property (nonatomic, readwrite) BOOL isConnected;

@property (strong, nonatomic) DJIBatteryWarningRecord *warningRecordBattery1;
@property (strong, nonatomic) DJIBatteryWarningRecord *warningRecordBattery2;

@property (strong, nonatomic) NSString *modelName;

//Exposed Properties
@property (strong, nonatomic, readwrite)  NSDictionary <NSString *,DUXBetaBatteryState *> *batteryInformation;

@property (nonatomic, readwrite) BOOL isBatteryAggregationConnected;
@property (assign, nonatomic) float batteryAggregationPercentage;
@property (assign, nonatomic) float batteryAggregationVoltage;
@property (strong, nonatomic) DJIBatteryWarningRecord *batteryAggregationWarningRecord;

@end

@implementation DUXBetaBatteryWidgetModel

NSString * _Nonnull const kDUXBetaBattery1Key = @"1";
NSString * _Nonnull const kDUXBetaBattery2Key = @"2";
NSString * _Nonnull const kDUXBetaBatteryAggregationKey = @"3";

- (instancetype)init {
    self = [super init];
    if (self) {

        NSMeasurement *voltage = [[NSMeasurement alloc] initWithDoubleValue:0 unit:NSUnitElectricPotentialDifference.volts];
        DUXBetaBatteryState *state = [[DUXBetaBatteryState alloc] initWithVoltage:voltage andBatteryPercentage:0.0 withWarningLevel:DUXBetaBatteryStatusUnknown];
        _batteryInformation = @{kDUXBetaBattery1Key:state};
        _isConnected = NO;
        _battery1Voltages = @[];
        _battery2Voltages = @[];
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIBatteryKey keyWithIndex:0 andParam:DJIBatteryParamChargeRemainingInPercent], battery1Percentage);
    BindSDKKey([DJIBatteryKey keyWithIndex:1 andParam:DJIBatteryParamChargeRemainingInPercent], battery2Percentage);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0 andParam:DJIFlightControllerParamBatteryThresholdBehavior], overallBatterySystemStatus);
    BindSDKKey([DJIBatteryKey keyWithIndex:0 andParam:DJIBatteryParamCellVoltages], battery1Voltages);
    BindSDKKey([DJIBatteryKey keyWithIndex:1 andParam:DJIBatteryParamCellVoltages], battery2Voltages);
    BindSDKKey([DJIProductKey keyWithParam:DJIParamConnection],isConnected);
    BindSDKKey([DJIBatteryKey keyWithIndex:0 andParam:DJIBatteryParamLatestWarningRecord], warningRecordBattery1);
    BindSDKKey([DJIBatteryKey keyWithIndex:1 andParam:DJIBatteryParamLatestWarningRecord], warningRecordBattery2);
    BindSDKKey([DJIProductKey keyWithParam:DJIProductParamModelName],modelName);

    // SDK needs a public API for this, LONG_MAX is a magic number
    BindSDKKey([DJIBatteryKey keyWithIndex:LONG_MAX andParam:DJIBatteryParamChargeRemainingInPercent], batteryAggregationPercentage);
    BindSDKKey([DJIBatteryKey keyWithIndex:LONG_MAX andParam:DJIBatteryParamVoltage], batteryAggregationVoltage);
    BindSDKKey([DJIBatteryKey keyWithIndex:LONG_MAX andParam:DJIBatteryParamLatestWarningRecord], batteryAggregationWarningRecord);
    BindSDKKey([DJIBatteryKey keyWithIndex:LONG_MAX andParam:DJIParamConnection], isBatteryAggregationConnected);

    BindRKVOModel(self, @selector(updateStates), isConnected, battery1Percentage, battery2Percentage, overallBatterySystemStatus, battery1Voltages, battery2Voltages, warningRecordBattery1, warningRecordBattery2, batteryAggregationPercentage, batteryAggregationVoltage, batteryAggregationWarningRecord, isBatteryAggregationConnected);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateBatteryAggregation {
    NSMutableDictionary <NSString *, DUXBetaBatteryState *> *batteryDict = [[NSMutableDictionary alloc] init];
    NSMeasurement *voltage = [[NSMeasurement alloc] initWithDoubleValue:self.batteryAggregationVoltage
                                                                   unit:NSUnitElectricPotentialDifference.volts];
    DUXBetaBatteryStatus status = DUXBetaBatteryStatusUnknown;
    if (self.batteryAggregationWarningRecord && self.batteryAggregationWarningRecord.isOverHeated) {
        status = DUXBetaBatteryStatusOverheating;
    } else  {
        if (self.overallBatterySystemStatus == DJIBatteryThresholdBehaviorLandImmediately) {
            status = DUXBetaBatteryStatusWarningLevel2;
        } else if (self.overallBatterySystemStatus == DJIBatteryThresholdBehaviorGoHome) {
            status = DUXBetaBatteryStatusWarningLevel1;
        } else {
            status = DUXBetaBatteryStatusNormal;
        }
    }

    DUXBetaBatteryState *state = [[DUXBetaBatteryState alloc] initWithVoltage:voltage
                                                     andBatteryPercentage:self.batteryAggregationPercentage
                                                         withWarningLevel:status];
    [batteryDict setObject:state forKey:kDUXBetaBatteryAggregationKey];
    self.batteryInformation = batteryDict;
}

- (void)updateStates {

    // There is no public API in Base Product for battery aggregation.
    if ((self.isBatteryAggregationConnected && [self.modelName isEqualToString:DJIAircraftModelNameMatrice600]) || [self.modelName isEqualToString:DJIAircraftModelNameMatrice600Pro]) {
        [self updateBatteryAggregation];
    } else {
        NSMutableDictionary <NSString *, DUXBetaBatteryState *> *batteryDict = [[NSMutableDictionary alloc] init];
        if (self.battery1Percentage >= 0 && self.battery1Voltages.count != 0 && self.isConnected) {
            DUXBetaBatteryStatus status = DUXBetaBatteryStatusUnknown;
            if (self.warningRecordBattery1 && self.warningRecordBattery1.isOverHeated) {
                status = DUXBetaBatteryStatusOverheating;
            } else  {
                if (self.overallBatterySystemStatus == DJIBatteryThresholdBehaviorLandImmediately) {
                    status = DUXBetaBatteryStatusWarningLevel2;
                } else if (self.overallBatterySystemStatus == DJIBatteryThresholdBehaviorGoHome) {
                    status = DUXBetaBatteryStatusWarningLevel1;
                } else {
                    status = DUXBetaBatteryStatusNormal;
                }
            }
            NSMeasurement *voltage = [[NSMeasurement alloc] initWithDoubleValue:([self minimumVoltageInArrayOfCells:self.battery1Voltages] / 1000) unit:NSUnitElectricPotentialDifference.volts];
            DUXBetaBatteryState *state = [[DUXBetaBatteryState alloc] initWithVoltage:voltage andBatteryPercentage:self.battery1Percentage withWarningLevel:status];
            [batteryDict setObject:state forKey:kDUXBetaBattery1Key];
        }

        if (self.battery2Percentage >= 0 && self.battery2Voltages.count != 0 && self.isConnected) {
            DUXBetaBatteryStatus status = DUXBetaBatteryStatusUnknown;
            if (self.warningRecordBattery1 && self.warningRecordBattery1.isOverHeated) {
                status = DUXBetaBatteryStatusOverheating;
            } else {
                if (self.overallBatterySystemStatus == DJIBatteryThresholdBehaviorLandImmediately) {
                    status = DUXBetaBatteryStatusWarningLevel2;
                } else if (self.overallBatterySystemStatus == DJIBatteryThresholdBehaviorGoHome) {
                    status = DUXBetaBatteryStatusWarningLevel1;
                } else {
                    status = DUXBetaBatteryStatusNormal;
                }
            }

            NSMeasurement *voltage = [[NSMeasurement alloc] initWithDoubleValue:([self minimumVoltageInArrayOfCells:self.battery2Voltages] / 1000) unit:NSUnitElectricPotentialDifference.volts];
            DUXBetaBatteryState *state = [[DUXBetaBatteryState alloc] initWithVoltage:voltage andBatteryPercentage:self.battery2Percentage withWarningLevel:status];
            [batteryDict setObject:state forKey:kDUXBetaBattery2Key];
        }

        if (self.isConnected == NO) {
            [batteryDict removeAllObjects];
            NSMeasurement *voltage = [[NSMeasurement alloc] initWithDoubleValue:0 unit:NSUnitElectricPotentialDifference.volts];
            DUXBetaBatteryState *state = [[DUXBetaBatteryState alloc] initWithVoltage:voltage andBatteryPercentage:0.0 withWarningLevel:DUXBetaBatteryStatusUnknown];
            [batteryDict setObject:state forKey:kDUXBetaBattery1Key];
        }

        if (batteryDict.count) {
            self.batteryInformation = [batteryDict copy];
        }
    }
}

- (float)minimumVoltageInArrayOfCells:(NSArray *)values {
    if (values) {
        NSNumber *min= [values valueForKeyPath:@"@min.doubleValue"];
        return min.floatValue;
    } else {
        return 0.0;
    }
}

@end
