//
//  UIColor+DUXBetaColors.m
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

+ (UIColor *)duxbeta_clearColor {
    return [UIColor clearColor];
}

+ (UIColor *)duxbeta_whiteColor {
    return [UIColor whiteColor];
}

+ (UIColor *)duxbeta_redColor {
    return [UIColor redColor];
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

+ (UIColor *)duxbeta_yellowColor {
    return RGBA(255.0, 192.0, 0.0, 1.0);
}

+ (UIColor *)duxbeta_backgroundColor {
    return RGBA(0.0, 0.0, 0.0, 0.6);
}

+ (UIColor *)duxbeta_rtkTableBorderColor {
    return RGBA(180.0, 180.0, 52.0, 0.25);
}

+ (UIColor *)duxbeta_lightGrayTransparentColor {
    return RGBA(100.0, 100.0, 100.0, 0.25);
}

+ (UIColor *)duxbeta_disabledGrayColor {
    return RGBA(149.0, 149.0, 149.0, 1.0);
}

+ (UIColor *)duxbeta_blueColor {
    return [UIColor blueColor];
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

+ (UIColor *)duxbeta_systemStatusWidgetGreenColor {
    return RGBA(97.0, 189.0, 23.0, 1.0);
}

+ (UIColor *)duxbeta_systemStatusWidgetRedColor {
    return RGBA(203.0, 26.0, 26.0, 1.0);
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

+ (UIColor *)duxbeta_linkBlueColor {
    return RGBA(61.0, 133.0, 199.0, 1.0);
}

+ (UIColor *)duxbeta_airSenseYellowColor {
    return RGBA(251, 207, 4, 1.0);
}

+ (UIColor *)duxbeta_simulatorIndicatorWidgetGreenColor {
    return RGBA(94, 240, 112, 1.0);
}

+ (UIColor *)duxbeta_batteryNormalGreen {
    return RGBA(63, 193, 77, 1.0);
}

+ (UIColor *)duxbeta_rtkOverallStatusGreen {
    return RGBA(126, 211, 33, 1.0);
}

+ (UIColor *)duxbeta_rtkOverallStatusYellow {
    return RGBA(248, 231, 28, 1.0);
}

+ (UIColor *)duxbeta_rtkOverallStatusRed {
    return RGBA(208, 2, 27, 1.0);
}

+ (UIColor *)duxbeta_fpvBackgroundColor {
    return [UIColor colorWithWhite:0.15 alpha:1];
}

+ (UIColor *)duxbeta_fpvGridLineColor {
    return [UIColor colorWithWhite:0.95 alpha:1];
}

+ (UIColor *)duxbeta_fpvGridLineShadowColor {
    return [UIColor colorWithWhite:0 alpha:0.4];
}

+ (UIColor *)duxbeta_fpvTextBackgroundColor {
    return RGBA(204, 27, 15, 0.6);
}

+ (UIColor *)duxbeta_fpvCenterPointYellowColor {
    return RGBA(251, 197, 2, 1);
}

+ (UIColor *)duxbeta_fpvCenterPointRedColor {
    return RGBA(241, 69, 67, 1);
}

+ (UIColor *)duxbeta_fpvCenterPointBlueColor {
    return RGBA(61, 162, 247, 1);
}

+ (UIColor *)duxbeta_fpvCenterPointGreenColor {
    return RGBA(87, 213, 92, 1);
}

+ (UIColor *)duxbeta_listPanelBackgroundColor {
    return RGBA(0, 0, 0, .9);
}

+ (UIColor *)duxbeta_listPanelSeparatorColor {
    return RGBA(255, 255, 255, .8);
}

+ (UIColor *)duxbeta_alertViewMaskColor {
    return RGBA(0, 0, 0, .4);
}

+ (UIColor *)duxbeta_alertBackgroundColor {
    return RGBA(66.0, 66.0, 66.0, 1.0);
}

+ (UIColor *)duxbeta_alertActionBlueColor {
    return RGBA(51.0, 156.0, 233.0, 1.0);
}
 
+ (UIColor *)duxbeta_slideTextColor {
    return RGBA(130.0, 80.0, 0.0, 1.0);
}

+ (UIColor *)duxbeta_slideIconSelectedColor {
    return RGBA(219.0, 221.0, 220.0, 1.0);
}

+ (UIColor *)duxbeta_slideSeparatorColor {
    return RGBA(91.0, 91.0, 91.0, 1.0);
}

+ (UIColor *)duxbeta_alertWarningColor {
    return RGBA(251.0, 225.0, 57.0, 1.0);
}

@end
