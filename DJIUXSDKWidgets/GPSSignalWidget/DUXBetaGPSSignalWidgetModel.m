//
//  DUXBetaGPSSignalWidgetModel.m
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

#import "DUXBetaGPSSignalWidgetModel.h"
#import "DUXBetaBaseWidgetModel+Protected.h"
@import DJIUXSDKCore;

@interface DUXBetaGPSSignalWidgetModel ()

// Exposed Properties
@property (nonatomic, readwrite) NSInteger satelliteCount;
@property (nonatomic, readwrite) DUXBetaGPSSatelliteStrength satelliteSignal;
@property (nonatomic, readwrite) BOOL isRTKEnabled;
@property (nonatomic, readwrite) BOOL isUsingExternalGPS;
@property (nonatomic, readwrite) BOOL isRTKAccurate;

// Private Properties
@property (nonatomic) DJIRTKPositioningSolution positioningSolutionRTK;
@property (nonatomic) NSInteger satelliteCountGPS;
@property (nonatomic) NSInteger satelliteCountRTK;

@property (nonatomic) NSInteger mainRTKGPSCount;
@property (nonatomic) NSInteger mainRTKBeidouCount;
@property (nonatomic) NSInteger mainRTKGlonassCount;
@property (nonatomic) NSInteger mainRTKGalileoCount;

//Attempt to check if redundant gps in-use
/*@property (assign, nonatomic, readwrite) NSArray *sensorsChanged;
@property (assign, nonatomic, readwrite) NSArray *sensorsBackupAbnormal;
@property (assign, nonatomic, readwrite) NSArray *sensorsInUseAbnormal;*/

@end

@implementation DUXBetaGPSSignalWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isRTKEnabled = NO;
        self.isUsingExternalGPS = NO;
        self.satelliteSignal = DUXBetaGPSSatelliteStrengthLevel0;
        self.isRTKAccurate = NO;
    }
    return self;
}

- (void)inSetup {
    //get app delegate;
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamSatelliteCount],satelliteCountGPS);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamGPSSignalStatus],satelliteSignal);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerRTKSubComponent
                                  subComponentIndex:0
                                           andParam:DJIRTKParamEnabled], isRTKEnabled);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerRTKSubComponent
                                  subComponentIndex:0
                                           andParam:DJIRTKParamMainGPSCount], mainRTKGPSCount);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerRTKSubComponent
                                  subComponentIndex:0
                                           andParam:DJIRTKParamMainBeidouCount], mainRTKBeidouCount);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerRTKSubComponent
                                  subComponentIndex:0
                                           andParam:DJIRTKParamMainGlonassCount], mainRTKGlonassCount);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerRTKSubComponent
                                  subComponentIndex:0
                                           andParam:DJIRTKParamMainGalileoCount], mainRTKGalileoCount);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerRTKSubComponent
                                  subComponentIndex:0
                                           andParam:DJIRTKParamPositioningSolution], positioningSolutionRTK);
    
    BindRKVOModel(self, @selector(updateIsRTKAccurate), positioningSolutionRTK);
    BindRKVOModel(self, @selector(updateRTKCount), mainRTKGPSCount, mainRTKBeidouCount, mainRTKGlonassCount, mainRTKGalileoCount);
    BindRKVOModel(self, @selector(updateSatelliteCount), satelliteCountRTK, satelliteCountGPS, isRTKEnabled);

    //Attempt to check if redundant gps in-use
    /*BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamSensorDevicesChanged], sensorsChanged);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamSensorDevicesBackupAbnormal], sensorsBackupAbnormal);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamSensorDevicesInUseAbnormal], sensorsInUseAbnormal);

    BindRKVOModel(self, @selector(updateGPS), sensorsChanged, sensorsBackupAbnormal, sensorsInUseAbnormal);*/
    
    //Keys to try:
    //BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFCConfigRedundancySystemConnected], redundancyConnected);

}

- (void)updateRTKCount {
    self.satelliteCountRTK = self.mainRTKGPSCount + self.mainRTKBeidouCount + self.mainRTKGalileoCount + self.mainRTKGlonassCount;
}

//Attempt to check if redundant gps in-use
/*
- (void)updateGPS {
    NSLog(@"sensorsChanged: %@", self.sensorsChanged);
    NSLog(@"sensorsInUseAbnormal: %@", self.sensorsInUseAbnormal);
    NSLog(@"sensorsBackupAbnormal: %@ \n", self.sensorsBackupAbnormal);
}*/

- (void)updateIsRTKAccurate {
    if (self.positioningSolutionRTK == DJIRTKPositioningSolutionFixedPoint) {
        self.isRTKAccurate = YES;
    } else {
        self.isRTKAccurate = NO;
    }
}

- (void)updateSatelliteCount {
    if (self.isRTKEnabled) {
        self.satelliteCount = self.satelliteCountRTK;
    } else {
        self.satelliteCount = self.satelliteCountGPS;
    }
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

@end
