//
//  DUXBetaRCStickModeListItemWidgetModel.m
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidgetModel.h>
#import "DUXBetaRCStickModeListItemWidgetModel.h"
#import "NSObject+DUXBetaRKVOExtension.h"
@import DJIUXSDKCore;

@implementation DUXBetaRCStickModeListItemWidgetModel

- (void)inSetup {
    DJIRemoteControllerKey *rcKey = [DJIRemoteControllerKey keyWithParam:DJIRemoteControllerParamAircraftMappingStyle];
    
    BindSDKKey(rcKey, remoteControllerMappingStyle);
}

- (void)inCleanup {
    UnBindSDK;
}

- (void)setStickMode:(DJIRCAircraftMappingStyle)newMode onCompletion:(void (^ _Nullable)(NSError *)  )resultsBlock {
    [[DJISDKManager keyManager]  setValue:@(newMode) forKey:[DJIRemoteControllerKey keyWithParam:DJIRemoteControllerParamAircraftMappingStyle] withCompletion:^(NSError * _Nullable error) {
        if (error) {
            [DUXBetaStateChangeBroadcaster send:[RCModeListItemModelState rcStickModeUpdateFailed:error]];
        } else {
            [DUXBetaStateChangeBroadcaster send:[RCModeListItemModelState rcStickModeUpdated:newMode]];
        }
        if (resultsBlock) {
            resultsBlock(error);
        }
    }];
}

@end

@implementation RCModeListItemModelState

+ (instancetype)rcStickModeUpdated:(DJIRCAircraftMappingStyle)newMode {
    return [[self alloc] initWithKey:@"rcStickModeUpdated" number:@(newMode)];
}

+ (instancetype)setRCStickModeSuccess {
    return [[self alloc] initWithKey:@"setRCrStickModeSuccess" number:@(YES)];
}

+ (instancetype)rcStickModeUpdateFailed:(NSError *)error {
    return [[self alloc] initWithKey:@"rcStickModeUpdatFailed" object:error];;
}

@end
