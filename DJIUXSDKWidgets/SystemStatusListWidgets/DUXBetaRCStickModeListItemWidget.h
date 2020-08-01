//
//  DUXBetaRCStickModeListItemWidget.h
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

#import <DJIUXSDKWidgets/DUXBetaListItemRadioButtonWidget.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Widget for displaying the RC stick mode in the SystemStatsList. This widget displays and allows the user to change
 * how the control sticks on the RC affect the aircraft from one of the preset values.
 */
@interface DUXBetaRCStickModeListItemWidget :  DUXBetaListItemRadioButtonWidget // DUXBetaListItemRadioButtonWidget DUXBetaListItemEditTextButtonWidget

@end

/**
 * RCModeListItemUIState contains the UI hooks for DUXBetaRCStickModeListItemWidget
 * It inherits from ListItemRadioButtonUIState and adds:
 *
 * Key: rcModeControlChange    Type: NSNumber - Sends the integer value for the RC stick mode when the user selects a new RC stick mode.
*/
@interface RCModeListItemUIState : ListItemRadioButtonUIState
+ (instancetype)rcModeControlChange:(NSInteger)newValue;
@end

NS_ASSUME_NONNULL_END
