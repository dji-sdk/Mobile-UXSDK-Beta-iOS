//
//  DUXBetaFPVDecodeModel.m
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

#import "DUXBetaFPVDecodeModel.h"
#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaFPVDecodeModel()

@property (nonatomic, strong) NSString *cameraName;
@property (nonatomic, strong) NSString *aircraftModel;
@property (nonatomic, assign) DJICameraOrientation orientation;
@property (nonatomic, assign) DJICameraPhotoAspectRatio photoRatio;

@property (nonatomic, assign, readwrite) CGRect contentClipRect;
@property (nonatomic, assign, readwrite) H264EncoderType encodeType;

@property (nonatomic, assign, readwrite, nullable) NSNumber *isEXTPortEnabled;
@property (nonatomic, assign, readwrite, nullable) NSNumber *LBEXTPercent;
@property (nonatomic, assign, readwrite, nullable) NSNumber *HDMIAVPercent;

@property (nonatomic, strong) DUXBetaFlatCameraModule *flatCameraModule;

@end

@implementation DUXBetaFPVDecodeModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _flatCameraModule = [DUXBetaFlatCameraModule new];
        [self addModule:self.flatCameraModule];
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIProductKey keyWithParam: DJIProductParamModelName], aircraftModel);
    BindSDKKey([DJICameraKey keyWithParam:DJICameraParamDisplayName], cameraName);
    BindSDKKey([DJICameraKey keyWithParam:DJICameraParamPhotoAspectRatio], photoRatio);
    
    // Bind to DJICameraParamOrientation key only if the model supports multiple orientations
    DJIAircraft *product = (DJIAircraft *)[DJISDKManager product];
    DJICamera *camera = product.camera;
    if (camera.capabilities.orientationRange.count > 1) {
        BindSDKKey([DJICameraKey keyWithParam:DJICameraParamOrientation], orientation);
    }
    
    BindRKVOModel(self, @selector(updateEncodeType), cameraName)
    BindRKVOModel(self, @selector(updateContentRect), cameraName, photoRatio, flatCameraModule.cameraMode, flatCameraModule.flatMode);
    BindRKVOModel(self, @selector(updateAircraftModel), aircraftModel);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateContentRect {
    if (self.flatCameraModule.cameraMode == DJICameraModeShootPhoto) {
        self.contentClipRect = self.contentRectInPhotoMode;
        return;
    }
    
    self.contentClipRect = self.defaultContentRect;
}

- (void)updateEncodeType {
    self.encodeType = self.computedEncodeType;
}

- (void)updateAircraftModel {
    if ([self.aircraftModel isEqualToString:DJIAircraftModelNameMatrice600] ||
        [self.aircraftModel isEqualToString:DJIAircraftModelNameMatrice600Pro] ||
        [self.aircraftModel isEqualToString:DJIAircraftModelNameA3] ||
        [self.aircraftModel isEqualToString:DJIAircraftModelNameN3]) {

        BindSDKKey([DJIAirLinkKey keyWithIndex:0
                                  subComponent:DJIAirLinkLightbridgeLinkSubComponent
                             subComponentIndex:0
                                      andParam:DJILightbridgeLinkParamEXTVideoInputPortEnabled], isEXTPortEnabled);
        BindSDKKey([DJIAirLinkKey keyWithIndex:0
                                  subComponent:DJIAirLinkLightbridgeLinkSubComponent
                             subComponentIndex:0
                                      andParam:DJILightbridgeLinkParamBandwidthAllocationForLBVideoInputPort], LBEXTPercent);
        BindSDKKey([DJIAirLinkKey keyWithIndex:0
                                  subComponent:DJIAirLinkLightbridgeLinkSubComponent
                             subComponentIndex:0
                                      andParam:DJILightbridgeLinkParamBandwidthAllocationForHDMIVideoInputPort], HDMIAVPercent);
    }
}

#pragma mark - Private Methods

- (CGRect)defaultContentRect {
    return CGRectMake(0, 0, 1, 1);
}

