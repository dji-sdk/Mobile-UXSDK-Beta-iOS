//
//  DUXBetaStorageModule.m
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2021 DJI
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

#import "DUXBetaStorageModule.h"
#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaStorageModule ()

@property (nonatomic, strong, readwrite) DUXBetaCameraStorageState              *cameraStorageState;
@property (nonatomic, strong, readwrite) DJICameraVideoResolutionAndFrameRate   *nonSSDRecordedVideoParameters;
@property (nonatomic, strong, readwrite) DJICameraVideoResolutionAndFrameRate   *ssdRecordedVideoParameters;
@property (nonatomic, strong, readwrite) DJICameraVideoResolutionAndFrameRate   *recordedVideoParameters;

@property (nonatomic, assign) NSUInteger sdCardAvailablePhotoCount;
@property (nonatomic, assign) NSUInteger internalStorageAvailablePhotoCount;
@property (nonatomic, assign) NSUInteger ssdAvailableRecordingTimeInSeconds;
@property (nonatomic, assign) NSUInteger sdCardAvailableRecordingTimeInSeconds;
@property (nonatomic, assign) NSUInteger internalStorageAvailableRecordingTimeInSeconds;

@property (nonatomic, assign) DJICameraSDCardOperationState sdCardOperationState;
@property (nonatomic, assign) DJICameraSDCardOperationState internalStorageOperationState;
@property (nonatomic, assign) DJICameraSSDOperationState    ssdOperationState;
@property (nonatomic, assign) DJICameraSSDVideoLicense      ssdVideoLicense;
@property (nonatomic, assign) DJICameraStorageLocation      cameraStorageLocation;

@property (nonatomic, strong) DUXBetaFlatCameraModule *flatCameraModule;

@end

@implementation DUXBetaStorageModule

- (instancetype)init {
    self = [super init];
    if (self) {
        self.flatCameraModule = [DUXBetaFlatCameraModule new];
    }
    return self;
}

- (void)setup {
    [self.flatCameraModule setup];
    
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamSDCardAvailablePhotoCount], sdCardAvailablePhotoCount);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamInternalStorageAvailablePhotoCount], internalStorageAvailablePhotoCount);
    
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamStorageLocation], cameraStorageLocation);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamSSDAvailableRecordingTimeInSeconds], ssdAvailableRecordingTimeInSeconds);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamSDCardAvailableRecordingTimeInSeconds], sdCardAvailableRecordingTimeInSeconds);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamInternalStorageAvailableRecordingTimeInSeconds], internalStorageAvailableRecordingTimeInSeconds);
    
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamSDCardOperationState], sdCardOperationState);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamSSDOperationState], ssdOperationState);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamInternalStorageOperationState], internalStorageOperationState);
    
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamSSDRAWLicense], ssdVideoLicense);
    
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamVideoResolutionAndFrameRate], nonSSDRecordedVideoParameters);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamSSDVideoResolutionAndFrameRate], ssdRecordedVideoParameters);
    
    BindRKVOModel(self, @selector(updateStorageState),
                  sdCardOperationState,
                  ssdOperationState,
                  internalStorageOperationState,
                  sdCardAvailableRecordingTimeInSeconds,
                  sdCardAvailablePhotoCount,
                  internalStorageAvailablePhotoCount,
                  internalStorageAvailableRecordingTimeInSeconds,
                  ssdAvailableRecordingTimeInSeconds,
                  cameraStorageLocation,
                  ssdRecordedVideoParameters,
                  nonSSDRecordedVideoParameters,
                  flatCameraModule.currentCameraMode);
}

- (void)cleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateStorageState {
    self.cameraStorageState = [self computedCameraStorageState];
}

- (DUXBetaCameraStorageState *)computedCameraStorageState {
    if (self.flatCameraModule.currentCameraMode == DJICameraModeShootPhoto) {
        if (self.cameraStorageLocation == DJICameraStorageLocationInternalStorage) {
            return [[DUXBetaCameraSDStorageState alloc] initWithStorageLocation:self.cameraStorageLocation
                                                                 availableCount:self.internalStorageAvailablePhotoCount
                                                           sdCardOperationState:self.internalStorageOperationState];
        } else {
            return [[DUXBetaCameraSDStorageState alloc] initWithStorageLocation:self.cameraStorageLocation
                                                                 availableCount:self.sdCardAvailablePhotoCount
                                                           sdCardOperationState:self.sdCardOperationState];
        }
    } else {
        if ([self isStoringVideoInSSD]) {
            self.recordedVideoParameters = [self ssdRecordedVideoParameters];
            return [[DUXBetaCameraSSDStorageState alloc] initWithStorageLocation:self.cameraStorageLocation
                                                                  availableCount:self.ssdAvailableRecordingTimeInSeconds
                                                                ssdOperationState:self.ssdOperationState];
        } else {
            self.recordedVideoParameters = [self nonSSDRecordedVideoParameters];
            if (self.cameraStorageLocation == DJICameraStorageLocationInternalStorage) {
                return [[DUXBetaCameraSDStorageState alloc] initWithStorageLocation:self.cameraStorageLocation
                                                                     availableCount:self.internalStorageAvailableRecordingTimeInSeconds
                                                               sdCardOperationState:self.internalStorageOperationState];
            } else {
                return [[DUXBetaCameraSDStorageState alloc] initWithStorageLocation:self.cameraStorageLocation
                                                                     availableCount:self.sdCardAvailableRecordingTimeInSeconds
                                                               sdCardOperationState:self.sdCardOperationState];
            }
        }
    }
}

- (BOOL)isStoringVideoInSSD {
    // This logic is adapted from page 21 of the X7 user manual
    return (self.ssdVideoLicense == DJICameraSSDVideoLicenseUnknown);
}

@end
