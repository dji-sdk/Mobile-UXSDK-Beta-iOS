//
//  DUXBetaMethodSwizzlingHelper.m
//  UXSDKUnitTests
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

#import "DUXBetaMethodSwizzlingHelper.h"

#if TEST

#import <objc/runtime.h>
#import <DJISDK/DJIFlyZoneInformation.h>
#import "DUXBetaMockMissionControl.h"
#import <DJISDK/DJIFlightController.h>
#import <DJISDK/DJIAircraft.h>
#import "DUXBetaMockAircraft.h"


void DUXBetaSwizzleSelectors(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation DJISDKManager (Swizzling)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(product);
        SEL swizzledSelector = @selector(duxbeta_product);
        
        DUXBetaSwizzleSelectors(class, originalSelector, swizzledSelector);
        
        originalSelector = @selector(missionControl);
        swizzledSelector = @selector(duxbeta_missionControl);
        
        DUXBetaSwizzleSelectors(class, originalSelector, swizzledSelector);
    });
}

+ (__kindof DJIBaseProduct *_Nullable)duxbeta_product {
    return [DUXBetaMockAircraft sharedMockAircraft];
}

+ (nullable DJIMissionControl *)duxbeta_missionControl {
    return [DUXBetaMockMissionControl sharedMockMissionControl];
}

@end

#endif

@implementation DUXBetaMethodSwizzlingHelper

@end
