//
//  DUXBetaVerticalVelocityWidget.swift
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
 * Widget displays the vertical velocity of the aircraft.
 */
@objcMembers public class DUXBetaVerticalVelocityWidget: DUXBetaBaseTelemetryWidget {
    /// The underlying widget model.
    dynamic public var widgetModel = DUXBetaVerticalVelocityWidgetModel()
    /// The image displayed when when aircraft is moving in an upward direction.
    public var upwardImage: UIImage? = UIImage.duxbeta_image(withAssetNamed: "UpArrow", for: VerticalVelocityState.self)
    /// The image displayed when when aircraft is moving in a downard direction.
    public var downwardImage: UIImage? = UIImage.duxbeta_image(withAssetNamed: "DownArrow", for: VerticalVelocityState.self)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the widget model
        widgetModel.setup()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaVerticalVelocityWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateUI),
                      (\DUXBetaVerticalVelocityWidget.widgetModel.verticalVelocityState.isProductDisconnected).toString,
                      (\DUXBetaVerticalVelocityWidget.widgetModel.verticalVelocityState.idleUnit).toString,
                      (\DUXBetaVerticalVelocityWidget.widgetModel.verticalVelocityState.upwardVelocity).toString,
                      (\DUXBetaVerticalVelocityWidget.widgetModel.verticalVelocityState.downwardVelocity).toString)
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
        type = .TextImageRight
        labelText = "V.S."
        valueTextMask = "88.8"
        
        super.setupUI()
    }
    
    /**
     * Override the parent updateUI to reflect widget model changes
     */
    open override func updateUI() {
        if widgetModel.verticalVelocityState.isProductDisconnected {
            valueText = NSLocalizedString("N/A", comment: "N/A")
            unitText = ""
            image = nil
        } else {
            if widgetModel.verticalVelocityState.downwardVelocity.value > 0.0 {
                let unit = widgetModel.verticalVelocityState.downwardVelocity.unit
                unitText = (unit == UnitLength.meters ? "m/s" : "mph")
                valueText = String(format: "%.1f", widgetModel.verticalVelocityState.downwardVelocity.value)
                image = downwardImage
            } else if widgetModel.verticalVelocityState.upwardVelocity.value > 0.0 {
                let unit = widgetModel.verticalVelocityState.upwardVelocity.unit
                unitText = (unit == UnitLength.meters ? "m/s" : "mph")
                valueText = String(format: "%.1f", widgetModel.verticalVelocityState.upwardVelocity.value)
                image = upwardImage
            } else {
                let unit = widgetModel.verticalVelocityState.idleUnit
                unitText = (unit == UnitLength.meters ? "m/s" : "mph")
                valueText = String(format: "%.1f", 0.0)
                image = nil
            }
        }
        
        DUXBetaStateChangeBroadcaster.send(VerticalVelocityModelState.verticalVelocityStateUpdated(widgetModel.verticalVelocityState))
        
        super.updateUI()
    }
    
    func updateIsConnected() {
        DUXBetaStateChangeBroadcaster.send(VerticalVelocityModelState.productConnected(widgetModel.isProductConnected))
    }
}

/**
 * VerticalVelocityModelState contains the hooks for the model changes in the DUXBetaVerticalVelocityWidget implementation.
 *
 * Key: productConnected                        Type: NSNumber - Sends a boolean value as an NSNumber
 *
 * Key: verticalVelocityStateUpdated            Type: VerticalVelocityState - Sends the Vertical velocity state update
 *
*/
@objcMembers public class VerticalVelocityModelState: DUXBetaStateChangeBaseData {
    
    public static func productConnected(_ isConnected: Bool) -> VerticalVelocityModelState {
        return VerticalVelocityModelState(key: "productConnected", number: NSNumber(value: isConnected))
    }
    
    public static func verticalVelocityStateUpdated(_ verticalVelocityState: VerticalVelocityState) -> VerticalVelocityModelState {
        return VerticalVelocityModelState(key: "verticalVelocityStateUpdated", object: verticalVelocityState)
    }
}
