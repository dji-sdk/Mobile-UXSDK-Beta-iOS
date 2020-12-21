//
//  DUXBetaMaxFlightDistanceListItemWidgetModel.m
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

#import "DUXBetaMaxFlightDistanceListItemWidgetModel.h"
#import "DUXBetaMaxFlightDistanceListItemWidget.h"

#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaMaxFlightDistanceListItemWidgetModel()

@property (nonatomic, readwrite) BOOL                   isNoviceMode;

@property (nonatomic, strong) DJIFlightControllerKey    *maxRangeKey;
@property (nonatomic, strong) DJIFlightControllerKey    *flightRadiusEnabledKey;
@property (nonatomic, strong) DJIFlightControllerKey    *maxFlightRadiusKey;

@end

@implementation DUXBetaMaxFlightDistanceListItemWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.unitModule = [DUXBetaUnitTypeModule new];
        [self addModule:self.unitModule];
    }
    return self;
}

- (void)inSetup {
    self.maxRangeKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamMaxFlightRadiusRange];
    self.flightRadiusEnabledKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamMaxFlightRadiusEnabled];
    self.maxFlightRadiusKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamMaxFlightRadius];
    
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamNoviceModeEnabled], isNoviceMode);
    BindSDKKey(self.maxRangeKey, rangeValue);
    BindSDKKey(self.maxFlightRadiusKey, maxFlightDistance);
    BindSDKKey(self.flightRadiusEnabledKey, isFlightRadiusEnabled);
}

- (void)inCleanup {
    UnBindSDK;
}

#pragma mark - Setters

- (void)flightRadiusEnable:(BOOL)enableFlightRadius onCompletion:(void (^)(DUXBetaMaxFlightDistanceChange))resultsBlock {
    if (self.isNoviceMode) {
        return;
    }

    [[DJISDKManager keyManager]  setValue:@(enableFlightRadius) forKey:self.flightRadiusEnabledKey withCompletion:^(NSError * _Nullable error) {
        if (resultsBlock) {
            if (error) {
                resultsBlock(DUXBetaMaxFlightDistanceRadiusEnabledChangeFailed);
            } else {
                [DUXBetaStateChangeBroadcaster send:[MaxFlightDistanceItemModelState maxFlightDistanceEnabled:enableFlightRadius]];
                resultsBlock(DUXBetaMaxFlightDistanceRadiusEnabledChangeSuccessful);
            }
        }
    }];
}

- (void)updateMaxDistance:(NSUInteger)newMaxDistance onCompletion:(void (^ _Nullable)(DUXBetaMaxFlightDistanceChange))resultsBlock {
    if (self.isNoviceMode) {
        if (resultsBlock) {
            resultsBlock(DUXBetaMaxFlightDistanceChangeUnableToChangeInBeginnerMode);
        }
        return;
    }
    
    [[DJISDKManager keyManager]  setValue:@(newMaxDistance) forKey:self.maxFlightRadiusKey withCompletion:^(NSError * _Nullable error) {
        DUXBetaMaxFlightDistanceChange returnValue = DUXBetaMaxFlightDistanceChangeUnknownError;
    
        if (error) {
            [DUXBetaStateChangeBroadcaster send:[MaxFlightDistanceItemModelState setMaxFlightDistanceFailed:error]];
        } else {
            [DUXBetaStateChangeBroadcaster send:[MaxFlightDistanceItemModelState setMaxFlightDistanceSucceeded]];
            [DUXBetaStateChangeBroadcaster send:[MaxFlightDistanceItemModelState maxFlightDistanceUpdated:newMaxDistance]];

            returnValue = DUXBetaMaxFlightDistanceChangeValid;
        }
        if (resultsBlock) {
            resultsBlock(returnValue);
        }
    }];
}

@end
