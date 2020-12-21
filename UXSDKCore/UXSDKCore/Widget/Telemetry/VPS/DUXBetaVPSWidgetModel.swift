//
//  DUXBetaVPSWidgetModel.swift
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
 * Widget Model for the DUXBetaVPSWidget used to define
 * the underlying logic and communication.
 */
@objcMembers public class DUXBetaVPSWidgetModel: DUXBetaBaseWidgetModel {
    /// Value of the current VPS state.
    dynamic public var vpsState: VPSState = VPSState()
    /// The module handling the unit type related logic
    dynamic public var unitModule = DUXBetaUnitTypeModule()
    
    dynamic var isEnabled: Bool = false
    dynamic var isBeingUsed: Bool = false
    dynamic var ultrasonicHeight: Double = 0.0
    
    public override init() {
        super.init()
        add(unitModule)
    }
    
    override public func inSetup() {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamVisionAssistedPositioningEnabled) {
            bindSDKKey(key, (\DUXBetaVPSWidgetModel.isEnabled).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamIsUltrasonicBeingUsed) {
            bindSDKKey(key, (\DUXBetaVPSWidgetModel.isBeingUsed).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamUltrasonicHeightInMeters) {
            bindSDKKey(key, (\DUXBetaVPSWidgetModel.ultrasonicHeight).toString)
        }
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaVPSWidgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateHeight),
                      (\DUXBetaVPSWidgetModel.unitModule.unitType).toString,
                      (\DUXBetaVPSWidgetModel.isEnabled).toString,
                      (\DUXBetaVPSWidgetModel.isBeingUsed).toString,
                      (\DUXBetaVPSWidgetModel.ultrasonicHeight).toString)
    }
    
    override public func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
    
    func updateHeight() {
        if isEnabled && isBeingUsed {
            vpsState.isDisabled = false
            // Compute height in meters
            let height = NSMeasurement(doubleValue: ultrasonicHeight, unit: UnitLength.meters)
            vpsState.currentVPS = height.converting(to: (unitModule.unitType == .Metric ? UnitLength.meters : UnitLength.feet))
        } else {
            vpsState.isDisabled = true
        }
    }
    
    func updateIsConnected() {
        vpsState.isProductDisconnected = !isProductConnected
    }
}

/**
 * Class to represent states of VPS.
 */
@objcMembers public class VPSState: NSObject {
    /// Product is disconnected.
    public dynamic var isProductDisconnected: Bool = false
    /// Vision disabled or ultrasonic is not being used.
    public dynamic var isDisabled: Bool = false
    /// Current VPS height.
    public dynamic var currentVPS: Measurement<Unit> = .init(value: 0.0, unit: UnitLength.meters)
}
