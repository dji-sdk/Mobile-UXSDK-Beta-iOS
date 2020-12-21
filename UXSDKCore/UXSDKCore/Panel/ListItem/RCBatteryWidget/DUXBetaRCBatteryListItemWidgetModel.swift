//
//  DUXBetaRCBatteryListItemWidgetModel.swift
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2020 DJI
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

import Foundation
import DJISDK


/**
 * DUXBetaRCBatteryListItemWidgetModel is the widget model for monitoring remote controller battery changes for DUXBetaRCBatteryListItemWidget
 */
@objcMembers open class DUXBetaRCBatteryListItemWidgetModel : DUXBetaBaseWidgetModel {
    /// The battery info to monitor for KVO notification. If the remaningChargeInPercent is > 100, this indicates the batteryInfo is invalid.
    dynamic public var rcBatteryInfo: DJIRCBatteryState = DJIRCBatteryState(remainingChargeInmAh: 0, remainingChargeInPercent: 255, isCharging: false)
    /// The low battery flag to monitor for KVO notification.
    dynamic public var isLowBattery = false
    /// The display name for the remote controller. This is used to detect if this isn't empty and product is not connected, aircraft is off
    dynamic public var rcDisplayName: NSString = ""
    /// Internal use variable used to retrieve and convert battery info from NSaValue into an easy to retrieve type
    dynamic public var rcBatteryInfoValue : NSValue = NSValue()
    
    /**
     * Set up the bindingsfor this model
     */
    open override func inSetup() {
        if let key = DJIRemoteControllerKey(param: DJIRemoteControllerParamBatteryState) {
            bindSDKKey(key, (\DUXBetaRCBatteryListItemWidgetModel.rcBatteryInfoValue).toString)
        }
        if let key = DJIRemoteControllerKey(param: DJIRemoteControllerParamDisplayName) {
            bindSDKKey(key, (\DUXBetaRCBatteryListItemWidgetModel.rcDisplayName).toString)
        }
        if let key = DJIRemoteControllerKey(param: DJIRemoteControllerParamIsChargeRemainingLow) {
            bindSDKKey(key, (\DUXBetaRCBatteryListItemWidgetModel.isLowBattery).toString)
        }

        bindRKVOModel(self, #selector(batteryInfoUpdated), (\DUXBetaRCBatteryListItemWidgetModel.rcBatteryInfoValue).toString)
}
    
    /**
     * And unbind for cleanup
     */
    open override func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }

    /**
     * The method batteryInfoUpdated is called when the remote controller updates the battery information. It then has to convert
     * the struct passed in an NSValue into an easy to consume variable.
     */
    @objc open func batteryInfoUpdated() {
        let tester: NSValue? = rcBatteryInfoValue
        if let tester = tester {
            // Safe to extract the value
            var localBatteryInfo : DJIRCBatteryState = DJIRCBatteryState(remainingChargeInmAh: 0, remainingChargeInPercent: 150, isCharging: false)
            // This dangling pointer will be dropped once scope is exited, and is used only for the next executable statement.
            let x = UnsafeMutableRawPointer(&localBatteryInfo)
            tester.getValue(x)
            rcBatteryInfo = localBatteryInfo
        } else {
            rcBatteryInfo = DJIRCBatteryState(remainingChargeInmAh: 0, remainingChargeInPercent: 255, isCharging: false)
        }
    }
}

