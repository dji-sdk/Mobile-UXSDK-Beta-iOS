//
//  NSObject+DUXBetaSDKBind.m
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

#import <objc/runtime.h>
#import <DJISDK/DJISDK.h>
#import "DUXBetaKeyManager.h"
#import "NSObject+DUXBetaMapping.h"

static void* DUXBetaObjectSharedLibBindDictKey = &DUXBetaObjectSharedLibBindDictKey;
static void* DUXBetaObjectSharedLibBindDictLockKey = &DUXBetaObjectSharedLibBindDictLockKey;

typedef void (^DUXBetaObjectSDKBindUpdateBlock)(DJIKey * _Nonnull key,
                                               DJIKeyedValue * _Nullable oldValue,
                                               DJIKeyedValue * _Nullable updatedValue,
                                               BOOL isFromPush);

@implementation NSObject (DUXBetaSDKBind)

- (void)setupSDKKey:(DJIKey *)key updateBlock:(DUXBetaObjectSDKBindUpdateBlock)block {
    NSAssert(block != nil, @"The block to setup cannot be nil. ");
    if ([[DUXBetaKeyInterfaceAdapter sharedInstance] getHandler] == nil) {
        [[DUXBetaKeyInterfaceAdapter sharedInstance] setHandler:nil];
    }
    [[[DUXBetaKeyInterfaceAdapter sharedInstance] getHandler] startListeningForChangesOnKey:key withListener:self andUpdateBlock:^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
        block(key, oldValue, newValue, YES);
    }];
    DJIKeyedValue *value = [[[DUXBetaKeyInterfaceAdapter sharedInstance] getHandler]getValueForKey:key];
    block(key, nil, value,NO);
}

- (void)duxbeta_bindSDKKey:(DJIKey *)key propertyName:(NSString *)propertyName {
    __weak typeof(self) weakSelf = self;
    [self setupSDKKey:key updateBlock:^(DJIKey * _Nonnull key, DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue, BOOL isFromPush) {
        __strong typeof(weakSelf) target = weakSelf;
        NSNumber* invalidValue = (newValue.value == nil ? @(NO) : @(YES));
        [[self bindDictLock] lock];
        [[self propertyValidDict] setObject:invalidValue forKey:propertyName];
        [[self bindDictLock] unlock];
        [target duxbeta_setCustomMappingValue:[newValue value] forKey:propertyName];
    }];
}

- (BOOL)duxbeta_checkSDKBindPropertyIsValid:(NSString *)propertyName {
    BOOL isValid = NO;
    [[self bindDictLock] lock];
    NSNumber* validValue = [[self propertyValidDict] objectForKey:propertyName];
    [[self bindDictLock] unlock];
    if (validValue != nil) {
        isValid = validValue.boolValue;
    }
    return isValid;
}

- (NSLock *)bindDictLock {
    NSLock* lock = objc_getAssociatedObject(self, DUXBetaObjectSharedLibBindDictLockKey);
    if (!lock) {
        lock = [[NSLock alloc] init];
        objc_setAssociatedObject(self, DUXBetaObjectSharedLibBindDictLockKey, lock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return lock;
}

- (NSMutableDictionary *)propertyValidDict {
    NSMutableDictionary* dict = objc_getAssociatedObject(self, DUXBetaObjectSharedLibBindDictKey);
    if (!dict) {
        dict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, DUXBetaObjectSharedLibBindDictKey, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

- (void)duxbeta_unBindSDK {
    [[DJISDKManager keyManager] stopAllListeningOfListeners:self];
}

@end
