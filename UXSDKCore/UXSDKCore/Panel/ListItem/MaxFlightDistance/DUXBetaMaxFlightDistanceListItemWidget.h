//
//  DUXBetaMaxFlightDistanceListItemWidgetViewController.h
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

#import "DUXBetaListItemEditTextButtonWidget.h"

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaMaxFlightDistanceListItemWidget : DUXBetaListItemEditTextButtonWidget
/// The string to use as the button title for the Enable button to turn on the max flight distance limitation
@property (nonatomic, strong) NSString *enableButtonTitle;
/// The string to use as the button title for the Disable button to turn of the max flight distance limitation
@property (nonatomic, strong) NSString *disableButtonTitle;
@end

/**
 * MaxFlightDistanceItemModelState contains the hooks for the DUXBetaMaxFlightDistanceListItemModel.
 * It inherits all model hooks in ListItemEditTextModelState and adds:
 *
 * Key: setMaxFlightDistanceSucceeded   Type: NSNumber - A constant number @(YES) indicating the max flight distance was successfully updated.
 *
 * Key: setMaxFlightDistanceFailed      Type: NSError - A NSError indicating the reason the max flight distance failed to update.
 *
 * Key: maxFlightDistanceEnabled        Type: NSNumber - A boolean indicated the new state when the maxFlightDistance has been enabled or disabled.
 *
 * Key: maxFlightDistanceUpdated        Type: NSNumber - The new value for the maxFlightDistance after it has been successfully changed.
*/
@interface MaxFlightDistanceItemModelState : ListItemEditTextButtonModelState
+ (instancetype)setMaxFlightDistanceSucceeded;
+ (instancetype)setMaxFlightDistanceFailed:(NSError*)error;
+ (instancetype)maxFlightDistanceEnabled:(BOOL)isEnabled;
+ (instancetype)maxFlightDistanceUpdated:(NSInteger)maxFlightDistance;
@end


NS_ASSUME_NONNULL_END
