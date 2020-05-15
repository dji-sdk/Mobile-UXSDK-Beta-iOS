//
//  NSObject+DUXBetaCommand.m
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

#import <objc/runtime.h>
#import "DUXBetaRKVOMetamacros.h"
#import "NSObject+DUXBetaCustomKVO.h"
@import Foundation;

@interface DUXBetaRKVOCommandTag : NSObject
@property (atomic, assign) NSUInteger commandTag;
@property (nonatomic, strong) id object;
@end

@implementation DUXBetaRKVOCommandTag
@end

////////////////////////


static void* kDUXBetaObjectCommandKey = &kDUXBetaObjectCommandKey;
static void* kDUXBetaObjectCommandTagDictKey = &kDUXBetaObjectCommandTagDictKey;
static void* kDUXBetaObjectCommandLockKey = &kDUXBetaObjectCommandLockKey;

@implementation NSObject (DUXBetaCommand)

- (NSLock *)duxbeta_commandLock {
    NSLock* lock = objc_getAssociatedObject(self, kDUXBetaObjectCommandLockKey);
    if (!lock) {
        lock = [[NSLock alloc] init];
        objc_setAssociatedObject(self, kDUXBetaObjectCommandLockKey, lock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return lock;
}

- (NSMutableDictionary *)duxbeta_commandTagDict {
    NSMutableDictionary* dictionary = objc_getAssociatedObject(self, kDUXBetaObjectCommandKey);
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, kDUXBetaObjectCommandKey, dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dictionary;
}


- (void)duxbeta_postRKVOCommandWithKey:(NSString *)key object:(id)object {
    NSMutableDictionary* dictionary = [self duxbeta_commandTagDict];
    [[self duxbeta_commandLock] lock];
    DUXBetaRKVOCommandTag* tag = dictionary[key];
    [[self duxbeta_commandLock] unlock];
    if (!tag) {
        return;
    }
    tag.object = object;
    tag.commandTag ++;
}

- (void)duxbeta_bindRKVOCommandWithTarget:(id)target Key:(NSString *)key selector:(SEL)selector {
    NSMutableDictionary* dictionary = [target duxbeta_commandTagDict];
    [[target duxbeta_commandLock] lock];
    DUXBetaRKVOCommandTag* tag = dictionary[key];
    [[target duxbeta_commandLock] unlock];
    if (!tag) {
        tag = [[DUXBetaRKVOCommandTag alloc] init];
    }
    [[target duxbeta_commandLock] lock];
    [dictionary setObject:tag forKey:key];
    [[target duxbeta_commandLock] unlock];
    
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(tag) weakTag = tag;
    [tag duxbeta_addCustomObserver:self forKeyPath:@RKVOKeypath(tag.commandTag) block:^(id  _Nullable oldValue, id  _Nullable newValue) {
        __strong typeof(weakSelf) sself = weakSelf;
        __strong typeof(weakTag) sTage = weakTag;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [sself performSelector:selector withObject:sTage.object];
#pragma clang diagnostic pop
    }];
}

- (void)duxbeta_unBindRKVOCommandWithTarget:(id)target key:(NSString *)key {
    NSMutableDictionary* dictionary = [target duxbeta_commandTagDict];
    [[target duxbeta_commandLock] lock];
    DUXBetaRKVOCommandTag* tag = dictionary[key];
    [tag duxbeta_removeCustomObserver:self forKeyPath:key];
    [dictionary removeObjectForKey:key];
    [[target duxbeta_commandLock] unlock];
}


- (void)duxbeta_unBindAllRKVOCommandWithTaget:(id)target {
    NSMutableDictionary* dictionary = [target duxbeta_commandTagDict];
    [[target duxbeta_commandLock] lock];
    for (DUXBetaRKVOCommandTag* tag in dictionary.allValues) {
        [tag duxbeta_removeCustomObserver:self];
    }
    [dictionary removeAllObjects];
    [[target duxbeta_commandLock] unlock];
}

@end
