//
//  DUXBetaCompassGyroHorizonLayer.h
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

@class DUXBetaCompassLayer;
@class DUXBetaCompassAircraftYawLayer;

/// Custom view that displays the following:
/// - True north relative to the pilot and the aircraft
/// - Distance of the aircraft from the pilot
/// - Position of the aircraft relative to the pilot
/// - The aircraft's last recorded home location
@interface DUXBetaCompassAircraftWorldLayer : CALayer

/// The resource for the north icon image.
@property (nonatomic, strong) UIImage *northImage;

/// The resource for the image displayed in the center layer.
@property (nonatomic, strong) UIImage *centerImage;

/// The resource for the image displayed in the second layer.
@property (nonatomic, strong) UIImage *secondImage;

/// The background color for the aircraft icon.
@property (nonatomic, strong) UIColor *northBackgroundColor;

/// The background color for the center icon.
@property (nonatomic, strong) UIColor *centerBackgroundColor;

/// The background color for the second icon.
@property (nonatomic, strong) UIColor *secondBackgroundColor;

/// The center layer presented by this custom view.
@property (nonatomic, strong) CALayer *centerLayer;

/// The second layer presented by this custom view.
@property (nonatomic, strong) CALayer *secondLayer;

/// Weak reference to the container layer.
@property (weak, nonatomic) DUXBetaCompassLayer *compassLayer;

/// The custom view displaying the aircraft gimbal's yaw relative to the pilot.
@property (nonatomic, readonly) DUXBetaCompassAircraftYawLayer *aircraftYawLayer;

- (void)applyDeviceHeading:(CGFloat)deviceHeading;

@end
