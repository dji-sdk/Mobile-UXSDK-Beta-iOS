//
//  DUXBetaSystemStatusWidgetModel.h
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

#import <UXSDKCore/DUXBetaBaseWidgetModel.h>

typedef NS_ENUM(NSInteger, DUXBetaSystemStatusWarningType) {
    DUXBetaSystemStatusWarningTypeNone,
    DUXBetaSystemStatusWarningTypeSingleBatteryNormalFlight,
    DUXBetaSystemStatusWarningTypeNormalFlight,
    DUXBetaSystemStatusWarningTypeNormalReady,
    DUXBetaSystemStatusWarningTypeLimitSpace,
    DUXBetaSystemStatusWarningTypeSingleBatteryNormalFlightNoGPS,
    DUXBetaSystemStatusWarningTypeNormalFlightNoGPS,
    DUXBetaSystemStatusWarningTypeNormalReadyNoGPS,
    DUXBetaSystemStatusWarningTypeLimitSpaceNoGPS,
    DUXBetaSystemStatusWarningTypeGoingHome,
    DUXBetaSystemStatusWarningTypeGoingHomePreascending,
    DUXBetaSystemStatusWarningTypeGoingHomeAlign,
    DUXBetaSystemStatusWarningTypeGoingHomeAscending,
    DUXBetaSystemStatusWarningTypeGoingHomeCruise,
    DUXBetaSystemStatusWarningTypeLowRadioQuality,
    DUXBetaSystemStatusWarningTypeSingleBatteryNormalFlightVision,
    DUXBetaSystemStatusWarningTypeNormalFlightVision,
    DUXBetaSystemStatusWarningTypeNormalReadyVision,
    DUXBetaSystemStatusWarningTypeLimitSpaceVision,
    DUXBetaSystemStatusWarningTypeSingleBatteryNormalFlightAtti,
    DUXBetaSystemStatusWarningTypeNormalFlightAtti,
    DUXBetaSystemStatusWarningTypeNormalReadyAtti,
    DUXBetaSystemStatusWarningTypeLimitSpaceAtti,
    DUXBetaSystemStatusWarningTypeGimbalStartupBlock,
    DUXBetaSystemStatusWarningTypeGimbalWaitAutoRestart,
    DUXBetaSystemStatusWarningTypeGimbalMotorOverload,
    DUXBetaSystemStatusWarningTypeGimbalVibration,
    DUXBetaSystemStatusWarningTypeGimbalBrokenState,
    DUXBetaSystemStatusWarningTypeGimbalReachedMechanicalLimit,
    DUXBetaSystemStatusWarningTypeGimbalRotationError,
    DUXBetaSystemStatusWarningTypeGimbalMotorProtectionEnabled,
    DUXBetaSystemStatusWarningTypeGaleWarning,
    DUXBetaSystemStatusWarningTypeStrongRadioSignalNoise,
    DUXBetaSystemStatusWarningTypeStrongRCRadioSignalNoise,
    DUXBetaSystemStatusWarningTypeLowRadioSignal,
    DUXBetaSystemStatusWarningTypeLowRCSignal,
    DUXBetaSystemStatusWarningTypeRCDisturbLow,
    DUXBetaSystemStatusWarningTypeRCDisturbMid,
    DUXBetaSystemStatusWarningTypeRCDisturbHigh,
    DUXBetaSystemStatusWarningTypeLowRCPower,
    DUXBetaSystemStatusWarningTypeLowPowerGoHome,
    DUXBetaSystemStatusWarningTypeLowPower,
    DUXBetaSystemStatusWarningTypeOutOfControlGoHome,
    DUXBetaSystemStatusWarningTypeOutOfControl,
    DUXBetaSystemStatusWarningTypeGroundAirVersionNotMatch,
    DUXBetaSystemStatusWarningTypeGoHomeError,
    DUXBetaSystemStatusWarningTypeFirmwareNotMatch,
    DUXBetaSystemStatusWarningTypeNotEnoughForce,
    DUXBetaSystemStatusWarningTypeSmartSeriousLowPower,
    DUXBetaSystemStatusWarningTypeSmartSeriousLowPowerLanding,
    DUXBetaSystemStatusWarningTypeSeriousLowVoltage,
    DUXBetaSystemStatusWarningTypeSeriousLowVoltageLanding,
    DUXBetaSystemStatusWarningTypeCannotTakeoffNoAttiData,
    DUXBetaSystemStatusWarningTypeCannotTakeoffIMUIniting,
    DUXBetaSystemStatusWarningTypeCannotTakeoffNoviceProtected,
    DUXBetaSystemStatusWarningTypeCannotTakeoff,
    DUXBetaSystemStatusWarningTypeIMUHeating,
    DUXBetaSystemStatusWarningTypeARHSCompassError,
    DUXBetaSystemStatusWarningTypeIMUError,
    DUXBetaSystemStatusWarningTypeSensorError,
    DUXBetaSystemStatusWarningTypeIMUIniting,
    DUXBetaSystemStatusWarningTypeBatteryLowTemperature,
    DUXBetaSystemStatusWarningTypeBatteryOverTemperature,
    DUXBetaSystemStatusWarningTypeBatteryOverCurrent,
    DUXBetaSystemStatusWarningTypeBatteryBroken,
    DUXBetaSystemStatusWarningTypeBatteryCommunicationError,
    DUXBetaSystemStatusWarningTypeVisionCriticalError_TOF,
    DUXBetaSystemStatusWarningTypeVisionCriticalError_UltraSonic,
    DUXBetaSystemStatusWarningTypeVisionCriticalError_3D_TOF,
    DUXBetaSystemStatusWarningTypeVisionCriticalError,
    DUXBetaSystemStatusWarningTypeVisionDownCeliError,
    DUXBetaSystemStatusWarningTypeVisionFrontCeliError,
    DUXBetaSystemStatusWarningTypeVisionBackCeliError,
    DUXBetaSystemStatusWarningTypeBarometerAirError,
    DUXBetaSystemStatusWarningTypeESCError,
    DUXBetaSystemStatusWarningTypeESCAirError,
    DUXBetaSystemStatusWarningTypeCompassErrorToPAtti,
    DUXBetaSystemStatusWarningTypeCompassError,
    DUXBetaSystemStatusWarningTypeCameraEncryptError,
    DUXBetaSystemStatusWarningTypeIMUNeedCalibrate,
    DUXBetaSystemStatusWarningTypeMCError,
    DUXBetaSystemStatusWarningTypeNoSignal,
    DUXBetaSystemStatusWarningTypeNotConnectedAircraft,
    DUXBetaSystemStatusWarningTypeMCInReadSDMode,
    DUXBetaSystemStatusWarningTypeBatteryNotInPosition,
    DUXBetaSystemStatusWarningTypeDisconnected,
};

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaSystemStatusWidgetModel : DUXBetaBaseWidgetModel

@property (nonatomic, strong) DJIWarningStatusItem *warningStatusItem;

@property (assign, nonatomic) DJIWarningStatusLevel systemStatusWarningLevel;
@property (nonatomic, strong) NSString *suggestedWarningMessage;
@property (assign, nonatomic) BOOL isCriticalWarning; // This maps to isUrgenting property in prior UXSDK implementation
/**
* The module handling the unit type related logic
*/
@property (nonatomic, strong) DUXBetaUnitTypeModule         *unitModule;

@end

NS_ASSUME_NONNULL_END
