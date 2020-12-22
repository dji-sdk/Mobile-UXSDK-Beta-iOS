//
//  DUXBetaListItemRadioButtonWidget.h
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

#import <UXSDKCore/DUXBetaListItemTitleWidget.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^RadioButtonOptionChanged)(NSInteger oldSelectedIndex, NSInteger newSelectedIndex);

/**
 * @class DUXBetaListItemRadioButtonWidget implements a list item with a radio button option (UISegmentedControl).
 * The radio button will call an action block when the selection changes. The radio buttons are also color customizable
 * and supports the same appearance under iOS 12, and iOS 13+.
 * When subclassing this widget, implement a custom RadioButtonOptionChanged and install it, then use the setOptionTitles or
 * addOptionToGroup methods to set the radio title.
 *
 * Subclasses will also need to implement a model class to process the changes to the radio options.
 */
@interface DUXBetaListItemRadioButtonWidget : DUXBetaListItemTitleWidget

/// The current value of the radio button selection (0...N)
@property (nonatomic, readwrite) NSInteger selection;

/// The color of the text to use for the selected item in the radio control. Non-selected text uses the normal customization color
@property (nonatomic, strong) UIColor *selectedRadioTextColor;

/**
 * @brief Use the method setOptionTitles to replace all existing options with the strings from the passed in array.
 * @param newTitles An array of NSStrings to use as titles for the radio groups.
 */
- (void)setOptionTitles:(NSArray<NSString *> *)newTitles;

/**
 * @brief The method addOptionToGroup will append a new option to the displayed options already in the control.
 * @param optionName The new option name to add.
 */
- (NSInteger)addOptionToGroup:(NSString*)optionName;

/**
 * @brief Use removeOptionFromGroup to remove an option from the radio group displayed.
 * @param optionIndex The index of the item to remove, in the range 0...N
 */
- (void)removeOptionFromGroup:(NSInteger)optionIndex;

/**
 * @brief Replace the displayed option string at the specified index with a new option string.
 * @param optionName The new name to put in the radio group.
 * @paran optionIndex The index to put the new name at in the radio group.
 * @return TRUE for successful replacement or FALSE for an error, such as optionIndex out of range.
 */
- (BOOL)setOption:(NSString *)optionName atIndex:(NSInteger)optionIndex;

/**
* @brief Retrieve the displayed option string at the specified index.
* @paran optionIndex The index to get the name from in the radio group.
* @return NSString containing the radio option name or nil.
*/
- (NSString *)optionTitleAtIndex:(NSInteger)optionIndex;

/**
 * @brief The method count returns the number of options currently in the radio group.
 * @return The number of options in the radio group.
 */
- (NSInteger)count;
/**
 * @brief Call setEnabled to either enable or disable the radio control.
 * @paran isEnabled should the control be enabled or not.
 */
- (void)setEnabled:(BOOL)isEnabled;

/**
 * @brief The method setEnabled:atOptionIndex: allows for enabling or disabling individual segments of the UISegmentControl
 * being used to display the radio group. Disabling an option prevents it from being selected.
 * @param isEnabled Flag to enable or disable the given option.
 * @param optionIndex The index to enable or disable.
 */
- (void)setEnabled:(BOOL)isEnabled atOptionIndex:(NSInteger)optionIndex;

/**
 * @brief Use setOptionSelectedAction to install the RadioButtonOptionChanged action block which will be called when the selected
 * radio option is changed. The action block will receive two parameters, the old selected index and the new selected index.
 * @param actionBlock The new action block to install.
 */
- (void)setOptionSelectedAction:(RadioButtonOptionChanged)actionBlock;

/**
 * @brief The method setTextColor:forState: sets the color for the option text for the designated state, allowing for disabled
 * or selected options to show a different color from non-selected or enabled options.
 * @param textColor The UIColor* to use for the designated state text color.
 * @param state The UIControlState the textColor will be applied to.
 */
- (void)setTextColor:(UIColor *)textColor forState:(UIControlState)state;

/**
 * @brief Use setTabsBackgroundColor to change the background color for the tabs in the UISegmentedController. This color
 * applies to all segments.
 * @param color The UIColor* to use for tab backgrounds.
 * @note iOS 13.0 and newer only.
 */
- (void)setTabsBackgroundColor:(UIColor *)color;     // Only functional for iOS 13.0 and newer

@end

#pragma mark - Hooks
/**
 * ListItemRadioButtonModelState is an empty hook class because this base class doesn't send any UI updates.
 * Inherit from this class for subclassing to include all parent model hooks.
 * It inherits all model hooks in ListItemTitleModelState.
*/
@interface ListItemRadioButtonModelState : ListItemTitleModelState
@end

/**
 * ListItemRadioButtonUIState is which implments the added hooks for DUXBetaListItemRadioButtonWidget.
 * It inherits all UI hooks in ListItemTitleUIState and adds:
 * Key: optionSelected
 *      Param optionValue:  Type: NSInteger containing the index of the segment controller selected.
 *      Param optionLabel:  Type: NSString with the label for the selected segment for the segment controller.
 *      NOTE:               Delivers an NSDictionary object containing the keys "optionValue" and "optionLabel".
*/
@interface ListItemRadioButtonUIState : ListItemTitleUIState
+ (instancetype)optionSelected:(NSInteger)optionValue label:(NSString*)optionLabel;

@end

NS_ASSUME_NONNULL_END
