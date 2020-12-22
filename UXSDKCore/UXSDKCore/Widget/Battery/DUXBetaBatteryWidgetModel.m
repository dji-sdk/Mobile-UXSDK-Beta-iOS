//
//  DUXBetaBatteryWidgetModel.m
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

#import "DUXBetaBatteryWidgetModel.h"
#import "DUXBetaBatteryState.h"


static const NSInteger kDUXBetaBattery1Index = 0;
static const NSInteger kDUXBetaBattery2Index = 1;

@interface DUXBetaBatteryWidgetModel ()

@property (assign, nonatomic) float battery1Percentage;
@property (assign, nonatomic) float battery2Percentage;
@property (assign, nonatomic) NSUInteger batteryPercentageNeededToGoHome;

@property (strong, nonatomic) NSArray *battery1Voltages;
@property (strong, nonatomic) NSArray *battery2Voltages;

@property (strong, nonatomic) DJIBatteryWarningRecord *warningRecordBattery1;
@property (strong, nonatomic) DJIBatteryWarningRecord *warningRecordBattery2;

@property (assign, nonatomic) DJIBatteryThresholdBehavior overallBatterySystemStatus;
@property (strong, nonatomic) DJIBatteryAggregationState *batteryAggregationState;

//Exposed Properties
@property (strong, nonatomic, readwrite) DUXBetaBatteryState *batteryState;

@end

@implementation DUXBetaBatteryWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMeasurement *voltage = [[NSMeasurement alloc] initWithDoubleValue:0 unit:NSUnitElectricPotentialDifference.volts];
        _batteryState = [[DUXBetaBatteryState alloc] initWithVoltage:voltage andBatteryPercentage:0.0 withWarningLevel:DUXBetaBatteryStatusUnknown];
        _battery1Voltages = @[];
        _battery2Voltages = @[];
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIBatteryKey keyWithIndex:kDUXBetaBattery1Index andParam:DJIBatteryParamChargeRemainingInPercent], battery1Percentage);
    BindSDKKey([DJIBatteryKey keyWithIndex:kDUXBetaBattery2Index andParam:DJIBatteryParamChargeRemainingInPercent], battery2Percentage);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamBatteryPercentageNeededToGoHome], batteryPercentageNeededToGoHome);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0 andParam:DJIFlightControllerParamBatteryThresholdBehavior], overallBatterySystemStatus);
    BindSDKKey([DJIBatteryKey keyWithIndex:kDUXBetaBattery1Index andParam:DJIBatteryParamCellVoltages], battery1Voltages);
    BindSDKKey([DJIBatteryKey keyWithIndex:kDUXBetaBattery2Index andParam:DJIBatteryParamCellVoltages], battery2Voltages);
    BindSDKKey([DJIBatteryKey keyWithIndex:kDUXBetaBattery1Index andParam:DJIBatteryParamLatestWarningRecord], warningRecordBattery1);
    BindSDKKey([DJIBatteryKey keyWithIndex:kDUXBetaBattery2Index andParam:DJIBatteryParamLatestWarningRecord], warningRecordBattery2);
    BindSDKKey([DJIBatteryKey keyWithAggregationParam:DJIBatteryParamAggregationState], batteryAggregationState);

    BindRKVOModel(self, @selector(updateStates), isProductConnected, battery1Percentage, battery2Percentage, batteryPercentageNeededToGoHome, overallBatterySystemStatus, battery1Voltages, battery2Voltages, warningRecordBattery1, warningRecordBattery2, batteryAggregationState);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (DUXBetaBatteryStatus)getAggregateStatus {
    DJIKeyManager *keyManager = [[DUXBetaKeyInterfaceAdapter sharedInstance] getHandler];
    DJIBatteryKey *batteryKey;
    
    for (int index = 0; index < self.batteryAggregationState.numberOfConnectedBatteries - 1; index++) {
        batteryKey = [DJIBatteryKey keyWithIndex:index andParam:DJIBatteryParamLatestWarningRecord];
        DJIKeyedValue *value = [keyManager getValueForKey:batteryKey];
        DJIBatteryWarningRecord *record = (DJIBatteryWarningRecord *)value.value;
        if (record.isOverHeated) {
            return DUXBetaBatteryStatusOverheating;
        }
    }
    
    if (self.batteryAggregationState.isAnyBatteryDisconnected ||
        self.batteryAggregationState.isCellDamaged ||
        self.batteryAggregationState.isFirmwareDifferenceDetected ||
        self.batteryAggregationState.isVoltageDifferenceDetected ||
        self.batteryAggregationState.isLowCellVoltageDetected) {
        return DUXBetaBatteryStatusError;
    }
    
    if (self.overallBatterySystemStatus == DJIBatteryThresholdBehaviorLandImmediately) {
       return DUXBetaBatteryStatusWarningLevel2;
    } else if (self.overallBatterySystemStatus == DJIBatteryThresholdBehaviorGoHome) {
       return DUXBetaBatteryStatusWarningLevel1;
    }
    
    return DUXBetaBatteryStatusNormal;
}

