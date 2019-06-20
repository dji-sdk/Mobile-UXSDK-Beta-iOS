//
//  UIColor+DUXBetaColors.h
//  DJIUXSDK
//
//  MIT License
//  
//  Copyright © 2018-2019 DJI
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

+ (UIColor *)duxbeta_whiteColor;
+ (UIColor *)duxbeta_blackColor;
+ (UIColor *)duxbeta_grayColor;
+ (UIColor *)duxbeta_lightGrayColor;
+ (UIColor *)duxbeta_darkGrayColor;

// Remaining Flight Time Widget Colors
+ (UIColor *)duxbeta_remainingFlightTimeWidgetRemainingBatteryColor;
+ (UIColor *)duxbeta_remainingFlightTimeWidgetLowBatteryColor;
+ (UIColor *)duxbeta_remainingFlightTimeWidgetSeriouslyLowBatteryColor;

// Manual Focus Widget Colors
+ (UIColor *)duxbeta_manualFocusWidgetBackgroundColor;
+ (UIColor *)duxbeta_manualFocusWidgetButtonBackgroundColor;

//Histogram Widget Colors
+ (UIColor *)duxbeta_histogramWidgetBackgroundColor;
+ (UIColor *)duxbeta_histogramWidgetLineColor;
+ (UIColor *)duxbeta_histogramWidgetFillColor;
+ (UIColor *)duxbeta_histogramWidgetGridColor;

//Preflight Widget Colors
+ (UIColor *)duxbeta_preflightStatusWidgetGreenColor;
+ (UIColor *)duxbeta_preflightStatusWidgetYellowColor;
+ (UIColor *)duxbeta_preflightStatusWidgetRedColor;
+ (UIColor *)duxbeta_preflightStatusWidgetGrayColor;

//Compass Widget Colors
+ (UIColor *)duxbeta_compassWidgetBackgroundColor;
+ (UIColor *)duxbeta_compassWidgetBorderColor;
+ (UIColor *)duxbeta_compassWidgetStrokeColor;
+ (UIColor *)duxbeta_compassWidgetHorizonColor;

//Auto Exposure Switch Widget Colors
+ (UIColor *)duxbeta_autoExposureSwitchWidgetWhiteColor;

@end

NS_ASSUME_NONNULL_END
