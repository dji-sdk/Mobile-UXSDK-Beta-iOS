//
//  NSObject+DUXBetaCustomKVO.m
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

#import "NSObject+DUXBetaCustomKVO.h"
#import "DUXBetaCustomObserverRuntime.h"
#import "DUXBetaCustomValueConfirmation.h"
#import <objc/runtime.h>
#import <objc/objc.h>

#define DUXBetaCustomObserverKey "__DUXBetaCustomObserver" //If conflict, fix it.
#define GetDUXBetaCustomObserverRuntime(__name__) objc_getAssociatedObject(self, DUXBetaCustomObserverKey); \
if(__name__ == nil){ \
    __name__ = [[DUXBetaCustomObserverRuntime alloc] initWithObject:self]; \
    objc_setAssociatedObject(self, DUXBetaCustomObserverKey, __name__, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
}

@implementation NSObject (DUXBetaCustomKVO)

- (void)duxbeta_addCustomObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(void(^)(id oldValue,id newValue))block{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime registerCustomObserver:observer forKeyPath:keyPath block:block];
}

- (void)duxbeta_addCustomObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath selector:(SEL)selector{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime registerCustomObserver:observer forKeyPath:keyPath selector:selector];
}

- (void)duxbeta_addCustomObserver:(nonnull NSObject *)observer forKeyPaths:(nonnull NSArray *)keyPaths block:(nonnull void(^)(NSString *_Nullable keypath,id _Nullable oldValue,id _Nullable newValue))block
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    for (int i = 0; i < keyPaths.count; i++) {
        [runtime registerCustomObserver:observer forKeyPath:keyPaths[i] block:^(id  _Nullable oldValue, id  _Nullable newValue) {
			if (block)
			{
				block(keyPaths[i],oldValue,newValue);
			}
        }];
    }
}

- (void)duxbeta_removeCustomObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime unregisterCustomObserver:observer forKeyPath:keyPath];
}

- (void)duxbeta_removeCustomObserver:(nonnull NSObject *)observer
                 forKeyPaths:(nonnull NSArray<NSString *> *)keyPaths
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    for (int i = 0; i < keyPaths.count; i++) {
        [runtime unregisterCustomObserver:observer forKeyPath:keyPaths[i]];
    }
}

- (void)duxbeta_removeCustomObserver:(NSObject *)observer{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime unregisterCustomObserver:observer];
}

- (void)duxbeta_removeAllCustomObservers{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime unregisterAllCustomObservers];
}

//DO NOT USE THIE METHOD! Because it will let runtime be autorelease, and delay release, cause crash.
- (DUXBetaCustomObserverRuntime *)customObserver{
    DUXBetaCustomObserverRuntime *runtime = objc_getAssociatedObject(self, DUXBetaCustomObserverKey);
    if(runtime == nil){
        runtime = [[DUXBetaCustomObserverRuntime alloc] initWithObject:self];
        objc_setAssociatedObject(self, DUXBetaCustomObserverKey, runtime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, DUXBetaCustomObserverKey);
}

@end

@implementation NSObject (CustomAsyncKVO)

- (nullable id)duxbeta_customValueForKeyPath:(nonnull NSString *)keyPath
{
    NSArray *array = [keyPath componentsSeparatedByString:@"."];
    id lastValue = nil;
    for (int i = 0;i < array.count; i++) {
        if (i == 0){
            lastValue = [self valueForKey:array[i]];
        }
        else
        {
            lastValue = [lastValue valueForKey:array[i]];
        }
        if (lastValue == nil)
        {
            break;
        }
    }
    return lastValue;
}

- (void)duxbeta_setCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath completion:(nullable DUXBetaCustomValueSetCompletionBlock)block
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime runtimeSetCustomValue:value forKeyPath:keyPath completion:block];
}

- (void)duxbeta_getCustomValueForKeyPath:(nonnull NSString *)keyPath completion:(nullable DUXBetaCustomValueGetCompletionBlock)block
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime runtimeGetCustomValueForKeyPath:keyPath completion:block];
}

- (DUXBetaCustomValueConfirmation *)duxbeta_willSetCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath completion:(nullable DUXBetaCustomValueSetCompletionBlock)block
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    return [runtime runtimeWillSetCustomValue:value forKeyPath:keyPath completion:block];
}

- (nullable id)duxbeta_settingCustomValueForKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    return [runtime runtimeSettingCustomValueForKeyPath:keyPath];
}

- (DUXBetaCustomValueConfirmation *)duxbeta_willGetCustomValueForKeyPath:(NSString *)keyPath completion:(nullable DUXBetaCustomValueGetCompletionBlock)block
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    return [runtime runtimeWillGetCustomValueForKeyPath:keyPath completion:block];
}

- (void)duxbeta_updateCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime runtimeUpdateCustomValue:value forKeyPath:keyPath];
}

- (BOOL)duxbeta_isSettingCustomValueForKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    return [runtime runtimeIsSettingCustomValueForkeyPath:keyPath];
}

- (BOOL)duxbeta_isInitCustomValueForKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    return [runtime runtimeIsInitCustomValueForKeyPath:keyPath];
}

- (void)duxbeta_initCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime runtimeInitCustomValue:value forKeyPath:keyPath];
}

- (void)duxbeta_deinitCustomValueForKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime runtimeDeinitCustomValueForKeyPath:keyPath];
}

@end

@implementation NSObject (CustomAsyncKVOReplace)

- (void)duxbeta_replaceSetCustomValueBlock:(nonnull void(^)(id _Nullable value,DUXBetaCustomValueSetCompletionBlock _Nullable completion))method forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime runtimeReplaceSetCustomValueBlock:method forKeyPath:keyPath];
}

- (void)duxbeta_replaceGetCustomValueBlock:(nonnull void(^)(DUXBetaCustomValueGetCompletionBlock _Nullable completion))method forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime runtimeReplaceGetCustomValueBlock:method forKeyPath:keyPath];
}

- (void)duxbeta_replaceSetCustomValueMethod:(nonnull SEL)method forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime runtimeReplaceSetCustomValueMethod:method forKeyPath:keyPath];
}

- (void)duxbeta_replaceGetCustomValueMethod:(nonnull SEL)method forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomObserverRuntime *runtime = GetDUXBetaCustomObserverRuntime(runtime);
    [runtime runtimeReplaceGetCustomValueMethod:method forKeyPath:keyPath];
}

@end
