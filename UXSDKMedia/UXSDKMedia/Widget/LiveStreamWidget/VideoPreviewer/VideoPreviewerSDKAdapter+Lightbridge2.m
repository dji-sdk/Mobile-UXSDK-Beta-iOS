//
//  VideoPreviewerSDKAdapter+Lightbridge2.m
//  DJISdkDemo
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

#import "VideoPreviewerSDKAdapter+Lightbridge2.h"
//#import "DJIDemoHelper.h"
#import <DJISDK/DJISDK.h>
#import <DJIWidget/DJIWidget.h>

#define IS_FLOAT_EQUAL(a, b) (fabs(a - b) < 0.0005)

@implementation VideoPreviewerSDKAdapter (Lightbridge2)

-(void)startLightbridgeListen {
    DJIAirLinkKey *extEnabledKey = [DJIAirLinkKey keyWithIndex:0
                                                    subComponent:DJIAirLinkLightbridgeLinkSubComponent
                                                      subComponentIndex:0
                                                      andParam:DJILightbridgeLinkParamEXTVideoInputPortEnabled];
//    WeakRef(target);
//    DJIKeyedValue *extEnabled = [DJIDemoHelper startListeningAndGetValueForChangesOnKey:extEnabledKey
//                                                                           withListener:self
//                                                                         andUpdateBlock:
//                                 ^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
//                                     WeakReturn(target);
//                                     target.isEXTPortEnabled = newValue.value;
//                                     [target updateVideoFeed];
//                                 }];
//    self.isEXTPortEnabled = extEnabled.value;

    DJIAirLinkKey *LBPercentKey = [DJIAirLinkKey keyWithIndex:0
                                                   subComponent:DJIAirLinkLightbridgeLinkSubComponent
                                                     subComponentIndex:0
                                                     andParam:DJILightbridgeLinkParamBandwidthAllocationForLBVideoInputPort];
//    DJIKeyedValue *LBPercent = [DJIDemoHelper startListeningAndGetValueForChangesOnKey:LBPercentKey
//                                                                          withListener:self
//                                                                        andUpdateBlock:
//                                ^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
//                                    WeakReturn(target);
//                                    target.LBEXTPercent = newValue.value;
//                                    [target updateVideoFeed];
//                                }];
//    self.LBEXTPercent = LBPercent.value;

    DJIAirLinkKey *HDMIPercentKey = [DJIAirLinkKey keyWithIndex:0
                                                     subComponent:DJIAirLinkLightbridgeLinkSubComponent
                                                       subComponentIndex:0
                                                       andParam:DJILightbridgeLinkParamBandwidthAllocationForHDMIVideoInputPort];
//    DJIKeyedValue *HDMIPercent = [DJIDemoHelper startListeningAndGetValueForChangesOnKey:HDMIPercentKey
//                                                                            withListener:self
//                                                                          andUpdateBlock:
//                                  ^(DJIKeyedValue * _Nullable oldValue, DJIKeyedValue * _Nullable newValue) {
//                                      WeakReturn(target);
//                                      target.HDMIAVPercent = newValue.value;
//                                      [target updateVideoFeed];
//                                  }];
//    self.HDMIAVPercent = HDMIPercent.value;

    [self updateVideoFeed];
}

-(void)stopLightbridgeListen {
    [[DJISDKManager keyManager] stopAllListeningOfListeners:self];
}

-(void)updateVideoFeed {
    if (self.isEXTPortEnabled == nil) {
        [self swapToPrimaryVideoFeedIfNecessary];
        return;
    }

    if ([self.isEXTPortEnabled boolValue]) {
        if (self.LBEXTPercent == nil) {
            [self swapToPrimaryVideoFeedIfNecessary];
            return;
        }

        if (IS_FLOAT_EQUAL(self.LBEXTPercent.floatValue, 1.0)) {
            // All in primary source
            if (![self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        }
        else if (self.LBEXTPercent.floatValue < 0.95) {
            if ([self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        }
    }
    else {
        if (self.HDMIAVPercent == nil)  {
            [self swapToPrimaryVideoFeedIfNecessary];
            return;
        }
        
        if (IS_FLOAT_EQUAL(self.HDMIAVPercent.floatValue, 1.0)) {
            // All in primary source
            if (![self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        }
        else if (IS_FLOAT_EQUAL(self.HDMIAVPercent.floatValue, 0.0)) {
            if ([self isUsingPrimaryVideoFeed]) {
                [self swapVideoFeed];
            }
            return;
        }
    }
}

-(BOOL)isUsingPrimaryVideoFeed {
    return (self.videoFeed == [DJISDKManager videoFeeder].primaryVideoFeed);
}

-(void)swapVideoFeed {
    [self.videoPreviewer pause];
    [self.videoFeed removeListener:self];
    if ([self isUsingPrimaryVideoFeed]) {
        self.videoFeed = [DJISDKManager videoFeeder].secondaryVideoFeed;
    }
    else {
        self.videoFeed = [DJISDKManager videoFeeder].primaryVideoFeed;
    }
    [self.videoFeed addListener:self withQueue:nil];
    [self.videoPreviewer safeResume];
}

-(void)swapToPrimaryVideoFeedIfNecessary {
    if (![self isUsingPrimaryVideoFeed]) {
        [self swapVideoFeed];
    }
}

@end
