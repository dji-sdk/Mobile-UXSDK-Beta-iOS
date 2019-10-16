//
//  NSObject+DUXBetaMapping.h
//  DJIUXSDK
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

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DUXBetaMapping)

/*
 *  This is used for determining a keypath's associated property's type and assigning value to it.  It uses the
 *  Objective C runtime to determine they property's type and then calls setValue:ForKey: updating the
 *  property associated with the key.
 *  If using CoreFoundation types look into Toll-Free Bridging
 *  https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/tollFreeBridgedTypes.html#//apple_ref/doc/uid/TP40010677
 *
 *  Key Value Coding for C unions is currently broken.
 *  https://stackoverflow.com/questions/14295505/objective-c-kvo-doesnt-work-with-c-unions
 *  https://openradar.appspot.com/radar?id=5033038689861632
 */

- (void)duxbeta_setCustomMappingValue:(id)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
