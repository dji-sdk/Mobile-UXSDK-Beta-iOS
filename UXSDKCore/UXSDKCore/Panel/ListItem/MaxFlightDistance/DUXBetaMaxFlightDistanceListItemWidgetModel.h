//
//  DUXBetaMaxFlightDistanceListItemWidgetModel.h
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
#import "DUXBetaListItemEditTextButtonWidget.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DUXBetaMaxFlightDistanceChange) {
    DUXBetaMaxFlightDistanceChangeValid,
    DUXBetaMaxFlightDistanceChangeOutOfMaximumRange,
    DUXBetaMaxFlightDistanceChangeUnableToChangeInBeginnerMode,
    DUXBetaMaxFlightDistanceChangeMaxDistanceEnableFailed,
    DUXBetaMaxFlightDistanceRadiusEnabledChangeSuccessful,
    DUXBetaMaxFlightDistanceRadiusEnabledChangeFailed,
    DUXBetaMaxFlightDistanceChangeUnknownError
};

@class DUXBetaUnitTypeModule;
@interface DUXBetaMaxFlightDistanceListItemWidgetModel : DUXBetaBaseWidgetModel
/**
* Boolean indicating if the aircraft is in Beginner Mode. If so, changing the maximum flight distance is not allowed.
*/
@property (nonatomic, readonly) BOOL                   isNoviceMode;

/**
 * The valid range of values (in meters) for the aircraft to fly within.
 */
@property (nonatomic, strong) DJIParamCapabilityMinMax  *rangeValue;

/**
* The current max distance allowed for the aircraft.
*/
@property (nonatomic, assign) double                    maxFlightDistance;

/**
* Boolean value indicating if the flight radius limit is enabled.
*/
@property (nonatomic, readwrite) BOOL                   isFlightRadiusEnabled;

/**
* The module handling the unit type related logic
*/
@property (nonatomic, strong) DUXBetaUnitTypeModule         *unitModule;

- (void)flightRadiusEnable:(BOOL)enableFlightRadius onCompletion:(void (^ _Nullable) (DUXBetaMaxFlightDistanceChange))resultsBlock;
- (void)updateMaxDistance:(NSUInteger)newMaxDistance onCompletion:(void (^ _Nullable)(DUXBetaMaxFlightDistanceChange))resultsBlock;

@end

NS_ASSUME_NONNULL_END
