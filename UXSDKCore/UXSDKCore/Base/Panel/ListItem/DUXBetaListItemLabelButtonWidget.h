//
//  DUXBetaListItemLabelButtonWidget.h
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

#import "DUXBetaListItemTitleWidget.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @enum DUXBetaListItemLabelWidgetType
 * @brief DUXBetaListItemLabelWidgetType is used to define the layout and elements of the DUXBetaListItemLabelButtonWidget.
 *
 * @field DUXBetaListItemLabelOnly - A label for information at the trailing edge of the widget.
 * @field DUXBetaListItemButtonOnly - An action button at the trailing edge of the widget.
 * @field DUXBetaListITemLabelAndButton - A label for information at the trailing edge of the widget and an action button centered in the widget.
 */
typedef NS_ENUM(NSInteger, DUXBetaListItemLabelWidgetType) {
    DUXBetaListItemLabelOnly,
    DUXBetaListItemButtonOnly,
    DUXBetaListItemLabelAndButton
};

/**
* @protocol: All subclasses of DUXBetaListItemLabelButtonWidget must conform to this protocol!
*
* Preferred method is to create a DUXBetaBaseWidgetModel property called widgetModel.
*/
@protocol DUXBetaListItemModelProducer

- (DUXBetaBaseWidgetModel *)widgetModel;

@end

/**
 * @class: DUXBetaListItemLabelButtonWidget is a list item widget descending from DUXBetaListItemTitleWidget. It supports three
 * visual layouts, defined by DUXBetaListItemLabelWidgetType enum.
 *
 * DUXBetaListItemLabelOnly - A label for information at the trailing edge of the widget.
 * DUXBetaListItemButtonOnly - An action button at the trailing edge of the widget.
 * DUXBetaListITemLabelAndButton - A label for information at the trailing edge of the widget and an action button centered in the widget.
 *
 * The action button uses an executable block to perform an action when the button is pressed.
 */
@interface DUXBetaListItemLabelButtonWidget : DUXBetaListItemTitleWidget
/// Flag indicating of the button is currently enabled
@property (nonatomic, readwrite) BOOL buttonEnabled;
/// The button which is used in the widget if the layout supplies a button
@property (nonatomic, strong, readonly) UIButton    *actionButton;
/// The UILabel used to display the text field if the layout supplies a text field
@property (nonatomic, strong, readonly) UILabel     *displayTextLabel;
/// The font of the label
@property (nonatomic, strong) UIFont *labelFont;

/**
 * @brief This init method for the class is used to define which layout is desired for the widget
 * @param widgetStyle The DUXBetaListItemLabelWidgetType to use for selecting the layout
 * @return a DUXBetaListItemLabelButtonWidget instance
 */
- (instancetype)init:(DUXBetaListItemLabelWidgetType)widgetStyle;

/**
 * @brief The setButtonTitle method sets the title of the optional action button if available based on the layout settings.
 * @param newButtonTitle The string to use for the button title.
 */
- (void)setButtonTitle:(NSString *)newButtonTitle;
/**
 * @brief The setLabelText method sets the text of the optional label if available based on the layout settings.
 * @param labelText The string to use for the text label.
*/
- (void)setLabelText:(NSString *)labelText;

/**
 * @brief The displayLabelColor method sets the color to be used for the label. The default implementation returns either
 * labelTextColorNormal or labelTextColorDisconnect. If other label colors are required for certain states, override this
 * method and return the appropriate color.
 * @return The color to use for the label text of the item.
*/
- (UIColor *)displayLabelColor;

/**
 * @brief The updateLabelDisplay method can be called to update the font and color display properties of the label if they have been adjusted
 * without changing any of the display properties of this class.
*/
- (void)updateLabelDisplay;

/**
 * @brief The updateButton method can be called to update the font and color display properties of the button if they have been adjusted
 * or the state of the button has been changed without changing any of the display properties of this class.
 */
- (void)updateButton;

/**
 * @brief Use setButtonAction to install the executable block which will be called when the optional action button is pressed.
 * @param action A block of type GenericButtonActionBlock which will be executed on button press.
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
  * ListItemLabelButtonModelState contains the hooks for model for descendents of this base class.
  * It inherits all model hooks in ListItemTitleModelState and adds no hooks.
*/
@interface ListItemLabelButtonModelState : ListItemTitleModelState

@end

/**
 * ListItemLabelButtonUIState contains common hooks for UI changes in the list item base class DUXBetaListItemLabelButtonWidget.
 * It inherits all UI hooks in ListItemTitleUIState and adds:
 *
 * Key: buttonTapped                Type: NSNumber - Always sends YES as an NSNumber when the actionButton is tapped
 *
 * Key: enabledButtonStateChanged   Type: NSNumber - Sends a boolean as an NSNumber whenever the enabled state of the
 *                                                   actionButton changes. YES indicates enabled, NO indicates disabled.
 *
 * Key: displayStringUpdated        Type: NSString - Sends the new display string with the label in the widget is updated.
*/
@interface ListItemLabelButtonUIState : ListItemTitleUIState

+ (instancetype)buttonTapped;

@end

NS_ASSUME_NONNULL_END