- (DUXBetaAggregateBatteryState *)getAggregateState {
    NSMeasurement *voltage = [[NSMeasurement alloc] initWithDoubleValue:self.batteryAggregationState.voltage / 1000.0
                                                                       unit:NSUnitElectricPotentialDifference.volts];
    DUXBetaBatteryStatus status = [self getAggregateStatus];
    
    return [[DUXBetaAggregateBatteryState alloc] initWithVoltage:voltage
                                        andBatteryPercentage:self.batteryAggregationState.chargeRemainingInPercent
                                            withWarningLevel:status];
}

- (DUXBetaBatteryState *)batteryStateForBattery:(NSInteger)batteryIndex {
    DJIBatteryWarningRecord *warningRecord = batteryIndex == kDUXBetaBattery1Index ? self.warningRecordBattery1 : self.warningRecordBattery2;
    NSArray *batteryVoltages = batteryIndex == kDUXBetaBattery1Index ? self.battery1Voltages : self.battery2Voltages;
    float batteryPercentage = batteryIndex == kDUXBetaBattery1Index ? self.battery1Percentage : self.battery2Percentage;
    
    DUXBetaBatteryStatus status = DUXBetaBatteryStatusUnknown;
    if (warningRecord && warningRecord.isOverHeated) {
        status = DUXBetaBatteryStatusOverheating;
    } else if (warningRecord && [self errorForWarningRecord:warningRecord]) {
        status = DUXBetaBatteryStatusError;
    } else {
        status = DUXBetaBatteryStatusNormal;
        if (self.overallBatterySystemStatus == DJIBatteryThresholdBehaviorLandImmediately) {
            status = MAX(DUXBetaBatteryStatusWarningLevel2, status);
        }
        if (self.overallBatterySystemStatus == DJIBatteryThresholdBehaviorGoHome || batteryPercentage <= self.batteryPercentageNeededToGoHome) {
            status = MAX(DUXBetaBatteryStatusWarningLevel1, status);
        }
    }

    NSMeasurement *voltage = [[NSMeasurement alloc] initWithDoubleValue:([self minimumVoltageInArrayOfCells:batteryVoltages] / 1000.0)
                                                                   unit:NSUnitElectricPotentialDifference.volts];
    return [[DUXBetaBatteryState alloc] initWithVoltage:voltage
                               andBatteryPercentage:batteryPercentage
                                   withWarningLevel:status];
}

- (BOOL)errorForWarningRecord:(DJIBatteryWarningRecord *)record {
    return (record.isCurrentOverloaded || record.isLowTemperature || record.isShortCircuited ||
            record.damagedCellIndex >= 0 || record.isCustomDischargeEnabled);
}

- (void)updateStates {
    if (self.isProductConnected) {
        if (self.batteryAggregationState.numberOfConnectedBatteries == 6) {
            self.batteryState = [self getAggregateState];
        } else if (self.batteryAggregationState.numberOfConnectedBatteries == 2 && self.battery2Voltages.count > 0) {
            DUXBetaBatteryState *battery1State = [self batteryStateForBattery:kDUXBetaBattery1Index];
            DUXBetaBatteryState *battery2State = [self batteryStateForBattery:kDUXBetaBattery2Index];
            
            DUXBetaBatteryStatus overallState = [self worstBatteryStatusForBatteryStates:@[battery1State, battery2State]];
            
            DUXBetaDualBatteryState *dualBatteryState = [[DUXBetaDualBatteryState alloc] initWithVoltage:battery1State.voltage andBatteryPercentage:battery1State.batteryPercentage withWarningLevel:overallState];
                
            dualBatteryState.battery2Percentage = battery2State.batteryPercentage;
            dualBatteryState.battery2Voltage = battery2State.voltage;
            self.batteryState = dualBatteryState;
        } else if (self.battery1Percentage >= 0 && self.battery1Voltages.count != 0) {
            self.batteryState = [self batteryStateForBattery:kDUXBetaBattery1Index];
        }
    } else {
        NSMeasurement *voltage = [[NSMeasurement alloc] initWithDoubleValue:0 unit:NSUnitElectricPotentialDifference.volts];
        DUXBetaBatteryState *state = [[DUXBetaBatteryState alloc] initWithVoltage:voltage andBatteryPercentage:0.0 withWarningLevel:DUXBetaBatteryStatusUnknown];
        self.batteryState = state;
        self.batteryAggregationState = nil;
    }
}

- (DUXBetaBatteryStatus)worstBatteryStatusForBatteryStates:(NSArray <DUXBetaBatteryState *> *)states {
    DUXBetaBatteryStatus worstStatusFound = DUXBetaBatteryStatusNormal;
    for (DUXBetaBatteryState *state in states) {
        if (state.warningStatus > worstStatusFound) {
            worstStatusFound = state.warningStatus;
        }
    }
    return worstStatusFound;
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
