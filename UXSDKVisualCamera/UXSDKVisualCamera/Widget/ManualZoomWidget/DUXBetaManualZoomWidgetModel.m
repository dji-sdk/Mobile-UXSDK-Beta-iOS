//
//  DUXBetaManualZoomWidgetModel.m
//  UXSDKVisualCamera
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

#import "DUXBetaManualZoomWidgetModel.h"


@interface DUXBetaManualZoomWidgetModel ()

@property (nonatomic) BOOL isConnected;
@property (nonatomic, readwrite) BOOL shouldShowWidget;
@property (nonatomic, readwrite) BOOL isOpticalZoomSupported;
@property (nonatomic, readwrite) float minFocalLength;
@property (nonatomic, readwrite) float maxFocalLength;
@property (nonatomic, readwrite) float currentFocalLength;

@property (nonatomic, readwrite) NSUInteger rawFocalLength;
@property (nonatomic, readwrite) DJICameraOpticalZoomSpec zoomSpec;

@end

@implementation DUXBetaManualZoomWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _preferredCameraIndex = 0;
        _isConnected = NO;
        _shouldShowWidget = NO;
        _minFocalLength = 0;
        _maxFocalLength = 0;
        _currentFocalLength = 0;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIParamConnection], isConnected);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamIsOpticalZoomSupported], isOpticalZoomSupported);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamOpticalZoomSpec], zoomSpec);
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamOpticalZoomFocalLength], rawFocalLength);
    
    BindRKVOModel(self, @selector(updateStates), isConnected, isOpticalZoomSupported);
    BindRKVOModel(self, @selector(updateZoomSpec), zoomSpec);
    BindRKVOModel(self, @selector(updateCurrentFocalLength), rawFocalLength);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateStates {
    if (self.isConnected && self.isOpticalZoomSupported) {
        self.shouldShowWidget = YES;
    } else {
        self.shouldShowWidget = NO;
    }
}

- (void)updateZoomSpec {
    self.minFocalLength = self.zoomSpec.minFocalLength * 0.1;
    self.maxFocalLength = self.zoomSpec.maxFocalLength * 0.1;
}

- (void)updateCurrentFocalLength {
    self.currentFocalLength = self.rawFocalLength * 0.1;
}

- (void)changeIndex:(NSInteger)preferredCameraIndex {
    _preferredCameraIndex = preferredCameraIndex;
    if (self.vmState == DUXBetaVMStateSetUp) {
        [self inCleanup];
        [self inSetup];
    }
}

- (void)zoomToFocalLength:(float)focalLength {
    if (!self.isOpticalZoomSupported) {
        return;
    }
    if (focalLength > self.maxFocalLength || focalLength < self.minFocalLength || focalLength == self.currentFocalLength) {
        return;
    }
    __weak typeof (self) target = self;
    DJICameraKey *focalLengthKey = [DJICameraKey keyWithParam:DJICameraParamOpticalZoomFocalLength];
    NSUInteger temp = (int)roundf(focalLength) * 10;
    [[DJISDKManager keyManager] setValue:@(temp) forKey:focalLengthKey withCompletion:^(NSError * _Nullable error) {
        target.isOpticalZoomSupported = YES;
    }];
}

@end
