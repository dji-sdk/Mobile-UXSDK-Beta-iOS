//
//  DUXBetaListItemEditTextButtonWidget.h
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

#import <DJIUXSDKWidgets/DUXBetaListItemTitleWidget.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief DUXBetaTextInputChangeBlock is an executable block prototype for a block which will be called when the text in this widget's
 * text edit field changes.
 * @param newText The updated text from the editText field
 */
typedef void(^DUXBetaTextInputChangeBlock)(NSString *newText);

/**
* @brief DUXBetaKeyBoardChangedState is an executable block prototype for a block which will be called when iOS keyboard changes
* state (is shown or hidden).
* @param isActive If the keyboard is now visible.
*/
typedef void(^DUXBetaKeyBoardChangedState)(BOOL isActive);

/**
* @enum DUXBetaListItemLabelWidgetType
* @brief DUXBetaListItemLabelWidgetType is used to define the layout and elements of the DUXBetaListItemEditTextButtonWidget.
*
* @field DUXBetaListItemOnlyEdit - An edit field with a hint label at the trailing edge of the widget.
* @field DUXBetaListItemEditAndButton - An action button centered and an edit field and hint label at the trailing edge of the widget.
*/
typedef NS_ENUM(NSInteger, DUXBetaListItemEditTextButtonWidgetType) {
    DUXBetaListItemOnlyEdit,
    DUXBetaListItemEditAndButton
};

/**
 * @class DUXBetaListItemEditTextButtonWidget is a list item widget which supplies an edit text field at the trailing edge of
 * the widget, with a hint field to the left of the edit field. It allows an optional action button centered in the widget.
 * The options for creating the widget are:
 *
 * DUXBetaListItemOnlyEdit - An edit field with a hint label at the trailing edge of the widget.
 * DUXBetaListItemEditAndButton - An action button centered and an edit field and hint label at the trailing edge of the widget.
 */
@interface DUXBetaListItemEditTextButtonWidget : DUXBetaListItemTitleWidget
/// Flag indicating if the edit field is enabled for editing
@property (nonatomic, readwrite) BOOL       enableEditField;    // This should also be tied to isProductConnected in the attached model
/// The actual text editing field
@property (nonatomic, strong) UITextField   *inputField;        // Subclasses will need to have access to this field. Do not enable/disable directly
/// The desired width of the text editing field
@property (nonatomic, readwrite) CGFloat    editFieldWidth;

/// Any hint text to be shown next to the text editing field
@property (nonatomic, strong) NSString      *hintText;
/// Flag indicating if the action button is enabled.
@property (nonatomic, readwrite) BOOL       buttonEnabled;
/// Flag indicating if the button should be moved to the edge if the text editing field is hidden
@property (nonatomic, readwrite) BOOL       dynamicButtonAdjustment;

/// Executable code block which will be called when the keyboard appears or disappears on screen
@property (nonatomic, strong) DUXBetaKeyBoardChangedState   keyboardChangedStatusBlock;

/// The color to be used for the text in the edit text field when enabled
@property (nonatomic, strong) UIColor   *editTextColor;
/// The color to be used for the text in the edit text field when enabled and entry is valid
@property (nonatomic, strong) UIColor   *editTextValidColor;
/// The color to be used for the text in the edit text field when enabled and entry is invalid
@property (nonatomic, strong) UIColor   *editTextInvalidColor;

/// The border color for the edit text field when enabled
@property (nonatomic, strong) UIColor   *editTextBorderColor;
/// The text color for the edit text field contents when editing is disabled
@property (nonatomic, strong) UIColor   *editTextDisabledColor;
/// The font/size to use or the edit text field
@property (nonatomic, strong) UIFont    *editTextFont;
/// The corner radius for the edit text field border
@property (nonatomic, assign) float     editTextCornerRadius;
/// The width of the edit text field border
@property (nonatomic, assign) float     editTextBorderWidth;

/// The background color for the hint text area
@property (nonatomic, strong) UIColor   *hintBackgroundColor;
/// The color for drawing the hint text
@property (nonatomic, strong) UIColor   *hintTextColor;
/// The font/size of the hint text
@property (nonatomic, strong) UIFont    *hintTextFont;

/**
* @brief This init method for the class is used to define which layout is desired for the widget
* @param widgetStyle The DUXBetaListItemEditTextButtonWidgetType to use for selecting the layout
* @return a DUXBetaListItemEditTextButtonWidget instance
*/
- (instancetype)init:(DUXBetaListItemEditTextButtonWidgetType)widgetStyle;

