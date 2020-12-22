//
//  DUXBetaBaseWidgetModel.m
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

#import "DUXBetaBaseWidgetModel.h"
#import "DUXBetaSingleton.h"

#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaBaseWidgetModel ()

@property (assign, nonatomic, readwrite) BOOL isProductConnected;
@property (nonatomic, strong) NSMutableArray *moduleList;
@property (nonatomic, weak) id<DUXBetaKeyInterfaces> handler;

@end

@implementation DUXBetaBaseWidgetModel

- (instancetype)init {
    if (self = [super init]) {
        _vmState = DUXBetaVMStateCreated;
        _isProductConnected = NO;
        _moduleList = [NSMutableArray new];
    }
    return self;
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
    
    for (DUXBetaBaseModule *module in self.moduleList) {
        [module setup];
    }
    
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
    
    for (DUXBetaBaseModule *module in self.moduleList) {
        [module cleanup];
    }

    UnBindSDK;
    self.vmState = DUXBetaVMStateCleanedUp;
}

- (void)addModule:(DUXBetaBaseModule *)module {
    if (self.vmState == DUXBetaVMStateSetUp) {
        NSLog(@"WidgetModel is already setup. Add the module in the initialization phase");
        return;
    }
    
    if ([self.moduleList containsObject:module]) {
        NSLog(@"WidgetModel was previously added.");
        return;
    } else {
        [self.moduleList addObject:module];
    }
}

@end
