//
//  DUXBetaReturnToHomeAltitudeListItemWidget.h
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

@class DUXBetaAlertViewApperance;

NS_ASSUME_NONNULL_BEGIN

/**
 * Widget for display in the SystemStatusList which shows the current return to home altitude setting for the aircraft
 * and also allows editing the height within the limits shown in the hint text.
 *
 * The widget has 2 potential alerts which may show. Each can be configured by setting the appropriate setting
 * properties of the appropriate DUXBetaAlertViewAppearance object below.
*/
@interface DUXBetaReturnToHomeAltitudeListItemWidget : DUXBetaListItemEditTextButtonWidget
/// AlertViewAppearance properties for alert after successfully changing the Return-To-Home Altitude
@property (nonatomic, strong) DUXBetaAlertViewAppearance    *rthAltitudeChangeAlertAppearance;
/// AlertViewAppearance properties for alert after attempting to set Return-To-Home altitude above the max altitude setting.
@property (nonatomic, strong) DUXBetaAlertViewAppearance    *rthAltitudeExceedsMaxAltitudeAlertAppearance;
@end

/**
 * ReturnToHomeAltitudeListItemUIState contains the hooks for the MaxAltitude list widget UI.
 * It inherits all UI hooks in ListItemEditTextUIState and adds:
 *
 * Key: invalidHeightRejected    Type: NSNumber - The entered height in meters which was rejected during validation in the return to home altitude model.
 *
 * Key: validHeightEntered       Type: NSNumber - The entered maximum altitude after being validated by the return to home altitude model.
 */
@interface ReturnToHomeAltitudeListItemUIState : ListItemEditTextUIState

+ (instancetype)invalidHeightRejected:(NSInteger)invalidHeightInMeters;
+ (instancetype)validHeightEntered:(NSInteger)validHeightInMeters;

@end

NS_ASSUME_NONNULL_END
