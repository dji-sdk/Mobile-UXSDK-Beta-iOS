//
//  DUXBetaMockKey.m
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

#import "DUXBetaMockKey.h"

@implementation DUXBetaMockKey

+ (nonnull instancetype)mockKeyWithKey:(nonnull DJIKey *)key {
    return [[self alloc] initWithKey:key];
}

+ (nullable NSString *)componentFromKey:(DJIKey *)key {
    if ([key isKindOfClass:[DJIProductKey class]]) {
        return nil;
    } else if ([key isKindOfClass:[DJIAccessoryKey class]]) {
        return DJIAccessoryAggregationComponent;
    } else if ([key isKindOfClass:[DJIAirLinkKey class]]) {
        return DJIAirLinkComponent;
    } else if ([key isKindOfClass:[DJIBatteryKey class]]) {
        return DJIBatteryComponent;
    } else if ([key isKindOfClass:[DJICameraKey class]]) {
        return DJICameraComponent;
    } else if ([key isKindOfClass:[DJIGimbalKey class]]) {
        return DJIGimbalComponent;
    } else if ([key isKindOfClass:[DJIHandheldControllerKey class]]) {
        return DJIHandheldControllerComponent;
    } else if ([key isKindOfClass:[DJIFlightControllerKey class]]) {
        return DJIFlightControllerComponent;
    } else if ([key isKindOfClass:[DJIPayloadKey class]]) {
        return DJIPayloadComponent;
    } else if ([key isKindOfClass:[DJIRemoteControllerKey class]]) {
        return DJIRemoteControllerComponent;
    } else if ([key isKindOfClass:[DJISystemControllerKey class]]) {
        return DJISystemControllerComponent;
    } else {
        return nil;
    }
}

- (nonnull instancetype)initWithKey:(nonnull DJIKey *)key {
    self = [super init];
    
    if (self) {
        _component = [[self class] componentFromKey:key];
        _index = key.index;
        _subComponent = key.subComponent;
        _subComponentIndex = key.subComponentIndex;
        _param = key.param;
    }
    
    return self;
}

- (nonnull instancetype)init {
    return [self initWithKey:[DJIProductKey keyWithParam:DJIProductParamModelName]];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    DUXBetaMockKey *key = [DUXBetaMockKey new];
    key.component = self.component;
    key.subComponent = self.subComponent;
    key.subComponentIndex = self.subComponentIndex;
    key.index = self.index;
    key.param = self.param;
    return key;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    
    if (![object isKindOfClass:[DUXBetaMockKey class]]) {
        return NO;
    }
    
    DUXBetaMockKey *mockKey = (DUXBetaMockKey *)object;
    
    if (mockKey.component) {
        if (mockKey.subComponent) {
            return [mockKey.component isEqualToString:self.component] &&
            mockKey.index == self.index &&
            [mockKey.subComponent isEqualToString:self.subComponent] &&
            mockKey.subComponentIndex == self.subComponentIndex &&
            [mockKey.param isEqualToString:self.param];
        } else {
            return [mockKey.component isEqualToString:self.component] &&
            mockKey.index == self.index &&
            [mockKey.param isEqualToString:self.param];
        }
    } else {
        return mockKey.index == self.index &&  [mockKey.param isEqualToString:self.param];
    }
}

- (NSUInteger)hash {
    return self.component.hash ^
    [@(self.index) hash] ^
    self.subComponent.hash ^
    [@(self.subComponentIndex) hash] ^
    self.param.hash;
}

@end
