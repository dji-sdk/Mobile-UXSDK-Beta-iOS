//
//  UIColor+DUXBetaColors.m
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

#import "UIColor+DUXBetaColors.h"

#define RGBA(_r_, _g_, _b_, _a_) [UIColor colorWithRed:_r_/255.0 green:_g_/255.0 blue:_b_/255.0 alpha:_a_]

@implementation UIColor (DUXBetaColors)

+ (UIColor *)duxbeta_successColor {
    return RGBA(10.0, 238.0, 139.0, 1.0);
}

+ (UIColor *)duxbeta_warningColor {
    return RGBA(255.0, 204.0, 0.0, 1.0);
}

+ (UIColor *)duxbeta_dangerColor {
    return RGBA(231.0, 1.0, 2.0, 1.0);
}

+ (UIColor *)duxbeta_selectedColor {
    return RGBA(31.0, 163.0, 246.0, 1.0);
}

+ (UIColor *)duxbeta_whiteColor {
    return [UIColor whiteColor];
}

+ (UIColor *)duxbeta_blackColor {
    return [UIColor blackColor];
}

+ (UIColor *)duxbeta_grayColor {
    return [UIColor grayColor];
}

+ (UIColor *)duxbeta_lightGrayColor {
    return [UIColor lightGrayColor];
}

+ (UIColor *)duxbeta_darkGrayColor {
    return [UIColor darkGrayColor];
}

+ (UIColor *)duxbeta_remainingFlightTimeWidgetRemainingBatteryColor {
    return RGBA(73.0, 214.0, 99.0, 1.0);
}

+ (UIColor *)duxbeta_remainingFlightTimeWidgetLowBatteryColor {
    return RGBA(238.0, 195.0, 0.0, 1.0);
}

+ (UIColor *)duxbeta_remainingFlightTimeWidgetSeriouslyLowBatteryColor {
    return RGBA(238.0, 43.0, 42.0, 1.0);
}

+ (UIColor *)duxbeta_manualFocusWidgetBackgroundColor {
    return RGBA(0.0, 0.0, 0.0, 0.6);
}

+ (UIColor *)duxbeta_manualFocusWidgetButtonBackgroundColor {
    return RGBA(0.0, 0.0, 0.0, 0.2);
}

+ (UIColor *)duxbeta_histogramWidgetBackgroundColor {
    return RGBA(0.0, 0.0, 0.0, 0.47);
}

+ (UIColor *)duxbeta_histogramWidgetLineColor {
    return RGBA(255.0, 255.0, 255.0, 0.2);
}

+ (UIColor *)duxbeta_histogramWidgetFillColor {
    return RGBA(255.0, 255.0, 255.0, 0.7);
}

+ (UIColor *)duxbeta_histogramWidgetGridColor {
    return RGBA(255.0, 255.0, 255.0, 0.4);
}

+ (UIColor *)duxbeta_preflightStatusWidgetGreenColor {
    return RGBA(97.0, 189.0, 23.0, 1.0);
}

+ (UIColor *)duxbeta_preflightStatusWidgetYellowColor {
    return RGBA(255.0, 192.0, 10.0, 1.0);
}

+ (UIColor *)duxbeta_preflightStatusWidgetRedColor {
    return RGBA(203.0, 26.0, 26.0, 1.0);
}

+ (UIColor *)duxbeta_preflightStatusWidgetGrayColor {
    return RGBA(71.0, 71.0, 71.0, 1.0);
}

+ (UIColor *)duxbeta_compassWidgetBackgroundColor {
    return RGBA(12.75, 12.75, 12.75, 1.0);
}

+ (UIColor *)duxbeta_compassWidgetBorderColor {
    return RGBA(102.0, 102.0, 102.0, 1.0);
}

+ (UIColor *)duxbeta_compassWidgetStrokeColor {
    return RGBA(255.0, 255.0, 255.0, 0.2);
}

+ (UIColor *)duxbeta_compassWidgetHorizonColor {
    return RGBA(32.0, 163.0, 246.0, 0.4);
}

+ (UIColor *)duxbeta_autoExposureSwitchWidgetWhiteColor {
    return RGBA(140.0, 140.0, 140.0, 1.0);
}

@end
