//
//  DUXBetaGenericLabelBaseWidget.h
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
#ifndef _H_DUXBetaGenericLabelBaseWidget
#define _H_DUXBetaGenericLabelBaseWidget

#import <UXSDKCore/DUXBetaBaseWidget.h>
#import <UXSDKCore/DUXBetaBaseWidgetModel.h>
#import <UXSDKCore/DUXBetaPanelWidgetSupport.h>
#import <UXSDKCore/DUXBetaStateChangeBroadcaster.h>

NS_ASSUME_NONNULL_BEGIN

// Define this here for the list items which need it. This may be moved once the full base class hierarchy is refactored
// for ListItemButtonWiget and ListItemLabelButtonWidget
@class DUXBetaListItemButtonWidget;
typedef void (^GenericButtonActionBlock)(id senderWidget);

/**
 * @class: DUXBetaListItemTitleWidget is the base class for list item widgets most often found in DUXBetaListPanelWidget lists.
 * These base widgets support a single icon and title. It also supports the customizations for colors and fonts for all the
 * descendent widgets.
 *
 * The icon is assumed to be a template compatible icon which can be colorized by tinting.
 *
 * Concrete final classes will need to implement their own property model.
*/
@interface DUXBetaListItemTitleWidget : DUXBetaBaseWidget <DUXBetaListPanelSupportProtocol>
/// The font/size to use for the title
@property (nonatomic, strong) UIFont *titleFont;
/// The color to draw the title with
@property (nonatomic, strong) UIColor *titleColor;
/// The tint color used to colorizing the icon
@property (nonatomic, strong) UIColor *iconTintColor;
/// The background color for the widget
@property (nonatomic, strong) UIColor *backgroundColor;
/// The icon to be drawn on the left side of the widget
@property (nonatomic, strong) UIImage *iconImage;
// The color to draw the widget value area with when disconnected
@property (nonatomic, strong) UIColor *disconnectedValueColor;
// The color to draw the widget value area with when in the normal connected state
@property (nonatomic, strong) UIColor *normalValueColor;
// The color to draw the widget value area with when a warning condition is displayed
@property (nonatomic, strong) UIColor *warningValueColor;
// The color to draw the widget value area with when an error or danger conditon is displayed
@property (nonatomic, strong) UIColor *errorValueColor;

/**
 * The following customizations do not directly apply to the base widget, but are relevant to sub-classed widgets
 */
/// The font/size to draw the button label for sub-classes with buttons
@property (nonatomic, strong) UIFont *buttonFont;
/// The width of the button border for sub-classes with buttons
@property (nonatomic, assign) float buttonBorderWidth;
/// The curvature radius for the border put on the butttons or controls for sub-classes with controls
@property (nonatomic, assign) float buttonCornerRadius;
/// A dictionary of colors to use for button states. Keys are NSNumber versions of states like @(UIControlStateNormal)
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, UIColor*> *buttonColors;
/// A dictionary of colors to use for button content area backgrounds. Absent values remove background color
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, UIColor*> *buttonBackgroundColors;
/// A dictionary of colors to use for button borders. Keys are NSNumber versions of states like @(UIControlStateNormal)
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, UIColor*> *buttonBorderColors;
/// The UILabel used to display the title for the widget
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

/**
 * Exposed UILayoutGuides which can be used or adjusted by subclasses for cleaner layout.
 * trailingTitleGuide is aligned to the trailing edge of the UILabel used for the title. It will shift to accomodate the
 * length of the title
 *
 * trailingMarginGuide is used to find the trailing edge of the display cell area. This is used to inset the drawing area if
 * an accessory has been displayed
 *
 * trailingMarginConstraint is the constraint anchoring the trailingTitleGuide to the titleLabel tailingAnchor. Adjusting it
 * will allow for post-label spacing to be set.
 */
@property (nonatomic, strong) IBOutlet UILayoutGuide *trailingTitleGuide;
@property (nonatomic, strong) IBOutlet UILayoutGuide *trailingMarginGuide;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *trailingMarginConstraint;

/// The minimum size this widget should be set to
@property (nonatomic) CGSize minWidgetSize;


- (instancetype)init;

/**
 * @brief Use initWithTitle to create this widget with a title and icon name to be loaded from the main bundle. The
 * iconName may be nil to prevent an icon from showing
 *
 * @param title The title string to use
 * @param iconName The icon name to use from the bundle
 *
 * @return instancetype
 */
- (instancetype)initWithTitle:(NSString*)title andIconName:(NSString* _Nullable)iconName;

/**
* @brief Use setTitle:andIconName: to set the title and icon name to be loaded from the main bundle. The
* iconName may be nil to prevent an icon from showing.
*
* @param titleString The title string to use
* @param iconName The icon name to use from the bundle
*
* @return instancetype
*/
- (instancetype)setTitle:(NSString*)titleString andIconName:(NSString* _Nullable)iconName;

/**
 * @brief The method setupCustomizableSettings is called by the init methods of this class. It sets the default
 * customizations used for drawing. Override this method to customize colors in sub-classes.
 *
 */
- (void)setupCustomizableSettings;

/**
 * @brief The method setupUI is called to instantiate the UI objects for this widget. Subclasses must call [super setupUI]
 * when their setupUI is called.
 */
