//
//  DUXBetaCustomKVOObserver.m
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

#import "DUXBetaCustomKVOObserver.h"

@interface DUXBetaCustomKVOObserver ()

@property (strong, nonatomic) NSString *observeKey;
@property (strong, nonatomic) NSString *observeSubpath;

@end

@implementation DUXBetaCustomKVOObserver

+ (nonnull DUXBetaCustomKVOObserver *)observerWithKeypath:(nonnull NSString *)keypath withObject:(nonnull id)object withSelector:(nonnull SEL)selector
{
    DUXBetaCustomKVOObserver *callback = [[DUXBetaCustomKVOObserver alloc] init];
    [callback setObject:object];
    [callback setSelector:selector];
    [callback setKeypath:keypath];
    return callback;

}

+ (nonnull DUXBetaCustomKVOObserver *)observerWithKeypath:(nonnull NSString *)keypath withObject:(nonnull id)object withBlock:(nonnull void(^)(id _Nullable oldValue,id _Nullable newValue))block
{
    DUXBetaCustomKVOObserver *callback = [[DUXBetaCustomKVOObserver alloc] init];
    [callback setObject:object];
    [callback setBlock:block];
    [callback setKeypath:keypath];
    return callback;
}

- (void)setKeypath:(NSString *)keypath
{
    NSRange range = [keypath rangeOfString:@"."];
    if (range.location == NSNotFound)
    {
        self.observeKey = keypath;
    }
    else
    {
        self.observeKey = [keypath substringToIndex:range.location];
        self.observeSubpath = [keypath substringFromIndex:range.location+1];
    }
}

- (void)callbackWithOldValue:(id)oldValue withNewValue:(id)newValue{
    if(_object){
        if(_block){
            _block(oldValue,newValue);
        }
        else if(_selector && [_object respondsToSelector:_selector]){
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_object performSelector:_selector withObject:oldValue withObject:newValue];
#pragma clang diagnostic pop
        }
    }
}

@end
