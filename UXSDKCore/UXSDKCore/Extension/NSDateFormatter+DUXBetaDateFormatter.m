//
//  NSDateFormatter+DUXBetaDateFormatter.m
//  UXSDKCore
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

#import "NSDateFormatter+DUXBetaDateFormatter.h"

@implementation NSDateFormatter (DUXBetaDateFormatter)

+ (instancetype)duxbeta_utcDateFormatter {
    static NSDateFormatter *_utcDateFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _utcDateFormatter = [[NSDateFormatter alloc] init];
        [_utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [_utcDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    });
    
    return _utcDateFormatter;
}

+ (instancetype)duxbeta_utcAlternateDateFormatter {
    static NSDateFormatter *_utcAlternateDateFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _utcAlternateDateFormatter = [[NSDateFormatter alloc] init];
        [_utcAlternateDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [_utcAlternateDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    
    return _utcAlternateDateFormatter;
}

@end
