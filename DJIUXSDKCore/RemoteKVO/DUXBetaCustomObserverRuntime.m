//
//  DUXBetaCustomObserverRuntime.m
//
//  MIT License
//  
//  Copyright © 2018-2019 DJI
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
#import <pthread/pthread.h>

#import "DUXBetaCustomObserverRuntime.h"
#import "DUXBetaCustomAsyncCache.h"
#import "DUXBetaCustomAsyncMethod.h"
#import "DUXBetaCustomKVOObserver.h"

#import "NSObject+DUXBetaCustomKVO.h"

/**
 *  Need improve speed.
 */
@interface DUXBetaCustomObserverRuntime ()
{
    pthread_mutex_t _observerMutex;
    pthread_mutex_t _asyncCacheMutex;
    pthread_mutex_t _asyncMethodMutex;
}

@property (assign, nonatomic) NSObject *observedObject;

@property (strong, nonatomic) NSMutableDictionary<NSString *,NSMutableArray<DUXBetaCustomKVOObserver *> *> *customObserverMap;
@property (strong, nonatomic) NSMutableDictionary<NSString *,DUXBetaCustomAsyncCache *> *customAsyncCacheMap;
@property (strong, nonatomic) NSMutableDictionary<NSString *,DUXBetaCustomAsyncMethod *> *customAsyncMethodMap;

@end

@implementation DUXBetaCustomObserverRuntime

- (void)dealloc{
    [self unregisterAllCustomObservers];
    _observedObject = nil;
    pthread_mutex_destroy(&_observerMutex);
    pthread_mutex_destroy(&_asyncCacheMutex);
    pthread_mutex_destroy(&_asyncMethodMutex);
}

- (id)initWithObject:(nonnull NSObject *)object
{
    self = [super init];
    self.customObserverMap = [[NSMutableDictionary alloc] init];
    self.customAsyncCacheMap = [[NSMutableDictionary alloc] init];
    self.customAsyncMethodMap = [[NSMutableDictionary alloc] init];
    [self setObservedObject:object];
    
    pthread_mutex_init(&_observerMutex, NULL);
    pthread_mutex_init(&_asyncCacheMutex, NULL);
    pthread_mutex_init(&_asyncMethodMutex, NULL);
    
    return self;
}

