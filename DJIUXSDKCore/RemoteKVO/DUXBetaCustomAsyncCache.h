//
//  DUXBetaCustomAsyncCache.h
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

@interface DUXBetaCustomAsyncCache : NSObject

@property (weak, nonatomic) NSObject* _Nullable object;
@property (strong, nonatomic) NSString * _Nonnull keypath;

@property (assign, nonatomic, getter=isSetting) BOOL setting;
@property (assign, nonatomic, getter=isInited) BOOL inited;

@property (strong, nonatomic, readonly) id _Nullable settingValue;

- (_Nonnull id)initWithObject:(NSObject * _Nonnull)object withKeyPath:(NSString * _Nonnull)keypath;

- (nonnull DUXBetaCustomValueConfirmation *)cacheWillSetCustomValue:(nullable id)value completion:(nullable DUXBetaCustomValueSetCompletionBlock)block;

- (nonnull DUXBetaCustomValueConfirmation *)cacheWillGetCustomValueCompletion:(nullable DUXBetaCustomValueGetCompletionBlock)block;

- (void)cacheUpdateCustomValue:(nullable id)value;

- (void)cacheInitCustomValue:(nullable id)value;
- (void)cacheDeinitCustomValue;

@end
