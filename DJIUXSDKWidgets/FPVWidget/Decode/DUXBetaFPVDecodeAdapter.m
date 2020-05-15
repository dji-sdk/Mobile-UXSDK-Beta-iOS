//
//  DUXBetaFPVDecodeAdapter.m
//  DJIUXSDKWidgets
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

#import "DUXBetaBaseWidgetModel+Protected.h"

#import <DJIUXSDKWidgets/DJIUXSDKWidgets-Swift.h>

@interface DUXBetaFPVDecodeAdapter ()

@property (nonatomic, weak) DJIVideoPreviewer *videoPreviewer;
@property (nonatomic, weak) DJIVideoFeed *videoFeed;

@property (nonatomic, strong) DUXBetaFPVDecodeModel *decodeModel;

@end

@implementation DUXBetaFPVDecodeAdapter

- (instancetype)initWithVideoFeed:(DJIVideoFeed *)videoFeed {
    self = [super init];
    if (self) {
        self.videoFeed = videoFeed;
        self.videoPreviewer = [DJIVideoPreviewer instance];
    }
    return self;
}

- (void)start {
    [self modelSetup];
    
    //Start the videoPreviewer
    self.videoPreviewer.type = DJIVideoPreviewerTypeAutoAdapt;
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

#pragma mark - Private Methods

- (void)modelSetup {
    self.decodeModel = [[DUXBetaFPVDecodeModel alloc] initWithVideoFeed:self.videoFeed];
    [self.decodeModel setup];
    BindRKVOModel(self, @selector(updatedDecodingRect), self.decodeModel.contentClipRect);
    BindRKVOModel(self, @selector(updateEncodeType), self.decodeModel.encodeType);
}

- (void)modelCleanup {
    [self.decodeModel cleanup];
    
    UnBindRKVOModel(self);
}

- (void)updatedDecodingRect {
    //Update videpreviewer contentClipRect
    self.videoPreviewer.contentClipRect = self.decodeModel.contentClipRect;
    
    //Broadcast the updated contentClipRect
    [DUXStateChangeBroadcaster send:[DUXFPVWidgetUIState contentFrameUpdate:self.decodeModel.contentClipRect]];
}

- (void)updateEncodeType {
    self.videoPreviewer.encoderType = self.decodeModel.encodeType;
    
    //Forward the model change
    [DUXStateChangeBroadcaster send:[DUXFPVWidgetModelState encodeTypeUpdate:self.decodeModel.encodeType]];
}

#pragma mark - DJIVideoFeedListener Method

- (void)videoFeed:(DJIVideoFeed *)videoFeed didUpdateVideoData:(NSData *)videoData {
    [self.videoPreviewer push:(uint8_t *)[videoData bytes] length:(int)videoData.length];
}

#pragma mark - DJIVideoFeedSourceListener

- (void)videoFeed:(nonnull DJIVideoFeed *)videoFeed didChangePhysicalSource:(DJIVideoFeedPhysicalSource)physicalSource {
    if (self.videoFeed ==  videoFeed) {
        
        //Forward the user interface change
        [DUXStateChangeBroadcaster send:[DUXFPVWidgetModelState physicalSourceUpdate:physicalSource]];
        
        if (physicalSource == DJIVideoFeedPhysicalSourceUnknown) {
            
        } else {
            //Update models
            [self.decodeModel updateEncodeType];
            [self.decodeModel updateContentRect];
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
    [DUXStateChangeBroadcaster send:[DUXFPVWidgetModelState decodingDidSucceedWithTimestamp:timestamp]];
}

- (void)decodingDidFail {
    [self.videoFeed decodingDidFail];
    
    //Forward the model change
    [DUXStateChangeBroadcaster send:[DUXFPVWidgetModelState decodingDidFail]];
}

@end
