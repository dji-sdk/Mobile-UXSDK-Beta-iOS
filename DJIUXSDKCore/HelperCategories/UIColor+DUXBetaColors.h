//
//  UIColor+DUXBetaColors.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (DUXBetaColors)

+ (UIColor *)duxbeta_successColor;
+ (UIColor *)duxbeta_warningColor;
+ (UIColor *)duxbeta_dangerColor;

+ (UIColor *)duxbeta_selectedColor;

+ (UIColor *)duxbeta_clearColor;
+ (UIColor *)duxbeta_whiteColor;
+ (UIColor *)duxbeta_blackColor;
+ (UIColor *)duxbeta_grayColor;
+ (UIColor *)duxbeta_redColor;
+ (UIColor *)duxbeta_lightGrayColor;
+ (UIColor *)duxbeta_darkGrayColor;
+ (UIColor *)duxbeta_yellowColor;
+ (UIColor *)duxbeta_backgroundColor;
+ (UIColor *)duxbeta_disabledGrayColor;
+ (UIColor *)duxbeta_blueColor;
+ (UIColor *)duxbeta_linkBlueColor;
+ (UIColor *)duxbeta_lightGrayTransparentColor;

// Remaining Flight Time Widget Colors
+ (UIColor *)duxbeta_remainingFlightTimeWidgetRemainingBatteryColor;
+ (UIColor *)duxbeta_remainingFlightTimeWidgetLowBatteryColor;
+ (UIColor *)duxbeta_remainingFlightTimeWidgetSeriouslyLowBatteryColor;

// Manual Focus Widget Colors
+ (UIColor *)duxbeta_manualFocusWidgetButtonBackgroundColor;

// Histogram Widget Colors
+ (UIColor *)duxbeta_histogramWidgetBackgroundColor;
+ (UIColor *)duxbeta_histogramWidgetLineColor;
+ (UIColor *)duxbeta_histogramWidgetFillColor;
+ (UIColor *)duxbeta_histogramWidgetGridColor;

// System Status Widget Colors
+ (UIColor *)duxbeta_systemStatusWidgetGreenColor;
+ (UIColor *)duxbeta_systemStatusWidgetRedColor;

// Compass Widget Colors
+ (UIColor *)duxbeta_compassWidgetBackgroundColor;
+ (UIColor *)duxbeta_compassWidgetBorderColor;
+ (UIColor *)duxbeta_compassWidgetStrokeColor;
+ (UIColor *)duxbeta_compassWidgetHorizonColor;

// Auto Exposure Switch Widget Colors
+ (UIColor *)duxbeta_autoExposureSwitchWidgetWhiteColor;

// Battery Widget Colors
+ (UIColor *)duxbeta_batteryNormalGreen;

// RTK Satellite Status Widget Colors
+ (UIColor *)duxbeta_rtkOverallStatusGreen;
+ (UIColor *)duxbeta_rtkOverallStatusYellow;
+ (UIColor *)duxbeta_rtkOverallStatusRed;
+ (UIColor *)duxbeta_rtkTableBorderColor;

// AirSense Widget Colors
+ (UIColor *)duxbeta_airSenseYellowColor;

// Simulator Indicator Widget Color
+ (UIColor *)duxbeta_simulatorIndicatorWidgetGreenColor;

// FPV camera name & side background color
+ (UIColor *)duxbeta_fpvBackgroundColor;
+ (UIColor *)duxbeta_fpvGridLineColor;
+ (UIColor *)duxbeta_fpvGridLineShadowColor;
+ (UIColor *)duxbeta_fpvTextBackgroundColor;
+ (UIColor *)duxbeta_fpvCenterPointYellowColor;
+ (UIColor *)duxbeta_fpvCenterPointRedColor;
+ (UIColor *)duxbeta_fpvCenterPointBlueColor;
+ (UIColor *)duxbeta_fpvCenterPointGreenColor;

// ListPanel Default Colors
+ (UIColor *)duxbeta_listPanelBackgroundColor;
+ (UIColor *)duxbeta_listPanelSeparatorColor;

// AlertView Mask Background Color
+ (UIColor *)duxbeta_alertViewMaskColor;

// TakeOff and ReturnHome Dialog Colors
+ (UIColor *)duxbeta_alertBackgroundColor;
+ (UIColor *)duxbeta_alertActionBlueColor;
+ (UIColor *)duxbeta_slideTextColor;
+ (UIColor *)duxbeta_slideIconSelectedColor;
+ (UIColor *)duxbeta_slideSeparatorColor;
+ (UIColor *)duxbeta_alertWarningColor;

@end

NS_ASSUME_NONNULL_END
