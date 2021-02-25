//
//  DUXBetaCameraStorageState.m
//  UXSDKCameraCore
//
//  MIT License
//  
//  Copyright © 2018-2021 DJI
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

#import "DUXBetaCameraStorageState.h"

@implementation DUXBetaCameraStorageState

- (nonnull instancetype)init {
    return [self initWithStorageLocation:DJICameraStorageLocationUnknown
                   availableCount:0];
}

- (nonnull instancetype)initWithStorageLocation:(DJICameraStorageLocation)storageLocation
                          availableCount:(NSUInteger)availableCaptureCount {
    self = [super init];
    
    if (self) {
        _storageLocation = storageLocation;
        _availableCount = availableCaptureCount;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[DUXBetaCameraStorageState class]]) {
        return NO;
    }
    
    DUXBetaCameraStorageState *cameraStorageState = (DUXBetaCameraStorageState *)object;
    
    if ((cameraStorageState.storageLocation == self.storageLocation) &&
        (cameraStorageState.availableCount == self.availableCount)) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return [@(self.storageLocation) hash] ^ [@(self.availableCount) hash];
}

- (DUXBetaCaptureStorageType)type {
    if ([self isKindOfClass:[DUXBetaCameraSSDStorageState class]]) {
        return DUXBetaCaptureStorageTypeSSD;
    }
    
    if ([self isKindOfClass:[DUXBetaCameraSDStorageState class]]) {
        if (self.storageLocation == DJICameraStorageLocationSDCard) {
            return DUXBetaCaptureStorageTypeSDCard;
        } else if (self.storageLocation == DJICameraStorageLocationInternalStorage) {
            return DUXBetaCaptureStorageTypeInternalStorage;
        }
    }
    
    return DUXBetaCaptureStorageTypeUnknown;
}

- (DUXBetaCaptureStorageState)state {
    if ([self isStorageLocationNotAvailable]) {
        return DUXBetaCaptureStorageStateNotInserted;
    }
    if ([self isStorageLocationOutOfStorageSpace]) {
        return DUXBetaCaptureStorageStateFull;
    }
    if ([self isStorageLocationSlow]) {
        return DUXBetaCaptureStorageStateSlow;
    }
    
    return DUXBetaCaptureStorageStateUnknown;
}

- (BOOL)isStorageLocationOutOfStorageSpace {
    return (self.availableCount < 1);
}

- (BOOL)isStorageLocationNotAvailable {
    return (self.storageLocation == DJICameraStorageLocationUnknown);
}

- (BOOL)isStorageLocationSlow {
    return NO;
}

@end


@implementation DUXBetaCameraSDStorageState

- (nonnull instancetype)initWithStorageLocation:(DJICameraStorageLocation)storageLocation
                          availableCount:(NSUInteger)availableCaptureCount {
    return [self initWithStorageLocation:storageLocation
                          availableCount:availableCaptureCount
                    sdCardOperationState:DJICameraSDCardOperationStateUnknownError];
}

- (nonnull instancetype)initWithStorageLocation:(DJICameraStorageLocation)storageLocation
                                                           availableCount:(NSUInteger)availableCaptureCount
                           sdCardOperationState:(DJICameraSDCardOperationState)sdCardOperationState {
    self = [super initWithStorageLocation:storageLocation
                    availableCount:availableCaptureCount];
    
    if (self) {
        _sdCardOperationState = sdCardOperationState;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[DUXBetaCameraSDStorageState class]]) {
        return NO;
    }
    
    DUXBetaCameraSDStorageState *cameraStorageState = (DUXBetaCameraSDStorageState *)object;
    
    if ((cameraStorageState.storageLocation == self.storageLocation) &&
        (cameraStorageState.availableCount == self.availableCount) &&
        (cameraStorageState.sdCardOperationState == self.sdCardOperationState)) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return [@(self.sdCardOperationState) hash] ^ [@(self.storageLocation) hash] ^ [@(self.availableCount) hash];
}

- (BOOL)isStorageLocationOutOfStorageSpace {
    return (self.availableCount < 1 || self.sdCardOperationState == DJICameraSDCardOperationStateFull);
}

- (BOOL)isStorageLocationNotAvailable {
    return (self.sdCardOperationState == DJICameraSDCardOperationStateNormal);
}

- (BOOL)isStorageLocationSlow {
    return (self.sdCardOperationState == DJICameraSDCardOperationStateSlow);
}

@end

@implementation DUXBetaCameraSSDStorageState

- (nonnull instancetype)initWithStorageLocation:(DJICameraStorageLocation)storageLocation
                          availableCount:(NSUInteger)availableCaptureCount {
    return [self initWithStorageLocation:storageLocation
                   availableCount:availableCaptureCount
                       ssdOperationState:DJICameraSSDOperationStateUnknown];
}

- (nonnull instancetype)initWithStorageLocation:(DJICameraStorageLocation)storageLocation
                          availableCount:(NSUInteger)availableCaptureCount
                              ssdOperationState:(DJICameraSSDOperationState)ssdOperationState {
    self = [super initWithStorageLocation:storageLocation
                    availableCount:availableCaptureCount];
    
    if (self) {
        _ssdOperationState = ssdOperationState;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[DUXBetaCameraSSDStorageState class]]) {
        return NO;
    }
    
    DUXBetaCameraSSDStorageState *cameraStorageState = (DUXBetaCameraSSDStorageState *)object;
    
    if ((cameraStorageState.storageLocation == self.storageLocation) &&
        (cameraStorageState.availableCount == self.availableCount) &&
        (cameraStorageState.ssdOperationState == self.ssdOperationState)) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return [@(self.ssdOperationState) hash] ^ [@(self.storageLocation) hash] ^ [@(self.availableCount) hash];
}

- (BOOL)isStorageLocationOutOfStorageSpace {
    return (self.availableCount < 1 || self.ssdOperationState == DJICameraSSDOperationStateFull);
}

- (BOOL)isStorageLocationNotAvailable {
    return (self.ssdOperationState == DJICameraSSDOperationStateIdle);
}

@end