- (void)registerCustomObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(void(^)(id oldValue,id newValue))block{
    DUXBetaCustomKVOObserver *observerObject = [DUXBetaCustomKVOObserver observerWithKeypath:keyPath withObject:observer withBlock:block];
    pthread_mutex_lock(&_observerMutex);
    NSMutableArray *array = [_customObserverMap objectForKey:observerObject.observeKey];
    if(array){
        [array addObject:observerObject];
    }
    else{
        array = [[NSMutableArray alloc] init];
        [array addObject:observerObject];
        [_customObserverMap setObject:array forKey:observerObject.observeKey];
        [_observedObject addObserver:self forKeyPath:observerObject.observeKey options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    }
    pthread_mutex_unlock(&_observerMutex);
    
    if (observerObject.observeSubpath)
    {
        id subObject = [self.observedObject valueForKey:observerObject.observeKey];
        if (subObject)
        {
            __weak DUXBetaCustomKVOObserver *weakObserverObject = observerObject;
            [subObject duxbeta_addCustomObserver:observerObject forKeyPath:observerObject.observeSubpath block:^(id  _Nullable oldValue, id  _Nullable newValue) {
                if (weakObserverObject == nil) return;
                [weakObserverObject callbackWithOldValue:oldValue withNewValue:newValue];
            }];
        }
    }
}

- (void)registerCustomObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath selector:(SEL)selector{
    DUXBetaCustomKVOObserver *observerObject = [DUXBetaCustomKVOObserver observerWithKeypath:keyPath withObject:observer withSelector:selector];
    pthread_mutex_lock(&_observerMutex);
    NSMutableArray *array = [_customObserverMap objectForKey:observerObject.observeKey];
    if(array){
        [array addObject:observerObject];
    }
    else{
        array = [[NSMutableArray alloc] init];
        [array addObject:observerObject];
        [_customObserverMap setObject:array forKey:observerObject.observeKey];
        [_observedObject addObserver:self forKeyPath:observerObject.observeKey options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    }
    pthread_mutex_unlock(&_observerMutex);
    
    if (observerObject.observeSubpath)
    {
        id subObject = [self.observedObject valueForKey:observerObject.observeKey];
        if (subObject)
        {
            __weak DUXBetaCustomKVOObserver *weakObserverObject = observerObject;
            [subObject duxbeta_addCustomObserver:observerObject forKeyPath:observerObject.observeSubpath block:^(id  _Nullable oldValue, id  _Nullable newValue) {
                if (weakObserverObject == nil) return;
                [weakObserverObject callbackWithOldValue:oldValue withNewValue:newValue];
            }];
        }
    }
}

- (void)unregisterCustomObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    NSRange range = [keyPath rangeOfString:@"."];
    NSString *observeKey = nil;
    NSString *observeSubpath = nil;
    if (range.location == NSNotFound)
    {
        observeKey = keyPath;
    }
    else
    {
        observeKey = [keyPath substringToIndex:range.location];
        observeSubpath = [keyPath substringFromIndex:range.location - 1];
    }
    
    pthread_mutex_lock(&_observerMutex);
    NSMutableArray *array = _customObserverMap[observeKey];
    if(array){
        NSMutableArray *toRemoved = [[NSMutableArray alloc] init];
        for (DUXBetaCustomKVOObserver *callback in array) {
            if(callback.object == observer){
                if (callback.observeSubpath == nil && observeSubpath == nil)
                {
                    [toRemoved addObject:callback];
                }
                else if(callback.observeSubpath && observeSubpath && [callback.observeSubpath isEqualToString:observeSubpath])
                {
                    [toRemoved addObject:callback];
                }
            }
        }
        [array removeObjectsInArray:toRemoved];
        if(array.count == 0){
            [_customObserverMap removeObjectForKey:observeKey];
            [_observedObject removeObserver:self forKeyPath:observeKey];
        }
    }
    pthread_mutex_unlock(&_observerMutex);
}

- (void)unregisterCustomObserver:(NSObject *)observer{
	pthread_mutex_lock(&_observerMutex);
	NSArray *observeKeys = _customObserverMap.allKeys;
	for (NSString *observeKey in observeKeys)
	{
		NSMutableArray *array = _customObserverMap[observeKey];
		if(array){
			NSMutableArray *toRemoved = [[NSMutableArray alloc] init];
			for (DUXBetaCustomKVOObserver *callback in array) {
				if(callback.object == observer){
					[toRemoved addObject:callback];
				}
			}
			[array removeObjectsInArray:toRemoved];
			if(array.count == 0){
				[_customObserverMap removeObjectForKey:observeKey];
				[_observedObject removeObserver:self forKeyPath:observeKey];
			}
		}
	}
	pthread_mutex_unlock(&_observerMutex);

}

- (void)unregisterAllCustomObservers{
    pthread_mutex_lock(&_observerMutex);
    for (NSString *keyPath in _customObserverMap.allKeys) {
        [_observedObject removeObserver:self forKeyPath:keyPath];
    }
    [_customObserverMap removeAllObjects];
    pthread_mutex_unlock(&_observerMutex);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    id oldValue = change[NSKeyValueChangeOldKey];
    id newValue = change[NSKeyValueChangeNewKey];
	if (oldValue == [NSNull null]) oldValue = nil;
	if (newValue == [NSNull null]) newValue = nil;

    if((!(oldValue == nil && newValue == nil)) && ![oldValue isEqual:newValue]){
        pthread_mutex_trylock(&_observerMutex);
        NSArray *array = [_customObserverMap objectForKey:keyPath];
        if (array != nil) array = [array copy];
        pthread_mutex_unlock(&_observerMutex);
        
        if(array){
            NSMutableArray *emptyCallback = nil;
            for (DUXBetaCustomKVOObserver *callback in array) {
                if (callback.object == nil)
                {
                    if (emptyCallback == nil) emptyCallback = [[NSMutableArray alloc] init];
                    [emptyCallback addObject:callback];
                }
                else
                {
                    if (callback.observeSubpath) //如果监听的是路径，则在第一级key上增加监听器。
                    {
                        if (oldValue)
                        {
                            [oldValue duxbeta_removeCustomObserver:callback forKeyPath:callback.observeSubpath];
                        }
                        if (newValue)
                        {
                            __weak DUXBetaCustomKVOObserver *weakCallback = callback;
                            [newValue duxbeta_addCustomObserver:callback forKeyPath:callback.observeSubpath block:^(id  _Nullable oldValue, id  _Nullable newValue) {
                                if (weakCallback == nil) return;
                                [weakCallback callbackWithOldValue:oldValue withNewValue:newValue];
                            }];
                        }
                        id oldSubValue = oldValue?[oldValue duxbeta_customValueForKeyPath:callback.observeSubpath]:nil;
                        id newSubValue = newValue?[newValue duxbeta_customValueForKeyPath:callback.observeSubpath]:nil;
						if (oldSubValue == [NSNull null]) oldSubValue = nil;
						if (newSubValue == [NSNull null]) newSubValue = nil;

                        if ((!(oldSubValue == nil && newSubValue == nil)) && ![oldSubValue isEqual:newSubValue])
                        {
                            [callback callbackWithOldValue:oldSubValue withNewValue:newSubValue];
                        }
                    }
                    else
                    {
                        [callback callbackWithOldValue:oldValue withNewValue:newValue];
                    }
                }
            }
            if (emptyCallback) //If found some already release observer, should release.
            {
                pthread_mutex_lock(&_observerMutex);
                NSMutableArray *array = _customObserverMap[keyPath];
                if(array){
                    [array removeObjectsInArray:emptyCallback];
                    if (array.count == 0)
                    {
                        [_customObserverMap removeObjectForKey:keyPath];
                        [_observedObject removeObserver:self forKeyPath:keyPath];
                    }
                }
                pthread_mutex_unlock(&_observerMutex);
            }
        }
    }
}

@end

@implementation DUXBetaCustomObserverRuntime (CustomAsyncKVO)

- (void)runtimeSetCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath completion:(DUXBetaCustomValueSetCompletionBlock _Nullable)block
{
    DUXBetaCustomAsyncMethod *customMethod = [self customMethodForKeyPath:keyPath];
    [customMethod callSetMethodWithValue:value completion:block];
}

- (void)runtimeGetCustomValueForKeyPath:(nonnull NSString *)keyPath completion:(DUXBetaCustomValueGetCompletionBlock _Nullable)block
{
    DUXBetaCustomAsyncMethod *customMethod = [self customMethodForKeyPath:keyPath];
    [customMethod callGetMethodCompletion:block];
}

- (nullable DUXBetaCustomValueConfirmation *)runtimeWillSetCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath completion:(DUXBetaCustomValueSetCompletionBlock _Nullable)block
{
    DUXBetaCustomAsyncCache *cache = [self customCacheForKeyPath:keyPath];
    return [cache cacheWillSetCustomValue:value completion:block];
}

- (nullable id)runtimeSettingCustomValueForKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomAsyncCache *cache = [self customCacheForKeyPath:keyPath];
    return cache.settingValue;
}

