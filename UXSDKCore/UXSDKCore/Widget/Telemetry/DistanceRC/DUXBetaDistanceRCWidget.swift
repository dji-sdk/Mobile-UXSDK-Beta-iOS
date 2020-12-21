//
//  DUXBetaDistanceRCWidget.swift
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
 * The widget that displays the distance between the current location of the aicraft
 * and the remote controller location.
 */
@objcMembers public class DUXBetaDistanceRCWidget: DUXBetaBaseTelemetryWidget {
    /// The underlying widget model.
    dynamic public var widgetModel = DUXBetaDistanceRCWidgetModel()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the widget model
        widgetModel.setup()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaDistanceRCWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateUI),
                      (\DUXBetaDistanceRCWidget.widgetModel.distanceRCState.isProductDisconnected).toString,
                      (\DUXBetaDistanceRCWidget.widgetModel.distanceRCState.isLocationUnavailable).toString,
                      (\DUXBetaDistanceRCWidget.widgetModel.distanceRCState.currentDistanceRC).toString)
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
        labelText = "DRC"
        
        super.setupUI()
    }
    
    /**
     * Override the parent updateUI to reflect widget model changes
     */
    open override func updateUI() {
        if widgetModel.distanceRCState.isProductDisconnected || widgetModel.distanceRCState.isLocationUnavailable {
            valueText = NSLocalizedString("N/A", comment: "N/A")
            unitText = ""
        } else {
            valueText = formattedValue(value: widgetModel.distanceRCState.currentDistanceRC.value, for: widgetModel.unitModule.unitType)
            unitText = widgetModel.distanceRCState.currentDistanceRC.unit.symbol
        }
        
        DUXBetaStateChangeBroadcaster.send(DistanceRCModelState.distanceRCStateUpdated(widgetModel.distanceRCState))
        
        super.updateUI()
    }
    
    func updateIsConnected() {
        DUXBetaStateChangeBroadcaster.send(DistanceRCModelState.productConnected(widgetModel.isProductConnected))
    }
}

/**
 * DistanceRCModelState contains the hooks for the model changes in the DUXBetaDistanceRCWidget implementation.
 *
 * Key: productConnected            Type: NSNumber - Sends a boolean value as an NSNumber
 *
 * Key: distanceRCStateUpdated      Type: distanceRCState - Sends the distance to remote controller state update
 *
*/
@objcMembers public class DistanceRCModelState: DUXBetaStateChangeBaseData {
    
    public static func productConnected(_ isConnected: Bool) -> DistanceRCModelState {
        return DistanceRCModelState(key: "productConnected", number: NSNumber(value: isConnected))
    }
    
    public static func distanceRCStateUpdated(_ DistanceRCState: DistanceRCState) -> DistanceRCModelState {
        return DistanceRCModelState(key: "distanceRCStateUpdated", object: DistanceRCState)
    }
}
