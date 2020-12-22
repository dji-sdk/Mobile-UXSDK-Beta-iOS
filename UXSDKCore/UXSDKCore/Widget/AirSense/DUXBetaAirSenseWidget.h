//
//  DUXBetaAirSenseWidget.h
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

#import <UXSDKCore/DUXBetaBaseWidget.h>
#import "DUXBetaAirSenseWidgetModel.h"
#import "DUXBetaStateChangeBaseData.h"
#include <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Widget to indicate danger level posed by manned aircraft according to ADSB signals received
*/
@interface DUXBetaAirSenseWidget : DUXBetaBaseWidget

/**
 *  The widget data model controlling AirSense widget.
*/
@property (nonatomic, strong) DUXBetaAirSenseWidgetModel *widgetModel;

/**
 *  The AirSense icon image.
*/
@property (nonatomic, strong) UIImage *airSenseImage;

/**
 *  The AirSense icon when product is disconnected.
*/
@property (nonatomic, strong) UIImage *disconnectedImage;

/**
 *   The AirSense icon background color.
*/
@property (nonatomic, strong) UIColor *iconBackgroundColor;

/**
 *   The dialog title text ("Another aircraft is nearby...").
*/
@property (strong, nonatomic) NSString *dialogTitle;

/**
 * The dialog title text color.
 */
@property (strong, nonatomic) UIColor *dialogTitleTextColor;

/**
 *   The dialog clickable message text ("Please make sure you have read...").
*/
@property (strong, nonatomic) NSString *dialogMessage;

/**
 * The dialog's background color.
 */
@property (strong, nonatomic) UIColor *dialogBackgroundColor;

/**
 *  The image for the checkbox to the left of the "Don't show again" label when checked.
*/
@property (nonatomic, strong) UIImage *checkedCheckboxImage;

/**
 *  Get/set image for the checkbox to the left of the "Don't show again" label when unchecked
*/
@property (nonatomic, strong) UIImage *uncheckedCheckboxImage;

/**
 *  The warning dialog checkbox label("Don't show again") text color.
*/
@property (nonatomic, strong) UIColor *checkboxLabelTextColor;

/**
 *  The warning dialog checkbox label("Don't show again") text font.
*/
@property (nonatomic, strong) UIFont *checkboxLabelTextFont;

/**
 *  The warning dialog message(clickable message: "make sure you have read and understood...") text color.
*/
@property (nonatomic, strong) UIColor *dialogMessageTextColor;

/**
 *  The warning dialog message(clickable message: "make sure you have read and understood...") text font.
*/
@property (nonatomic, strong) UIFont *dialogMessageTextFont;

/**
 *  The property determining if the user has opted to not show the "Another Aircraft is Nearby..." dialog again.
*/
@property (nonatomic) BOOL hasOptedOutDialog;

/**
 *  Set tint color for given warning level.
*/
- (void)setTintColor:(UIColor *)color forWarningState:(DUXBetaAirSenseState)state;

/**
 *  Get tint color for given warning level.
*/
- (UIColor *)getTintColorForWarningState:(DUXBetaAirSenseState)state;

@end

/**
 * AirSenseUIState contains the hooks for UI changes in the widget class DUXBetaAirSenseWidget.
 * The AirSenseUIState can send dialog information for two dialogs, identified as "AirSenseAircraftNearby" or "AirSenseTermsInformation".
 * It implements the hooks:
 *
 * Key: dialogDisplayed         Type: id - Sends a string identifier for a dialog being displayed (usually in response to a
 *                                         button tap or edit value update).
 *
 * Key: dialogActionConfirmed   Type: id - Sends the string identifier for a dialog after the OK/Confirmation btutton was
 *                                         tapped in the displayed dialog.
 *
 * Key: dialogDismissed         Type: id - Sends the string identifier for a dialog after the Cancel/Dismiss button was
 *                                         tapped in the displayed dialog.
 *
 * Key: termsLinkTapped         Type: NSNumber - Sends a boolean YES as an NSNumber when the Terms link is tapped to display the
 *                                               terms dialog for AirSense
 *
 * Key: neverShowAgainCheckChanged Type: NSNumber - Sends a boolean as an NSNumber indicating the state of the Don't Show Again
 *                                                  checkbox for the Terms dialog.
*/
@interface DUXBetaAirSenseUIState : DUXBetaStateChangeBaseData

+ (instancetype)dialogDisplayed:(id)dialogIdentifier;
+ (instancetype)dialogActionConfirmed:(id)dialogIdentifier;
+ (instancetype)dialogDismissed:(id)dialogIdentifier;

+ (instancetype)termsLinkTapped;
+ (instancetype)neverShowAgainCheckChanged:(BOOL)isChecked;

@end

/**
 * AirSenseWidgetModelState contains the hooks for model changes in the AirSenseWidgetModel.
 * It implements the hooks:
 *
 * Key: productConnected    Type: NSNumber - Sends a boolean value as an NSNumber indicating the connected state of
 *                                           the device when it changes
 *
 * Key: airSenseWarningStateUpdate   Type: NSNumber - Sends an NSNumber containing the AirSense warning state as an integer
*/
@interface AirSenseModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;
+ (instancetype)airSenseWarningStateUpdate:(NSNumber *)warningState;

@end

NS_ASSUME_NONNULL_END
