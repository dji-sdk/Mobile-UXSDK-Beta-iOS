//
//  NSObject+DUXBetaSDKBind.h
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

#import <Foundation/Foundation.h>
#import <UXSDKCore/DUXBetaKeyManager.h>

#define DUXBetaKeypath(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))
#define DUXBetaVMProperty(PATH) DUXBetaKeypath(self, PATH)

/**
 * If you are working in Objective C these macros are avaliable to use rather than the method calls.
 */

#ifndef BindSDKKey
#define BindSDKKey(__key__, __property__) [self duxbeta_bindSDKKey:__key__ propertyName:@DUXBetaVMProperty(__property__)]
#endif

#ifndef UnBindSDK
#define UnBindSDK [self duxbeta_unBindSDK]
#endif

#define weakSelf(__TARGET__) __weak typeof(self) __TARGET__=self
#define strongSelf(__TARGET__, __WEAK__) typeof(self) __TARGET__=__WEAK__
#ifdef weakReturn
#undef weakReturn
#endif
#define weakReturn(__TARGET__) __strong typeof(__TARGET__) __strong##__TARGET__ = __TARGET__; \
if(__strong##__TARGET__==nil)return;

NS_ASSUME_NONNULL_BEGIN

@class DUXBetaKey;

/**
 *  Use these methods to manage the binding of DJI SDK Keys to an associated property's keypath.
 *  This uses the runtime to map the DJIKey's value's type to the propertyName's property type.
 *  When you want to cleanup the object managing the binding it is important to call the unBindSDK and unBinDUXBetaKey
 *  methods to keep memory leaks from occuring.
 */

@interface NSObject (DUXBetaSDKBind)

/**
 *  Bind a DJI Key to a property's keypath
 */

- (void)duxbeta_bindSDKKey:(DJIKey *)key propertyName:(NSString *)propertyName;

/**
 *  Checks if the given keypath to a property has a valid value associated with it.  A property is considered
 *  valid if the key it has been bound to has updated.
 */

- (BOOL)duxbeta_checkSDKBindPropertyIsValid:(NSString *)propertyName;

/**
 *  UnBind all DJI Keys and properties.
 */

- (void)duxbeta_unBindSDK;

@end

NS_ASSUME_NONNULL_END
