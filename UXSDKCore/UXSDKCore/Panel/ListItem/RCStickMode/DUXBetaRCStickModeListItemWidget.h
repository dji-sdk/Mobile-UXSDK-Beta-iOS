//
//  DUXBetaRCStickModeListItemWidget.h
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

#import <UXSDKCore/DUXBetaListItemRadioButtonWidget.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Widget for displaying the RC stick mode in the SystemStatsList. This widget displays and allows the user to change
 * how the control sticks on the RC affect the aircraft from one of the preset values.
 */
@interface DUXBetaRCStickModeListItemWidget :  DUXBetaListItemRadioButtonWidget

@end

/**
 * RCModeItemUIState contains the UI hooks for DUXBetaRCStickModeListItemWidget
 * It inherits from ListItemRadioButtonUIState.
*/
@interface RCStickModeItemUIState : ListItemRadioButtonUIState

@end


/**
 * RCModeItemModelState contains the model hooks for DUXBetaRCStickModeListItemWidgetModel
 * It inherits from ListItemTitleModelState and adds:
 *
 * Key: rcStickModeUpdated      Type: NSNumber - Sends the new stick mode of type DJIRCAircraftMappingStyle as an NSNumber
 *                                               when the mode changes either as the result of user action or aircraft connecting.
 *
 * Key: setRCStickModeSucceded  Type NSNumber - Sends a boolean value when an RC stick mode update has been attemtped
 *                                              successfully.
 *
 * Key: rcStickModeFailed       Type id - Sends the NSError* returend when an attempt to change the RC stick mode fails.
*/
@interface RCStickModeItemModelState : ListItemTitleModelState

+ (instancetype)rcStickModeUpdated:(DJIRCAircraftMappingStyle)newMode;
+ (instancetype)setRCStickModeSucceded;
+ (instancetype)rcStickModeFailed:(NSError *)error;

@end


NS_ASSUME_NONNULL_END
