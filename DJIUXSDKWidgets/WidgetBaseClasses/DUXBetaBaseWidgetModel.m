//
//  DUXBetaBaseWidgetModel.m
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

#import "DUXBetaBaseWidgetModel.h"
#import "DUXBetaBaseWidgetModel+Protected.h"
#import "DUXBetaSingleton.h"
@import DJIUXSDKCore;
@import DJIUXSDKCommunication;

@interface DUXBetaBaseWidgetModel ()

@property (assign, nonatomic, readwrite) BOOL isProductConnected;

@end

@implementation DUXBetaBaseWidgetModel

- (instancetype)init {
    if (self = [super init]) {
        _unitSystem = [[self class] preferredUnitSystem];
        _vmState = DUXBetaVMStateCreated;
        _isProductConnected = NO;
    }
    return self;
}

+ (DUXBetaUnitSystem)preferredUnitSystem {
    DUXMeasureUnitType measureUnitType = [[DUXBetaSingleton sharedGlobalPreferences] measureUnitType];
    if (measureUnitType == DUXMeasureUnitTypeUnknown) {
        return DUXBetaUnitSystemMetric;
    } else {
        if (measureUnitType == DUXMeasureUnitTypeImperial) {
            return DUXBetaUnitSystemImperial;
        } else {
            return DUXBetaUnitSystemMetric;
        }
    }
}

- (void)setup {
    if (self.vmState == DUXBetaVMStateSetUp) {
        NSLog(@"Already setup. Skip. ");
        return;
    }

    NSAssert(self.vmState == DUXBetaVMStateCreated || self.vmState == DUXBetaVMStateCleanedUp, @"Called setup in a wrong state!");

    self.vmState = DUXBetaVMStateSettingUp;
    _handler = [[DUXBetaKeyInterfaceAdapter sharedInstance] getHandler];
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIParamConnection], isProductConnected);
    [self inSetup];
    self.vmState = DUXBetaVMStateSetUp;
    [self postSetup];
}

- (void)inSetup {
}

- (void)postSetup {
}

- (void)inCleanup {
}

- (void)cleanup {
    if (self.vmState == DUXBetaVMStateCleanedUp) {
        NSLog(@"Already cleaned up. skip. ");
        return;
    }

    NSAssert(self.vmState == DUXBetaVMStateSetUp, @"Called cleanup in a wrong state!");

    self.vmState = DUXBetaVMStateCleaningUp;
    [self.handler stopAllListeningOfListeners:self];
    [self inCleanup];
    UnBindSDK;
    self.vmState = DUXBetaVMStateCleanedUp;
}

@end
