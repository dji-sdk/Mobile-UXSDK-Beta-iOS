//
//  DUXBetaManualFocusWidgetModel.m
//  UXSDKCameraCore
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

#import "DUXBetaManualFocusWidgetModel.h"


@interface DUXBetaManualFocusWidgetModel ()

@property (nonatomic) BOOL isConnected;
@property (nonatomic, readwrite) BOOL shouldShowWidget;
@property (nonatomic) DJICameraFocusMode cameraFocusMode;
@property (nonatomic, readwrite) int focusRingUpperBound;
@property (nonatomic, readwrite) int focusRingValue;
@property (nonatomic, readwrite) int infinityFocusValue;

@end

@implementation DUXBetaManualFocusWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.preferredCameraIndex = 0;
        self.isConnected = NO;
        self.shouldShowWidget = NO;
        self.cameraFocusMode = DJICameraFocusModeUnknown;
        self.focusRingUpperBound = 0;
        self.focusRingValue = 0;
        self.infinityFocusValue = 0;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIParamConnection], isConnected);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamFocusMode], cameraFocusMode);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamFocusRingValueUpperBound], focusRingUpperBound);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamFocusRingValue], focusRingValue);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamMFCalibrateInfinityLength], infinityFocusValue);
    BindRKVOModel(self, @selector(updateStates), isConnected, cameraFocusMode);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateStates {
    if (self.isConnected && self.cameraFocusMode == DJICameraFocusModeManual) {
        self.shouldShowWidget = YES;
    } else {
        self.shouldShowWidget = NO;
    }
}

- (void)changeIndex:(NSInteger)preferredCameraIndex {
    _preferredCameraIndex = preferredCameraIndex;
    if (self.vmState == DUXBetaVMStateSetUp) {
        [self inCleanup];
        [self inSetup];
    }
}

@end
