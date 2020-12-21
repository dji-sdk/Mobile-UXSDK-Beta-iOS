//
//  DUXBetaMaxAltitudeListItemWidgetModel.m
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

#import "DUXBetaMaxAltitudeListItemWidgetModel.h"
#import "DUXBetaMaxAltitudeListItemWidget.h"
#import <UXSDKCore/UXSDKCore-Swift.h>

// The legal height limit (USA) is 400 feet. 122 m is almost 4 inches over the 400 foot height limit. This gets as close to the ceiling as possible.
static const CGFloat maxLegalHeight = 121;

@interface DUXBetaMaxAltitudeListItemWidgetModel ()
@property (nonatomic, strong) DJIFlightControllerKey *maxAltitudeKey;
@property (nonatomic, strong) DJIFlightControllerKey *maxAltitudeRangeKey;
@property (nonatomic, strong) DJIFlightControllerKey *noviceModeKey;
@property (nonatomic, strong) DJIFlightControllerKey *returnHomeHeightKey;
@property (nonatomic, strong) DJIFlightControllerKey *needsFlightHeightLimitKey;

@property (nonatomic, assign) NSUInteger    limitMaxFlightHeight;
@property (nonatomic, assign) float         returnHomeHeight;
@end

@implementation DUXBetaMaxAltitudeListItemWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.unitModule = [DUXBetaUnitTypeModule new];
        [self addModule:self.unitModule];
    }
    return self;
}

- (void)inSetup {
    self.limitMaxFlightHeight = maxLegalHeight;
    
    self.maxAltitudeKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamMaxFlightHeight];
    self.maxAltitudeRangeKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamMaxFlightHeightRange];
    self.noviceModeKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamNoviceModeEnabled];
    self.returnHomeHeightKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamGoHomeHeightInMeters];
    self.needsFlightHeightLimitKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamNeedLimitFlightHeight];

    BindSDKKey(self.maxAltitudeRangeKey, rangeValue);
    BindSDKKey(self.noviceModeKey, isNoviceMode);
    BindSDKKey(self.maxAltitudeKey, maxAltitude);
    BindSDKKey(self.returnHomeHeightKey, returnHomeHeight);
    BindSDKKey(self.needsFlightHeightLimitKey, needsFlightHeightLimit);
}

- (void)inCleanup {
    UnBindSDK;
}

- (DUXBetaMaxAltitudeChange)validateNewHeight:(NSInteger)newHeight {
    if (newHeight < self.rangeValue.min.intValue) {
        return DUXBetaMaxAltitudeChangeBelowMininimumAltitude;
    }
    
    if (newHeight > self.rangeValue.max.intValue) {
        return DUXBetaMaxAltitudeChangeAboveMaximumAltitude;
    }

    if (newHeight > _limitMaxFlightHeight) {
        if (newHeight < _returnHomeHeight) {
            return DUXBetaMaxAltitudeChangeAboveWarningHeightLimitAndBelowReturnHomeAltitude;
        } else {
            return DUXBetaMaxAltitudeChangeAboveWarningHeightLimit;
        }
    }
    if (newHeight < _returnHomeHeight) {
        return DUXBetaMaxAltitudeChangeBelowReturnHomeAltitude;
    }
    
    if (newHeight > _returnHomeHeight) {
        return DUXBetaMaxAltitudeChangeAboveReturnHomeMaxAltitude;
    }
    
    return DUXBetaMaxAltitudeChangeMaxAltitudeValid;
}

- (void)updateMaxHeight:(NSInteger)newHeight onCompletion:(void (^)(DUXBetaMaxAltitudeChange))resultsBlock {
    if (self.isNoviceMode) {
        resultsBlock(DUXBetaMaxAltitudeChangeUnableToChangeMaxAltitudeInBeginnerMode);
        return;
    }
    
    [[DJISDKManager keyManager] setValue:@(newHeight) forKey:self.maxAltitudeKey withCompletion:^(NSError * _Nullable error) {
        DUXBetaMaxAltitudeChange returnValue = DUXBetaMaxAltitudeChangeUnknownError;
    
        if (error == nil) {
            [DUXBetaStateChangeBroadcaster send:[MaxAltitudeItemModelState maxAltitudeChanged:newHeight]];
            returnValue = DUXBetaMaxAltitudeChangeMaxAltitudeValid;
        }
        resultsBlock(returnValue);
    }];

    // Now we need to see what the current return home height is. If it is higher than the new max altidude, make sure it
    // is set to keep under that maximum
    if (self.returnHomeHeight > newHeight) {
        [[DJISDKManager keyManager] setValue:@(newHeight) forKey:self.returnHomeHeightKey withCompletion:^(NSError * _Nullable error) {
            DUXBetaMaxAltitudeChange returnValue = DUXBetaMaxAltitudeChangeMaxAltitudeValid;
            if (error) {
                returnValue = DUXBetaMaxAltitudeChangeUnableToChangeReturnHomeAltitude;
                resultsBlock(returnValue);
            }
        }];
    }
}

@end

