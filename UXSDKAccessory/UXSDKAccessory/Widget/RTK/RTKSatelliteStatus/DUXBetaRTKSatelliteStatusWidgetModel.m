//
//  DUXBetaRTKSatelliteStatusWidgetModel.m
//  UXSDKAccessory
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

#import "DUXBetaRTKSatelliteStatusWidgetModel.h"


@interface DUXBetaRTKSatelliteStatusWidgetModel()

@property (assign, nonatomic, readwrite) BOOL rtkSupported;

@property (assign, nonatomic, readwrite) BOOL rtkEnabled;
@property (assign, nonatomic, readwrite) BOOL rtkInUse;

@property (assign, nonatomic, readwrite) DUXBetaRTKConnectionStatus rtkConnectionStatus;

@property (assign, nonatomic, readwrite) BOOL isHeadingValid;

@property (assign, nonatomic) DJIRTKReferenceStationSource rtkReferenceSource;

@property (assign, nonatomic, readwrite) DUXBetaRTKSignal rtkSignal;

@property (assign, nonatomic) DJIRTKNetworkServiceState *networkServiceState;

@property (assign, nonatomic, readwrite) DJIRTKHeadingSolution headingSolution;

@property (strong, nonatomic, readwrite) NSString *modelName;

@property (strong, nonatomic, readwrite, nullable) NSError *rtkError;

@property (assign, nonatomic, readwrite) NSUInteger locationState;

@property (strong, nonatomic, readwrite) DJIRTKState *rtkState;

@end

@implementation DUXBetaRTKSatelliteStatusWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _modelName = DJIAircraftModelNameUnknownAircraft;
        _rtkSupported = NO;
        _rtkEnabled = YES;
        _locationState = 0;
        _rtkError = nil;
        _rtkConnectionStatus = DUXBetaRTKConnectionStatusDisconnected;
    }
    return self;
}

- (void)inSetup {
    //Model Name
    BindSDKKey([DJIProductKey keyWithParam:DJIProductParamModelName], modelName);

    //RTK Reference Source
    BindSDKKey([self rtkKeyWithParam:DJIRTKParamReferenceStationSource], rtkReferenceSource);

    //Supported
    BindSDKKey([self rtkKeyWithParam:DJIFlightControllerParamRTKSupported], rtkSupported);

    //Using rtk?
    BindSDKKey([self rtkKeyWithParam:DJIRTKParamIsRTKBeingUsed], rtkInUse);

    //Enabled
    BindSDKKey([self rtkKeyWithParam:DJIRTKParamEnabled], rtkEnabled);
    
    //Status
    BindSDKKey([self rtkKeyWithParam:DJIRTKParamStatus], locationState);
    
    //Error
    BindSDKKey([self rtkKeyWithParam:DJIRTKParamError], rtkError);

    BindSDKKey([self rtkKeyWithParam:DJIRTKParamIsHeadingValid], isHeadingValid);
    BindSDKKey([self rtkKeyWithParam:DJIRTKParamHeadingSolution], headingSolution);

    
    [DJISDKManager.rtkNetworkServiceProvider addNetworkServiceStateListener:self queue:nil block:^(DJIRTKNetworkServiceState * _Nonnull state) {
        self.networkServiceState = state;
    }];
    
    if ([[DJISDKManager product] isKindOfClass:DJIAircraft.class]) {
        DJIAircraft *djiAircraft = (DJIAircraft *)[DJISDKManager product];
        djiAircraft.flightController.RTK.delegate = self;
    }
   
    BindRKVOModel(self, @selector(updateRTKSignal), modelName, rtkReferenceSource);
    BindRKVOModel(self, @selector(updateRTKConnectionStatus), rtkEnabled, rtkInUse, isProductConnected);
}

// Helper method to create an RTK Sub-Component Key
- (DJIFlightControllerKey *)rtkKeyWithParam:(NSString *)paramIn {
    return [DJIFlightControllerKey keyWithIndex:0
                                   subComponent:DJIFlightControllerRTKSubComponent
                              subComponentIndex:0
                                       andParam:paramIn];
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

// DJIRTKDelegate method to receive RTK State updates
- (void)rtk:(DJIRTK *_Nonnull)rtk didUpdateState:(DJIRTKState *_Nonnull)state {
    self.rtkState = state;
}

// Update RTK Signal Type
- (void)updateRTKSignal {
    if ([self.modelName isEqualToString:DJIAircraftModelNameMatrice210RTK]) {
        self.rtkSignal = DUXBetaRTKSignalBaseStation;
    } else {
        switch (self.rtkReferenceSource) {
            case DJIRTKReferenceStationSourceBaseStation:
                self.rtkSignal = DUXBetaRTKSignalDRTK2;
                break;
            case DJIRTKReferenceStationSourceUnknown:
                self.rtkSignal = DUXBetaRTKSignalBaseStation;
                break;
            case DJIRTKReferenceStationSourceCustomNetworkService:
                self.rtkSignal = DUXBetaRTKSignalCustomNetwork;
                break;
            case DJIRTKReferenceStationSourceNetworkRTK:
                self.rtkSignal = DUXBetaRTKSignalNetworkRTK;
                break;
        }
    }
}

// Calculate Connection Status
- (void)updateRTKConnectionStatus {
    if (self.rtkEnabled && self.isProductConnected) {
        if (self.rtkInUse) {
            self.rtkConnectionStatus = DUXBetaRTKConnectionStatusInUse;
        } else {
            self.rtkConnectionStatus = DUXBetaRTKConnectionStatusNotInUse;
        }
    } else {
        self.rtkConnectionStatus = DUXBetaRTKConnectionStatusDisconnected;
    }
}

@end
