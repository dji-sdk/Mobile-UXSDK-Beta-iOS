//
//  DUXLiveStreamControlWidgetModel.m
//  DJIUXSDK
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

#import "DUXLiveStreamControlWidgetModel.h"

#import <DJIWidget/DJIRtmpMuxer.h>
#import <DJIWidget/DJIVideoPreviewer.h>

#import "DUXLiveStreamContext.h"
#import "DUXLiveStreamFacebookContext.h"
#import "VideoPreviewerSDKAdapter.h"

@interface DUXLiveStreamControlWidgetModel () <DJIRtmpMuxerStateUpdateDelegate>

@property (nonatomic, strong) DJIRtmpMuxer* rtmpMuxer;
@property (nonatomic, strong) DUXLiveStreamContext *context;
@property (nonatomic, strong ,readwrite) UIImage* snapshot;
@property(nonatomic) VideoPreviewerSDKAdapter* previewerAdapter;

@end


@implementation DUXLiveStreamControlWidgetModel

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.context = [[DUXLiveStreamFacebookContext alloc] init];
        self.context.widgetModel = self;
        [self bindData];
    }
    
    return self;
}

-(void) bindData{
    [DJIVideoPreviewer instance].type = DJIVideoPreviewerTypeAutoAdapt;
    [[DJIVideoPreviewer instance] start];
    [[DJIVideoPreviewer instance] reset];
    [[DJIVideoPreviewer instance] setEnableHardwareDecode:YES];
    DJIVideoFeed *videoFeed = nil;
    videoFeed = [DJISDKManager videoFeeder].primaryVideoFeed;
    self.previewerAdapter = [VideoPreviewerSDKAdapter adapterWithVideoPreviewer:[DJIVideoPreviewer instance] andVideoFeed:videoFeed];
    [self.previewerAdapter start];
    self.rtmpMuxer = [DJIRtmpMuxer sharedInstance];
    [self.rtmpMuxer setupVideoPreviewer:[DJIVideoPreviewer instance]];
    self.rtmpMuxer.delegate = self;
}

- (void)startLiveStream{
    int retry_time = 3;
    
    DJIRtmpMuxer* muxer = self.rtmpMuxer;
    [muxer setServerURL:self.context.rtmpServerURL];
    [muxer setEnabled:YES];
    [muxer setConvertGDR:YES];
    [muxer start];
    [muxer setRetryCount:retry_time];
    
    //delay 1 second for smooth output
    muxer.smoothDelayTimeSeconds = 1.0;
    [self requestSnapshotImage];
}

- (void)stopLiveStream {
    [self.rtmpMuxer stop];
    [self.rtmpMuxer setEnabled:NO];
}

- (void)rtmpMuxer:(DJIRtmpMuxer *_Nonnull)rtmpMuxer didUpdateStreamState:(DJIRtmpMuxerState)state {
    //JMRTODO:tell UI to update.
    NSLog(@"JMR: Got a muxer status:%lu", (unsigned long)state);
}

- (void)rtmpMuxer:(DJIRtmpMuxer * _Nonnull)rtmpMuxer didUpdateAudioGain:(float)gain {
    NSLog(@"didUpdateAudioGain");
}

-(void) requestSnapshotImage{
    weakSelf(target);
    [[DJIVideoPreviewer instance] snapshotPreview:^(UIImage *snapshot) {
        if (!snapshot) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[DJIVideoPreviewer instance] snapshotPreview:^(UIImage *snapshot) {
                    if (snapshot) {
                        target.snapshot = snapshot;
                    }
                }];
            });
        }
        
        target.snapshot = snapshot;
    }];
}

- (void)startPageNeedsMetadata {
    [self.delegate needsMetadataForStream];
}

@end
