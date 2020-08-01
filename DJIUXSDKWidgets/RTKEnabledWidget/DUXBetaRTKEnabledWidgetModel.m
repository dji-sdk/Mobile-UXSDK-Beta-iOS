//
//  DUXBetaRTKEnabledWidgetModel.m
//  DJIUXSDKWidgets
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

#import <DJISDK/DJISDK.h>
#import "DUXBetaRTKEnabledWidgetModel.h"
@import DJIUXSDKCore;

@interface DUXBetaRTKEnabledWidgetModel()

@property (assign, nonatomic, readwrite) BOOL canEnableRTK;
@property (assign, nonatomic, readwrite) BOOL areMotorsOn;
@property (assign, nonatomic) BOOL isRTKTakeoffHeightSet;
@property (assign, nonatomic) DJIRTKDataSource rtkDataSource;
@property (strong, nonatomic) DJIFlightControllerKey *rtkEnabledKey;

@end

@implementation DUXBetaRTKEnabledWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _isRTKTakeoffHeightSet = NO;
        _rtkDataSource = DJIRTKDataSourceUnknown;
    }
    return self;
}

- (void)inSetup {
    self.rtkEnabledKey = [DJIFlightControllerKey keyWithIndex:0
                                                 subComponent:DJIFlightControllerRTKSubComponent
                                            subComponentIndex:0
                                                     andParam:DJIRTKParamEnabled];
    _rtkEnabled = [[DJISDKManager keyManager] getValueForKey:self.rtkEnabledKey];
    BindSDKKey(self.rtkEnabledKey, rtkEnabled);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAreMotorsOn], areMotorsOn);
    BindRKVOModel(self, @selector(updateCanEnableRTK), areMotorsOn);
    
    if ([[DJISDKManager product] isKindOfClass:DJIAircraft.class]) {
        DJIAircraft *djiAircraft = (DJIAircraft *)[DJISDKManager product];
        djiAircraft.flightController.RTK.delegate = self;
    }
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)rtk:(DJIRTK *_Nonnull)rtk didUpdateState:(DJIRTKState *_Nonnull)state {
    self.isRTKTakeoffHeightSet = state.isTakeoffAltitudeRecorded;
    self.rtkDataSource = state.homePointDataSource;
    [self updateCanEnableRTK];
}

- (void)updateCanEnableRTK {
    BOOL isHomePointTypeRTK = (self.rtkDataSource == DJIRTKDataSourceRTK);
    self.canEnableRTK = !self.areMotorsOn || (self.isRTKTakeoffHeightSet && isHomePointTypeRTK);
}

- (void)sendRtkEnabled:(BOOL)rtkEnabled {
    [[DJISDKManager keyManager] setValue:@(rtkEnabled) forKey:self.rtkEnabledKey withCompletion:^(NSError * _Nullable error) {
        if (error == nil) {
            self.rtkEnabled = rtkEnabled;
        } else {
            NSLog(@"Error setting rtkEnabled to %@:%@", rtkEnabled ? @"YES" : @"NO", error.description);
        }
    }];
    
}

@end
