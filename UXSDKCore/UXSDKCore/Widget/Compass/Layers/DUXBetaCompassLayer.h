//
//  DUXBetaCompassLayer.h
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2018-2021 DJI
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

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "DUXBetaGimbalYawLayer.h"
#import "DUXBetaCompassWidgetModel.h"
#import "DUXBetaCompassGyroHorizonLayer.h"
#import "DUXBetaCompassAircraftWorldLayer.h"

/// Custom view resposible for drawing the compass widget.
@interface DUXBetaCompassLayer : CAShapeLayer

/// The background color of the compass widget.
@property (nonatomic, strong) UIColor *compassBackgroundColor;

/// The background color used to display the attitude of the aircraft.
@property (nonatomic, strong) UIColor *horizonColor;

/// The color of the border layer background.
@property (nonatomic, strong) UIColor *boundsColor;

/// The color for the crosshair lines.
@property (nonatomic, strong) UIColor *lineColor;

/// The color for the notch image icon.
@property (nonatomic, strong) UIImage *notchImage;

/// The color for the aircraft image icon.
@property (nonatomic, strong) UIImage *aircraftImage;

/// The color for the gimbal's yaw image icon.
@property (nonatomic, strong) UIImage *gimbalYawImage;

/// The color for the north image icon.
@property (nonatomic, strong) UIImage *northImage;

/// The color for the home image icon.
@property (nonatomic, strong) UIImage *homeImage;

/// The color for the remote control image icon.
@property (nonatomic, strong) UIImage *rcImage;

/// The background color for the notch image icon.
@property (nonatomic, strong) UIColor *notchBackgoundColor;

/// The background color for the aircraft image icon.
@property (nonatomic, strong) UIColor *aircraftBackgoundColor;

/// The background color for the gimbal's yaw image icon.
@property (nonatomic, strong) UIColor *gimbalYawBackgoundColor;

/// The background color for the north image icon.
@property (nonatomic, strong) UIColor *northBackgoundColor;

/// The background color for the home image icon.
@property (nonatomic, strong) UIColor *homeBackgoundColor;

/// The background color for the remote control image icon.
@property (nonatomic, strong) UIColor *rcBackgoundColor;

/// The color for a normal yaw value.
@property (nonatomic, strong) UIColor *yawColor;

/// The color used when the blink animation is visible.
@property (nonatomic, strong) UIColor *blinkColor;

/// The color for an invalid yaw color.
@property (nonatomic, strong) UIColor *invalidColor;

/// The size of the compass widget, by default {87, 87}
@property (nonatomic) CGSize designSize;

/// The margin of the compass, by default 6.
@property (nonatomic) CGFloat innerMargin;

/// The margin of the layer whose alpha channel is used to mask the layer’s content.
@property (nonatomic) CGFloat maskMargin;

/// The distance in meters represented by the radius of the compass, by default 400m.
@property (nonatomic) CGFloat radiusSize;

/// The interval distance between lines, by default 100m.
@property (nonatomic) CGFloat ringsInterDistance;

/// The aspect ratio of the notch icon image, by default {7, 7}
@property (nonatomic) CGSize notchSize;

/// The aspect ratio of the aircraft icon image, by default {14, 22}
@property (nonatomic) CGSize aircraftSize;

/// The aspect ratio of the gimbal's yaw image, by default {54, 65}
@property (nonatomic) CGSize gimbalYawSize;

/// The aspect ratio of the north icon image, by default {10, 10}
@property (nonatomic) CGSize northIconSize;

/// The aspect ratio of the home icon image, by default {12, 12}
@property (nonatomic) CGSize homeIconSize;

/// The aspect ratio of the remote control image, by default {10, 10}
@property (nonatomic) CGSize rcIconSize;

/// The computed value of the center image size based on the view model's center type.
@property (assign, nonatomic) CGSize centerImageSize;

/// The computed value of the second image size based on the view model's center type.
@property (assign, nonatomic) CGSize secondImageSize;

/// The object displaying the heading of the gimbal
/// relative to the heading of the aircraft.
@property (nonatomic, readonly) DUXBetaGimbalYawLayer *gimbalYawLayer;

/// The object displaying the attitude of the aircraft.
@property (nonatomic, readonly) DUXBetaCompassGyroHorizonLayer *gyroHorizonLayer;

/// The object displaying aircraft position relative to the pilot location,
/// rc location and true north relative location.
@property (nonatomic, readonly) DUXBetaCompassAircraftWorldLayer *aircraftWorldLayer;

/// Method that updates all the sublayer of this view with the given
/// widget model state.
/// @param compassState The state of the compass widget model.
- (void)updateCompassState:(DUXBetaCompassState *)compassState;

@end
