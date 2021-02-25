//
//  DUXBetaHeadingView.h
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

/// Custom view that displays a Bézier path object with an arc
/// of a circle having the option to perform a blink animation between
/// main color and secondary color.
@interface DUXBetaHeadingLayer : CAShapeLayer

/// The principal color of the arc.
@property (nonatomic, strong) UIColor *mainColor;

/// The color used when by the animation.
@property (nonatomic, strong) UIColor *secondaryColor;


/// Method that shows an arc of a circle.
///
/// @param startAngle Specifies the starting angle of the arc measured in degrees.
/// @param sweepAngle Specifies the end angle of the arc measured in degrees.
- (void)showStartAngle:(CGFloat)startAngle withSweepAngle:(CGFloat)sweepAngle;

/// Method that shows an animated arc of a circle.
/// 
/// @param startAngle Specifies the starting angle of the arc measured in degrees.
/// @param sweepAngle Specifies the end angle of the arc measured in degrees.
- (void)animateStartAngle:(CGFloat)startAngle withSweepAngle:(CGFloat)sweepAngle;

@end

NS_ASSUME_NONNULL_END
