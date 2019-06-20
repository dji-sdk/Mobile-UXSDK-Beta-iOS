//
//  DUXBetaCustomAsyncMethod.m
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

#import "DUXBetaCustomAsyncMethod.h"

@interface DUXBetaCustomAsyncMethod ()

@property (assign, nonatomic) SEL defaultGetMethod;
@property (assign, nonatomic) SEL defaultSetMethod;

@end

@implementation DUXBetaCustomAsyncMethod

- (id)init
{
    self = [super init];
    _setBlock = nil;
    _getBlock = nil;
    _getMethod = nil;
    _setMethod = nil;
    _defaultGetMethod = nil;
    _defaultSetMethod = nil;
    return self;
}

- (nonnull id)initWithObject:(NSObject* _Nonnull)object withKeypath:(NSString * _Nonnull)keyPath
{
    self = [self init];
    [self setObject:object];
    [self setKeyPath:keyPath];
    return self;
}

- (BOOL)isReplacedGetMethod
{
    if (_getBlock == nil && _getMethod == nil)
    {
        return NO;
    }
    return YES;
}

- (BOOL)isReplacedSetMethod
{
    if (_setBlock == nil && _setMethod == nil)
    {
        return NO;
    }
    return YES;
}

- (void)callGetMethodCompletion:(DUXBetaCustomValueGetCompletionBlock _Nullable)block
{
    if (self.getBlock)
    {
        self.getBlock(block);
    }
    else if(self.getMethod)
    {
        if(self.object && [self.object respondsToSelector:self.getMethod])
        {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.object performSelector:self.getMethod withObject:block];
#pragma clang diagnostic pop
        }
    }
    else
    {
        [self callDefaultGetMethod:block];
    }
}

- (void)callSetMethodWithValue:(nullable id)value completion:(DUXBetaCustomValueSetCompletionBlock _Nullable)block
{
    if (self.setBlock)
    {
        self.setBlock(value,block);
    }
    else if(self.setMethod)
    {
        if(self.object && [self.object respondsToSelector:self.setMethod])
        {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.object performSelector:self.setMethod withObject:value withObject:block];
#pragma clang diagnostic pop
        }
    }
    else
    {
        [self callDefaultSetMethodWithValue:value completion:block];
    }
}

- (void)callDefaultGetMethod:(DUXBetaCustomValueGetCompletionBlock _Nullable)block
{
    if (_defaultGetMethod == nil)
    {
        NSArray *array = [self.keyPath componentsSeparatedByString:@"."];
        NSString *key = array.lastObject;
        
        NSString *setMethodName = [NSString stringWithFormat:@"get%@%@Completion:",[[key substringWithRange:NSMakeRange(0, 1)] uppercaseString],[key substringWithRange:NSMakeRange(1, key.length - 1)]];
        
        _defaultGetMethod = NSSelectorFromString(setMethodName);
    }
    if (self.object)
    {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.object performSelector:_defaultGetMethod withObject:block];
#pragma clang diagnostic pop
    }
}

- (void)callDefaultSetMethodWithValue:(nullable id)value completion:(DUXBetaCustomValueSetCompletionBlock _Nullable)block
{
    if (_defaultSetMethod == nil)
    {
        NSArray *array = [self.keyPath componentsSeparatedByString:@"."];
        NSString *key = array.lastObject;
        
        NSString *setMethodName = [NSString stringWithFormat:@"set%@%@:completion:",[[key substringWithRange:NSMakeRange(0, 1)] uppercaseString],[key substringWithRange:NSMakeRange(1, key.length - 1)]];
        
        _defaultSetMethod = NSSelectorFromString(setMethodName);
    }
    if (self.object)
    {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.object performSelector:_defaultSetMethod withObject:value withObject:block];
#pragma clang diagnostic pop
    }
}

@end
