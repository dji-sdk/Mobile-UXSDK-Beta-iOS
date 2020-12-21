//
//  DUXBetaHorizontalVelocityWidget.swift
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

/**
 * Widget displays the horizontal velocity of the aircraft.
 */
@objcMembers public class DUXBetaHorizontalVelocityWidget: DUXBetaBaseTelemetryWidget {
    /// The underlying widget model.
    dynamic public var widgetModel = DUXBetaHorizontalVelocityWidgetModel()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the widget model
        widgetModel.setup()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaHorizontalVelocityWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateUI),
                      (\DUXBetaHorizontalVelocityWidget.widgetModel.horizontalVelocityState.isProductDisconnected).toString,
                      (\DUXBetaHorizontalVelocityWidget.widgetModel.horizontalVelocityState.currentVelocity).toString)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unbindRKVOModel(self)
    }
    
    deinit {
        widgetModel.cleanup()
    }
    
    /**
     * Override the parent setupUI method in order to setup the widget's specific properties
     */
    open override func setupUI() {
        type = .Text
        labelText = "H.S."
        
        super.setupUI()
        
        valueTextMask = "88.8"
    }
    
    /**
     * Override the parent updateUI to reflect widget model changes
     */
    open override func updateUI() {
        if widgetModel.horizontalVelocityState.isProductDisconnected {
            valueText = NSLocalizedString("N/A", comment: "N/A")
            unitText = ""
        } else {
            valueText = String(format: "%.1f", widgetModel.horizontalVelocityState.currentVelocity.value)
            unitText = (widgetModel.horizontalVelocityState.currentVelocity.unit == UnitLength.meters ? "m/s" : "mph")
        }
        
        DUXBetaStateChangeBroadcaster.send(HorizontalVelocityModelState.horizontalVelocityStateUpdated(widgetModel.horizontalVelocityState))
        
        super.updateUI()
    }
    
    func updateIsConnected() {
        DUXBetaStateChangeBroadcaster.send(HorizontalVelocityModelState.productConnected(widgetModel.isProductConnected))
    }
}

/**
 * HorizontalVelocityModelState contains the hooks for the model changes in the DUXBetaHorizontalVelocityWidget implementation.
 *
 * Key: productConnected                      Type: NSNumber - Sends a boolean value as an NSNumber
 *
 * Key: horizontalVelocityStateUpdated        Type: HorizontalVelocityState - Sends the horizontal velocity state update
 *
*/
@objcMembers public class HorizontalVelocityModelState: DUXBetaStateChangeBaseData {
    
    public static func productConnected(_ isConnected: Bool) -> HorizontalVelocityModelState {
        return HorizontalVelocityModelState(key: "productConnected", number: NSNumber(value: isConnected))
    }
    
    public static func horizontalVelocityStateUpdated(_ horizontalVelocityState: HorizontalVelocityState) -> HorizontalVelocityModelState {
        return HorizontalVelocityModelState(key: "horizontalVelocityStateUpdated", object: horizontalVelocityState)
    }
}
