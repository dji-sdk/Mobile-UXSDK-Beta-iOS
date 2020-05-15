//
//  DUXBetaFlightModeWidget.h
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidget.h>
#import "DUXBetaFlightModeWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Widget to show the current flight mode of the aircraft.
*/
@interface DUXBetaFlightModeWidget : DUXBetaBaseWidget

/**
 *  The widget data model controlling flight mode widget
*/
@property (nonatomic, strong) DUXBetaFlightModeWidgetModel *widgetModel;

/**
 *  Get/Set the widget's background color
*/
@property (nonatomic, strong) UIColor *overallBackgroundColor;

/**
 *  Get/Set the label text color while aircraft is connected
*/
@property (nonatomic, strong) UIColor *labelTextColorConnected;

/**
 *  Get/Set the label text color while aircraft is disconnected
*/
@property (nonatomic, strong) UIColor *labelTextColorDisconnected;

/**
 *  Get/Set the label background color
*/
@property (nonatomic, strong) UIColor *labelBackgroundColor;

/**
 *  Get/Set the icon tint color
*/
@property (nonatomic, strong) UIColor *iconTintColorConnected;

/**
 *  Get/Set the icon tint color
*/
@property (nonatomic, strong) UIColor *iconTintColorDisconnected;

/**
 *  Get/Set the icon background color
*/
@property (nonatomic, strong) UIColor *iconBackgroundColor;

/**
 *  Get/Set the icon image. For tinting to work, pass an image with UIImageRenderingModeAlwaysTemplate
*/
@property (nonatomic, strong) UIImage *iconImage;

/**
 *  Get/Set the icon font. Default point size = 70.0, scales with widget
*/
@property (nonatomic, strong) UIFont *labelFont;

/**
 *  The widget's fixed width property. When YES, the widget's width is set to the largest flight mode string. When NO, the widget's width depends on the length of the flight mode string
*/
@property (assign) BOOL hasFixedWidth;

@end

NS_ASSUME_NONNULL_END
