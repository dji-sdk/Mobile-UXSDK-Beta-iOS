//
//  DUXBetaCustomAsyncMethod.h
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

#import <Foundation/Foundation.h>
#import <DJIUXSDKCore/NSError+DUXBetaCustomKVO.h>

@interface DUXBetaCustomAsyncMethod : NSObject

@property (weak, nonatomic) NSObject* _Nullable object;
@property (strong, nonatomic) NSString* _Nonnull keyPath;

@property (copy, nonatomic) void(^ _Nullable setBlock)(id _Nullable value,DUXBetaCustomValueSetCompletionBlock _Nullable completion);
@property (copy, nonatomic) void(^ _Nullable getBlock)(DUXBetaCustomValueGetCompletionBlock _Nullable completion);

@property (assign, nonatomic) SEL _Nullable getMethod;
@property (assign, nonatomic) SEL _Nullable setMethod;

- (nonnull id)initWithObject:(NSObject* _Nonnull)object withKeypath:(NSString * _Nonnull)keyPath;

- (BOOL)isReplacedGetMethod;
- (BOOL)isReplacedSetMethod;

- (void)callGetMethodCompletion:(DUXBetaCustomValueGetCompletionBlock _Nullable)block;
- (void)callSetMethodWithValue:(nullable id)value completion:(DUXBetaCustomValueSetCompletionBlock _Nullable)block;

- (void)callDefaultGetMethod:(DUXBetaCustomValueGetCompletionBlock _Nullable)block;
- (void)callDefaultSetMethodWithValue:(nullable id)value completion:(DUXBetaCustomValueSetCompletionBlock _Nullable)block;

@end
