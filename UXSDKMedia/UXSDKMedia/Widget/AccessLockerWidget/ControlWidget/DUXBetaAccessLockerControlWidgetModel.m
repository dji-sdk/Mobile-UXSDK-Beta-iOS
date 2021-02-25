//
//  DUXBetaAccessLockerControlWidgetModel.m
//  UXSDKMedia
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

#import "DUXBetaAccessLockerControlWidgetModel.h"


@interface DUXBetaAccessLockerControlWidgetModel ()

@property (nonatomic, assign, readwrite) DJIAccessLockerState currentAccessLockerStateType;

@end

@implementation DUXBetaAccessLockerControlWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentAccessLockerStateType = DJIAccessLockerStateUnknown;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0
                                       subComponent:DJIFlightControllerAccessLockerSubComponent
                                  subComponentIndex:0
                                           andParam:DJIAccessLockerParamState], currentAccessLockerStateType);
}

- (void)inCleanup {
    UnBindSDK;
}

- (void)initalizeAccessLockerWithPassword:(NSString *)password andCompletion:(DUXBetaWidgetModelActionCompletionBlock)completionBlock {
    DJIFlightControllerKey *key = [DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerAccessLockerSubComponent subComponentIndex:0 andParam:DJIAccessLockerParamSetUpUserAccount];
    [[DJISDKManager keyManager] performActionForKey: key
                                      withArguments:@[[[DJIAccessLockerUserAccountInfo alloc] initWithUserName:@"username" securityCode:password]]
                                      andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
                                          completionBlock(error);
        
                                    }];
}

- (void)loginToAccessLockerWithPassword:(NSString *)password andCompletion:(DUXBetaWidgetModelActionCompletionBlock)completionBlock {
    DJIFlightControllerKey *key = [DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerAccessLockerSubComponent subComponentIndex:0 andParam:DJIAccessLockerParamLogin];
    [[DJISDKManager keyManager] performActionForKey: key
                                      withArguments:@[[[DJIAccessLockerUserAccountInfo alloc] initWithUserName:@"username" securityCode:password]]
                                      andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
                                          completionBlock(error);
                                      }];
}

- (void)changeAccessLockerPassword:(NSString *)newPassword fromCurrentPassword:(NSString *)currentPassword withCompletion:(DUXBetaWidgetModelActionCompletionBlock)completionBlock {
    DJIFlightControllerKey *key = [DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerAccessLockerSubComponent subComponentIndex:0 andParam:DJIAccessLockerParamModifyUserAccount];
    DJIAccessLockerUserAccountInfo *currentAccountInfo = [[DJIAccessLockerUserAccountInfo alloc] initWithUserName:@"username" securityCode:currentPassword];
    DJIAccessLockerUserAccountInfo *newAccountInfo  = [[DJIAccessLockerUserAccountInfo alloc] initWithUserName:@"username" securityCode:newPassword];
    [[DJISDKManager keyManager] performActionForKey:key withArguments:@[currentAccountInfo, newAccountInfo] andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
        completionBlock(error);
    }];
}

- (void)removeAccessLockerPassword:(NSString *)password withCompletion:(DUXBetaWidgetModelActionCompletionBlock)completionBlock {
    DJIFlightControllerKey *key = [DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerAccessLockerSubComponent subComponentIndex:0 andParam:DJIAccessLockerParamResetUserAccount];
    DJIAccessLockerUserAccountInfo *accountInfo = [[DJIAccessLockerUserAccountInfo alloc] initWithUserName:@"username" securityCode:password];
    [[DJISDKManager keyManager] performActionForKey:key withArguments:@[accountInfo] andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
        completionBlock(error);
    }];
}

- (void)formatAircraftWithCompletion:(DUXBetaWidgetModelActionCompletionBlock)completionBlock {
    DJIFlightControllerKey *key = [DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerAccessLockerSubComponent subComponentIndex:0 andParam:DJIAccessLockerParamFormat];
    [[DJISDKManager keyManager] performActionForKey:key withArguments:nil andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
        completionBlock(error);
    }];
}

@end
