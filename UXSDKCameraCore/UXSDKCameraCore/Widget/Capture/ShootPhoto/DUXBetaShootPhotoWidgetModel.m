//
//  DUXBetaShootPhotoWidgetModel.m
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

#import "DUXBetaShootPhotoWidgetModel.h"
#import "DUXBetaCameraStorageState.h"
#import "DUXBetaCameraPhotoState.h"

@interface DUXBetaShootPhotoWidgetModel ()

@property (nonatomic, strong) DUXBetaCameraPhotoState *cameraPhotoState;

@property (nonatomic, assign) BOOL isShootingPhoto;
@property (nonatomic, assign) BOOL isStoringPhoto;

@property (nonatomic, assign) BOOL canStartShootingPhoto;
@property (nonatomic, assign) BOOL canStopShootingPhoto;

@property (nonatomic, assign) BOOL isShootingSinglePhoto;
@property (nonatomic, assign) BOOL isShootingSinglePhotoInRAWFormat;
@property (nonatomic, assign) BOOL isShootingIntervalPhoto;
@property (nonatomic, assign) BOOL isShootingBurstPhoto;
@property (nonatomic, assign) BOOL isShootingRAWBurstPhoto;
@property (nonatomic, assign) BOOL isShootingPanoramaPhoto;
@property (nonatomic, assign) BOOL isShootingHyperanalytic;

@property (nonatomic, assign) DJICameraShootPhotoMode cameraShootPhotoMode;
@property (nonatomic, assign) DJICameraPhotoBurstCount photoBurstCount;
@property (nonatomic, assign) DJICameraPhotoAEBCount photoAEBCount;
@property (nonatomic, assign) DJICameraPhotoTimeIntervalSettings photoTimeIntervalSettings;
@property (nonatomic, assign) DJICameraPhotoPanoramaMode photoPanoramaMode;
@property (nonatomic, assign) NSUInteger currentPanoramaPhotoCount;

@property (nonatomic, assign) BOOL shootPhotoForbiddenFlag;

@property (nonatomic, assign) DJICameraPhotoFileFormat photoFileFormat;
@property (nonatomic, assign) DJICameraPhotoTimeLapseSettings photoTimeLapseSettings;

@end

NSString *const DUXBetaShootPhotoWidgetDomain = @"DUXBetaShootPhotoWidgetDomain";

@implementation DUXBetaShootPhotoWidgetModel

- (void)inSetup {
    [super inSetup];
    
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamIsShootingSinglePhoto], isShootingSinglePhoto);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamIsShootingSinglePhotoInRAWFormat], isShootingSinglePhotoInRAWFormat);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamIsShootingIntervalPhoto], isShootingIntervalPhoto);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamIsShootingBurstPhoto], isShootingBurstPhoto);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamIsShootingRAWBurstPhoto], isShootingRAWBurstPhoto);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamIsShootingPanoramaPhoto], isShootingPanoramaPhoto);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamIsShootingPanoramaPhoto], isShootingHyperanalytic);
    
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamIsStoringPhoto], isStoringPhoto);
    
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamShootPhotoMode], cameraShootPhotoMode);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamPhotoBurstCount], photoBurstCount);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamPhotoAEBCount], photoAEBCount);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamPhotoTimeIntervalSettings], photoTimeIntervalSettings);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamPhotoPanoramaMode], photoPanoramaMode);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamCurrentPanoramaPhotoCount], currentPanoramaPhotoCount);
    
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamShootPhotoForbiddenFlag], shootPhotoForbiddenFlag);
    
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamPhotoFileFormat], photoFileFormat);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamPhotoTimeLapseSettings], photoTimeLapseSettings);
    
    BindRKVOModel(self, @selector(updatePhotoState), cameraShootPhotoMode,
                                                     photoBurstCount,
                                                     photoAEBCount,
                                                     photoTimeIntervalSettings,
                                                     photoPanoramaMode,
                                                     currentPanoramaPhotoCount,
                                                     photoTimeLapseSettings);
    
    BindRKVOModel(self, @selector(updateIsShooting), isShootingSinglePhoto,
                                                     isShootingIntervalPhoto,
                                                     isShootingPanoramaPhoto,
                                                     isShootingBurstPhoto,
                                                     isShootingRAWBurstPhoto,
                                                     isShootingSinglePhotoInRAWFormat,
                                                     cameraShootPhotoMode);
    
    BindRKVOModel(self, @selector(updateCanStartShootingPhoto), shootPhotoForbiddenFlag, storageModule.cameraStorageState.availableCount);
    BindRKVOModel(self, @selector(updateCanStopShootingPhoto), isShootingPhoto, isStoringPhoto, cameraShootPhotoMode);
}

- (void)updatePhotoState {
    self.cameraPhotoState = [self computedCameraPhotoState];
}

- (void)updateIsShooting {
    if (self.cameraShootPhotoMode == DJICameraShootPhotoModeSingle) {
        self.isShootingPhoto = self.isShootingSinglePhoto;
    } else if (self.cameraShootPhotoMode == DJICameraShootPhotoModeInterval) {
        self.isShootingPhoto = self.isShootingIntervalPhoto;
    } else if (self.cameraShootPhotoMode == DJICameraShootPhotoModePanorama) {
        self.isShootingPhoto = self.isShootingPanoramaPhoto;
    } else if (self.cameraShootPhotoMode == DJICameraShootPhotoModeBurst) {
        self.isShootingPhoto = self.isShootingBurstPhoto;
    } else if (self.cameraShootPhotoMode == DJICameraShootPhotoModeRAWBurst) {
        self.isShootingPhoto = self.isShootingRAWBurstPhoto;
    }
}

