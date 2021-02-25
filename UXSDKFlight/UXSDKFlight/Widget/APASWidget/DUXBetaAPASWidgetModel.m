//
//  DUXBetaAPASWidgetModel.m
//  UXSDKFlight
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

#import "DUXBetaAPASWidgetModel.h"

#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaAPASWidgetModel ()

@property (nonatomic, assign, readwrite) BOOL isConnected;
@property (nonatomic, assign, readwrite) BOOL isSupported;
@property (nonatomic, strong, readwrite) NSString *productName;
@property (nonatomic, assign, readwrite) BOOL isActive;
@property (nonatomic, assign, readwrite) BOOL isEnabled;
@property (nonatomic, assign, readwrite) DUXBetaAPASState apasState;

@end

@implementation DUXBetaAPASWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _isConnected = NO;
        _isSupported = NO;
        _isActive = NO;
        _isEnabled = NO;
        _productName = @"";
        _apasState = DUXBetaAPASStateUnknown;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIParamConnection],isConnected);
    BindSDKKey([DJIProductKey keyWithParam:DJIProductParamModelName],productName);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerFlightAssistantSubComponent
                                  subComponentIndex:0
                                           andParam:DJIFlightAssistantParamIsAdvancedPilotAssistanceSystemActive],isActive);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerFlightAssistantSubComponent
                                  subComponentIndex:0
                                           andParam:DJIFlightAssistantParamAdvancedPilotAssistanceSystemEnabled],isEnabled);
    
    BindRKVOModel(self, @selector(updateAPASState),isConnected, productName, isActive, isEnabled);

}

- (void)updateAPASState {
    self.isSupported = [ProductUtil isAPASSupportedProduct];
    
    if (!self.isConnected) {
        self.apasState = DUXBetaAPASStateUnknown;
    } else if (!self.isSupported) {
        self.apasState = DUXBetaAPASStateNotSupported;
    } else if (!self.isEnabled) {
        self.apasState = DUXBetaAPASStateDisabled;
    } else if (!self.isActive) {
        self.apasState = DUXBetaAPASStateInactive;
    } else {
        self.apasState = DUXBetaAPASStateActive;
    }
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)toggleAPASWithCompletion:(DUXBetaWidgetModelActionCompletionBlock)completionBlock {
    DJIFlightControllerKey *key = [DJIFlightControllerKey keyWithIndex:0
                                                          subComponent:DJIFlightControllerFlightAssistantSubComponent
                                                     subComponentIndex:0
                                                              andParam:DJIFlightAssistantParamAdvancedPilotAssistanceSystemEnabled];
    [[DJISDKManager keyManager] setValue:@(!self.isEnabled) forKey:key withCompletion:^(NSError * _Nullable error) {
        completionBlock(error);
    }];
}

@end
