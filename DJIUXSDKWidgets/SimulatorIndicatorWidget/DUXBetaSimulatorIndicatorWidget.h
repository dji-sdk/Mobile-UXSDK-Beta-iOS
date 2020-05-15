//
//  DUXBetaSimulatorIndicatorWidget.h
//  DJIUXSDKWidgets
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
#import "DUXBetaSimulatorIndicatorWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This widget displays the state of the simulator indicator.
*/
typedef NS_ENUM(NSUInteger, DUXBetaSimulatorIndicatorState) {
    DUXBetaSimulatorIndicatorStateDisconnected, // no aircraft connected
    DUXBetaSimulatorIndicatorStateInactive, // aircraft connected, not simulating
    DUXBetaSimulatorIndicatorStateActive // aircraft connected and simulating
};

@interface DUXBetaSimulatorIndicatorWidget : DUXBetaBaseWidget

@property (nonatomic, retain) DUXBetaSimulatorIndicatorWidgetModel *widgetModel;

/**
 *  Simulator indicator widget state
*/

@property (nonatomic, assign, readonly) DUXBetaSimulatorIndicatorState state;

 /**
  *  Image background color
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 *  Set image for given simulator state
*/
- (void)setImage:(UIImage *)image forState:(DUXBetaSimulatorIndicatorState)state;

/**
 *  Get image for given simulator state
*/
- (UIImage *)getImageForState:(DUXBetaSimulatorIndicatorState)state;

/**
 *  Set tint color for given simulator state
*/
- (void)setTintColor:(UIColor *)color forState:(DUXBetaSimulatorIndicatorState)state;

/**
 *  Get tint color for given simulator state
*/
- (UIColor *)getTintColorForState:(DUXBetaSimulatorIndicatorState)state;

@end

NS_ASSUME_NONNULL_END
