//
//  DUXBetaSDCardStatusListItemWidget.h
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

@class DUXBetaAlertViewAppearance;

NS_ASSUME_NONNULL_BEGIN

/**
 * Widget for display in the SystemStatusList which shows the current status/remaining storage on the SD Card in the aircraft
 * and also allows formatting that SD Card.
 *
 * The widget has 3 potential alerts which may show. Each can be configured by setting the appropriate setting
 * properties of the appropriate DUXBetaAlertViewAppearance object below.
 */
@interface DUXBetaSDCardStatusListItemWidget : DUXBetaListItemLabelButtonWidget <DUXBetaListItemModelProducer>

/// AlertViewAppearance properties for alert confirm formatting the SD card
@property (nonatomic, strong) DUXBetaAlertViewAppearance    *sdCardConfirmFormatAlertAppearance;
/// AlertViewAppearance properties for alert when the SD card has been formatted successfully
@property (nonatomic, strong) DUXBetaAlertViewAppearance    *sdCardFormattingSuccessAlertAppearance;
/// AlertViewAppearance properties for alert when there was an error formattng the SD card
@property (nonatomic, strong) DUXBetaAlertViewAppearance    *sdCardFormattingErrorAlertAppearance;

@end

/**
 * SDCardStatusListWidgetModelState contains the model hooks for SDCardStatusListWidgetModelState
 * It inherits from ListItemTitleModelState and adds:
 *
 * Key: sdCardStatusCapacityChanged       Type: NSNumber - Sends the remaining free storage on the aircraft SD card when
 *                                                          the values changes (due to photos or video recording).
 *
 * Key sdCardStateUpdated   Type NSNumber - Sends the DJICameraSDCardOperationState for the SD card
 *                                          when it changes.
*/
@interface SDCardStatusListWidgetModelState : ListItemTitleModelState

+ (instancetype)sdCardStatusCapacityChanged:(NSInteger)freeStorageChanged;
+ (instancetype)sdCardStateUpdated:(NSNumber *)operationState;

@end

/**
 * SDCardStatusListWidgetUIState contains the model hooks for DUXBetaSDCardRemainingCapacityListItemWidget
 * It inherits from ListItemLabelButtonUIState and adds no hooks
*/
@interface SDCardStatusListWidgetUIState : ListItemLabelButtonUIState

@end

NS_ASSUME_NONNULL_END
