//
//  DUXMaxAltitudeListItemWidget.h
//  DJIUXSDKWidgets
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

#import <DJIUXSDKWidgets/DUXListItemEditTextButtonWidget.h>
#import "DUXMaxAltitudeListItemWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN
/**
* Widget for display in the SystemStatusList which shows the current max altitude setting for the aircraft
* and also allows editing the height within the limits shown in the hint text.
*/
@interface DUXMaxAltitudeListItemWidget : DUXListItemEditTextButtonWidget

@end

/**
 * MaxAltitudeListItemUIState contains the hooks for the MaxAltitude list widget UI.
 * It inherits all UI hooks in ListItemEditTextUIState and adds:
 *
 * Key: invalidHeightRejected    Type: NSNumber - The entered height in meters which was rejected during validation in the max altitude model.
 *
 * Key: validHeightEntered       Type: NSNumber - The entered maximum altitude after being validated by the max altitude model.
 */
@interface MaxAltitudeListItemUIState : ListItemEditTextUIState

+ (instancetype)invalidHeightRejected:(NSInteger)invalidHeightInMeters;
+ (instancetype)validHeightEntered:(NSInteger)invalidHeightInMeters;

@end

NS_ASSUME_NONNULL_END
