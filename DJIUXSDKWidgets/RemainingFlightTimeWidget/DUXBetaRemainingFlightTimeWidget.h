//
//  DUXBetaRemainingFlightTimeWidget.h
//  DJIUXSDK
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidget.h>
@class DUXBetaRemainingFlightTimeWidgetModel;

NS_ASSUME_NONNULL_BEGIN

/**
*  Widget that shows the remaining flight time information for the aircraft.
*/

@interface DUXBetaRemainingFlightTimeWidget : DUXBetaBaseWidget

/**
*  The widget model that the battery widget receives its information from.
*/
@property (nonatomic, strong) DUXBetaRemainingFlightTimeWidgetModel *widgetModel;

/**
*  The font for the remaining flight time text.
*/
@property (nonatomic, strong) UIFont *remainingTimeFont;

/**
*  The background color of the remaining time label.
*/
@property (nonatomic, strong) UIColor *remainingTimeLabelBackgroundColor;

/**
*  The color of the remaining flight time text.
*/
@property (nonatomic, strong) UIColor *remainingTimeLabelTextColor;

/**
*  The color of the remaining battery battery bar (default green).
*/
@property (nonatomic, strong) UIColor *remainingBatteryBarColor;

/**
*  The color of the low battery warning bar (default yellow).
*/
@property (nonatomic, strong) UIColor *lowBatteryWarningBarColor;

/**
*  The color of the seriously low battery warning bar (default red).
*/
@property (nonatomic, strong) UIColor *seriouslyLowBatteryWarningBarColor;

/**
* The tint color of the seriously low battery indicator (default white dot).
*/
@property (nonatomic, strong) UIColor *seriouslyLowBatteryIndicatorColor;

/**
*  The tint color of the low battery indicator (default white dot).
*/
@property (nonatomic, strong) UIColor *lowBatteryIndicatorColor;

/**
*  The tint color of the home indicator icon.
*/
@property (nonatomic, strong) UIColor *homeIndicatorColor;

/**
*  The low battery indicator image.
*/
@property (nonatomic, strong) UIImage *lowBatteryIndicatorImage;

/**
*  The seriously low battery indicator image.
*/
@property (nonatomic, strong) UIImage *seriouslyLowBatteryIndicatorImage;

/**
*   The return home indicator image.
*/
@property (nonatomic, strong) UIImage *homeIndicatorImage;

@end

NS_ASSUME_NONNULL_END
