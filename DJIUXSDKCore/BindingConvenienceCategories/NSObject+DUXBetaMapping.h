//
//  NSObject+DUXBetaMapping.h
//  DJIUXSDK
//  
//  Copyright © 2018-2019 DJI. All rights reserved.
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
