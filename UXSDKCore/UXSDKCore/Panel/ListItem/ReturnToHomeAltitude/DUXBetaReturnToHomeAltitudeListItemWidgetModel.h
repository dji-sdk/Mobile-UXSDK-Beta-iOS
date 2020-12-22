//
//  DUXBetaReturnToHomeAltitudeListItemWidgetModel.h
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

/**
 * The DUXBetaReturnToHomeAltitudeChange defines the possible states related to validating and changing the ReturnToHomeAltitude
 */
typedef NS_ENUM(NSInteger, DUXBetaReturnToHomeAltitudeChange) {
    /**
     * The new altitude value is valid and/or is accepted by the aircraft during a change
     */
    DUXBetaReturnToHomeAltitudeChangeValid,
    
    /**
     * The new altitude is above the maximum height allowed by the FAA (400 feet, 122 meters)
     */
    DUXBetaReturnToHomeAltitudeChangeAboveWarningHeightLimit,
    
    /**
     * The new altitude is above the maximum height allowed by the aircraft
     */
    DUXBetaReturnToHomeAltitudeChangeAboveMaximumAltitude,
    
    /**
     * The new altitude is above the below the minimum height allowed by the aircraft
     */
    DUXBetaReturnToHomeAltitudeChangeBelowMininimumAltitude,
    
    /**
     * The aricraft is in beginner/novice mode and the RTH altitude may not be changed.
     */
    DUXBetaReturnToHomeAltitudeChangeUnableToChangeInBeginnerMode,
    
    /**
     * The RTH altitude was unable to be changed for an unknown reason. (Did aircraft disconnect?)
     */
    DUXBetaReturnToHomeAltitudeChangeUnknownError
};


@class DUXBetaUnitTypeModule;
/**
 *  Model for the SystemStatusList widget to show and edit the return to home alitiude for the aircraft.
*/
@interface DUXBetaReturnToHomeAltitudeListItemWidgetModel : DUXBetaBaseWidgetModel
/**
* Boolean indicating if the aircraft is in Beginner Mode. If so, changing the maximum altitude is not allowed.
*/
@property (nonatomic, readonly) BOOL                   isNoviceMode;

/**
 * The valid range of values (in meters) for the aircraft to fly within.
 */
@property (nonatomic, strong) DJIParamCapabilityMinMax  *rangeValue;

/**
 * The current maximum altitude (in meters) for the aircraft to fly within.
*/
@property (nonatomic, readonly) double                    maxAltitude;

/**
* The current altitude setting for Return-To-Home flight.
*/
@property (nonatomic, assign) double                    returnToHomeAltitude;

/**
* The module handling the unit type related logic
*/
@property (nonatomic, strong) DUXBetaUnitTypeModule         *unitModule;

/**
* Method used to check the new return to home altitude and return an enum indicating the suitability of the new return to home altitude.
*/
- (DUXBetaReturnToHomeAltitudeChange)validateNewHeight:(NSInteger)newHeight;
/**
 * Method called to acutally change the return to home altitude of the aircraft. The completion block is called after setting with a
 * result value indicating if the change succeeded or if there was an error condition.
*/
- (void)updateReturnHomeHeight:(NSInteger)newHeight onCompletion:(void (^)(DUXBetaReturnToHomeAltitudeChange))resultsBlock;

@end

NS_ASSUME_NONNULL_END
