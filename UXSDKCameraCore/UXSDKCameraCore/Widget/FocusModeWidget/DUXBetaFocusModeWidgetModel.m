//
//  DUXBetaFocusModeWidgetModel.m
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

#import "DUXBetaFocusModeWidgetModel.h"


@interface DUXBetaFocusModeWidgetModel ()

@property (assign, nonatomic) BOOL isConnected;
@property (assign, nonatomic) BOOL isSupported;
@property (assign, nonatomic) BOOL isAFCSupportedOnAircraft;

@end


@implementation DUXBetaFocusModeWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _isConnected = NO;
        _isSupported = NO;
        _isAFCSupportedOnAircraft = NO;
        _focusMode = DJICameraFocusModeUnknown;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIParamConnection], isConnected);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamIsMFSupported], isSupported);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamIsAFCSupported], isAFCSupportedOnAircraft);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamFocusMode], focusMode);
    BindRKVOModel(self, @selector(updateStates), isConnected, isSupported);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateStates {
    if (!self.isConnected) {
        self.isSupported = NO;
        self.focusMode = DJICameraFocusModeUnknown;
    }
}

// TODO: Add check for isAFCEnabled through camera settings panel when implemented
- (void)switchFocusMode:(DJICompletionBlock)completion {
    __weak typeof(self) weakSelf = self;
    if (self.focusMode == DJICameraFocusModeManual) {
        if (self.isAFCSupportedOnAircraft) {
            self.focusMode = DJICameraFocusModeAFC;
        } else {
            self.focusMode = DJICameraFocusModeAuto;
        }
    } else {
        self.focusMode = DJICameraFocusModeManual;
    }
    [[DJISDKManager keyManager] setValue:@(weakSelf.focusMode)
                                  forKey:[DJICameraKey keyWithIndex:self.preferredCameraIndex
                                                           andParam:DJICameraParamFocusMode]
                          withCompletion:^(NSError * _Nullable error) {
                              if (error) {
                                  if (completion) {
                                      completion(error);
                                  }
                              }
                          }];
}

@end
