//
//  DUXBetaBatteryState.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  An enum describing the different possible states of the battery.  They are ordered from least important to most important.
 */
typedef NS_ENUM(NSUInteger, DUXBetaBatteryStatus) {
    /**
     *  The battery state is normal
     */
    DUXBetaBatteryStatusNormal = 0,
    /**
     *  The battery state is at warning level 1. This happens when the aircraft needs to go home.
     */
    DUXBetaBatteryStatusWarningLevel1,
    /**
     *  The battery state is at warning level 2. This happens when the aircraft needs to land immediately.
     */
    DUXBetaBatteryStatusWarningLevel2,
    /**
     *  The battery state is error.
     */
    DUXBetaBatteryStatusError,
    /**
     *  The battery state is overheating.
     */
    DUXBetaBatteryStatusOverheating,
    /**
     *  The battery state is unknown.
     */
    DUXBetaBatteryStatusUnknown
};

/**
 *  Used to describe the state of a battery.  This encapsulates all the data that the widget needs to display correctly.
 */

@interface DUXBetaBatteryState : NSObject

/**
 *  Create a new DUXBetaBatteryState object.
 *
 *  @param voltage An voltage value using `NSMeasurement`.
 *  @param batteryPercentage numerical value to represent the current percentage of the battery.
 *  @param state An enum value of `DUXBetaBatteryStatus`.
 */

- (instancetype)initWithVoltage:(NSMeasurement *)voltage andBatteryPercentage:(float)batteryPercentage withWarningLevel:(DUXBetaBatteryStatus)state;

/**
 *  The battery's voltage.
 */
@property (nonatomic, readonly) NSMeasurement *voltage;
/**
 *  The battery's percentage.
 */
@property (nonatomic, readonly) float batteryPercentage;
/**
 *  The battery's state.
 */
@property (nonatomic, readonly) DUXBetaBatteryStatus state;

@end

NS_ASSUME_NONNULL_END
