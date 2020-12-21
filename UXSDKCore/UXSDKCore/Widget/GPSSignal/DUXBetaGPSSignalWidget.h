//
//  DUXBetaGPSSignalWidget.h
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

#import <UXSDKCore/DUXBetaBaseWidget.h>
#import "DUXBetaGPSSignalWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Display:
 *  This widget displays the drone's connection strength to GPS.  It also has a label indicating how many satellites the
 *  drone is currently connected to. If the connected drone can connect to RTK this widget will also indicate if RTK is
 *  connected.
 *
 *  Usage:
 *  Preferred Aspect Ratio 38:15
 */

@interface DUXBetaGPSSignalWidget : DUXBetaBaseWidget

/**
 *  The widget model that the gps signal widget receives its information from.
 */
@property (nonatomic, strong) DUXBetaGPSSignalWidgetModel *widgetModel;

/**
 *  The overall widget background color
 */
@property (nonatomic, strong) UIColor *widgetBackgroundColor;

/**
 *  The satellite icon located to the left of the signal strength bars identifying this widget as the GPS widget
 */
@property (nonatomic, strong) UIImage *widgetIcon;

/**
 *  The background color of the icon
 */
@property (nonatomic, strong) UIColor *iconBackgroundColor;

/**
 *  The tint color of the icon
 */
@property (nonatomic, strong) UIColor *iconTintColorConnected;

/**
 *  The tint color of the icon when there is no connection to the flight controller
 */
@property (nonatomic, strong) UIColor *iconTintColorDisconnected;

/**
 *  Updates the image to be displayed for the corresponding signal strength level.
 *
 *  @param image The desired image.
 *  @param satelliteStrength The signal strength level to change the image for.
 */
- (void)setImage:(UIImage *)image forSatelliteStrength:(DUXBetaGPSSatelliteStrength)satelliteStrength;

/**
 *  Gets the image for corresponding signal strength level.
 *
 *  @param satelliteStrength The signal strength level to get the image for.
 */
- (UIImage *)imageForSatelliteStrength:(DUXBetaGPSSatelliteStrength)satelliteStrength;

/**
 *  The background color signal indicator (signal strength bars)
 */
@property (nonatomic, strong) UIColor *signalBackgroundColor;

/**
 *  The font for the text that shows how many satellites are connected.
 */
@property (nonatomic, strong) UIFont *satelliteCountNumberFont;

/**
 *  The color of the text that shows how many satellites are connected.
 */
@property (nonatomic, strong) UIColor *satelliteCountNumberColor;

/**
 *  The background color of the text that shows how many satellites are connected.
 */
@property (nonatomic, strong) UIColor *satelliteCountBackgroundColor;

/**
 *  The font of the RTK connection indicator (the R in the bottom right of the widget when RTK is in use)
 */
@property (nonatomic, strong) UIFont *rtkIndicatorFont;

/**
 *  The color of the RTK connection indicator (the R in the bottom right of the widget when RTK is in use) when the RTK connection is very strong
 */
@property (nonatomic, strong) UIColor *rtkIndicatorTextColorAccurate;

/**
 *  The color of the RTK connection indicator (the R in the bottom right of the widget when RTK is in use) when the RTK connection isn't very strong
 */
@property (nonatomic, strong) UIColor *rtkIndicatorTextColorInaccurate;

/**
 *  The background color of the RTK connection indicator (the R in the bottom right of the widget when RTK is in use)
 */
@property (nonatomic, strong) UIColor *rtkIndicatorBackgroundColor;

@end

NS_ASSUME_NONNULL_END
