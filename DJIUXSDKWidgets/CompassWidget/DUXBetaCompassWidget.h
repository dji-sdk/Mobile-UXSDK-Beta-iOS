//
//  DUXBetaVPSWidget.h
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
#import "DUXBetaCompassWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaCompassWidget : DUXBetaBaseWidget

@property (nonatomic, strong) DUXBetaCompassWidgetModel *widgetModel;

@property (nonatomic, strong) UIColor *compassBackgroundColor;
@property (nonatomic, strong) UIColor *horizonColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *strokeColor;

/*
 Compass Widget uses layers to draw the various subcomponents for
 good drawing performance, and uses explicit size values to arrange
 its various sublayers so that it scales correctly to any size.
 
 When changing any image, also make sure to change its corresponding
 size so that the widget can render the image at its proper desired
 size and aspect ratio.
 
 All of these image sizes are not pixel values, but describe the
 ratio of each image with respect to a default compass widget size
 of {87, 87}.
 */

// Size of compass widget
@property (nonatomic) CGSize designSize; // Defaults to {87, 87}

@property (nonatomic) CGFloat innerPadding; // Defaults to 6
@property (nonatomic) CGFloat maskPaddingSize; // Defaults to 15

@property (nonatomic) CGSize notchSize; // Defaults to {8, 6}
@property (nonatomic, strong) UIImage *notchImage;

@property (nonatomic) CGSize aircraftSize; // Defaults to {15, 20}
@property (nonatomic, strong) UIImage *aircraftImage;

@property (nonatomic) CGSize visionConeSize; // Defaults to {35, 50}
@property (nonatomic, strong) UIImage *visionConeImage;

@property (nonatomic) CGSize northIconSize; // Defaults to {10, 10}
@property (nonatomic, strong) UIImage *northIconImage;

@property (nonatomic) CGSize homeIconSize; // Defaults to {15, 15}
@property (nonatomic, strong) UIImage *homeIconImage;

@end

NS_ASSUME_NONNULL_END
