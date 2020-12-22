//
//  DUXBetaVPSWidget.swift
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
 * Widget that displays the status of the vision positioning system
 * as well as the height of the aircraft as received from the
 * vision positioning system if available.
 */
@objcMembers public class DUXBetaVPSWidget: DUXBetaBaseTelemetryWidget {
    /// The underlying widget model.
    dynamic public var widgetModel = DUXBetaVPSWidgetModel()
    /// The image for vps enabled.
    public var vpsEnabledImage: UIImage? = .duxbeta_image(withAssetNamed: "VPSEnabled", for: DUXBetaVPSWidget.self)
    /// The image for vps disabled.
    public var vpsDisabledImage: UIImage? = .duxbeta_image(withAssetNamed: "VPSDisabled", for: DUXBetaVPSWidget.self)
    
    fileprivate var dangerHeight = NSMeasurement(doubleValue: 1.2, unit: UnitLength.meters)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the widget model
        widgetModel.setup()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaVPSWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateUI),
                      (\DUXBetaVPSWidget.widgetModel.vpsState.isProductDisconnected).toString,
                      (\DUXBetaVPSWidget.widgetModel.vpsState.isDisabled).toString,
                      (\DUXBetaVPSWidget.widgetModel.vpsState.currentVPS).toString)
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
        labelText = "VPS"
        
        super.setupUI()
    }
    
    /**
     * Override the parent updateUI to reflect widget model changes
     */
    open override func updateUI() {
        if widgetModel.vpsState.isProductDisconnected || widgetModel.vpsState.isDisabled {
            valueText = NSLocalizedString("N/A", comment: "N/A")
            valueTextColor = normalValueColor
            unitText = ""
            image = vpsDisabledImage
        } else {
            let unit = widgetModel.vpsState.currentVPS.unit
            let value = widgetModel.vpsState.currentVPS.value
            valueText = String(format: DUXBetaUnitTypeModule.stringFormat(for: widgetModel.unitModule.unitType), value)
            
            var heightLimit = dangerHeight
            if dangerHeight.unit != unit {
                heightLimit = dangerHeight.converting(to: unit) as NSMeasurement
            }
            valueTextColor = value > heightLimit.doubleValue ? normalValueColor : errorValueColor
            unitText = unit.symbol
            image = vpsEnabledImage
        }
        
        DUXBetaStateChangeBroadcaster.send(VPSModelState.vpsStateUpdated(widgetModel.vpsState))
        
        super.updateUI()
    }
    
    func updateIsConnected() {
        DUXBetaStateChangeBroadcaster.send(VPSModelState.productConnected(widgetModel.isProductConnected))
    }
}

/**
 * VPSModelState contains the hooks for the model changes in the DUXBetaVPSWidget implementation.
 *
 * Key: productConnected        Type: NSNumber - Sends a boolean value as an NSNumber
 *
 * Key: vpsStateUpdated         Type: VPSState - Sends the vps state update
 *
*/
@objcMembers public class VPSModelState: DUXBetaStateChangeBaseData {
    
    public static func productConnected(_ isConnected: Bool) -> VPSModelState {
        return VPSModelState(key: "productConnected", number: NSNumber(value: isConnected))
    }
    
    public static func vpsStateUpdated(_ vpsState: VPSState) -> VPSModelState {
        return VPSModelState(key: "vpsStateUpdated", object: vpsState)
    }
}
