//
//  VideoPreviewerSDKAdapter.m
//  VideoPreviewer
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

#import "VideoPreviewerSDKAdapter.h"
#import "VideoPreviewerSDKAdapter+Lightbridge2.h"
#import <DJIWidget/DJIWidget.h>
#import <UXSDKCore/UXSDKCore.h>

#define weakSelf(__TARGET__) __weak typeof(self) __TARGET__=self
#define weakReturn(__TARGET__) if(__TARGET__==nil)return;

const static NSTimeInterval REFRESH_INTERVAL = 1.0;

/**
 *  Information needed by VideoPreviewer includes: 
 *  1. Product names.
 *  2. (Osmo only) Is digital zoom supported. 
 *  3. (Marvik only) Is in portrait mode.
 *  4. Photo Ratio.
 *  5. Camera Mode. 
 */
@interface VideoPreviewerSDKAdapter ()

@property (nonatomic) NSTimer *refreshTimer;

@property (nonatomic) NSString *productName;
@property (nonatomic) NSString *cameraName;
@property (nonatomic) BOOL isAircraft;
@property (nonatomic) DJICameraMode cameraMode;
@property (nonatomic) DJICameraPhotoAspectRatio photoRatio;

@property (nonatomic) BOOL isForLightbridge2;

@property (nonatomic, assign, readwrite) NSUInteger currentCameraIndex;
@property (nonatomic, assign) CGFloat bandwidthAllocationForLeftCamera;
@property (nonatomic, assign) CGFloat bandwidthAllocationForMainCamera;

@end

@implementation VideoPreviewerSDKAdapter

+ (instancetype)defaultAdapterWithVideoPreviewer:(DJIVideoPreviewer *)videoPreviewer; {
    return [self adapterWithVideoPreviewer:videoPreviewer
                              andVideoFeed:[DJISDKManager videoFeeder].primaryVideoFeed];
}

+ (instancetype)lightbridge2AdapterWithVideoPreviewer:(DJIVideoPreviewer *)videoPreviewer {
    VideoPreviewerSDKAdapter *adapter = [self defaultAdapterWithVideoPreviewer:videoPreviewer];
    adapter.isForLightbridge2 = YES;
    return adapter;
}

+(instancetype)adapterWithVideoPreviewer:(DJIVideoPreviewer *)videoPreviewer
                            andVideoFeed:(DJIVideoFeed *)videoFeed {
    VideoPreviewerSDKAdapter *adapter = [VideoPreviewerSDKAdapter new];
    adapter.videoPreviewer = videoPreviewer;
    adapter.videoFeed = videoFeed;

    return adapter;
}

+ (nonnull instancetype)adapterWithAircraftModel:(nonnull NSString *)model
                                  videoPreviewer:(nonnull DJIVideoPreviewer *)videoPreviewer
                                       videoFeed:(nonnull DJIVideoFeed *)videoFeed {
    VideoPreviewerSDKAdapter *adapter = [VideoPreviewerSDKAdapter new];
    adapter.videoPreviewer            = videoPreviewer;
    adapter.videoFeed                 = videoFeed;
    
    if ([model isEqualToString:DJIAircraftModelNameMatrice600] ||
        [model isEqualToString:DJIAircraftModelNameMatrice600Pro] ||
        [model isEqualToString:DJIAircraftModelNameA3] ||
        [model isEqualToString:DJIAircraftModelNameN3]) {
        adapter.isForLightbridge2 = YES;
    }
    
    return adapter;
}

-(instancetype)init {
    if (self = [super init]) {
        _cameraMode = DJICameraModeUnknown;
        _photoRatio = DJICameraPhotoAspectRatioUnknown;
        if (g_loadPrebuildIframeOverrideFunc == NULL) {
            g_loadPrebuildIframeOverrideFunc = loadPrebuildIframePrivate;
        }
        _isForLightbridge2 = NO;
        _preferredCameraIndex = 0;
    }
    return self;
}

-(void)start {
    [self startRefreshTimer];
    [[DJISDKManager videoFeeder] addVideoFeedSourceListener:self];
    if (self.videoFeed) {
        [self.videoFeed addListener:self withQueue:nil];
    }
    if (self.isForLightbridge2) {
        [self startLightbridgeListen];
    }
    [self setupFrameControlHandler];
}

-(void)stop {
    
    [self stopRefreshTimer];
    [[DJISDKManager videoFeeder] removeVideoFeedSourceListener:self];
    if (self.videoFeed) {
        [self.videoFeed removeListener:self];
    }
    if (self.isForLightbridge2) {
        [self stopLightbridgeListen]; 
    }
}


