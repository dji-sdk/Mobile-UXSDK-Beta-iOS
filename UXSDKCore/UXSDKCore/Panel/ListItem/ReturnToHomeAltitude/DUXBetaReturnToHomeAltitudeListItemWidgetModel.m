//
//  DUXBetaReturnToHomeAltitudeListItemWidgetModel.m
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

#import "DUXBetaReturnToHomeAltitudeListItemWidgetModel.h"
#import "DUXBetaReturnToHomeAltitudeListItemWidget.h"
#import <UXSDKCore/UXSDKCore-Swift.h>

static const CGFloat maxLegalHeight = 120;

@interface DUXBetaReturnToHomeAltitudeListItemWidgetModel()
@property (nonatomic, readwrite) BOOL                isNoviceMode;

@property (nonatomic, strong) DJIFlightControllerKey *maxAltitudeKey;
@property (nonatomic, strong) DJIFlightControllerKey *maxAltitudeRangeKey;
@property (nonatomic, strong) DJIFlightControllerKey *returnHomeHeightKey;

@property (nonatomic, assign) NSUInteger    limitRTHFlightHeight;
@end

@implementation DUXBetaReturnToHomeAltitudeListItemWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.unitModule = [DUXBetaUnitTypeModule new];
        [self addModule:self.unitModule];
    }
    return self;
}

- (void)inSetup {
    self.limitRTHFlightHeight = maxLegalHeight;

    self.returnHomeHeightKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamGoHomeHeightInMeters];
    self.maxAltitudeKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamMaxFlightHeight];
    self.maxAltitudeRangeKey = [DJIFlightControllerKey keyWithParam:DJIFlightControllerParamMaxFlightHeightRange];

    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamNoviceModeEnabled], isNoviceMode);
    BindSDKKey(self.maxAltitudeRangeKey, rangeValue);
    BindSDKKey(self.maxAltitudeKey, maxAltitude);
    BindSDKKey(self.returnHomeHeightKey, returnToHomeAltitude);
}

- (void)inCleanup {
    UnBindSDK;
}

- (DUXBetaReturnToHomeAltitudeChange)validateNewHeight:(NSInteger)newHeight {
    if (newHeight < self.rangeValue.min.intValue) {
        return DUXBetaReturnToHomeAltitudeChangeBelowMininimumAltitude;
    }
    
    if ((newHeight > self.rangeValue.max.intValue) || (newHeight > self.maxAltitude)) {
        return DUXBetaReturnToHomeAltitudeChangeAboveMaximumAltitude;
    }

    if (newHeight > _limitRTHFlightHeight) {
        return DUXBetaReturnToHomeAltitudeChangeAboveWarningHeightLimit;
    }
    
    return DUXBetaReturnToHomeAltitudeChangeValid;
}

- (void)updateReturnHomeHeight:(NSInteger)newHeight onCompletion:(void (^)(DUXBetaReturnToHomeAltitudeChange))resultsBlock {
    if (self.isNoviceMode) {
        resultsBlock(DUXBetaReturnToHomeAltitudeChangeUnableToChangeInBeginnerMode);
        return;
    }
    
    [[DJISDKManager keyManager]  setValue:@(newHeight) forKey:self.returnHomeHeightKey withCompletion:^(NSError * _Nullable error) {
        DUXBetaReturnToHomeAltitudeChange returnValue = DUXBetaReturnToHomeAltitudeChangeUnknownError;
    
        if (error) {
            [DUXBetaStateChangeBroadcaster send:[ReturnToHomeAltitudeItemModelState setReturnToHomeAltitudeFailed:error]];
        } else {
            [DUXBetaStateChangeBroadcaster send:[ReturnToHomeAltitudeItemModelState returnHeightUpdated:newHeight]];
            [DUXBetaStateChangeBroadcaster send:[ReturnToHomeAltitudeItemModelState setReturnToHomeAltitudeSucceeded]];
            returnValue = DUXBetaReturnToHomeAltitudeChangeValid;
        }
        resultsBlock(returnValue);
    }];
}

@end
