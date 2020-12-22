//
//  NSObject+DUXBetaRKVOExtension.m
//  UXSDKCore
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

#import "NSObject+DUXBetaRKVOExtension.h"
#import "NSObject+DUXBetaCustomKVO.h"

@implementation DUXBetaRKVOTransform

- (NSString *)description {
    return [NSString stringWithFormat:@"keyPath:[%@] transformed from [%@] to [%@]",self.keyPath, self.oldValue, self.updatedValue];
}

@end

typedef void(^DUXBetaObjectRKVOBindUpdateBlock)(id target , id _Nullable oldValue, id _Nullable newValue);

@implementation NSObject (DUXBetaRKVOExtension)

- (void)setupRKVOKey:(NSString *)key target:(id)target updateBlock:(DUXBetaObjectRKVOBindUpdateBlock)block {
    NSAssert(block != nil, @"The block to setup cannot be nil. ");
    [self duxbeta_addCustomObserver:target forKeyPath:key block:^(id  _Nullable oldValue, id  _Nullable newValue) {
        block(target,oldValue,newValue);
    }];
    block(target,[self valueForKeyPath:key],[self valueForKeyPath:key]);
}

- (void)duxbeta_bindRKVOWithTarget:(id)target selector:(SEL)selector property:(NSString *)property {
    if (property) {
        [self setupRKVOKey:property target:target updateBlock:^(id target, id  _Nullable oldValue, id  _Nullable newValue) {
            if ([target respondsToSelector:selector]) {
                NSMethodSignature* methodSignature = [[target class] instanceMethodSignatureForSelector:selector];
                NSUInteger argumentNum = [methodSignature numberOfArguments];
                if (argumentNum == 2) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [target performSelector:selector];
    #pragma clang diagnostic pop
                }
                else {
                    DUXBetaRKVOTransform* transform = [[DUXBetaRKVOTransform alloc] init];
                    transform.keyPath = property;
                    transform.oldValue = oldValue;
                    transform.updatedValue = newValue;
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [target performSelector:selector withObject:transform];
    #pragma clang diagnostic pop
                }
            }
        }];
    }
}

- (void)duxbeta_bindRKVOWithTarget:(id)target selector:(SEL)selector properties:(NSString *)properties, ... NS_REQUIRES_NIL_TERMINATION {
    va_list args;
    va_start(args, properties);
    if (properties) {
        NSString* nextArg = properties;
        while(nextArg) {
            [self setupRKVOKey:nextArg target:target updateBlock:^(id target, id  _Nullable oldValue, id  _Nullable newValue) {
                if ([target respondsToSelector:selector]) {
                    NSMethodSignature* methodSignature = [[target class] instanceMethodSignatureForSelector:selector];
                    NSUInteger argumentNum = [methodSignature numberOfArguments];
                    if (argumentNum == 2) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        [target performSelector:selector];
#pragma clang diagnostic pop
                    }
                    else {
                        DUXBetaRKVOTransform* transform = [[DUXBetaRKVOTransform alloc] init];
                        transform.keyPath = nextArg;
                        transform.oldValue = oldValue;
                        transform.updatedValue = newValue;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        [target performSelector:selector withObject:transform];
#pragma clang diagnostic pop
                    }
                }
            }];
            nextArg = va_arg(args, NSString *);
        }
    }
    va_end(args);
}

- (void)duxbeta_bindRKVOWithTarget:(id)target selector:(SEL)selector propertiesList:(va_list)properties {
    NSString* nextArg = va_arg(properties, NSString *);
    while(nextArg) {
        [self setupRKVOKey:nextArg target:target updateBlock:^(id target, id  _Nullable oldValue, id  _Nullable newValue) {
            if ([target respondsToSelector:selector]) {
                NSMethodSignature* methodSignature = [[target class] instanceMethodSignatureForSelector:selector];
                NSUInteger argumentNum = [methodSignature numberOfArguments];
                if (argumentNum == 2) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [target performSelector:selector];
#pragma clang diagnostic pop
                }
                else {
                    DUXBetaRKVOTransform* transform = [[DUXBetaRKVOTransform alloc] init];
                    transform.keyPath = nextArg;
                    transform.oldValue = oldValue;
                    transform.updatedValue = newValue;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [target performSelector:selector withObject:transform];
#pragma clang diagnostic pop
                }
            }
        }];
        nextArg = va_arg(properties, NSString *);
    }
}

- (void)duxbeta_unBindRKVO {
    [self duxbeta_removeCustomObserver:self];
}

@end