- (void)setVideoFeed:(DJIVideoFeed *)videoFeed {
    [self willChangeValueForKey:@"videoFeed"];
    _videoFeed = videoFeed;
    [self didChangeValueForKey:@"videoFeed"];
    [self updateCurrentCameraIndex];
}

-(void)startRefreshTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.refreshTimer) {
            self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_INTERVAL
                                                                 target:self
                                                               selector:@selector(updateInformation)
                                                               userInfo:nil
                                                                repeats:YES];
        }
    });
}

-(void)stopRefreshTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.refreshTimer) {
            [self.refreshTimer invalidate];
            self.refreshTimer = nil;
        }
    });
}

-(void) updateInformation {
    if (!self.videoPreviewer) {
        return;
    }

    // 1. check if the product is still connecting
    DJIBaseProduct *product = [DJISDKManager product];
    if (product == nil) {
        return;
    }

    // 2. Get product names and camera names
    self.productName = product.model;
    if (!self.productName) {
        [self setDefaultConfiguration];
        return;
    }
    self.isAircraft = [product isKindOfClass:[DJIAircraft class]];
    self.cameraName = [[self class] camera].displayName;

    // Set decode type
    [self updateEncodeType];
}

-(void)setDefaultConfiguration {
    [self.videoPreviewer setEncoderType:H264EncoderType_unknown];
    self.videoPreviewer.rotation = VideoStreamRotationDefault;
    self.videoPreviewer.contentClipRect = CGRectMake(0, 0, 1, 1);
    self.videoPreviewer.enableHardwareDecode = YES;
}

-(void)updateEncodeType {
    // Check if Inspire 2 FPV
    if (self.videoFeed.physicalSource == DJIVideoFeedPhysicalSourceFPVCamera) {
        [self.videoPreviewer setEncoderType:H264EncoderType_1860_Inspire2_FPV];
        return;
    }

    // Check if Lightbridge 2
    if ([[self class] isUsingLightbridge2WithProductName:self.productName
                                              isAircraft:self.isAircraft
                                              cameraName:self.cameraName]) {
        [self.videoPreviewer setEncoderType:H264EncoderType_LightBridge2];
        return;
    }

    H264EncoderType encodeType = [[self class] getDataSourceWithCameraName:self.cameraName
                                                             andIsAircraft:self.isAircraft];;

    [self.videoPreviewer setEncoderType:encodeType];
}

-(void)updateContentRect {
    if (self.videoFeed.physicalSource == DJIVideoFeedPhysicalSourceFPVCamera) {
        [self setDefaultContentRect];
        return;
    }
    
    if ([self.cameraName isEqual:DJICameraDisplayNameXT]) {
        [self updateContentRectForXT];
        return;
    }

    if (self.cameraMode == DJICameraModeShootPhoto) {
        [self updateContentRectInPhotoMode];
    }
    else {
        [self setDefaultContentRect];
    }
}

-(void)updateContentRectForXT {
    // Workaround: when M100 is setup with XT, there are 8 useless pixels on
    // the left and right hand sides.
    if ([self. productName isEqual:DJIAircraftModelNameMatrice100]) {
        self.videoPreviewer.contentClipRect = CGRectMake(0.010869565217391, 0
                                                         , 0.978260869565217, 1);
    }
}

-(void)updateContentRectInPhotoMode {
    CGRect area = CGRectMake(0, 0, 1, 1);
    BOOL needFitToRate = NO;
    
    if ([self.cameraName isEqualToString:DJICameraDisplayNameX3] ||
        [self.cameraName isEqualToString:DJICameraDisplayNameX5] ||
        [self.cameraName isEqualToString:DJICameraDisplayNameX5R] ||
        [self.cameraName isEqualToString:DJICameraDisplayNamePhantom3ProfessionalCamera] ||
        [self.cameraName isEqualToString:DJICameraDisplayNamePhantom4Camera] ||
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
        area = [DJIVideoPresentViewAdjustHelper normalizeFrame:destRect withIdentityRect:streamRect];
    }
    
    if (!CGRectEqualToRect(self.videoPreviewer.contentClipRect, area)) {
        self.videoPreviewer.contentClipRect = area;
    }
}

-(void)setDefaultContentRect {
    self.videoPreviewer.contentClipRect = CGRectMake(0, 0, 1, 1);
}

- (nullable NSString *)productName {
    if (!_productName && [[DJISDKManager product] model]) {
        _productName = [[DJISDKManager product] model];
    }
    return _productName;
}