- (CGRect)contentRectInPhotoMode {
    CGRect rect = self.defaultContentRect;
    BOOL needFitToRate = NO;
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNameX3] ||
        [self.cameraName isEqualToString:DJICameraDisplayNameX5] ||
        [self.cameraName isEqualToString:DJICameraDisplayNameX5R] ||
        [self.cameraName isEqualToString:DJICameraDisplayNamePhantom3ProfessionalCamera] ||
        [self.cameraName isEqualToString:DJICameraDisplayNameMavicProCamera]) {
        needFitToRate = YES;
    }
    if (needFitToRate && self.photoRatio != DJICameraPhotoAspectRatioUnknown) {
        CGSize rateSize;
        
        switch (self.photoRatio) {
            case DJICameraPhotoAspectRatio3_2:
                rateSize = CGSizeMake(3, 2);
                break;
            case DJICameraPhotoAspectRatio4_3:
                rateSize = CGSizeMake(4, 3);
                break;
            default:
                rateSize = CGSizeMake(16, 9);
                break;
        }
        
        CGRect streamRect = CGRectMake(0, 0, 16, 9);
        CGRect destRect = [DJIVideoPresentViewAdjustHelper aspectFitWithFrame:streamRect size:rateSize];
        rect = [DJIVideoPresentViewAdjustHelper normalizeFrame:destRect withIdentityRect:streamRect];
    }
    return rect;
}

- (H264EncoderType)computedEncodeType {
    DJIAircraft *product = (DJIAircraft *)[DJISDKManager product];
    DJICamera *camera = product.camera;
    NSString *productName = product.model;
    BOOL isAircraft = [product isKindOfClass:[DJIAircraft class]];
    
    if (isAircraft && [ProductUtil isExtPortSupportedProduct]) {
        return H264EncoderType_LightBridge2;
    }
    
    //Special case: can be stand-alone Lightbridge 2
    if (isAircraft &&
        [productName isEqual:DJIAircraftModelNameUnknownAircraft] &&
        camera.displayName == nil) {
        return H264EncoderType_LightBridge2;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNameX3]) {
        if (!isAircraft && [camera isDigitalZoomSupported]) {
            return H264EncoderType_A9_OSMO_NO_368;
        }
        return H264EncoderType_DM368_inspire;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNameZ3]) {
        return H264EncoderType_A9_OSMO_NO_368;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNameX5] ||
        [self.cameraName isEqualToString:DJICameraDisplayNameX5R]) {
        return H264EncoderType_DM368_inspire;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNamePhantom3ProfessionalCamera]) {
        return H264EncoderType_DM365_phamtom3x;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNamePhantom3AdvancedCamera]) {
        return H264EncoderType_A9_phantom3s;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNamePhantom3StandardCamera]) {
        return H264EncoderType_A9_phantom3c;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNamePhantom4Camera]) {
        return H264EncoderType_1860_phantom4x;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNameMavicProCamera]) {
        DJIAircraft *product = (DJIAircraft *)[DJISDKManager product];
        if (product.airLink.wifiLink) {
            return H264EncoderType_1860_phantom4x;
        }
        return H264EncoderType_unknown;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNameSparkCamera]) {
        return H264EncoderType_1860_phantom4x;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNameZ30]) {
        return H264EncoderType_GD600;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNamePhantom4ProCamera] ||
        [self.cameraName isEqualToString:DJICameraDisplayNamePhantom4AdvancedCamera] ||
        [self.cameraName isEqualToString:DJICameraDisplayNameX5S] ||
        [self.cameraName isEqualToString:DJICameraDisplayNameX4S] ||
        [self.cameraName isEqualToString:DJICameraDisplayNameX7] ||
        [self.cameraName isEqualToString:DJICameraDisplayNamePayload]) {
        return H264EncoderType_H1_Inspire2;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNameMavicAirCamera]) {
        return H264EncoderType_MavicAir;
    }
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNameMavicMiniCamera]) {
        return H264EncoderType_MavicMini;
    }

    return H264EncoderType_unknown;
}

@end

