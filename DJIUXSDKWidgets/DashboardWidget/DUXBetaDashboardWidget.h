//
//  DUXBetaDashboardWidget.h
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidget.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Compound widget that aggregates important physical state information
 * about the aircraft into a dashboard.
 *
 * It includes the CompassWidget, AltitudeWidget, DistanceHomeWidget
 * DistanceRCWidget, HorizontalVelocityWidget, VerticalVelocityWidget
 * and the VPSWidget.
 */

@interface DUXBetaDashboardWidget : DUXBetaBaseWidget

/*
 *  Type used to represent a location accuracy level in meters. The lower the value in meters, the
 *  more physically precise the location is. A negative accuracy value indicates an invalid location.
 */
@property (assign, nonatomic) CLLocationAccuracy locationManagerAccuracy;

@end

NS_ASSUME_NONNULL_END
