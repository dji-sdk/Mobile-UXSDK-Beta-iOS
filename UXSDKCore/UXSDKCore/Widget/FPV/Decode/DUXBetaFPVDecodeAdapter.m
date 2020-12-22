//
//  DUXBetaFPVDecodeAdapter.m
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
#import "DUXBetaFPVDecodeAdapter.h"
#import <DJIWidget/DJIVideoPreviewer.h>
#import <UXSDKCore/UXSDKCore-Swift.h>

#define IS_FLOAT_EQUAL(a, b) (fabs(a - b) < 0.0005)

@interface DUXBetaFPVDecodeAdapter ()

@property (nonatomic, weak) DJIVideoPreviewer *videoPreviewer;

@property (nonatomic, strong) DUXBetaFPVDecodeModel *decodeModel;

@end

@implementation DUXBetaFPVDecodeAdapter

- (instancetype)init {
    self = [super init];
    if (self) {
        _videoPreviewer = [DJIVideoPreviewer instance];
    }
    return self;
}

- (void)startWithVideoFeed:(DJIVideoFeed *)videoFeed {
    _videoFeed = videoFeed;
    
    [self modelSetup];
    
    //Start the videoPreviewer
    self.videoPreviewer.type = DJIVideoPreviewerTypeAutoAdapt;
    self.videoPreviewer.enableHardwareDecode = YES;
    [self.videoPreviewer start];
    
    //Setup delegates
    [[DJISDKManager videoFeeder] addVideoFeedSourceListener:self];
    [self.videoFeed addListener:self withQueue:nil];
    self.videoPreviewer.frameControlHandler = self;
}

- (void)stop {
    [self modelCleanup];
    
    [self.videoPreviewer unSetView];
    [self.videoPreviewer close];
    
    // Clean delegate
    [[DJISDKManager videoFeeder] removeVideoFeedSourceListener:self];
    self.videoPreviewer.frameControlHandler = nil;
    [self.videoFeed removeListener:self];
}

- (void)setRenderingView:(UIView *)view {
    [self.videoPreviewer setView:view];
}

- (void)removeRenderingView {
    [self.videoPreviewer unSetView];
}

- (void)adjustPreviewer {
    [self.videoPreviewer adjustViewSize];
}

- (void)setVideoFeed:(DJIVideoFeed *)videoFeed {
    [self.videoPreviewer pause];
    [self.videoFeed removeListener:self];
    
    _videoFeed = videoFeed;
    
    [self.videoFeed addListener:self withQueue:nil];
    [self.videoPreviewer safeResume];
}

#pragma mark - Private Methods

- (void)modelSetup {
    self.decodeModel = [[DUXBetaFPVDecodeModel alloc] init];
    [self.decodeModel setup];
    
    BindRKVOModel(self, @selector(updateLiveViewFrame), self.videoPreviewer.frame);
    BindRKVOModel(self, @selector(updatedDecodingRect), self.decodeModel.contentClipRect);
    BindRKVOModel(self, @selector(updateEncodeType), self.decodeModel.encodeType);
    BindRKVOModel(self, @selector(updateHardwareDecode), self.enableHardwareDecode);
    BindRKVOModel(self, @selector(updateOrientation), self.decodeModel.orientation);
    BindRKVOModel(self, @selector(updateVideoFeed), self.decodeModel.isEXTPortEnabled, self.decodeModel.LBEXTPercent, self.decodeModel.HDMIAVPercent);
}

- (void)modelCleanup {
    [self.decodeModel cleanup];
    
    UnBindRKVOModel(self);
}

- (void)updateHardwareDecode {
    self.videoPreviewer.enableHardwareDecode = self.enableHardwareDecode;
}

- (void)updatedDecodingRect {
    //Update videpreviewer contentClipRect
    self.videoPreviewer.contentClipRect = self.decodeModel.contentClipRect;
    
    //Broadcast the updated contentClipRect
    [DUXBetaStateChangeBroadcaster send:[FPVUIState contentFrameUpdated:self.decodeModel.contentClipRect]];
}

- (void)updateEncodeType {
    self.videoPreviewer.encoderType = self.decodeModel.encodeType;
    
    //Forward the model change
    [DUXBetaStateChangeBroadcaster send:[FPVModelState encodeTypeUpdated:self.decodeModel.encodeType]];
}

- (void)updateOrientation {
    if (self.decodeModel.orientation == DJICameraOrientationLandscape) {
        self.videoPreviewer.rotation = VideoStreamRotationDefault;
    } else {
        self.videoPreviewer.rotation = VideoStreamRotationCW90;
    }
}

