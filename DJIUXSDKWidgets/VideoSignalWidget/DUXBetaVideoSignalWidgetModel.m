//
//  DUXBetaVideoSignalWidgetModel.m
//  DJIUXSDK
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

#import "DUXBetaVideoSignalWidgetModel.h"

#import "DUXBetaBaseWidgetModel+Protected.h"
@import DJIUXSDKCore;

@interface DUXBetaVideoSignalWidgetModel ()

//Exposed properties
@property (assign, nonatomic) NSInteger videoSignalStrength;
@property (assign, nonatomic) DUXBetaVideoSignalStrength barsLevel;
@property (assign, nonatomic) DJILightbridgeFrequencyBand lightBridgeFrequencyBand;
@property (assign, nonatomic) DJIOcuSyncFrequencyBand ocuSyncFrequencyBand;
@property (assign, nonatomic) DJIWiFiFrequencyBand wifiFrequencyBand;

//private properties
@property (assign) NSUInteger ocuSyncChannel;
@property (assign, nonatomic) DJIOcuSyncFrequencyBand rawOcuSyncFrequencyBand;
//@property (assign) NSUInteger wifiChannel;    // Might be needed for wifi dual band

@end

@implementation DUXBetaVideoSignalWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.videoSignalStrength = 0;
        self.barsLevel = DUXBetaVideoSignalStrengthLevel0;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIAirLinkKey keyWithIndex:0 andParam:DJIAirLinkParamDownlinkSignalQuality],videoSignalStrength);
    
    BindSDKKey([DJIAirLinkKey keyWithIndex:0
                              subComponent:DJIAirLinkLightbridgeLinkSubComponent
                         subComponentIndex:0
                                  andParam:DJILightbridgeLinkParamFrequencyBand], lightBridgeFrequencyBand);
    
    BindSDKKey([DJIAirLinkKey keyWithIndex:0
                              subComponent:DJIAirLinkOcuSyncLinkSubComponent
                         subComponentIndex:0
                                  andParam:DJIOcuSyncLinkParamFrequencyBand], rawOcuSyncFrequencyBand);
    
    BindSDKKey([DJIAirLinkKey keyWithIndex:0
                              subComponent:DJIAirLinkWiFiLinkSubComponent
                         subComponentIndex:0
                                  andParam:DJIWiFiLinkParamFrequencyBand], wifiFrequencyBand);
    
    BindSDKKey([DJIAirLinkKey keyWithIndex:0
                              subComponent:DJIAirLinkOcuSyncLinkSubComponent
                         subComponentIndex:0
                                  andParam:DJIOcuSyncLinkParamChannelNumber], ocuSyncChannel);
    // Might be needed for wifi dual band
    /*BindSDKKey([DJIAirLinkKey keyWithIndex:0
                              subComponent:DJIAirLinkWiFiLinkSubComponent
                         subComponentIndex:0
                                  andParam:DJIWiFiLinkParamChannelNumber], wifiChannel);*/
    
    BindRKVOModel(self, @selector(videoSignalStrengthChanged),videoSignalStrength);
    BindRKVOModel(self, @selector(ocuSyncBandChanged), rawOcuSyncFrequencyBand, ocuSyncChannel);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)ocuSyncBandChanged {
    if (self.rawOcuSyncFrequencyBand == DJIOcuSyncFrequencyBandDual) {
        if (self.ocuSyncChannel > 5470) {
            self.ocuSyncFrequencyBand = DJIOcuSyncFrequencyBand5Dot8GHz;
        } else if (self.ocuSyncChannel > 2400 && self.ocuSyncChannel < 5470) {
            self.ocuSyncFrequencyBand = DJIOcuSyncFrequencyBand2Dot4GHz;
        } else {
            self.ocuSyncFrequencyBand = DJIOcuSyncFrequencyBandUnknown;
        }
    }
}

- (void)videoSignalStrengthChanged {
    if (self.videoSignalStrength <= 0 && self.barsLevel != DUXBetaVideoSignalStrengthLevel0) {
        self.barsLevel = DUXBetaVideoSignalStrengthLevel0;
    } else if (self.videoSignalStrength > 0 && self.videoSignalStrength < 21 && self.barsLevel != DUXBetaVideoSignalStrengthLevel1) {
        self.barsLevel = DUXBetaVideoSignalStrengthLevel1;
    } else if (self.videoSignalStrength >= 21 && self.videoSignalStrength < 41 && self.barsLevel != DUXBetaVideoSignalStrengthLevel2) {
        self.barsLevel = DUXBetaVideoSignalStrengthLevel2;
    } else if (self.videoSignalStrength >= 41 && self.videoSignalStrength < 61 && self.barsLevel != DUXBetaVideoSignalStrengthLevel3) {
        self.barsLevel = DUXBetaVideoSignalStrengthLevel3;
    } else if (self.videoSignalStrength >= 61 && self.videoSignalStrength < 81 && self.barsLevel != DUXBetaVideoSignalStrengthLevel4) {
        self.barsLevel = DUXBetaVideoSignalStrengthLevel4;
    } else if (self.videoSignalStrength >= 81 && self.barsLevel != DUXBetaVideoSignalStrengthLevel5) {
        self.barsLevel = DUXBetaVideoSignalStrengthLevel5;
    }
}

@end
