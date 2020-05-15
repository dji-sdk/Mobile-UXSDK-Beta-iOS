//
//  DUXBetaAirSenseWidgetUIState.h
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

#import <DJIUXSDKCore/DJIUXSDKCore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * DUXAirSenseWidgetUIState contains the hooks for UI changes in the widget class AirSenseWidget.
 * It implements the hooks:
 *
 * Key: warningDialogDismiss    Type: NSNumber - Sends a boolean YES as an NSNumber when the AirSense warning dialog is dismissed
 *
 * Key: termLinkTap             Type: NSNumber - Sends a boolean YES as an NSNumber when the Terms link is tapped to display the
 *                                               terms dialog for AirSense
 *
 * Key: termsDialogDismiss      Type: NSNumber - Sends a boolean YES as an NSNumber when the Terms dialog for AirSense is dismissed
 *
 * Key: dontShowAgainCheckboxTapped Type: NSNumber - Sends a boolean as an NSNumber indicating the state of the Don't Show Again
 *                                                   checkbox for the Terms dialog.
*/
@interface DUXBetaAirSenseWidgetUIState : DUXStateChangeBaseData

+ (instancetype)warningDialogDismiss;
+ (instancetype)termsLinkTap;
+ (instancetype)termsDialogDismiss;
+ (instancetype)dontShowAgainCheckBoxTap:(BOOL)isChecked;

@end

NS_ASSUME_NONNULL_END
