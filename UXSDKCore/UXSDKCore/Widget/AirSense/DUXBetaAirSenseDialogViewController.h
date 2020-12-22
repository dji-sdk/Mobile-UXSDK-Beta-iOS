//
//  DUXBetaAirSenseDialogViewController.h
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

#import <UIKit/UIKit.h>

@class DUXBetaDialogCustomizations;
@class DUXBetaAirSenseWidget;

NS_ASSUME_NONNULL_BEGIN

/**
 * Enum defining the possible action states for the DUXBetaAirSenseDialog
 */
typedef NS_ENUM(NSInteger, DUXBetaAirSenseDialogState) {
    DUXBetaAirSenseDialogStateShown,
    DUXBetaAirSenseDialogStateConfirmed,
    DUXBetaAirSenseDialogStateDismissed
};

typedef void(^DUXBetaAirSenseDialogPhaseCallback)(DUXBetaAirSenseDialogState state);
typedef void(^DUXBetaAirSenseDialogToggleCheckboxCallback)(BOOL isChecked);
typedef void(^DUXBetaAirSensePresentTermsDialogPhaseCallback)(DUXBetaAirSenseDialogState state);

@interface DUXBetaAirSenseDialogViewController : UIViewController

/**
 *   The dialog title text ("Another aircraft is nearby...").
*/
@property (strong, nonatomic) NSString *dialogTitle;

/**
 *   The dialog title color.
*/
@property (strong, nonatomic) UIColor *dialogTitleTextColor;

/**
 *   The dialog clickable message text ("Please make sure you have read...").
*/
@property (strong, nonatomic) NSString *dialogMessage;

/**
 *  The image for the checkbox to the left of the "Don't show again" label when checked.
*/
@property (strong, nonatomic) UIImage *checkedCheckboxImage;

/**
 *  The image for the checkbox to the left of the "Don't show again" label when empty.
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
@property (nonatomic, strong) UIColor *warningMessageTextColor;

/**
 *  The warning dialog message(clickable message: "make sure you have read and understood...") text font.
*/
@property (nonatomic, strong) UIFont *warningMessageTextFont;

/**
 *  The widget that presented this dialog. Used to pass back the dontShowAgainCheckBoxTap data.
*/
@property (nonatomic, weak) DUXBetaAirSenseWidget *presentingWidget;

/**
 *  Callback to allow the DUXBetaAirSenseWidget to monitor the state of the dialog and send UI hooks for the dialog.
 */
@property (nonatomic, strong) DUXBetaAirSenseDialogPhaseCallback dialogPhaseCallback;

/**
 *  Callback to allow the DUXBetaAirSenseWidget to monitor the state of the "Don't Show Again" checkbox and send the appropriate hook.
 */
@property (nonatomic, strong) DUXBetaAirSenseDialogToggleCheckboxCallback neverShowAgainToggleCallback;

/**
 *  Callback to allow the DUXBetaAirSenseWidget to monitor the state of the Terms dialog and send UI Hooks for the dialog.
 */
@property (nonatomic, strong) DUXBetaAirSensePresentTermsDialogPhaseCallback presentingTermsPhaseCallback;

/**
 *  Construct with title and message.
*/
- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
