//
//  DUXBetaMaxAltitudeListItemWidgetModel.h
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidgetModel.h>
#import <DJIUXSDKWidgets/DUXBetaListItemEditTextButtonWidget.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DUXBetaMaxAltitudeChange) {
    DUXBetaMaxAltitudeChangeMaxAltitudeValid,
    DUXBetaMaxAltitudeChangeAboveWarningHeightLimit,
    DUXBetaMaxAltitudeChangeAboveReturnHomeMaxAltitude,
    DUXBetaMaxAltitudeChangeBelowMininimumAltitude,
    DUXBetaMaxAltitudeChangeAboveMaximumAltitude,
    DUXBetaMaxAltitudeChangeAboveWarningHeightLimitAndBelowReturnHomeAltitude,
    DUXBetaMaxAltitudeChangeBelowReturnHomeAltitude,
    DUXBetaMaxAltitudeChangeUnableToChangeMaxAltitudeInBeginnerMode,
    DUXBetaMaxAltitudeChangeUnableToChangeReturnHomeAltitude,
    DUXBetaMaxAltitudeChangeUnknownError
};

/**
 *  Model for the SystemStatusList widget to show and edit the max alitiude for the aircraft.
*/
@interface DUXBetaMaxAltitudeListItemWidgetModel : DUXBetaBaseWidgetModel
/**
 * Boolean indicating if the aircraft is in Beginner Mode. If so, changing the maximum altitude is not allowed.
 */
@property (assign, nonatomic, readonly) BOOL            isNoviceMode;

/**
 * The valid range of values (in meters) for the aircraft to fly within.
 */
@property (nonatomic, strong) DJIParamCapabilityMinMax  *rangeValue;

/**
* The current max altitude allowed for the aircraft.
*/
@property (nonatomic, assign) double                    maxAltitude;

/**
 * Method used to check the new maximum altitude and return an enum indicating the suitability of the new max altitude.
 */
- (DUXBetaMaxAltitudeChange)validateNewHeight:(NSInteger)newHeight;

/**
 * Method called to acutally change the max altitude of the aircraft. The completion block is called after setting with a result value indicating if the
 * change succeeded or if there was an error condition.
 */
- (void)updateMaxHeight:(NSInteger)newHeight onCompletion:(void (^)(DUXBetaMaxAltitudeChange))resultsBlock;

@end

/**
* MaxAltitudeListItemModelState contains the hooks for the DUXBetaMaxAltitudeListItemWidgetModel.
* It inherits all model hooks in ListItemEditTextModelState and adds:
*
* Key: maxAltitudeChanged    Type: NSNumber - The new value for maximum altitude when the user changes the altitude or when the drone connects and updats values.
*/
@interface MaxAltitudeListItemModelState : ListItemEditTextModelState
+ (instancetype)maxAltitudeChanged:(NSInteger)maxAltitude;
@end

NS_ASSUME_NONNULL_END
