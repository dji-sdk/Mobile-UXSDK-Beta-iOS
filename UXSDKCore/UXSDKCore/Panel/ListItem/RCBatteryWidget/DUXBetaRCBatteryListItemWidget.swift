//
//  DUXBetaRCBatteryListItemWidget.swift
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
 * Widget for displaying the current status of the remote controller battery
 */
@objcMembers open class DUXBetaRCBatteryListItemWidget : DUXBetaListItemLabelButtonWidget {
    /// The color of the label text when the battery charge is below the warning threshold
    open var labelTextColorLowBattery: UIColor = UIColor.uxsdk_errorDanger()
    /// The widget model for monitoring aircraft status
    lazy var widgetModel = DUXBetaRCBatteryListItemWidgetModel()
    /// Internal setting for battery threshhold for warnings
    fileprivate var rcLowBatteryThreshold: UInt = 30;

    override public init() {
        super.init(.labelOnly)
    }

    override public init(title: String, andIconName: String?) {
        super.init(title: title, andIconName: andIconName)
        
    }
    /**
     * Required init for Swift implemntation of list item subclass.
     */
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /**
     * Override of viewDidLoad to set up widget model, text settings, and set title and icon when widget loads
     */
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        widgetModel.setup()
        displayTextLabel.minimumScaleFactor = 0.6
        displayTextLabel.adjustsFontSizeToFitWidth = true
        
        setTitle(NSLocalizedString("Remote Controller Battery", comment: "List Item Widget Title"), andIconName:"SystemStatusRCBattery")
    }
    
    /*
     * Override of viewWillAppear to establish bindings to the widgetModel
     */
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaRCBatteryListItemWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateBatteryInfo), (\DUXBetaRCBatteryListItemWidget.widgetModel.rcBatteryInfo).toString)
        bindRKVOModel(self, #selector(updateUI), (\DUXBetaRCBatteryListItemWidget.widgetModel.rcDisplayName).toString, (\DUXBetaRCBatteryListItemWidget.widgetModel.isLowBattery).toString)
    }
    
    /*
     * Override of viewWillDisappear to clean up bindings to the widgetModel
     */
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unbindRKVOModel(self)
    }

    open override func updateUI() {
        if !widgetModel.isProductConnected && (widgetModel.rcDisplayName.length < 1) {
            setLabelText(NSLocalizedString("N/A", comment: "N/A"))
        } else {
            if widgetModel.rcBatteryInfo.remainingChargeInPercent <= 100 {
                let outString = String(format: "%d%%", widgetModel.rcBatteryInfo.remainingChargeInPercent)
                setLabelText(outString)
            } else {
                setLabelText(NSLocalizedString("N/A", comment: "N/A"))
            }
        }
        super.updateLabelDisplay()
    }

    deinit {
        widgetModel.cleanup()
    }

    /**
     * The method displayLabelColor is overridden from the base class to handle the low battery case and return the
     * propper color to use for display. If above threshhold, just return the parent method result.
     */
    override open func displayLabelColor() -> UIColor {
        if (widgetModel.rcDisplayName.length > 0) && (widgetModel.rcBatteryInfo.remainingChargeInPercent <= 100) {
            if (widgetModel.isLowBattery) {
                return errorValueColor
            } else {
                // Since the RC is connected, we want this normal color, not possibly product disconnected color.
                return normalValueColor
            }
        } else {
            return super.displayLabelColor()
        }
    }

    /**
     * Update the UI and send the hook when the product conection changes.
     */
    @objc func updateIsConnected() {
        updateUI()
        //Forward the model change
        DUXBetaStateChangeBroadcaster.send(RCBatteryItemModelState.productConnected(widgetModel.isProductConnected))
    }

    /**
     * Update the UI and send the hook when the battery info changes.
     */
    @objc func updateBatteryInfo() {
        updateUI()
        //Forward the model change
        if widgetModel.rcBatteryInfo.remainingChargeInPercent <= 100 {
            DUXBetaStateChangeBroadcaster.send(RCBatteryItemModelState.rcBatteryStateUpdated(widgetModel.rcBatteryInfo))
        }
    }

}

/**
 * RCBatteryItemModelState contains the hooks for the DUXBetaRCBatteryListItemWidgetModel model class.
 * It inherits all model hooks in ListItemTitleModelState and adds:
 *  Key: rcBatteryStateUpdated  Type: id - Sends the updated battery information as an NSDictionary instead of a structure when battery info changes.
 */
@objcMembers open class RCBatteryItemModelState : ListItemTitleModelState {
    @objc static public func rcBatteryStateUpdated(_ batteryState: DJIRCBatteryState) -> RCBatteryItemModelState {
        return RCBatteryItemModelState(key: "rcBatteryStateUpdated", object:
            ["remainingChargeInPercent" : NSNumber(value: batteryState.remainingChargeInPercent),
                "remainingChargeInmAh" :   NSNumber(value: batteryState.remainingChargeInmAh),
                "isCharging" : NSNumber(value: batteryState.isCharging)])
        
    }
}
