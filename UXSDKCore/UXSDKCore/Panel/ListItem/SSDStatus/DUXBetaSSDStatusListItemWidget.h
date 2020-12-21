//
//  DUXBetaSSDStatusListItemWidget.h
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2020 DJI
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

#import <UXSDKCore/UXSDKCore.h>

@class DUXBetaAlertViewAppearance;

NS_ASSUME_NONNULL_BEGIN

/**
 * Widget for display in the SystemStatusList which shows the current status/remaining storage on the SSD in the aircraft
 * and also allows formatting that SSD Card.
 *
 * The widget has 3 potential alerts which may show. Each can be configured by setting the appropriate setting
 * properties of the appropriate DUXBetaAlertViewAppearance object below.
 */
@interface DUXBetaSSDStatusListItemWidget : DUXBetaListItemLabelButtonWidget

/// AlertViewAppearance properties for alert confirm formatting the SD card
@property (nonatomic, strong) DUXBetaAlertViewAppearance    *ssdConfirmFormatAlertAppearance;
/// AlertViewAppearance properties for alert when the SD card has been formatted successfully
@property (nonatomic, strong) DUXBetaAlertViewAppearance    *ssdFormattingSuccessAlertAppearance;
/// AlertViewAppearance properties for alert when there was an error formattng the SD card
@property (nonatomic, strong) DUXBetaAlertViewAppearance    *ssdFormattingErrorAlertAppearance;


@end

/**
 * SSDStatusItemModelState contains the model hooks for DUXBetaSSDStatusListItemWidgetModel
 * It inherits from ListItemTitleModelState and adds:
 *
 * Key: ssdStatusCapacityChanged       Type: NSNumber - Sends the remaining free storage on the aircraft SSD when
 *                                                      the values changes (due to photos or video recording).
 *
 * Key ssdStateUpdated                 Type NSNumber - Sends the DJICameraSSDOperationState for the SD card
 *                                                     when it changes.
 */
@interface SSDStatusItemModelState : ListItemTitleModelState

+ (instancetype)ssdStatusCapacityChanged:(NSInteger)freeStorageChanged;
+ (instancetype)ssdStateUpdated:(NSNumber *)operationState;

@end

/**
 * SSDStatusItemUIState contains the model hooks for DUXBetaSSDStatusListItemWidget
 * It inherits from ListItemLabelButtonUIState and adds no hooks
 */
@interface SSDStatusItemUIState : ListItemLabelButtonUIState

@end

NS_ASSUME_NONNULL_END
