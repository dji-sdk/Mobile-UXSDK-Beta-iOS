//
//  DUXBetaVisionWidgetModel.m
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

#import "DUXBetaVisionWidgetModel.h"
#import "DUXBetaBaseWidgetModel+Protected.h"
@import DJIUXSDKCore;

@interface DUXBetaVisionWidgetModel()

@property (assign, nonatomic) NSString* aircraftModel;
@property (assign, nonatomic) DJIFlightMode flightMode;
@property (assign, nonatomic) DJILandingGearState landingGearState;
@property (nonatomic, readwrite) BOOL isSensorWorking;
@property (nonatomic, readwrite) BOOL isCollisionAvoidanceEnabled;
@property (nonatomic, readwrite) BOOL isLeftRightSensorEnabled;
@property (nonatomic, readwrite) BOOL isNoseTailSensorEnabled;

//Exposed properties
@property (assign, nonatomic, readwrite) DUXBetaVisionStatus visionStatus;

@end

@implementation DUXBetaVisionWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _aircraftModel = DJIAircraftModelNameUnknownAircraft;
        _flightMode = DJIFlightModeUnknown;
        _landingGearState = DJILandingGearStateUnknown;
        _isSensorWorking = NO;
        _isCollisionAvoidanceEnabled = NO;
        _isLeftRightSensorEnabled = NO;
        _isNoseTailSensorEnabled = NO;
        _visionStatus = DUXBetaVisionStatusUnknown;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIProductKey keyWithParam:DJIProductParamModelName], aircraftModel);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamFlightMode], flightMode);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamLandingGearState], landingGearState);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamIsSensorBeingUsed], isSensorWorking);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerFlightAssistantSubComponent
                                  subComponentIndex:0
                                           andParam:DJIFlightAssistantParamCollisionAvoidanceEnabled], isCollisionAvoidanceEnabled);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerFlightAssistantSubComponent
                                  subComponentIndex:0
                                           andParam:DJIFlightAssistantParamVisionLeftRightSensorEnabled], isLeftRightSensorEnabled);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerFlightAssistantSubComponent
                                  subComponentIndex:0
                                           andParam:DJIFlightAssistantParamVisionNoseTailSensorEnabled], isNoseTailSensorEnabled);

    BindRKVOModel(self, @selector(updateStates), isSensorWorking, aircraftModel, isCollisionAvoidanceEnabled, flightMode, landingGearState, isNoseTailSensorEnabled, isLeftRightSensorEnabled);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateStates {
    if (!self.isSensorWorking) {
        self.visionStatus = DUXBetaVisionStatusDisabled;
        return;
    }

    if ([self.aircraftModel isEqualToString:DJIAircraftModelNameMavic2] ||
        [self.aircraftModel isEqualToString:DJIAircraftModelNameMavic2Pro] ||
        [self.aircraftModel isEqualToString:DJIAircraftModelNameMavic2Zoom]) {
        self.visionStatus = [self visionStatusForMavic2];
    } else if ([self.aircraftModel isEqualToString:DJIAircraftModelNameMavic2Enterprise] ||
               [self.aircraftModel isEqualToString:DJIAircraftModelNameMavic2EnterpriseDual]) {
        self.visionStatus = [self visionStatusForMavic2Enterprise];
    } else {
        if (!self.isCollisionAvoidanceEnabled) {
            self.visionStatus = DUXBetaVisionStatusClosed;
        } else if (![self isVisionSystemEnabled]) {
            self.visionStatus = DUXBetaVisionStatusDisabled;
        } else {
            self.visionStatus = DUXBetaVisionStatusEnabled;
        }
    }
}

- (DUXBetaVisionStatus)visionStatusForMavic2 {
    if (self.isCollisionAvoidanceEnabled) {
        if (self.isLeftRightSensorEnabled && self.isNoseTailSensorEnabled && [self isVisionSystemEnabled]) {
            return DUXBetaVisionStatusObstacleAvoidanceAllSensorsEnabled;
        } else if (!self.isLeftRightSensorEnabled && self.isNoseTailSensorEnabled && [self isVisionSystemEnabled]) {
            return DUXBetaVisionStatusObstacleAvoidanceLeftRightSensorsDisabled;
        } else {
            return DUXBetaVisionStatusObstacleAvoidanceAllSensorsDisabled;
        }
    } else {
        return DUXBetaVisionStatusObstacleAvoidanceAllSensorsDisabled;
    }
}

- (DUXBetaVisionStatus)visionStatusForMavic2Enterprise {
    if (self.isCollisionAvoidanceEnabled) {
        if (self.isLeftRightSensorEnabled && self.isNoseTailSensorEnabled) {
            return DUXBetaVisionStatusObstacleAvoidanceAllSensorsEnabled;
        } else if (self.isNoseTailSensorEnabled || [self isVisionSystemEnabled]) {
            return DUXBetaVisionStatusObstacleAvoidanceLeftRightSensorsDisabled;
        } else {
            return DUXBetaVisionStatusObstacleAvoidanceAllSensorsDisabled;
        }
    } else {
        return DUXBetaVisionStatusObstacleAvoidanceAllSensorsDisabled;
    }
}

- (BOOL)isVisionSystemEnabled {
    if (self.flightMode == DJIFlightModeAtti
        || self.flightMode == DJIFlightModeGPSSport
        || self.flightMode == DJIFlightModeGoHome
        || self.flightMode == DJIFlightModeAutoLanding
        || self.flightMode == DJIFlightModeConfirmLanding
        || self.flightMode == DJIFlightModeDraw
        || self.flightMode == DJIFlightModeGPSFollowMe
        || self.flightMode == DJIFlightModeActiveTrack
        || self.flightMode == DJIFlightModeTapFly
        || self.flightMode == DJIFlightModeActiveTrackSpotlight
        || self.flightMode == DJIFlightModeUnknown
        || self.landingGearState == DJILandingGearStateDeployed) {
        return NO;
    } else {
        return YES;
    }
}

@end
