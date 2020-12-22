//
//  UIColor+DUXBetaColors.m
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

#import "UIColor+DUXBetaColors.h"

#define RGBA(_r_, _g_, _b_, _a_) [UIColor colorWithRed:_r_/255.0 green:_g_/255.0 blue:_b_/255.0 alpha:_a_]

@implementation UIColor (DUXBetaColors)

// successColor and goodColor are the only duplicated colors defined. Their meaning are distinct but the same color is
// used to maintain a clean color pallete
+ (UIColor *)uxsdk_successColor {
    return RGBA(10.0, 238.0, 139.0, 1.0);
}

+ (UIColor *)uxsdk_goodColor {
    return RGBA(10.0, 238.0, 139.0, 1.0);
}

+ (UIColor *)uxsdk_errorDangerColor {
    return RGBA(255.0, 0.0, 0.0, 1.0);
}

+ (UIColor *)uxsdk_warningColor {
    return RGBA(255.0, 204.0, 0.0, 1.0);
}

+ (UIColor *)uxsdk_selectedBlueColor {
    return RGBA(31.0, 163.0, 246.0, 1.0);
}

+ (UIColor *)uxsdk_linkBlueColor {
    return RGBA(61.0, 133.0, 199.0, 1.0);
}

+ (UIColor *)uxsdk_compassWidgetHorizonColor {
    return RGBA(31.0, 163.0, 246.0, 0.4);
}

+ (UIColor *)uxsdk_slideTextColor {
    return RGBA(130.0, 80.0, 0.0, 1.0);
}

+ (UIColor *)uxsdk_rtkTableBorderColor {
    return RGBA(180.0, 180.0, 52.0, 0.25);
}

+ (UIColor *)uxsdk_fpvTextBackgroundColor {
    return RGBA(204, 27, 15, 0.6);
}

+ (UIColor *)uxsdk_fpvCenterPointRedColor {
    return RGBA(241, 69, 67, 1);
}


// Alpha whites and gray colors
+ (UIColor *)uxsdk_clearColor {
    return [UIColor clearColor];
}

+ (UIColor *)uxsdk_whiteAlpha20 {
    return RGBA(255.0, 255.0, 255.0, 0.2);
}

+ (UIColor *)uxsdk_whiteAlpha40 {
    return RGBA(255.0, 255.0, 255.0, 0.4);
}

+ (UIColor *)uxsdk_whiteAlpha60 {
    return RGBA(255.0, 255.0, 255.0, 0.6);
}

+ (UIColor *)uxsdk_whiteAlpha70 {
    return RGBA(255.0, 255.0, 255.0, 0.7);
}

+ (UIColor *)uxsdk_whiteAlpha80 {
    return RGBA(255, 255, 255, .8);
}

+ (UIColor *)uxsdk_lightGrayTransparentColor {
    return RGBA(100.0, 100.0, 100.0, 0.25);
}

+ (UIColor *)uxsdk_blackAlpha40 {
    return RGBA(0.0, 0.0, 0.0, 0.4);
}

+ (UIColor *)uxsdk_blackAlpha50 {
    return RGBA(0.0, 0.0, 0.0, 0.5);
}

+ (UIColor *)uxsdk_blackAlpha60 {
    return RGBA(0.0, 0.0, 0.0, 0.6);
}

+ (UIColor *)uxsdk_blackAlpha90 {
    return RGBA(0, 0, 0, .9);
}


// Solid white and grays
+ (UIColor *)uxsdk_whiteColor {
    return [UIColor whiteColor];
}

+ (UIColor *)uxsdk_white95 {
    return [UIColor colorWithWhite:0.95 alpha:1];
}

+ (UIColor *)uxsdk_white85 {
    return RGBA(218.0, 218.0, 218.0, 1.0);
}

+ (UIColor *)uxsdk_lightGrayWhite66 {
    return [UIColor lightGrayColor];
}

+ (UIColor *)uxsdk_disabledGrayWhite58 {
    return RGBA(149.0, 149.0, 149.0, 1.0);
}

+ (UIColor *)uxsdk_darkGrayWhite25 {
    return RGBA(64.0, 64.0, 64.0, 1.0);
}

+ (UIColor *)uxsdk_grayWhite50 {
    return RGBA(127.5, 127.5, 127.5, 1.0);
}

+ (UIColor *)uxsdk_darkGrayColor {
    return [UIColor darkGrayColor];
}

+ (UIColor *)uxsdk_white15 {
    return RGBA(33.0, 33.0, 33.0, 1.0);
}

+ (UIColor *)uxsdk_white5 {
    return RGBA(12.75, 12.75, 12.75, 1.0);
}

+ (UIColor *)uxsdk_blackColor {
    return [UIColor blackColor];
}

@end
