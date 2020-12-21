//
//  DUXBetaAltitudeWidgetModel.swift
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
 * Widget Model for the DUXBetaAMSLAltitudeWidget and DUXBetaAGLAltitudeWidget used to define
 * the underlying logic and communication.
 */
@objcMembers public class DUXBetaAltitudeWidgetModel: DUXBetaBaseWidgetModel {
    /// Value of the altitude state of the aircraft
    dynamic public var altitudeState: AltitudeState = AltitudeState()
    /// The module handling the unit type related logic
    dynamic public var unitModule = DUXBetaUnitTypeModule()
    
    dynamic var altitude: Double = 0.0
    dynamic var takeOffLocationAltitude: Double = 0.0
    
    public override init() {
        super.init()
        add(unitModule)
    }
    
    override public func inSetup() {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamAltitudeInMeters) {
            bindSDKKey(key, (\DUXBetaAltitudeWidgetModel.altitude).toString)
        }
        
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamTakeoffLocationAltitude) {
            bindSDKKey(key, (\DUXBetaAltitudeWidgetModel.takeOffLocationAltitude).toString)
        }
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaAltitudeWidgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateAltitude),
                      (\DUXBetaAltitudeWidgetModel.unitModule.unitType).toString,
                      (\DUXBetaAltitudeWidgetModel.altitude).toString,
                      (\DUXBetaAltitudeWidgetModel.takeOffLocationAltitude).toString)
    }
    
    override public func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
    
    func updateAltitude() {
        //Compute system unit
        let unit = (unitModule.unitType == .Metric ? UnitLength.meters : UnitLength.feet)
        
        //Convert sdk values into corresponding measurement values based on system unit
        let altitudeAGL = NSMeasurement(doubleValue: altitude, unit: UnitLength.meters).converting(to: unit)
        let takeOffAltitude = NSMeasurement(doubleValue: takeOffLocationAltitude, unit: UnitLength.meters).converting(to: unit)
        
        //Update altitude model state
        altitudeState.altitudeAGL = altitudeAGL
        altitudeState.altitudeAMSL = altitudeAGL + takeOffAltitude
    }
    
    func updateIsConnected() {
        altitudeState.isProductDisconnected = !isProductConnected
    }
}

/**
 * Class to represent states of the altitude
 */
@objcMembers public class AltitudeState: NSObject {
    /// Product is disconnected.
    public dynamic var isProductDisconnected: Bool = false
    /// The altitude measurement above ground level.
    public dynamic var altitudeAGL: Measurement<Unit> = .init(value: 0.0, unit: UnitLength.meters)
    /// The altitude measurement above mean sea level.
    public dynamic var altitudeAMSL: Measurement<Unit> = .init(value: 0.0, unit: UnitLength.meters)
}