#pragma mark Helper Methods
+(DJICamera *)camera {
    DJIBaseProduct *product = [DJISDKManager product];
    if (product == nil) {
        return nil;
    }

    if ([product isKindOfClass:[DJIAircraft class]]) {
        DJIAircraft *aircraft = (DJIAircraft *)product;
        return aircraft.camera;
    }
    else if ([product isKindOfClass:[DJIHandheld class]]) {
        DJIHandheld *handheld = (DJIHandheld *)product;
        return handheld.camera;
    }

    return nil;
}

+(BOOL) isUsingLightbridge2WithProductName:(NSString *)productName
                                isAircraft:(BOOL)isAircraft
                                cameraName:(NSString *)cameraName {
    if (!isAircraft) {
        return NO;
    }

    if ([productName isEqual:DJIAircraftModelNameA3] ||
        [productName isEqual:DJIAircraftModelNameN3] ||
        [productName isEqual:DJIAircraftModelNameMatrice600] ||
        [productName isEqual:DJIAircraftModelNameMatrice600Pro]) {
        return YES;
    }

    // Special case: can be stand-alone Lightbridge 2
    if ([productName isEqual:DJIAircraftModelNameUnknownAircraft]) {
        if (cameraName == nil) {
            return YES;
        }
    }

    return NO;
}

+ (H264EncoderType) getDataSourceWithCameraName:(NSString *)cameraName andIsAircraft:(BOOL)isAircraft {
    if ([cameraName isEqualToString:DJICameraDisplayNameX3] ||
        [cameraName isEqualToString:DJICameraDisplayNameZ3]) {
        DJICamera *camera = [VideoPreviewerSDKAdapter camera];
        /**
         *  Osmo's video encoding solution is changed since a firmware version.
         *  X3 also began to support digital zoom since that version. Therefore, 
         *  `isDigitalZoomSupported` is used to determine the correct
         *  encode type.
         */
        if (!isAircraft && [camera isDigitalZoomSupported]) {
            return H264EncoderType_A9_OSMO_NO_368;
        }
        else {
            return H264EncoderType_DM368_inspire;
        }
    }
    else if ([cameraName isEqualToString:DJICameraDisplayNameX5] ||
             [cameraName isEqualToString:DJICameraDisplayNameX5R]) {
        return H264EncoderType_DM368_inspire;
    }
    else if ([cameraName isEqualToString:DJICameraDisplayNamePhantom3ProfessionalCamera]) {
        return H264EncoderType_DM365_phamtom3x;
    }
    else if ([cameraName isEqualToString:DJICameraDisplayNamePhantom3AdvancedCamera]) {
        return H264EncoderType_A9_phantom3s;
    }
    else if ([cameraName isEqualToString:DJICameraDisplayNamePhantom3StandardCamera]) {
        return H264EncoderType_A9_phantom3c;
    }
    else if ([cameraName isEqualToString:DJICameraDisplayNamePhantom4Camera]) {
        return H264EncoderType_1860_phantom4x;
    }
    else if ([cameraName isEqualToString:DJICameraDisplayNameMavicProCamera]) {
        DJIAircraft *product = (DJIAircraft *)[DJISDKManager product];
        if (product.airLink.wifiLink) {
            return H264EncoderType_1860_phantom4x;
        }
        else {
            return H264EncoderType_unknown;
        }
    }
    else if ([cameraName isEqualToString:DJICameraDisplayNameSparkCamera]) {
        return H264EncoderType_1860_phantom4x;
    }
    else if ([cameraName isEqualToString:DJICameraDisplayNameZ30]) {
        return H264EncoderType_GD600;
    }
    else if ([cameraName isEqualToString:DJICameraDisplayNamePhantom4ProCamera] ||
             [cameraName isEqualToString:DJICameraDisplayNamePhantom4AdvancedCamera] ||
             [cameraName isEqualToString:DJICameraDisplayNameX5S] ||
             [cameraName isEqualToString:DJICameraDisplayNameX4S] ||
             [cameraName isEqualToString:DJICameraDisplayNameX7]) {
        return H264EncoderType_H1_Inspire2;
    } else if ([cameraName isEqualToString:DJICameraDisplayNameMavicAirCamera]) {
        return H264EncoderType_MavicAir;
    }

    return H264EncoderType_unknown;
}

#pragma mark - Multiple Camera Support

- (NSUInteger)currentCameraIndex {
    return _currentCameraIndex;
}

