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

+ (UIColor *)duxbeta_systemStatusWidgetGreenColor {
    return RGBA(97.0, 189.0, 23.0, 1.0);
}

+ (UIColor *)duxbeta_systemStatusWidgetYellowColor {
    return RGBA(255.0, 192.0, 10.0, 1.0);
}

+ (UIColor *)duxbeta_batteryOverheatingYellowColor {
    return RGBA(255.0, 192.0, 0.0, 1.0);
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

@end
