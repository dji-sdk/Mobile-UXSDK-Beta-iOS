//
//  DUXBetaMapWidgetModel.m
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

#import "DUXBetaMapWidgetModel.h"
#import "DUXBetaBaseWidgetModel+Protected.h"
@import DJIUXSDKCore;

@interface DUXBetaMapWidgetModel ()

@property (strong, nonatomic, readwrite) CLLocation *homeLocation;
@property (strong, nonatomic, readwrite) CLLocation *aircraftLocation;
@property (strong, nonatomic, readwrite) DJISDKVector3D *attitude;
@property (assign, nonatomic, readwrite) BOOL isHomeLocationSet;

@end

@implementation DUXBetaMapWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.homeLocation = nil;
        self.aircraftLocation = nil;
        self.attitude = nil;
        self.isHomeLocationSet = NO;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAttitude],attitude);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAircraftLocation],aircraftLocation);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamHomeLocation],homeLocation);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamIsHomeLocationSet],isHomeLocationSet);
    //TODO Add this once we figure out our communication system for UXSDK
    //[DUXBetaKey keyWithParam:DUXBetaParamUserAccountState]
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

@end