/**
* @brief The setButtonTitle method sets the title of the optional action button if available based on the layout settings.
* @param newButtonTitle The string to use for the button title.
*/
- (void)setButtonTitle:(NSString*)newButtonTitle;

/**
* @brief The setButtonHidden method hides or shows the action button.
* @param isHidden A boolean indicating if the button should be hidden.
*/
- (void)setButtonHidden:(BOOL)isHidden;

/**
* @brief The hideInputAndHint method hides/shows both the input edit text field and the hint label. It also disables the edit text field.
* @param doHide The boolean indicating if hiding is YES or NO.
*/
- (void)hideInputAndHint:(BOOL)doHide;

/**
* @brief The hideInputField method hides/shows and enables/disables only input edit text field.
* @param doHide The boolean indicating if hiding is YES or NO.
*/
- (void)hideInputField:(BOOL)doHide;

/**
* @brief The hideHintLabel method hides/shows the hint label.
* @param doHide The boolean indicating if hiding is YES or NO.
*/
- (void)hideHintLabel:(BOOL)doHide;

/**
 * @brief The setEditText method sets the text in the edit text field.
 * @param editFieldText The string to put into the edit text field.
*/
- (void)setEditText:(NSString*)editFieldText;

/**
 * @brief The setHintText method replaces any current hint text with the new hint text next to the edit text field.
 * @param hintText The new hint text string.
 */
- (void)setHintText:(NSString*)hintText;

/**
 * @brief The setEditFieldWidthHint method sets the desired width for the edit text field in points. The value set here is used
 *  when initially creating the widget.
 * @param editWidthHint A CGFloat specifying the width for the edit text field.
 */
- (void)setEditFieldWidthHint:(CGFloat)editWidthHint;

/**
 * @brief The setEditFieldWidth method attempts to set the edit field to the desired width.
 * @param editWidth The width to change the edit text filed to.
 */
- (void)setEditFieldWidth:(CGFloat)editWidth;

/**
 * @brief The setEditFieldValueMin:maxValue: method sets a minimum and maximum value for the integer value of the text field.
 * @param minValue The minimum integer value for the edit text field to accept
 * @paran maxValue The maximum integet value for the edit text field to accept
 */
- (void)setEditFieldValuesMin:(NSInteger)minValue maxValue:(NSInteger)maxValue;

/**
 * @brief Call setTextChangedBlock to install a custom executable block which will be called when the edit text field changes.
 * The executable block takes a single parameter, an NSString with the new edit text field value.
 * @param newBlock The next executable block to call when the text field changes.
 */
- (void)setTextChangedBlock:(DUXBetaTextInputChangeBlock)newBlock;

/**
 * @brief Call setButtonAction to install a new action button code block that is executed when the action button is pressed.
 * @param action The executable block to install for the action button
 * @return Returns intancetype to allow chaining of calls during setup.
 */
- (instancetype)setButtonAction:(GenericButtonActionBlock)action;
/**
 * @brief Use getButtonAction to retrieve the executable block which will be called when the optional action button is pressed.
 * This allows for saving and restoring of actions when a button function changes based on external factors.
 * @return An executable block of type GenericButtonActionBlock which will be executed on button press.
*/
- (GenericButtonActionBlock)getButtonAction;

@end

#pragma mark - Hooks

/**
 * ListItemEditTextUIState contains the hooks for UI changes in the widget class DUXBetaListItemEditTextButtonWidget.
 * It inherits all UI hooks in ListItemTitleUIState and adds:
 *
 * Key: editBeginsUpdate    Type: NSNumber - Always sends YES as an NSNumber.
 *
 * Key: editEndsUpdate      Type: NSNumber - Always sends YES as an NSNumber.
 *
 * Key: buttonTapped        Type: NSNumber - Always sends YES as an NSNumber
 *
 * Key: buttonStateChanged  Type: NSNumber - Sent when the widget button changes enabled state. Sends YES for button
 *                                           enabled, NO for disabled.
*/
@interface ListItemEditTextUIState : ListItemTitleUIState

+ (instancetype)editBeginsUpdate;
+ (instancetype)editEndsUpdate;
+ (instancetype)buttonTapped;
+ (instancetype)buttonStateChanged:(BOOL)newState;

@end

// This class is intentionally empty to allow hierarchical building of the hooks back to top class
/**
 * ListItemEditTextModelState is an empty hook class because this base class does not contrain a model.
 * Inherit from this class for subclassing to include all parent model hooks.
 * It inherits all UI hooks in ListItemTitleModelState.
*/
@interface ListItemEditTextModelState : ListItemTitleModelState

@end

NS_ASSUME_NONNULL_END