- (DUXBetaCustomValueConfirmation *)runtimeWillGetCustomValueForKeyPath:(nonnull NSString *)keyPath completion:(nullable DUXBetaCustomValueGetCompletionBlock)block
{
    DUXBetaCustomAsyncCache *cache = [self customCacheForKeyPath:keyPath];
    return [cache cacheWillGetCustomValueCompletion:block];
}

- (void)runtimeUpdateCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomAsyncCache *cache = [self customCacheForKeyPath:keyPath];
    [cache cacheUpdateCustomValue:value];
}

- (BOOL)runtimeIsSettingCustomValueForkeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomAsyncCache *cache = [self customCacheForKeyPath:keyPath];
    return [cache isSetting];
}

- (BOOL)runtimeIsInitCustomValueForKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomAsyncCache *cache = [self customCacheForKeyPath:keyPath];
    return [cache isInited];
}

- (void)runtimeInitCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomAsyncCache *cache = [self customCacheForKeyPath:keyPath];
    [cache cacheInitCustomValue:value];
}

- (void)runtimeDeinitCustomValueForKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomAsyncCache *cache = [self customCacheForKeyPath:keyPath];
    [cache cacheDeinitCustomValue];
}

#pragma mark - private

- (DUXBetaCustomAsyncCache *)customCacheForKeyPath:(NSString *)keyPath
{
    DUXBetaCustomAsyncCache *cache = nil;
    pthread_mutex_lock(&_asyncCacheMutex);
    cache = [self.customAsyncCacheMap objectForKey:keyPath];
    if (cache == nil)
    {
        cache = [[DUXBetaCustomAsyncCache alloc] initWithObject:_observedObject withKeyPath:keyPath];
        [self.customAsyncCacheMap setObject:cache forKey:keyPath];
    }
    pthread_mutex_unlock(&_asyncCacheMutex);
    return cache;
}

- (DUXBetaCustomAsyncMethod *)customMethodForKeyPath:(NSString *)keyPath
{
    DUXBetaCustomAsyncMethod *method = nil;
    pthread_mutex_lock(&_asyncMethodMutex);
    method = [self.customAsyncMethodMap objectForKey:keyPath];
    if (method == nil)
    {
        method = [[DUXBetaCustomAsyncMethod alloc] initWithObject:_observedObject withKeypath:keyPath];
        [self.customAsyncMethodMap setObject:method forKey:keyPath];
    }
    pthread_mutex_unlock(&_asyncMethodMutex);
    return method;
}

@end

@implementation DUXBetaCustomObserverRuntime (DUXBetaCustomAsyncKVOReplace)

- (void)runtimeReplaceSetCustomValueBlock:(nonnull void(^)(id _Nullable value,DUXBetaCustomValueSetCompletionBlock _Nullable completion))method forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomAsyncMethod *customMethod = [self customMethodForKeyPath:keyPath];
    [customMethod setSetBlock:method];
}

- (void)runtimeReplaceGetCustomValueBlock:(nonnull void(^)(DUXBetaCustomValueGetCompletionBlock _Nullable completion))method forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomAsyncMethod *customMethod = [self customMethodForKeyPath:keyPath];
    [customMethod setGetBlock:method];
}

- (void)runtimeReplaceSetCustomValueMethod:(nonnull SEL)method forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomAsyncMethod *customMethod = [self customMethodForKeyPath:keyPath];
    [customMethod setSetMethod:method];
}

- (void)runtimeReplaceGetCustomValueMethod:(nonnull SEL)method forKeyPath:(nonnull NSString *)keyPath
{
    DUXBetaCustomAsyncMethod *customMethod = [self customMethodForKeyPath:keyPath];
    [customMethod setGetMethod:method];
}

@end