- (void)updateCurrentCameraIndex {
    if ([[DJISDKManager product] cameras].count > 1) {
        if (self.bandwidthAllocationForLeftCamera > 0.05) {
            if ([self.videoFeed isEqual:[DJISDKManager videoFeeder].primaryVideoFeed]) {
                self.currentCameraIndex = 0;
            } else {
                self.currentCameraIndex = 1;
            }
        } else {
            self.currentCameraIndex = [self.videoFeed isEqual:[DJISDKManager videoFeeder].primaryVideoFeed] ? 1 : NSNotFound;
        }
    } else {
        if (self.videoFeed.physicalSource != DJIVideoFeedPhysicalSourceFPVCamera) {
            self.currentCameraIndex = 0;
        } else {
            self.currentCameraIndex = NSNotFound;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPreviewerSDKAdapter:didChangeCurrentCameraIndexTo:)]) {
        [self.delegate videoPreviewerSDKAdapter:self didChangeCurrentCameraIndexTo:self.currentCameraIndex];
    }
}

// preferredCameraIndex is 0 for port, 1 for starboard
// port corresponds to "left camera", whose video bandwidth is controlled via airlink
- (void)setPreferredCameraIndex:(NSUInteger)preferredCameraIndex {
    [self willChangeValueForKey:@"preferredCameraIndex"];
    _preferredCameraIndex = preferredCameraIndex;
    [self didChangeValueForKey:@"preferredCameraIndex"];
    [self updateBandwidthSettings];
}

- (void)updateBandwidthSettings {
    if ([self.productName isEqualToString:DJIAircraftModelNameMatrice210] ||
        [self.productName isEqualToString:DJIAircraftModelNameMatrice210RTK]) {
        
        DJIAirLinkKey *bandwidthAllocationForLeftCameraKey = [DJIAirLinkKey keyWithIndex:0
                                                                              subComponent:DJIAirLinkLightbridgeLinkSubComponent
                                                                                subComponentIndex:0
                                                                                andParam:DJILightbridgeLinkParamBandwidthAllocationForLeftCamera];
        
        CGFloat leftCameraBandwidthIntegerValue = self.preferredCameraIndex == 0 ? 1.0 : 0;
        NSNumber *leftCameraBandwidthValue = @(leftCameraBandwidthIntegerValue);
        
        [[DJISDKManager keyManager] setValue:leftCameraBandwidthValue
                                      forKey:bandwidthAllocationForLeftCameraKey
                              withCompletion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"ERROR: %@", error.localizedDescription);
            }
        }];
        
        DJIAirLinkKey *bandWidthAllocationForMainCameraKey = [DJIAirLinkKey keyWithIndex:0
                                                                              subComponent:DJIAirLinkLightbridgeLinkSubComponent
                                                                                subComponentIndex:0
                                                                                andParam:DJILightbridgeLinkParamBandwidthAllocationForMainCamera];
        [[DJISDKManager keyManager] setValue:@(0.5)
                                      forKey:bandWidthAllocationForMainCameraKey
                              withCompletion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"ERROR: %@", error.localizedDescription);
            }
        }];
    }
}

#pragma mark video delegate
-(void)videoFeed:(DJIVideoFeed *)videoFeed didUpdateVideoData:(NSData *)videoData {
    if (videoFeed != self.videoFeed) {
        NSLog(@"ERROR: Wrong video feed update is received!");
    }
    [self.videoPreviewer push:(uint8_t *)[videoData bytes] length:(int)videoData.length];
}

-(void)videoFeed:(DJIVideoFeed *)videoFeed didChangePhysicalSource:(DJIVideoFeedPhysicalSource)physicalSource {
    if (videoFeed == self.videoFeed) {
        if (physicalSource == DJIVideoFeedPhysicalSourceUnknown) {
            NSLog(@"Video feed is disconnected. ");
            return;
        } else {
            [self updateEncodeType];
            [self updateContentRect];
        }
    }
}

-(void)setupFrameControlHandler {
    self.videoPreviewer.frameControlHandler = self;
}

- (BOOL)parseDecodingAssistInfoWithBuffer:(uint8_t *)buffer length:(int)length assistInfo:(DJIDecodingAssistInfo *)assistInfo {
	return [self.videoFeed parseDecodingAssistInfoWithBuffer:buffer length:length assistInfo:(void *)assistInfo];
}

- (BOOL)isNeedFitFrameWidth {
	NSString* displayName = [[self class] camera].displayName;
	if ([displayName isEqualToString:DJICameraDisplayNameMavic2ZoomCamera] ||
		[displayName isEqualToString:DJICameraDisplayNameMavic2ProCamera]) {
		return YES;
	}
	
	return NO;
}

- (void)syncDecoderStatus:(BOOL)isNormal {
	[self.videoFeed syncDecoderStatus:isNormal];
}

- (void)decodingDidSucceedWithTimestamp:(uint32_t)timestamp {
	[self.videoFeed decodingDidSucceedWithTimestamp:(NSUInteger)timestamp];
}

- (void)decodingDidFail {
	[self.videoFeed decodingDidFail];
}

@end
