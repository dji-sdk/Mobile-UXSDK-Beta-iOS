//
//  DUXBetaConstString.m
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

#import "DUXBetaConstString.h"
#import <pthread/pthread.h>

@interface DUXBetaConstString ()
{
    pthread_mutex_t _mutex;
}

@property (strong, nonatomic) NSMutableDictionary *constStringDictionary;

@end

@implementation DUXBetaConstString

+ (instancetype)sharedRuntime{
    static DUXBetaConstString *runtime = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        runtime = [[DUXBetaConstString alloc] init];
    });
    return runtime;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_mutex);
}

- (id)init{
    self = [super init];
    if(self){
        _constStringDictionary = [[NSMutableDictionary alloc] init];
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

+ (const char *)constCharByString:(NSString *)string{
    return [[self sharedRuntime] constCharByString:string];
}

- (const char *)constCharByString:(NSString *)string{
    NSData *constKey = nil;
    pthread_mutex_lock(&_mutex);
    constKey = [_constStringDictionary objectForKey:string];
    if(!constKey){
        constKey = [NSData dataWithBytes:string.UTF8String length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]+1];
        [_constStringDictionary setObject:constKey forKey:string];
    }
    pthread_mutex_unlock(&_mutex);
    return constKey.bytes;
}

@end

@implementation NSString (DUXBetaConstString)

- (const char *)constStringChars{
    return [DUXBetaConstString constCharByString:self];
}

@end
