//
//  DUXBetaCameraSettingsIndicatorWidgetModel.swift
//  UXSDKCameraCore
//
//  MIT License
//  
//  Copyright © 2021 DJI
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

import UXSDKCore

/**
 * Data model for the DUXBetaCameraSettingsIndicatorWidget used to define
 * the underlying logic and communication.
*/
@objcMembers public class DUXBetaCameraSettingsIndicatorWidgetModel: DUXBetaBaseWidgetModel {
    
    // MARK: - Public Properties
    dynamic public var state: DUXBetaCameraSettingsIndicatorState = DUXBetaCameraSettingsIndicatorState()
    /// Index of the camera the widget model is communicating with
    dynamic public var cameraIndex: Int = 0 {
        willSet {
            inCleanup()
        }
        didSet {
            inSetup()
        }
    }
    
    dynamic public var isCameraConnected: Bool = false
    dynamic public var exposureMode: DJICameraExposureMode = .unknown
    
    // MARK: - Private Properties
    
    // MARK: - Public Methods
    
    public override init() {
        super.init()
    }
    
    /**
     * Override of parent inSetup method that binds properties to keys
     * and attaches method callbacks on properties updates.
     */
    override public func inSetup() {
    
        if let key = DJICameraKey(index: cameraIndex, andParam: DJICameraParamExposureMode) {
            bindSDKKey(key, (\DUXBetaCameraSettingsIndicatorWidgetModel.exposureMode).toString)
        }
        if let key = DJICameraKey(index: cameraIndex, andParam: DJIParamConnection) {
            bindSDKKey(key, (\DUXBetaCameraSettingsIndicatorWidgetModel.isCameraConnected).toString)
        }
        bindRKVOModel(self, #selector(updateState),
                      (\DUXBetaCameraSettingsIndicatorWidgetModel.isProductConnected).toString,
                      (\DUXBetaCameraSettingsIndicatorWidgetModel.isCameraConnected).toString,
                      (\DUXBetaCameraSettingsIndicatorWidgetModel.exposureMode).toString)
    }
    
    /**
     * Override of parent inCleanup method that unbinds properties from keys
     * and detaches methods callbacks.
    */
    override public func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }

    // MARK: - Private Methods
    
    @objc func updateState() {
        var mode: DJICameraExposureMode = .unknown
        if isProductConnected {
            state.isProductDisconnected = false
            if isCameraConnected {
                state.isCameraDisconnected = false
                mode = exposureMode
            } else {
                state.isCameraDisconnected = true
            }
        } else {
            state.isProductDisconnected = true
            state.isCameraDisconnected = true
        }
        
        state.cameraSettingsExposureMode = mode
    }

}

/**
 * Class to represent the states of the DUXBetaCameraSettingsIndicatorWidgetModel.
 */
@objcMembers public class DUXBetaCameraSettingsIndicatorState: NSObject {
    /// When product is disconnected.
    public dynamic var isProductDisconnected: Bool = false
    /// When camera is disconnected.
    public dynamic var isCameraDisconnected: Bool = false
    /// When product and camera are connected and exposure mode is updated
    public dynamic var cameraSettingsExposureMode: DJICameraExposureMode = .unknown
}
