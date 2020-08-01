//
//  DUXBetaFlightModeListItemWidgetModel.h
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

#import <DJIUXSDKWidgets/DJIUXSDKWidgets.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class DUXBetaFlightModeListItemWidgetModel is a subclass of DUXBetaBaseWidgetModel used to implement the model
 * for the DUXBetaFlightModeListItemWigetModel.
 * It exposes a single property for the flight mode string.
 */
 @interface DUXBetaFlightModeListItemWidgetModel : DUXBetaBaseWidgetModel
/// The string for the name of the current flight mode
@property (nonatomic, strong, readonly) NSString *flightModeString;

@end

/**
 * FlightModeListItemModelState contains the hooks for model changes in the widget class
 * DUXBetaFlightModeListItemWidgetModel.
 * It inherits all model hooks in ListItemLabelButtonModelState and adds:
 *
 * Key: flightModeUpdated    Type: NSString - The new flight mode string when flight mode changes.
*/
@interface FlightModeListItemModelState : ListItemLabelButtonModelState

+ (instancetype)flightModeUpdated:(NSString*)newMode;

@end

NS_ASSUME_NONNULL_END
