//
//  DUXBetaCustomAsyncCache.m
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

#import "DUXBetaCustomValueConfirmation_Private.h"
#import "DUXBetaCustomAsyncCache.h"
#import <pthread/pthread.h>

@interface DUXBetaCustomAsyncCache()<DUXBetaCustomValueConfirmationDelegate>
{
    pthread_mutex_t _getmutex;
    pthread_mutex_t _setmutex;
}

@property (strong, nonatomic) NSMutableArray<DUXBetaCustomValueGetCompletionBlock> *gettingCallbackQueue;

@property (copy, nonatomic) DUXBetaCustomValueSetCompletionBlock settingCallback;

@property (weak, nonatomic) DUXBetaCustomValueConfirmation *settingConfirmation;
@property (weak, nonatomic) DUXBetaCustomValueConfirmation *gettingConfirmation;
@property (strong, nonatomic) id settingValue;

@end

@implementation DUXBetaCustomAsyncCache

- (void)dealloc
{
    //通知所有回调操作被取消。
    [self cacheDidSetCustomValue:nil withError:[NSError errorForDUXCustomKVO:DUXBetaCustomKVOError_Cancel]];
    [self callbackGettingBlock:nil withError:[NSError errorForDUXCustomKVO:DUXBetaCustomKVOError_Cancel]];
    pthread_mutex_destroy(&_getmutex);
    pthread_mutex_destroy(&_setmutex);
}

- (id)init
{
    self = [super init];
    _setting = NO;
    _inited = NO;
    _settingCallback = nil;
    _gettingCallbackQueue = [[NSMutableArray alloc] init];
    _gettingConfirmation = nil;
    _settingConfirmation = nil;
    pthread_mutex_init(&_getmutex, NULL);
    pthread_mutex_init(&_setmutex, NULL);
    return self;
}

- (id)initWithObject:(NSObject *)object withKeyPath:(NSString *)keypath
{
    self = [self init];
    [self setObject:object];
    [self setKeypath:keypath];
    return self;
}

- (DUXBetaCustomValueConfirmation *)cacheWillSetCustomValue:(nullable id)value completion:(nullable DUXBetaCustomValueSetCompletionBlock)block
{
    DUXBetaCustomValueConfirmation *confirmation = [DUXBetaCustomValueConfirmation new];
    confirmation.settingValue = value;
    if (self.isSetting)
    {
        //检测到上一次写入未完成，则直接取消掉，返回已取消error,并用当前写入的block覆盖上一次写入的block。
        DUXBetaCustomValueSetCompletionBlock lastBlock = nil;
        
        pthread_mutex_lock(&_setmutex);
        lastBlock = _settingCallback;
        _settingCallback = block;
        
        [self setSettingValue:value];
        [self setSettingConfirmation:confirmation];
        [self.settingConfirmation setDelegate:self];
        
        pthread_mutex_unlock(&_setmutex);
        if (lastBlock)
        {
            lastBlock([NSError errorForDUXCustomKVO:DUXBetaCustomKVOError_Cancel]);
        }
    }
    else
    {
        //检测到当前没有在写入中，则保存当前写入的block
        [self setSetting:YES];
        pthread_mutex_lock(&_setmutex);
        _settingCallback = block;
        [self setSettingConfirmation:confirmation];
        [self.settingConfirmation setDelegate:self];
        [self setSettingValue:value];
        pthread_mutex_unlock(&_setmutex);
    }
    
    return confirmation;
}

- (void)cacheDidSetCustomValue:(nullable id)value withError:(nullable NSError *)error
{
    if (_setting)
    {
        //当正在设置中，且完成写入的tag能与当前准备写入的tag对应时，执行以下逻辑。
        DUXBetaCustomValueSetCompletionBlock lastBlock = nil;
        pthread_mutex_lock(&_setmutex);
        lastBlock = _settingCallback;
        _settingCallback = nil;
        [self setSettingValue:nil];
        [self.settingConfirmation setDelegate:nil];
        [self setSettingConfirmation:nil];
        pthread_mutex_unlock(&_setmutex);
        [self setSetting:NO];
        if (error == nil) //如果写入没有错误，则将值写入到keypath中，如果有错误，则deinit。
        {
            [self cacheDidGetCustomValue:value withError:nil];
        }
        else
        {
            [self cacheDeinitCustomValue];
        }
        if (lastBlock)
        {
            lastBlock(error);
        }
    }
}

- (DUXBetaCustomValueConfirmation *)cacheWillGetCustomValueCompletion:(nullable DUXBetaCustomValueGetCompletionBlock)block
{
    if (block)
    {
        pthread_mutex_lock(&_getmutex);
        [_gettingCallbackQueue addObject:block];
        pthread_mutex_unlock(&_getmutex);
    }
    DUXBetaCustomValueConfirmation *getValueConfirmation = [[DUXBetaCustomValueConfirmation alloc] init];
    [getValueConfirmation setDelegate:self];
    return getValueConfirmation;
}

- (void)cacheDidGetCustomValue:(nullable id)value withError:(nullable NSError *)error
{
    if (_object && !_setting)
    {
        if (error == nil)
        {
            [self cacheInitCustomValue:value];
        }
        [self callbackGettingBlock:value withError:error];
    }
}

- (void)cacheUpdateCustomValue:(nullable id)value
{
    //更新值的逻辑和获取到一个新的值的逻辑没什么实质上的区别。
    [self cacheDidGetCustomValue:value withError:nil];
}

- (void)callbackGettingBlock:(nullable id)value withError:(nullable NSError *)error
{
    NSArray *callbackArray = nil; //如果有对象正在获取该值，则回调。
    pthread_mutex_lock(&_getmutex);
    //NSLog(@"%d",self.gettingCallbackQueue.count);
    if (self.gettingCallbackQueue.count > 0)
    {
        callbackArray = self.gettingCallbackQueue;
        self.gettingCallbackQueue = [[NSMutableArray alloc] init];
    }
    pthread_mutex_unlock(&_getmutex);
    
    for (DUXBetaCustomValueGetCompletionBlock block in callbackArray) {
        block(value,error);
    }
}

- (void)cacheInitCustomValue:(nullable id)value
{
    if (_object){
        [self setInited:YES];
        if (value != nil && [value isEqual:[_object valueForKeyPath:_keypath]])
        {
            return;
        }
        [_object setValue:value forKeyPath:_keypath];
    }
}

- (void)cacheDeinitCustomValue
{
    [self setInited:NO];
}

#pragma mark - DUXBetaCustomValueConfirmationDelegate
- (void)confirmation:(DUXBetaCustomValueConfirmation *)confirmation acceptWithValue:(id)value
{
    if (confirmation == self.settingConfirmation)
    {
        [self cacheDidSetCustomValue:value withError:nil];
    }
    else
    {
        [self cacheDidGetCustomValue:value withError:nil];
    }
}

- (void)confirmation:(DUXBetaCustomValueConfirmation *)confirmation declineWithError:(nonnull NSError *)error
{
    if (confirmation == self.settingConfirmation)
    {
        [self cacheDidSetCustomValue:nil withError:error];
    }
    else
    {
        [self cacheDidGetCustomValue:nil withError:error];
    }
}

@end
