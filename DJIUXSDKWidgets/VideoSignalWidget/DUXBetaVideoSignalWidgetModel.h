//
//  DUXBetaVideoSignalWidgetModel.h
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidgetModel.h>

typedef NS_ENUM(NSUInteger, DUXBetaVideoSignalStrength) {
    DUXBetaVideoSignalStrengthLevel0,
    DUXBetaVideoSignalStrengthLevel1,
    DUXBetaVideoSignalStrengthLevel2,
    DUXBetaVideoSignalStrengthLevel3,
    DUXBetaVideoSignalStrengthLevel4,
    DUXBetaVideoSignalStrengthLevel5,
};

typedef NS_ENUM(NSUInteger, DUXBetaAirLinkType) {
    DUXBetaAirLinkTypeLightbridge,
    DUXBetaAirLinkTypeOcuSync,
    DUXBetaAirLinkTypeWiFi,
    DUXBetaAirLinkTypeUnknown
};

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaVideoSignalWidgetModel : DUXBetaBaseWidgetModel

@property (assign, nonatomic, readonly) NSInteger videoSignalStrength;
@property (assign, nonatomic, readonly) DUXBetaVideoSignalStrength barsLevel;
@property (assign, nonatomic, readonly) DJILightbridgeFrequencyBand lightBridgeFrequencyBand;
@property (assign, nonatomic, readonly) DJIOcuSyncFrequencyBand ocuSyncFrequencyBand;
@property (assign, nonatomic, readonly) DJIWiFiFrequencyBand wifiFrequencyBand;

@end

NS_ASSUME_NONNULL_END
