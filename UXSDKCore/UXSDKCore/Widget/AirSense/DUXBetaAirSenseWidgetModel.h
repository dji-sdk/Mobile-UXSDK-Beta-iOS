//
//  DUXBetaAirSenseWidgetModel.h
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

#import "DUXBetaBaseWidgetModel.h"

typedef enum : NSUInteger {
    DUXBetaAirSenseState_Disconnected,
    DUXBetaAirSenseState_NoAirplanesNearby,
    DUXBetaAirSenseState_Level0,
    DUXBetaAirSenseState_Level1,
    DUXBetaAirSenseState_Level2,
    DUXBetaAirSenseState_Level3,
    DUXBetaAirSenseState_Level4,
    DUXBetaAirSenseState_Unknown
} DUXBetaAirSenseState;

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaAirSenseWidgetModel : DUXBetaBaseWidgetModel

/**
 *  The current ADS-B warning level of the aircraft
 */
@property (assign, nonatomic, readonly) BOOL isAirSenseConnected;
@property (assign, nonatomic, readonly) NSUInteger airSenseWarningLevel;
@property (assign, nonatomic, readonly) DUXBetaAirSenseState airSenseWarningState;

@end

NS_ASSUME_NONNULL_END
