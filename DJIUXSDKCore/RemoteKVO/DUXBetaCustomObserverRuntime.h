//
//  DUXBetaCustomObserverRuntime.h
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

#import <Foundation/Foundation.h>
#import <DJIUXSDKCore/NSError+DUXBetaCustomKVO.h>
#import <DJIUXSDKCore/DUXBetaCustomValueConfirmation.h>

/**
 *  Just used to implement Custom KVO.
 */
@interface DUXBetaCustomObserverRuntime : NSObject

- (nonnull id)initWithObject:(nonnull NSObject *)object;

- (void)registerCustomObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyPath block:(nonnull void(^)(id _Nullable oldValue,id _Nullable newValue))block;
- (void)registerCustomObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyPath selector:(nonnull SEL)selector;

- (void)unregisterCustomObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyPath;
- (void)unregisterCustomObserver:(nonnull NSObject *)observer;
- (void)unregisterAllCustomObservers;

@end

@interface DUXBetaCustomObserverRuntime (DUXBetaCustomAsyncKVO)

- (void)runtimeSetCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath completion:(DUXBetaCustomValueSetCompletionBlock _Nullable)block;
- (void)runtimeGetCustomValueForKeyPath:(nonnull NSString *)keyPath completion:(DUXBetaCustomValueGetCompletionBlock _Nullable)block;

- (nullable DUXBetaCustomValueConfirmation *)runtimeWillSetCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath completion:(DUXBetaCustomValueSetCompletionBlock _Nullable)block;
- (nullable id)runtimeSettingCustomValueForKeyPath:(nonnull NSString *)keyPath;

- (nullable DUXBetaCustomValueConfirmation *)runtimeWillGetCustomValueForKeyPath:(nonnull NSString *)keyPath completion:(nullable DUXBetaCustomValueGetCompletionBlock)block;

- (void)runtimeUpdateCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath;

- (BOOL)runtimeIsSettingCustomValueForkeyPath:(nonnull NSString *)keyPath;
- (BOOL)runtimeIsInitCustomValueForKeyPath:(nonnull NSString *)keyPath;

- (void)runtimeInitCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath;
- (void)runtimeDeinitCustomValueForKeyPath:(nonnull NSString *)keyPath;

@end

@interface DUXBetaCustomObserverRuntime (DUXBetaCustomAsyncKVOReplace)

- (void)runtimeReplaceSetCustomValueBlock:(nonnull void(^)(id _Nullable value,DUXBetaCustomValueSetCompletionBlock _Nullable completion))method forKeyPath:(nonnull NSString *)keyPath;
- (void)runtimeReplaceGetCustomValueBlock:(nonnull void(^)(DUXBetaCustomValueGetCompletionBlock _Nullable completion))method forKeyPath:(nonnull NSString *)keyPath;

- (void)runtimeReplaceSetCustomValueMethod:(nonnull SEL)method forKeyPath:(nonnull NSString *)keyPath;
- (void)runtimeReplaceGetCustomValueMethod:(nonnull SEL)method forKeyPath:(nonnull NSString *)keyPath;

@end


