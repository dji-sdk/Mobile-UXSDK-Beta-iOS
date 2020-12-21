//
//  DUXBetaAGLAltitudeWidget.swift
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
 * Widget displays the above ground level altitude.
 */
@objcMembers public class DUXBetaAGLAltitudeWidget: DUXBetaBaseTelemetryWidget {
    /// The underlying widget model.
    dynamic public var widgetModel = DUXBetaAltitudeWidgetModel()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the widget model
        widgetModel.setup()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaAGLAltitudeWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateUI),
                      (\DUXBetaAGLAltitudeWidget.widgetModel.altitudeState.isProductDisconnected).toString,
                      (\DUXBetaAGLAltitudeWidget.widgetModel.altitudeState.altitudeAGL).toString)
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
        labelText = "H AGL"
        
        super.setupUI()
    }
    
    /**
     * Override the parent updateUI to reflect widget model changes
     */
    open override func updateUI() {
        if widgetModel.altitudeState.isProductDisconnected {
            valueText = NSLocalizedString("N/A", comment: "N/A")
            unitText = ""
        } else {
            valueText = formattedValue(value: widgetModel.altitudeState.altitudeAGL.value, for: widgetModel.unitModule.unitType)
            unitText = widgetModel.altitudeState.altitudeAGL.unit.symbol
        }
        
        DUXBetaStateChangeBroadcaster.send(AGLAltitudeModelState.altitudeStateUpdated(widgetModel.altitudeState))
        
        super.updateUI()
    }
    
    func updateIsConnected() {
        DUXBetaStateChangeBroadcaster.send(AGLAltitudeModelState.productConnected(widgetModel.isProductConnected))
    }
}

/**
 * AGLAltitudeModelState contains the hooks for the model changes in the DUXBetaAGLAltitudeWidget implementation.
 *
 * Key: productConnected            Type: NSNumber - Sends a boolean value as an NSNumber
 *
 * Key: altitudeStateUpdated        Type: AltitudeState - Sends the altitude state update
 *
*/
@objcMembers public class AGLAltitudeModelState: DUXBetaStateChangeBaseData {
    
    public static func productConnected(_ isConnected: Bool) -> AGLAltitudeModelState {
        return AGLAltitudeModelState(key: "productConnected", number: NSNumber(value: isConnected))
    }
    
    public static func altitudeStateUpdated(_ altitudeState: AltitudeState) -> AGLAltitudeModelState {
        return AGLAltitudeModelState(key: "altitudeStateUpdated", object: altitudeState)
    }
}
