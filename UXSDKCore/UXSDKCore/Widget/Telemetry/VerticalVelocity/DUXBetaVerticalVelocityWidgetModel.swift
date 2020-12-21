//
//  DUXBetaVerticalVelocityWidgetModel.swift
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
 * Widget Model for the DUXBetaVerticalVelocityWidget used to define
 * the underlying logic and communication
 */
@objcMembers public class DUXBetaVerticalVelocityWidgetModel: DUXBetaBaseWidgetModel {
    /// Value of the vertical state of the aircraft
    dynamic public var verticalVelocityState: VerticalVelocityState = VerticalVelocityState()
    /// The module handling the unit type related logic
    dynamic public var unitModule = DUXBetaUnitTypeModule()
    
    dynamic var velocityVector: DJISDKVector3D = DJISDKVector3D()
    
    public override init() {
        super.init()
        add(unitModule)
    }
    
    override public func inSetup() {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamVelocity) {
            bindSDKKey(key, (\DUXBetaVerticalVelocityWidgetModel.velocityVector).toString)
        }
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaVerticalVelocityWidgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateVelocity),
                      (\DUXBetaVerticalVelocityWidgetModel.unitModule.unitType).toString,
                      (\DUXBetaVerticalVelocityWidgetModel.velocityVector).toString,
                      (\DUXBetaVerticalVelocityWidgetModel.isProductConnected).toString)
    }
    
    override public func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
    
    func updateVelocity() {
        //Compute system unit
        let unit = (unitModule.unitType == .Metric ? UnitLength.meters : UnitLength.feet)
        
        //Compute velocity value
        let velocity = abs(velocityVector.z)
        
        //Convert sdk value into corresponding measurement values based on system unit
        let verticalVelocity = NSMeasurement(doubleValue: velocity, unit: UnitLength.meters).converting(to: unit)
        let zeroVelocity = NSMeasurement(doubleValue: 0.0, unit: unit) as Measurement<Unit>
        
        if velocityVector.z < 0 {
            verticalVelocityState.upwardVelocity = verticalVelocity
            verticalVelocityState.downwardVelocity = zeroVelocity
        } else if velocityVector.z > 0 {
            verticalVelocityState.downwardVelocity = verticalVelocity
            verticalVelocityState.upwardVelocity = zeroVelocity
        } else {
            verticalVelocityState.idleUnit = unit
            verticalVelocityState.upwardVelocity = zeroVelocity
            verticalVelocityState.downwardVelocity = zeroVelocity
        }
    }
    
    func updateIsConnected() {
        verticalVelocityState.isProductDisconnected = !isProductConnected
    }
}

/**
 * Class to represent states of the vertical velocity
 */
@objcMembers public class VerticalVelocityState: NSObject {
    /// Product is disconnected.
    public dynamic var isProductDisconnected: Bool = false
    /// The current system unit when aircraft is idle.
    public dynamic var idleUnit: Unit = UnitLength.meters
    /// The current velocity when aircraft is moving in upward direction.
    public dynamic var upwardVelocity: Measurement<Unit> = .init(value: 0.0, unit: UnitLength.meters)
    /// The current velocity when aircraft is moving in downward direction.
    public dynamic var downwardVelocity: Measurement<Unit> = .init(value: 0.0, unit: UnitLength.meters)
}
