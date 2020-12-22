//
//  UIColor+DUXColors.h
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

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (DUXColors)

+ (UIColor *)dux_successColor;
+ (UIColor *)dux_errorColor;
+ (UIColor *)dux_warningColor;
+ (UIColor *)dux_dangerColor;

+ (UIColor *)dux_selectedColor;

+ (UIColor *)dux_clearColor;
+ (UIColor *)dux_whiteColor;
+ (UIColor *)dux_whiteColor60Alpha;
+ (UIColor *)dux_blackColor;
+ (UIColor *)dux_blackColor50Alpha;
+ (UIColor *)dux_grayColor;
+ (UIColor *)dux_redColor;
+ (UIColor *)dux_lightGrayColor;
+ (UIColor *)dux_darkGrayColor;
+ (UIColor *)dux_yellowColor;
+ (UIColor *)dux_backgroundColor;
+ (UIColor *)dux_disabledGrayColor;
+ (UIColor *)dux_blueColor;
+ (UIColor *)dux_linkBlueColor;
+ (UIColor *)dux_lightGrayTransparentColor;

// Remaining Flight Time Widget Colors
+ (UIColor *)dux_remainingFlightTimeWidgetRemainingBatteryColor;
+ (UIColor *)dux_remainingFlightTimeWidgetLowBatteryColor;
+ (UIColor *)dux_remainingFlightTimeWidgetSeriouslyLowBatteryColor;

// Manual Focus Widget Colors
+ (UIColor *)dux_manualFocusWidgetButtonBackgroundColor;

// Histogram Widget Colors
+ (UIColor *)dux_histogramWidgetBackgroundColor;
+ (UIColor *)dux_histogramWidgetLineColor;
+ (UIColor *)dux_histogramWidgetFillColor;
+ (UIColor *)dux_histogramWidgetGridColor;

// System Status Widget Colors
+ (UIColor *)dux_systemStatusWidgetGreenColor;
+ (UIColor *)dux_systemStatusWidgetRedColor;

// Compass Widget Colors
+ (UIColor *)dux_compassWidgetBackgroundColor;
+ (UIColor *)dux_compassWidgetBorderColor;
+ (UIColor *)dux_compassWidgetStrokeColor;
+ (UIColor *)dux_compassWidgetHorizonColor;

// Auto Exposure Switch Widget Colors
+ (UIColor *)dux_autoExposureSwitchWidgetWhiteColor;

// Battery Widget Colors
+ (UIColor *)dux_batteryNormalGreen;

// RTK Satellite Status Widget Colors
+ (UIColor *)dux_rtkOverallStatusGreen;
+ (UIColor *)dux_rtkOverallStatusYellow;
+ (UIColor *)dux_rtkOverallStatusRed;
+ (UIColor *)dux_rtkTableBorderColor;

// AirSense Widget Colors
+ (UIColor *)dux_airSenseYellowColor;

// Simulator Indicator Widget Color
+ (UIColor *)dux_simulatorIndicatorWidgetGreenColor;

// FPV camera name & side background color
+ (UIColor *)dux_fpvGrayColor;
+ (UIColor *)dux_fpvBackgroundColor;
+ (UIColor *)dux_fpvGridLineColor;
+ (UIColor *)dux_fpvGridLineShadowColor;
+ (UIColor *)dux_fpvTextBackgroundColor;
+ (UIColor *)dux_fpvCenterPointYellowColor;
+ (UIColor *)dux_fpvCenterPointRedColor;
+ (UIColor *)dux_fpvCenterPointBlueColor;
+ (UIColor *)dux_fpvCenterPointGreenColor;

// ListPanel Default Colors
+ (UIColor *)dux_listPanelBackgroundColor;
+ (UIColor *)dux_listPanelSeparatorColor;

// AlertView Mask Background Color
+ (UIColor *)dux_alertViewMaskColor;

// TakeOff and ReturnHome Dialog Colors
+ (UIColor *)dux_alertBackgroundColor;
+ (UIColor *)dux_alertActionBlueColor;
+ (UIColor *)dux_slideTextColor;
+ (UIColor *)dux_slideIconSelectedColor;
+ (UIColor *)dux_slideSeparatorColor;
+ (UIColor *)dux_alertWarningColor;

@end

NS_ASSUME_NONNULL_END