- (void)updateCanStartShootingPhoto {
    self.canStartShootingPhoto = !self.shootPhotoForbiddenFlag && self.storageModule.cameraStorageState.availableCount > 0;
}

- (void)updateCanStopShootingPhoto {
    if ((self.cameraShootPhotoMode == DJICameraShootPhotoModeInterval ||
         self.cameraShootPhotoMode == DJICameraShootPhotoModePanorama) &&
        (self.isShootingPhoto || self.isStoringPhoto)) {
        self.canStopShootingPhoto = YES;
    } else {
        self.canStopShootingPhoto = NO;
    }
}

- (DUXBetaCameraPhotoState *)computedCameraPhotoState {
    if (self.cameraShootPhotoMode == DJICameraShootPhotoModePanorama) {
        return [[DUXBetaCameraPanoramaPhotoState alloc] initWithShootPhotoMode:self.cameraShootPhotoMode
                                                             photoPanoramaMode:self.photoPanoramaMode];
    } else if (self.cameraShootPhotoMode == DJICameraShootPhotoModeBurst) {
        return [[DUXBetaCameraBurstPhotoState alloc] initWithShootPhotoMode:self.cameraShootPhotoMode
                                                            photoBurstCount:self.photoBurstCount];
    } else if (self.cameraShootPhotoMode == DJICameraShootPhotoModeRAWBurst) {
        return [[DUXBetaCameraBurstPhotoState alloc] initWithShootPhotoMode:self.cameraShootPhotoMode
                                                            photoBurstCount:self.photoBurstCount];
    } else if (self.cameraShootPhotoMode == DJICameraShootPhotoModeAEB) {
        return [[DUXBetaCameraAEBPhotoState alloc] initWithShootPhotoMode:self.cameraShootPhotoMode
                                                            photoAEBCount:self.photoAEBCount];
    } else if (self.cameraShootPhotoMode == DJICameraShootPhotoModeInterval) {
        return [[DUXBetaCameraIntervalPhotoState alloc] initWithShootPhotoMode:self.cameraShootPhotoMode
                                                                  captureCount:self.photoTimeIntervalSettings.captureCount
                                                         timeIntervalInSeconds:self.photoTimeIntervalSettings.timeIntervalInSeconds];
    } else {
        return [[DUXBetaCameraPhotoState alloc] initWithShootPhotoMode:self.cameraShootPhotoMode];
    }
}

#pragma mark - Action Methods

- (void)startShootPhotoWithCompletion:(DJICompletionBlock)completion {
    if (self.canStartShootingPhoto) {
        DJICameraKey *startShootPhotoKey = [DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamStartShootPhoto];
        
        [[[DUXBetaKeyInterfaceAdapter sharedInstance] getHandler] performActionForKey:startShootPhotoKey
                                                                      withArguments:nil
                                                                      andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
                                                                          if (completion) {
                                                                              completion(error);
                                                                          }
                                                                      }];
    } else {
        NSError *startShootPhotoError = [NSError errorWithDomain:DUXBetaShootPhotoWidgetDomain
                                                            code:DUXBetaShootPhotoWidgetErrorCameraNotOperational
                                                        userInfo:@{
                                                                   NSLocalizedDescriptionKey : [self localizedDescriptionForErrorCode:DUXBetaShootPhotoWidgetErrorCameraNotOperational]
        }];
        if (completion) {
            completion(startShootPhotoError);
        }
    }
}

- (void)stopShootPhotoWithCompletion:(DJICompletionBlock)completion {
    if (self.canStopShootingPhoto) {
        DJICameraKey *stopShootPhotoKey = [DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamStopShootPhoto];
        
        [[[DUXBetaKeyInterfaceAdapter sharedInstance] getHandler] performActionForKey:stopShootPhotoKey
                                                                      withArguments:nil
                                                                      andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
                                                                          if (completion) {
                                                                              completion(error);
                                                                          }
                                                                      }];
    } else {
        NSError *stopShootPhotoError = [NSError errorWithDomain:DUXBetaShootPhotoWidgetDomain
                                                           code:DUXBetaShootPhotoWidgetErrorCameraNotOperational
                                                       userInfo:@{
                                                                   NSLocalizedDescriptionKey : [self localizedDescriptionForErrorCode:DUXBetaShootPhotoWidgetErrorCameraNotOperational]
                                                                   }];
        if (completion) {
            completion(stopShootPhotoError);
        }
    }
}

- (nonnull NSString *)localizedDescriptionForErrorCode:(DUXBetaShootPhotoWidgetError)errorCode {
    switch (errorCode) {
        case DUXBetaShootPhotoWidgetErrorCameraNotOperational:
            return NSLocalizedString(@"The camera is not in the correct mode for this operation.", @"Shoot Photo Widget Localized Error Description");
            break;
        default:
            return NSLocalizedString(@"Unknown error.", @"Shoot Photo Widget Unknown error");
            break;
    }
}

@end
