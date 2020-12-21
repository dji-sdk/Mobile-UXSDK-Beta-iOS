//
//  UIColor+DUXBetaColors.h
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

@interface UIColor (DUXBetaColors)

+ (UIColor *)uxsdk_successColor;
+ (UIColor *)uxsdk_goodColor;
+ (UIColor *)uxsdk_errorDangerColor;
+ (UIColor *)uxsdk_warningColor;

+ (UIColor *)uxsdk_selectedBlueColor;
+ (UIColor *)uxsdk_linkBlueColor;
+ (UIColor *)uxsdk_compassWidgetHorizonColor;

+ (UIColor *)uxsdk_slideTextColor;

// RTK Satellite Status Widget Colors
+ (UIColor *)uxsdk_rtkTableBorderColor;

// FPV Widget colors
+ (UIColor *)uxsdk_fpvTextBackgroundColor;
+ (UIColor *)uxsdk_fpvCenterPointRedColor;

// Alpha whites and gray colors
+ (UIColor *)uxsdk_clearColor;
+ (UIColor *)uxsdk_whiteAlpha20;
+ (UIColor *)uxsdk_whiteAlpha40;
+ (UIColor *)uxsdk_whiteAlpha60;
+ (UIColor *)uxsdk_whiteAlpha70;
+ (UIColor *)uxsdk_whiteAlpha80;
+ (UIColor *)uxsdk_lightGrayTransparentColor;
+ (UIColor *)uxsdk_blackAlpha40;
+ (UIColor *)uxsdk_blackAlpha50;
+ (UIColor *)uxsdk_blackAlpha60;
+ (UIColor *)uxsdk_blackAlpha90;

// Solid whites, grays, blacks
+ (UIColor *)uxsdk_whiteColor;
+ (UIColor *)uxsdk_white95;
+ (UIColor *)uxsdk_white85;
+ (UIColor *)uxsdk_lightGrayWhite66;  // system lightGray
+ (UIColor *)uxsdk_disabledGrayWhite58;
+ (UIColor *)uxsdk_darkGrayWhite25;
+ (UIColor *)uxsdk_grayWhite50;
+ (UIColor *)uxsdk_darkGrayColor;     // system darkGray
+ (UIColor *)uxsdk_white15;
+ (UIColor *)uxsdk_white5;
+ (UIColor *)uxsdk_blackColor;
@end

NS_ASSUME_NONNULL_END
