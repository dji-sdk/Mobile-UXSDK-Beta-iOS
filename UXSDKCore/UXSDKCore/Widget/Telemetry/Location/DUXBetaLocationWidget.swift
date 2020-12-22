//
//  DUXBetaLocationWidget.swift
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
@objcMembers public class DUXBetaLocationWidget: DUXBetaBaseTelemetryWidget {
    /// The underlying widget model.
    dynamic public var widgetModel = DUXBetaLocationWidgetModel()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the widget model
        widgetModel.setup()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaLocationWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateUI),
                      (\DUXBetaLocationWidget.widgetModel.locationState.isProductDisconnected).toString,
                      (\DUXBetaLocationWidget.widgetModel.locationState.isLocationUnavailable).toString,
                      (\DUXBetaLocationWidget.widgetModel.locationState.currentLocation).toString)
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
        image = UIImage.duxbeta_image(withAssetNamed: "Location", for: DUXBetaLocationWidget.self)
        labelVisibility = false
        unitVisibility = false
        type = .TextImageLeft
        
        super.setupUI()
        
        valueAlignment = .left
        valueTextMask = "-888.888888, +888.888888"
    }
    
    /**
     * Override the parent updateUI to reflect widget model changes
     */
    open override func updateUI() {
        if widgetModel.locationState.isProductDisconnected || widgetModel.locationState.isLocationUnavailable {
            valueText = NSLocalizedString("N/A, N/A", comment: "N/A, N/A")
        } else {
            valueText = String(format: "%.6f, %.6f ", widgetModel.locationState.currentLocation.latitude, widgetModel.locationState.currentLocation.longitude)
        }
        
        DUXBetaStateChangeBroadcaster.send(LocationModelState.locationStateUpdated(widgetModel.locationState))
        
        super.updateUI()
    }
    
    func updateIsConnected() {
        DUXBetaStateChangeBroadcaster.send(LocationModelState.productConnected(widgetModel.isProductConnected))
    }
}

/**
 * LocationModelState contains the hooks for the model changes in the DUXBetaLocationWidget implementation.
 *
 * Key: productConnected            Type: NSNumber - Sends a boolean value as an NSNumber
 *
 * Key: locationStateUpdated        Type: LocationState - Sends the location state update
 *
*/
@objcMembers public class LocationModelState: DUXBetaStateChangeBaseData {
    
    public static func productConnected(_ isConnected: Bool) -> LocationModelState {
        return LocationModelState(key: "productConnected", number: NSNumber(value: isConnected))
    }
    
    public static func locationStateUpdated(_ locationState: LocationState) -> LocationModelState {
        return LocationModelState(key: "locationStateUpdated", object: locationState)
    }
}
