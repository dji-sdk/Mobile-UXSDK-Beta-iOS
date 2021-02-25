//
//  DUXBetaCameraPhotoState.m
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

#import "DUXBetaCameraPhotoState.h"

@implementation DUXBetaCameraPhotoState

- (nonnull instancetype)init {
    return [self initWithShootPhotoMode:DJICameraShootPhotoModeUnknown];
}

- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode {
    self = [super init];
    
    if (self) {
        _shootPhotoMode = shootPhotoMode;
    }
    
    return self;
}

- (NSUInteger)count {
    return 0;
}

@end

@implementation DUXBetaCameraPanoramaPhotoState

- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode {
    return [self initWithShootPhotoMode:shootPhotoMode
                      photoPanoramaMode:DJICameraPhotoPanoramaModeUnknown];
}

- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode
                             photoPanoramaMode:(DJICameraPhotoPanoramaMode)photoPanoramaMode {
    self = [super initWithShootPhotoMode:shootPhotoMode];
    
    if (self) {
        _photoPanoramaMode = photoPanoramaMode;
    }
    
    return self;
}

- (NSUInteger)count {
    return self.photoPanoramaMode;
}

@end

@implementation DUXBetaCameraBurstPhotoState

- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode {
    return [self initWithShootPhotoMode:shootPhotoMode
                        photoBurstCount:DJICameraPhotoBurstCountUnknown];
}

- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode
                               photoBurstCount:(DJICameraPhotoBurstCount)photoBurstCount {
    self = [super initWithShootPhotoMode:shootPhotoMode];
    
    if (self) {
        _photoBurstCount = photoBurstCount;
    }
    
    return self;
}

- (NSUInteger)count {
    return self.photoBurstCount;
}

@end

@implementation DUXBetaCameraAEBPhotoState

- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode {
    return [self initWithShootPhotoMode:shootPhotoMode
                          photoAEBCount:DJICameraPhotoAEBCountUnknown];
}

- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode
                                 photoAEBCount:(DJICameraPhotoAEBCount)photoAEBCount {
    self = [super initWithShootPhotoMode:shootPhotoMode];
    
    if (self) {
        _photoAEBCount = photoAEBCount;
    }
    
    return self;
}

- (NSUInteger)count {
    return self.photoAEBCount;
}

@end

@implementation DUXBetaCameraIntervalPhotoState

- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode {
    return [self initWithShootPhotoMode:shootPhotoMode
                           captureCount:0
                  timeIntervalInSeconds:0];
}

- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode
                                  captureCount:(uint8_t)captureCount
                         timeIntervalInSeconds:(uint8_t)timeIntervalInSeconds {
    self = [super initWithShootPhotoMode:shootPhotoMode];
    
    if (self) {
        _captureCount = captureCount;
        _timeIntervalInSeconds = timeIntervalInSeconds;
    }
    
    return self;
}

- (NSUInteger)count {
    if (self.timeIntervalInSeconds > 60) {
        return  0;
    }
    return self.timeIntervalInSeconds;
}

@end