- (void)setupUI;    // When a child class of this creates the UI, it needs to call this method in this superclass.
/**
 * @brief The updateUI method is used to update user interface elements for this base class. Subclasses must call [super updateUI]
 * when their updateUI is called.
 */
- (void)updateUI;

/**
 * @brief Method normalColor returns the color to use for normal status items.
 * @returns UIColor* to use for drawing items in a normal state.
 */
- (UIColor *)normalColor;

/**
 * @brief Method disabledColor returns the color to use for disabled or non-connected status items.
 * @returns UIColor* to use for drawing items in a disabled state.
 */
- (UIColor *)disabledColor;

/**
 * @brief Method warningColor returns the color to use for status items in a warning state.
 * @returns UIColor* to use for drawing items with a warning status.
 */
- (UIColor *)warningColor;

/**
 * @brief Method buttonBorderNormalColor returns the color to use for drawing a widget button when in a normal state.
 * @returns UIColor* to use for drawing a button border in a normal state.
 */
- (UIColor *)buttonBorderNormalColor;

/**
 * @brief Method buttonBorderDisabledColor returns the color to use for drawing a widget button when it is in a disabled state.
 * @returns UIColor* to use for drawing a button border in a disabled state.
 */
- (UIColor *)buttonBorderDisabledColor;

/**
 * @brief Method buttonBorderSelectedColor returns the color to use for drawing a widget button when it is in a selected state.
 * @returns UIColor* to use for drawing a button border in a selected state.
 */
- (UIColor *)buttonBorderSelectedColor;

/**
 * @brief Override forceAspectRatio if the subclass needs to be presented in a hard aspect ratio instead of being able to
 * expand and contract horizontally.
 * @returns BOOL indicating if a forced aspect ration is required.
 */
- (BOOL)forceAspectRatio;

/**
 * @brief Method setButtonColor:forUIControlState: sets the color for drawing any subclass button for the given controlState.
 * It manages updating the button colors dictionary.
 */
- (void)setButtonColor:(UIColor *)buttonColor forUIControlState:(UIControlState)controlState;

/**
 * @brief Method getButtonColorForUIControlState retrieves the color for drawing any subclass button for the given controlState.
 * @return UIColor* to use for drawing with the given UIControlState
 */
- (UIColor *)getButtonColorForUIControlState:(UIControlState)controlState;

/**
 * @brief Method setButtonBorderColor:forUIControlState: sets the color for drawing any subclass button border for the given
 *  controlState. It manages updating the border colors dictionary.
 */
- (void)setButtonBorderColor:(UIColor *)buttonColor forUIControlState:(UIControlState)controlState;

/**
 * @brief Method getButtonBorderColorForUIControlState retrieves the color for drawing the border of any subclass button
 * for the given controlState.
 * @return UIColor* to use for drawing with the given UIControlState
*/
- (UIColor *)getButtonBorderColorForUIControlState:(UIControlState)controlState;

/**
 * @brief Method setButtonBackgroundColor:forUIControlState: sets the color for drawing any subclass button fill color for the given
 *  controlState. It manages updating the background colors dictionary.
 */
- (void)setButtonBackgroundColor:(UIColor *)buttonBackgroundColor forUIControlState:(UIControlState)controlState;

/**
 * @brief Method getButtonBackgroundColorForUIControlState retrieves the color used to fill the background of any subclass button
 * for the given controlState.
 * @return UIColor* to use for filling the button background with the given UIControlState
 */
- (UIColor *)getButtonBackgroundColorForUIControlState:(UIControlState)controlState;

@end

#pragma mark - Hooks
/**
 * ListItemTitleUIState is the base class for all UI hooks descended from DUXBetaListenItemTitleWidget.
 * It inherits from DUXBetaStateChangeBaseData which is the root hook data class and impements common UIHooks which may
 * be used by and of the UI subclases for ListItems
 *
 * Key: dialogDisplayed         Type: id - Sends a string identifier for a dialog being displayed (usually in response to a
 *                                         button tap or edit value update).
 *
 * Key: dialogActionConfirmed   Type: id - Sends the string identifier for a dialog after the OK/Confirmation btutton was
 *                                         tapped in the displayed dialog.
 *
 * Key: dialogActionCanceled    Type: id - Sends the string identifier for a dialog after the Cancel btutton was
 *                                         tapped in the displayed dialog.
 *
 * Key: dialogDismissed         Type: id - Sends the string identifier for a dialog after the Cancel/Dismiss button was
 *                                         tapped in the displayed dialog.
*/
@interface ListItemTitleUIState : DUXBetaStateChangeBaseData

+ (instancetype)dialogDisplayed:(id)info;
+ (instancetype)dialogActionConfirmed:(id)info;
+ (instancetype)dialogActionCanceled:(id)info;
+ (instancetype)dialogDismissed:(id)info;

@end

/**
 * ListItemTitleModelState contains the hooks for the widget models for classes desceneded from the ListItemTitleModelState
 * It inherits from DUXBetaStateChangeBaseData which is the root hook data class.
 *
 * Key: productConnected    Type: NSNumber -  Sends a boolean value as an NSNumber when the product connection state changes.
                                    Boolean indicates if product is connected.
*/
@interface ListItemTitleModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END

#endif
