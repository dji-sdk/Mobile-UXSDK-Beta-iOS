//
//  DUXBetaDistanceHomeWidgetModel.swift
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
 * Widget Model for the DUXBetaDistanceHomeWidget used to define
 * the underlying logic and communication.
 */
@objcMembers public class DUXBetaDistanceHomeWidgetModel: DUXBetaBaseWidgetModel {
    /// Value of the distance to home state of the aircraft
    dynamic public var distanceHomeState: DistanceHomeState = DistanceHomeState()
    /// The module handling the unit type related logic
    dynamic public var unitModule = DUXBetaUnitTypeModule()
    
    dynamic var homeLocation: CLLocation?
    dynamic var aircraftLocation: CLLocation?
    
    public override init() {
        super.init()
        add(unitModule)
    }
    
    override public func inSetup() {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamHomeLocation) {
            bindSDKKey(key, (\DUXBetaDistanceHomeWidgetModel.homeLocation).toString)
        }
        
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) {
            bindSDKKey(key, (\DUXBetaDistanceHomeWidgetModel.aircraftLocation).toString)
        }
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaDistanceHomeWidgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateDistance),
                      (\DUXBetaDistanceHomeWidgetModel.unitModule.unitType).toString,
                      (\DUXBetaDistanceHomeWidgetModel.homeLocation).toString,
                      (\DUXBetaDistanceHomeWidgetModel.aircraftLocation).toString)
    }
    
    override public func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
    
    func updateDistance() {
        // Validate home location
        guard let homeLocation = homeLocation else {
            distanceHomeState.isLocationUnavailable = true
            return
        }
        guard CLLocationCoordinate2DIsValid(homeLocation.coordinate) else {
            distanceHomeState.isLocationUnavailable = true
            return
        }
        
        // Validate aircraft location
        guard let aircraftLocation = aircraftLocation else {
            distanceHomeState.isLocationUnavailable = true
            return
        }
        guard CLLocationCoordinate2DIsValid(aircraftLocation.coordinate) else {
            distanceHomeState.isLocationUnavailable = true
            return
        }
        
        distanceHomeState.isLocationUnavailable = false
        
        // Compute distance in meters
        let distanceInMeters = aircraftLocation.distance(from: homeLocation)
        let distance = NSMeasurement(doubleValue: distanceInMeters, unit: UnitLength.meters)
        distanceHomeState.currentDistanceHome = distance.converting(to: (unitModule.unitType == .Metric ? UnitLength.meters : UnitLength.feet))
    }
    
    func updateIsConnected() {
        distanceHomeState.isProductDisconnected = !isProductConnected
    }
}

/**
 * Class to represent states distance of aircraft from the home point
 */
@objcMembers public class DistanceHomeState: NSObject {
    /// Product is disconnected.
    public dynamic var isProductDisconnected: Bool = false
    /// Product is connected but gps location fix is unavailable.
    public dynamic var isLocationUnavailable: Bool = false
    /// The distance to the home point.
    public dynamic var currentDistanceHome: Measurement<Unit> = .init(value: 0.0, unit: UnitLength.meters)
}
