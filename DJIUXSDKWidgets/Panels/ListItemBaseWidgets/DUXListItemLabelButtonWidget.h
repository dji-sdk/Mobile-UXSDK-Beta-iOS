//
//  DUXListItemLabelButtonWidget.h
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

#import <DJIUXSDKWidgets/DUXListItemTitleWidget.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @enum DUXListItemLabelWidgetType
 * @brief DUXListItemLabelWidgetType is used to define the layout and elements of the DUXListItemLabelButtonWidget.
 *
 * @field DUXListItemLabelOnly - A label for information at the trailing edge of the widget.
 * @field DUXListItemButtonOnly - An action button at the trailing edge of the widget.
 * @field DUXListITemLabelAndButton - A label for information at the trailing edge of the widget and an action button centered in the widget.
 */
typedef NS_ENUM(NSInteger, DUXListItemLabelWidgetType) {
    DUXListItemLabelOnly,
    DUXListItemButtonOnly,
    DUXListItemLabelAndButton
};

/**
* @protocol: All subclasses of DUXListItemLabelButtonWidget must conform to this protocol!
*
* Preferred method is to create a DUXBaseWidgetModel property called widgetModel.
*/
@protocol DUXListItemModelProducer

- (DUXBetaBaseWidgetModel *)widgetModel;

@end

/**
 * @class: DUXListItemLabelButtonWidget is a list item widget descending from DUXListItemTitleWidget. It supports three
 * visual layouts, defined by DUXListItemLabelWidgetType enum.
 *
 * DUXListItemLabelOnly - A label for information at the trailing edge of the widget.
 * DUXListItemButtonOnly - An action button at the trailing edge of the widget.
 * DUXListITemLabelAndButton - A label for information at the trailing edge of the widget and an action button centered in the widget.
 *
 * The action button uses an executable block to perform an action when the button is pressed.
 */
@interface DUXListItemLabelButtonWidget : DUXListItemTitleWidget
/// Flag indicating of the button is currently enabled
@property (nonatomic, readwrite) BOOL buttonEnabled;
/// The button which is used in the widget if the layout supplies a button
@property (nonatomic, strong, readonly) UIButton    *actionButton;
/// The UILabel used to display the text field if the layout supplies a text field
@property (nonatomic, strong, readonly) UILabel     *displayTextLabel;
/// The font of the label
@property (nonatomic, strong) UIFont *labelFont;
/// The color of the label text in a normal state
@property (nonatomic, strong) UIColor *labelTextColorNormal;
/// The color of the label text in a disconnected state
@property (nonatomic, strong) UIColor *labelTextColorDisconnected;

/**
 * @brief This init method for the class is used to define which layout is desired for the widget
 * @param widgetStyle The DUXListItemLabelWidgetType to use for selecting the layout
 * @return a DUXListItemLabelButtonWidget instance
 */
- (instancetype)init:(DUXListItemLabelWidgetType)widgetStyle;

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

 /**
  * ListItemLabelButtonModelState contains the hooks for model for descendents of this base class.
  * It inherits all model hooks in ListItemTitleModelState and adds no hooks.
*/
@interface ListItemLabelButtonModelState : ListItemTitleModelState

@end

/**
 * ListItemLabelButtonUIState contains common hooks for UI changes in the list item base class DUXListItemLabelButtonWidget.
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
+ (instancetype)enabledButtonStateChanged:(BOOL)newState;
+ (instancetype)displayStringUpdated:(NSString *)newValue;

@end

NS_ASSUME_NONNULL_END
