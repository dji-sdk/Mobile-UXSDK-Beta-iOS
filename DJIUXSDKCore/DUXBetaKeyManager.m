//
//  DUXBetaKeyManager.m
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

#import "DUXBetaKeyManager.h"
#import <pthread.h>

@interface DUXBetaKeyInterfaceAdapter ()

@property (nonatomic) id<DUXBetaKeyInterfaces> handler;

@end

@implementation DUXBetaKeyInterfaceAdapter
{
    pthread_rwlock_t _lock;
}

+(instancetype)sharedInstance {
    static DUXBetaKeyInterfaceAdapter *adapter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        adapter = [DUXBetaKeyInterfaceAdapter new];
    });
    return adapter;
}

-(instancetype)init {
    if (self = [super init]) {
        pthread_rwlock_init(&_lock, NULL);
    }
    return self;
}

-(void)setHandler:(id<DUXBetaKeyInterfaces>)handler {
    pthread_rwlock_wrlock(&_lock);
    if (handler == nil) {
        _handler = [DUXBetaKeyManager new];
    }
    else {
        _handler = handler;
    }
    pthread_rwlock_unlock(&_lock);
}

-(id<DUXBetaKeyInterfaces>)getHandler {
    id<DUXBetaKeyInterfaces> temp = nil;
    pthread_rwlock_rdlock(&_lock);
    temp = _handler;
    pthread_rwlock_unlock(&_lock);
    return temp; 
}

@end



@implementation DUXBetaKeyManager

- (nullable DJIKeyedValue *)getValueForKey:(DJIKey *)key {
    return [[DJISDKManager keyManager] getValueForKey:key];
}

- (void)getValueForKey:(DJIKey *)key
        withCompletion:(DJIKeyedGetCompletionBlock)completion {
    [[DJISDKManager keyManager] getValueForKey:key withCompletion:completion];
}

- (void)setValue:(id)value
          forKey:(DJIKey *)key
  withCompletion:(DJIKeyedSetCompletionBlock)completion {
    [[DJISDKManager keyManager] setValue:value forKey:key withCompletion:completion];
}

- (void)performActionForKey:(DJIKey *)key
              withArguments:(nullable NSArray *)arguments
              andCompletion:(DJIKeyedActionCompletionBlock)completion {
    [[DJISDKManager keyManager] performActionForKey:key withArguments:arguments andCompletion:completion];
}

- (void)startListeningForChangesOnKey:(DJIKey *)key
                         withListener:(id)listener
                       andUpdateBlock:(DJIKeyedListenerUpdateBlock)updateBlock {
    [[DJISDKManager keyManager] startListeningForChangesOnKey:key withListener:listener andUpdateBlock:updateBlock];
}

- (void)stopListeningOnKey:(DJIKey *)key
                ofListener:(id)listener {
    [[DJISDKManager keyManager] stopListeningOnKey:key ofListener:listener];
}

- (void)stopAllListeningOfListeners:(id)listener {
    [[DJISDKManager keyManager] stopAllListeningOfListeners:listener];
}

- (BOOL)isKeySupported:(DJIKey *)key {
    return [[DJISDKManager keyManager] isKeySupported:key];
}

@end
