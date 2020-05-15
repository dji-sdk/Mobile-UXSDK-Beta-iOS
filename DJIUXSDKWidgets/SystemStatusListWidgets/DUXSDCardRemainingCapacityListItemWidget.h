//
//  DUXSDCardRemainingCapacityListItemWidget.h
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

#import <DJIUXSDKWidgets/DJIUXSDKWidgets.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Widget for display in the SystemStatusList which shows the current status/remaining storage on the SD Card in the aircraft
 * and also allows formatting that SD Card.
 */
@interface DUXSDCardRemainingCapacityListItemWidget : DUXListItemLabelButtonWidget <DUXListItemModelProducer>

@end

/**
 * SDCardRemainingCapacityListWidgetModelState contains the model hooks for DUXSDCardRemainingCapacityListItemWidgetModel
 * It inherits from ListItemTitleModelState and adds:
 *
 * Key: sdCardRemainingCapacityChanged       Type: NSNumber - Sends the remaining free storage on the aircraft SD card when
 *                                                            the values changes (due to photos or video recording).
 *
 * Key sdCardRemainingCapacityCardInserted   Type NSNumber - Sends a boolean value as an NSInteger when an SD card is
 *                                                  inserted or removed. YES indicates insertion, NO indicates removal.
 *                                                  Beware of crows removing SD cards mid-flight
 *
 * Key sdCardRemainingCapacityOperatingStatusChanged   Type NSNumber - Sends the DJICameraSDCardOperationState for the SD card
 *                                                                     when it changes.
*/
@interface SDCardRemainingCapacityListWidgetModelState : ListItemTitleModelState

+ (instancetype)sdCardRemainingCapacityChanged:(NSInteger)freeStorageChanged;
+ (instancetype)sdCardRemainingCapacityCardInserted:(BOOL)cardInserted;
+ (instancetype)sdCardRemainingCapacityOperatingStatusChanged:(NSNumber *)operationState;

@end

/**
 * SDCardRemainingCapacityListWidgetUIState contains the model hooks for DUXSDCardRemainingCapacityListItemWidget
 * It inherits from ListItemLabelButtonUIState and adds no hooks
*/
@interface SDCardRemainingCapacityListWidgetUIState : ListItemLabelButtonUIState

@end

NS_ASSUME_NONNULL_END
