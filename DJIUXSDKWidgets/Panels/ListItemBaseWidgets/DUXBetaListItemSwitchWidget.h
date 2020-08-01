//
//  DUXBetaListItemSwitchWidget.h
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
#import <DJIUXSDKWidgets/DUXBetaBaseWidget.h>

#import "DUXBetaListItemSwitchWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SwitchChangedActionBlock)(BOOL newSwitchValue);

@interface DUXBetaListItemSwitchWidget : DUXBetaListItemTitleWidget
@property (nonatomic, strong) IBOutlet UISwitch *onOffSwitch;

@property (nonatomic, strong) UIColor *switchTintColor;

- (void)setSwitchAction:(SwitchChangedActionBlock)newBlock;
- (void)switchEnabledStateChanged;

@end

#pragma mark - UIState Hooks
/**
 * ListItemSwitchUIState contains the hooks for UI changes in the widget class DUXBetaListItemEditTextButtonWidget.
 * It inherits all UI hooks in ListItemTitleUIState and adds:
 *
 * Key: switchValueChanged  Type: NSNumber - Sends a boolean value as an NSNumber to indicate the new state of the option switch.
 *
 * Key: switchEnabled       Type: NSNumber - Sends a boolean value as an NSNumber to indicate of the option switch is enabled.
*/

@interface ListItemSwitchUIState : ListItemTitleUIState
+ (instancetype)switchValueChanged:(BOOL)isOn;
+ (instancetype)switchEnabled:(BOOL)isEnabled;
@end

NS_ASSUME_NONNULL_END
