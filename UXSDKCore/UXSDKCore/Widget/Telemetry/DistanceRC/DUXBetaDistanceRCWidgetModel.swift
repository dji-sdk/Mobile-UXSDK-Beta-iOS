//
//  DUXBetaDistanceRCWidgetModel.swift
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
 * Widget Model for the DUXBetaDistanceRCWidget used to define
 * the underlying logic and communication.
 */
@objcMembers public class DUXBetaDistanceRCWidgetModel: DUXBetaBaseWidgetModel {
    /// Value of the distance to home state of the aircraft
    dynamic public var distanceRCState: DistanceRCState = DistanceRCState()
    /// The module handling the unit type related logic
    dynamic public var unitModule = DUXBetaUnitTypeModule()
    
    dynamic var rcGPSData: DJIRCGPSData = DJIRCGPSData()
    dynamic var aircraftLocation: CLLocation?
    
    public override init() {
        super.init()
        add(unitModule)
    }
    
    override public func inSetup() {
        if let key = DJIRemoteControllerKey(param: DJIRemoteControllerParamGPSData) {
            bindSDKKey(key, (\DUXBetaDistanceRCWidgetModel.rcGPSData).toString)
        }
        
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) {
            bindSDKKey(key, (\DUXBetaDistanceRCWidgetModel.aircraftLocation).toString)
        }
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaDistanceRCWidgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateDistance),
                      (\DUXBetaDistanceRCWidgetModel.unitModule.unitType).toString,
                      (\DUXBetaDistanceRCWidgetModel.rcGPSData).toString,
                      (\DUXBetaDistanceRCWidgetModel.aircraftLocation).toString,
                      (\DUXBetaDistanceRCWidgetModel.isProductConnected).toString)
    }
    
    override public func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
    
    func updateDistance() {
        // Validate remote controller location
        guard rcGPSData.isValid.boolValue else {
            distanceRCState.isLocationUnavailable = true
            return
        }
        guard CLLocationCoordinate2DIsValid(rcGPSData.location) else {
            distanceRCState.isLocationUnavailable = true
            return
        }
        
        // Validate aircraft location
        guard let aircraftLocation = aircraftLocation else {
            distanceRCState.isLocationUnavailable = true
            return
        }
        guard CLLocationCoordinate2DIsValid(aircraftLocation.coordinate) else {
            distanceRCState.isLocationUnavailable = true
            return
        }
        
        distanceRCState.isLocationUnavailable = false
        
        // Compute distance in meters
        let rcLocation = CLLocation(latitude: rcGPSData.location.latitude, longitude: rcGPSData.location.longitude)
        let distance = NSMeasurement(doubleValue: rcLocation.distance(from: aircraftLocation), unit: UnitLength.meters)
        distanceRCState.currentDistanceRC = distance.converting(to: (unitModule.unitType == .Metric ? UnitLength.meters : UnitLength.feet))
    }
    
    func updateIsConnected() {
        distanceRCState.isProductDisconnected = !isProductConnected
    }
}

/**
 * Class to represent states distance of aircraft from the remote controller location
 */
@objcMembers public class DistanceRCState: NSObject {
    /// Product is disconnected.
    public dynamic var isProductDisconnected: Bool = false
    /// Product is connected, but gps location is unavailable.
    public dynamic var isLocationUnavailable: Bool = false
    /// The distance to the home point.
    public dynamic var currentDistanceRC: Measurement<Unit> = .init(value: 0.0, unit: UnitLength.meters)
}