- (void)updateLiveViewFrame {
    CGRect frame = [self.videoPreviewer frame];
    
    //get available area
    CGRect availableArea = self.videoPreviewer.contentClipRect;
    CGRect rotatedAvailableArea = availableArea;
    
    //handle orientation
    switch (self.videoPreviewer.rotation) {
        case VideoStreamRotationDefault:
            break;
        case VideoStreamRotationCW90:
            rotatedAvailableArea.origin.x = availableArea.origin.y;
            rotatedAvailableArea.origin.y = availableArea.origin.x;
            rotatedAvailableArea.size.width = availableArea.size.height;
            rotatedAvailableArea.size.height = availableArea.size.width;
            break;
        case VideoStreamRotationCW270:
            rotatedAvailableArea.origin.x = 1 - availableArea.size.height
                                                - availableArea.origin.y;
            rotatedAvailableArea.origin.y = 1 - availableArea.size.width
                                                - availableArea.origin.x;
            rotatedAvailableArea.size.width = availableArea.size.height;
            rotatedAvailableArea.size.height = availableArea.size.width;
            break;
        case VideoStreamRotationCW180:
            rotatedAvailableArea.origin.x = 1 - availableArea.origin.x - availableArea.size.width;
            rotatedAvailableArea.origin.y = 1 - availableArea.origin.y - availableArea.size.height;
            break;
    }
    
    frame.origin.x = frame.origin.x + frame.size.width*rotatedAvailableArea.origin.x;
    frame.origin.y = frame.origin.y + frame.size.height*rotatedAvailableArea.origin.y;
    frame.size.width = frame.size.width*rotatedAvailableArea.size.width;
    frame.size.height = frame.size.height*rotatedAvailableArea.size.height;
    
    self.widgetModel.gridFrame = frame;
}

// MARK: Lightbridge2 support methods

- (void)updateVideoFeed {
    if (self.decodeModel.isEXTPortEnabled == nil) {
        [self swapToPrimaryVideoFeedIfNecessary];
        return;
    }

    if ([self.decodeModel.isEXTPortEnabled boolValue]) {
        if (self.decodeModel.LBEXTPercent == nil) {
            [self swapToPrimaryVideoFeedIfNecessary];
            return;
        }

        if (IS_FLOAT_EQUAL(self.decodeModel.LBEXTPercent.floatValue, 1.0)) {
            if (![self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        } else if (self.decodeModel.LBEXTPercent.floatValue < 0.95) {
            if ([self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        }
    } else {
        if (self.decodeModel.HDMIAVPercent == nil) {
            [self swapToPrimaryVideoFeedIfNecessary];
            return;
        }
        
        if (IS_FLOAT_EQUAL(self.decodeModel.HDMIAVPercent.floatValue, 1.0)) {
            if (![self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        } else if (IS_FLOAT_EQUAL(self.decodeModel.HDMIAVPercent.floatValue, 0.0)) {
            if ([self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        }
    }
}

- (BOOL)isUsingPrimaryVideoFeed {
    return (self.videoFeed == [DJISDKManager videoFeeder].primaryVideoFeed);
}

- (void)swapToPrimaryVideoFeedIfNecessary {
    if (![self isUsingPrimaryVideoFeed]) {
        [self swapVideoFeed];
    }
}

- (void)swapVideoFeed {
    if ([self isUsingPrimaryVideoFeed]) {
        self.videoFeed = [DJISDKManager videoFeeder].secondaryVideoFeed;
    } else {
        self.videoFeed = [DJISDKManager videoFeeder].primaryVideoFeed;
    }
}

#pragma mark - DJIVideoFeedListener Method

- (void)videoFeed:(DJIVideoFeed *)videoFeed didUpdateVideoData:(NSData *)videoData {
    [self.videoPreviewer push:(uint8_t *)[videoData bytes] length:(int)videoData.length];
}

#pragma mark - DJIVideoFeedSourceListener

- (void)videoFeed:(nonnull DJIVideoFeed *)videoFeed didChangePhysicalSource:(DJIVideoFeedPhysicalSource)physicalSource {
    if (self.videoFeed ==  videoFeed) {
        
        //Forward the user interface change
        [DUXBetaStateChangeBroadcaster send:[FPVModelState physicalSourceUpdated:physicalSource]];
        
        if (physicalSource == DJIVideoFeedPhysicalSourceUnknown) {
            
        } else {
            //Update models
            [self.decodeModel updateEncodeType];
            [self.decodeModel updateContentRect];
            [self.widgetModel updateDisplayedValues];
            [self.widgetModel updateCurrentCameraIndex];
        }
    }
}

#pragma mark - DJIVideoPreviewerFrameControlDelegate Methods

- (BOOL)parseDecodingAssistInfoWithBuffer:(uint8_t *)buffer length:(int)length assistInfo:(DJIDecodingAssistInfo *)assistInfo {
    return [self.videoFeed parseDecodingAssistInfoWithBuffer:buffer length:length assistInfo:(void *)assistInfo];
}

- (BOOL)isNeedFitFrameWidth {
    return YES;
}

- (void)syncDecoderStatus:(BOOL)isNormal {
    [self.videoFeed syncDecoderStatus:isNormal];
}

- (void)decodingDidSucceedWithTimestamp:(uint32_t)timestamp {
    [self.videoFeed decodingDidSucceedWithTimestamp:(NSUInteger)timestamp];
    
    //Forward the model change
    [DUXBetaStateChangeBroadcaster send:[FPVModelState decodingDidSucceedWithTimestamp:timestamp]];
}

- (void)decodingDidFail {
    [self.videoFeed decodingDidFail];
    
    //Forward the model change
    [DUXBetaStateChangeBroadcaster send:[FPVModelState decodingDidFail]];
}

@end
