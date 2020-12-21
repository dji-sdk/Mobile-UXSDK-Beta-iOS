//
//  DUXBetaRTKEnabledWidget.h
//  UXSDKAccessory
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

#import <Foundation/Foundation.h>
#import <UXSDKCore/DUXBetaBaseWidget.h>
@class DUXBetaRTKEnabledWidgetModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Display:
 *  This widget displays a switch that will enable or disable RTK.
 *
 *  Usage:
 *  Preferred Aspect Ratio 400:120
 */
@interface DUXBetaRTKEnabledWidget : DUXBetaBaseWidget

/**
 *  The widget model that the battery widget receives its information from.
*/
@property (nonatomic, strong) DUXBetaRTKEnabledWidgetModel *widgetModel;

/**
 *  The font of the title (RTK Positioning). Default point size = 20.
*/
@property (nonatomic, strong) UIFont *titleFont;

/**
 *  The color of the title (RTK Positioning).
*/
@property (nonatomic, strong) UIColor *titleTextColor;

/**
 *  The background color of the title (RTK Positioning).
*/
@property (nonatomic, strong) UIColor *titleBackgroundColor;

/**
 *  The font of the description: (When RTK module malfunctions, manually disable...). Default point size = 14.
*/
@property (nonatomic, strong) UIFont *descriptionFont;

/**
 *  The color of the description text: (When RTK module malfunctions, manually disable...).
*/
@property (nonatomic, strong) UIColor *descriptionTextColor;

/**
 *  The background color of the description label: (When RTK module malfunctions, manually disable...).
*/
@property (nonatomic, strong) UIColor *descriptionBackgroundColor;

/**
 *  The color the enable switch shows when RTK is enabled. Set to nil to use default iOS color.
*/
@property (nonatomic, strong) UIColor *enableSwitchOnTintColor;

/**
 *  The color the enable switch shows when turned off. Set to nil to use default iOS color.
*/
@property (nonatomic, strong) UIColor *enableSwitchOffTintColor;

/**
 * The color for the border around the switch. Changeable in iOS 13 and above only.
 */
@property (nonatomic, strong) UIColor *enableSwitchTrackColor;

/**
 *  The widget's background color.
*/
@property (nonatomic, strong) UIColor *widgetBackgroundColor;

@end

NS_ASSUME_NONNULL_END
