//
//  DUXBetaCompassAircraftYawLayer.h
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

/// Custom view to display the heading of the aircraft
/// relative to the pilot.
@interface DUXBetaCompassAircraftYawLayer : CALayer

/// The resource for the aircraft icon image.
@property (nonatomic, strong) UIImage *aircraftImage;

/// The resource for the gimbal's yaw image.
@property (nonatomic, strong) UIImage *gimbalYawImage;

/// The background color for the aircraft icon.
@property (nonatomic, strong) UIColor *aircraftBackgroundColor;

/// The background color for the gimbal's yaw icon.
@property (nonatomic, strong) UIColor *gimbalYawBackgroundColor;

/// Weak reference to the container layer.
@property (weak, nonatomic) DUXBetaCompassLayer *compassLayer;

/// Method that updates the aircraft layer position.
/// @param heading The heading value in degrees.
- (void)updateAircraftHeading:(CGFloat)heading;

/// Method that updates the gimbal's yaw layer position.
/// @param heading The heading value in degrees.
- (void)updateGimbalHeading:(CGFloat)heading;

@end
