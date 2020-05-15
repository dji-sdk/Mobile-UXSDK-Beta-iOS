//
//  DUXStateChangeBaseData.m
//  DJIUXSDKCore
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

#import "DUXStateChangeBaseData.h"

@interface DUXStateChangeBaseData ()
@property (nonatomic, strong) NSMutableDictionary *dict;
@end

@implementation DUXStateChangeBaseData

- (instancetype)initWithKey:(NSString*)key {
    if (self = [super init]) {
        _dict = [[NSMutableDictionary alloc] init];
        [_dict setObject:@(YES) forKey:key];
    }
    return self;
}

- (instancetype)initWithKey:(NSString*)key number:(NSNumber*)number {
    if (self = [super init]) {
        _dict = [[NSMutableDictionary alloc] init];
        [_dict setObject:number forKey:key];
    }
    return self;
}
- (instancetype)initWithKey:(NSString*)key value:(NSValue*)value {
    if (self = [super init]) {
        _dict = [[NSMutableDictionary alloc] init];
        [_dict setValue:value forKey:key];
    }
    return self;
}
- (instancetype)initWithKey:(NSString*)key string:(NSString*)string {
    if (self = [super init]) {
        _dict = [[NSMutableDictionary alloc] init];
        [_dict setObject:string forKey:key];
    }
    return self;
}
- (instancetype)initWithKey:(NSString*)key object:(id)object {
    if (self = [super init]) {
        _dict = [[NSMutableDictionary alloc] init];
        [_dict setObject:object forKey:key];
    }
    return self;
}

- (NSString*)key {
    return _dict.allKeys[0];
}

- (NSValue*)value {
    return _dict.allValues[0];
}

- (NSNumber*)number {
    return _dict.allValues[0];
}

- (NSString*)string {
    return _dict.allValues[0];
}

- (id)object {
    return _dict.allValues[0];
}

@end
