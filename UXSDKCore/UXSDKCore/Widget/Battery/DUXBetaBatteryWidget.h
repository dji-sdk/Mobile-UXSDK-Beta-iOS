//
//  DUXBetaBatteryWidget.h
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
#import "DUXBetaBatteryState.h"
@class DUXBetaBatteryWidgetModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Display:
 *  Battery icon has two color states. White color indicates everything is ok. Icon
 *  will change into red color if aircraft needs to return home, land immediately,
 *  or battery connection is bad. Text shows percentage of charge remaining in
 *  battery. Text also has two color states. Green indicates the percentage is ok.
 *  Red indicates the percentage is either below or just enough for returning home
 *  or landing immediately.
 *
 *  Usage:
 *  Preferred Aspect Ratio For Single Battery State: 44:18
 *  Preferred Aspect Ratio For Dual Battery State: 88:20
 */

typedef NS_ENUM(NSUInteger, DUXBetaBatteryWidgetDisplayState) {
    /**
     *  The widget is currently displaying single battery or aggregate battery information.
     */
    DUXBetaBatteryWidgetDisplayStateSingleBattery,
    /**
     *  The widget is currently displaying dual battery information.
     */
    DUXBetaBatteryWidgetDisplayStateDualBattery
};

@protocol DUXBetaBatteryWidgetDelegate <NSObject>

/**
 *  Use this delegate method to receive updates from the widget if it changes display states.  Using the `widgetSizeHint` property you can recompute the constraints you currently have set on the widget.
 */
- (void)batteryWidgetChangedDisplayState:(DUXBetaBatteryWidgetDisplayState)newState;

@end

@interface DUXBetaBatteryWidget : DUXBetaBaseWidget

/**
 *  The widget model that the battery widget receives its information from.
 */
@property (nonatomic, strong) DUXBetaBatteryWidgetModel *widgetModel;

/**
 *  The delegate for reacting to updates in the widget.  Use this to re-configure your constraints on the battery widget if it changes aspect ratio.
 */
@property (nonatomic, weak) id<DUXBetaBatteryWidgetDelegate> delegate;

/**
 *  The current state of the widget.  This will either be `DUXBetaBatteryWidgetDisplayStateSingleBattery` or `DUXBetaBatteryWidgetDisplayStateDualBattery`.
 */
@property (nonatomic, readonly) DUXBetaBatteryWidgetDisplayState widgetDisplayState;

/**
 *  Set the color of the battery widget voltage text for the desired battery status.
 *
 *  @param color The desired color.
 *  @param batteryStatus The battery status to set the color for.
 */
- (void)setVoltageColor:(UIColor *)color forBatteryStatus:(DUXBetaBatteryStatus)batteryStatus;

/**
 *  Set the color of the battery widget percentage text for the desired battery status.
 *
 *  @param color The desired color.
 *  @param batteryStatus The battery status to change the color for.
 */
- (void)setPercentageColor:(UIColor *)color forBatteryStatus:(DUXBetaBatteryStatus)batteryStatus;

/**
 *  Get the color of the battery widget percentage text for the desired battery status.
 *
 *  @param batteryStatus The battery status to get the color of the percentage text for.
*/
- (UIColor *)getPercentageColorForBatteryStatus:(DUXBetaBatteryStatus)batteryStatus;

/**
 *  Get the current color for the desired battery status.
 *
 *  @param batteryStatus The battery status to get the color for.
 */
- (UIColor *)getVoltageColorForBatteryStatus:(DUXBetaBatteryStatus)batteryStatus;

/**
 *  Set the image of the battery widget when it is displaying a single battery's information.
 *
 *  @param image The desired image.
 *  @param batteryStatus The battery status to change the color for.
 */
- (void)setImage:(UIImage *)image forSingleBatteryStatus:(DUXBetaBatteryStatus)batteryStatus;

/**
 *  Get the current image for when the widget is displaying a single battery's information.
 *
 *  @param batteryStatus The battery status to get the image for.
 */
- (UIImage *)getImageForSingleBatteryStatus:(DUXBetaBatteryStatus)batteryStatus;

/**
 *  Set the image of the battery widget when it is displaying dual battery information.
 *
 *  @param image The desired image.
 *  @param batteryStatus The battery status to change the color for.
 */
- (void)setImage:(UIImage *)image forDualBatteryStatus:(DUXBetaBatteryStatus)batteryStatus;

/**
 *  Get the current image for when the widget is displaying a dual battery information.
 *
 *  @param batteryStatus The battery status to get the image for.
 */
- (UIImage *)getImageForDualBatteryStatus:(DUXBetaBatteryStatus)batteryStatus;

/**
 *  Set the tint color for the widget icon for a particular battery status.
 *
 *  @param batteryStatus The battery status to set the  color for.
*/
- (void)setTintColor:(UIColor *)color forBatteryStatus:(DUXBetaBatteryStatus)batteryStatus;

/**
 *  Get the tint color for the widget icon for a particular battery status.
 *
 *  @param batteryStatus The battery status to get the color for.
*/
- (UIColor *)getTintColorForBatteryStatus:(DUXBetaBatteryStatus)batteryStatus;

/**
 *  The font for the battery percentage in single battery state.
 */
@property (nonatomic, strong) UIFont *percentageFontSingle;

/**
 *  The font for the battery percentage in dual battery state.
 */
@property (nonatomic, strong) UIFont *percentageFontDual;

/**
 *  The font for the battery voltage in dual battery state.
 */
@property (nonatomic, strong) UIFont *voltageFontDual;

@end

NS_ASSUME_NONNULL_END
