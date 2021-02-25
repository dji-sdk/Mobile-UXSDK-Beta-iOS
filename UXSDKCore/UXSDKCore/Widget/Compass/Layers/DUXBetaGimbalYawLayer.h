//
//  DUXBetaGimabalYawView.h
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2021 DJI
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

NS_ASSUME_NONNULL_BEGIN

/// Abstraction responsible for displaying the heading
/// of the gimbal relative to the heading of the aircraft.
@interface DUXBetaGimbalYawLayer : CAShapeLayer

/// The yaw angle measured in degrees to be indicated in the view.
@property (nonatomic, assign) CGFloat yaw;

/// The color for a normal yaw value.
@property (nonatomic, strong) UIColor *yawColor;

/// The color used when the blink animation is visible.
@property (nonatomic, strong) UIColor *blinkColor;

/// The color for an invalid yaw color.
@property (nonatomic, strong) UIColor *invalidColor;

@end

NS_ASSUME_NONNULL_END
