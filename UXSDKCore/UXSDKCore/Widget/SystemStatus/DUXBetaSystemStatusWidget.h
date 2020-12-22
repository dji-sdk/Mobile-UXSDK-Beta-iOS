//
//  DUXBetaSystemStatusWidget.h
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
#import "DUXBetaSystemStatusWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaSystemStatusWidget : DUXBetaBaseWidget

/**
 *  The widget data model providing state information to the widget.
 */
@property (nonatomic, strong) DUXBetaSystemStatusWidgetModel *widgetModel;

/**
 *  The font of the pre-flight status message. Default point size = 28, scales with widget.
 */
@property (nonatomic, strong) UIFont *messageFont;

/**
 *  Toggles the Red/Yellow/Green gradient backgrounds from DJI Go.
*/
@property (nonatomic, assign) BOOL isGradientEnabled;

/**
 *  Set the background color of the widget for the warning level.
 *
 *  @param color Set the background to this color...
 *  @param systemStatusWarningLevel ... when the message has this warning level
*/
- (void)setBackgroundColor:(UIColor *)color forSystemStatusWarningLevel:(DJIWarningStatusLevel)systemStatusWarningLevel;

/**
 *  Get the background color of the widget when messages with a certain warning level are displayed.
 *
 *  @param systemStatusWarningLevel Get the background color  when messages of this warning level are displayed
*/
- (UIColor *)backgroundColorForSystemStatusWarningLevel:(DJIWarningStatusLevel)systemStatusWarningLevel;

/**
 *  Set the text color of messages with the warning level.
 *
 *  @param color Set the message text to this color
 *  @param systemStatusWarningLevel Set the text color for this warning level
*/
- (void)setTextColor:(UIColor *)color forSystemStatusWarningLevel:(DJIWarningStatusLevel)systemStatusWarningLevel;

/**
 *  Get the text color of messages with the warning level.
 *
 *  @param systemStatusWarningLevel  Get the text color for this warning level
*/
- (UIColor *)textColorForSystemStatusWarningLevel:(DJIWarningStatusLevel)systemStatusWarningLevel;

@end

NS_ASSUME_NONNULL_END
