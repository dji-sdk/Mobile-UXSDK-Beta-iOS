//
//  LocationWidgetModel.swift
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
 * Widget Model for the DUXBetaLocationWidget used to define
 * the underlying logic and communication
 */
@objcMembers public class DUXBetaLocationWidgetModel: DUXBetaBaseWidgetModel {
    /// Value of the location state of the aircraft
    dynamic public var locationState: LocationState = LocationState()
    
    dynamic var aircraftLocation: CLLocation?
    
    override public func inSetup() {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) {
            bindSDKKey(key, (\DUXBetaLocationWidgetModel.aircraftLocation).toString)
        }
        
        bindRKVOModel(self, #selector(updateIsConnected), (\DUXBetaLocationWidgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateDistance),
                      (\DUXBetaLocationWidgetModel.aircraftLocation).toString)
    }
    
    override public func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
    
    func updateDistance() {
        // Validate aircraft location
        guard let aircraftLocation = aircraftLocation else {
            locationState.isLocationUnavailable = true
            return
        }
        guard CLLocationCoordinate2DIsValid(aircraftLocation.coordinate) else {
            locationState.isLocationUnavailable = true
            return
        }
        
        locationState.isLocationUnavailable = false
        
        // Update location state property
        locationState.currentLocation = aircraftLocation.coordinate
    }
    
    func updateIsConnected() {
        locationState.isProductDisconnected = !isProductConnected
    }
}

/**
 * Class to represent location state of the aircraft 
 */
@objcMembers public class LocationState: NSObject {
    /// Product is disconnected.
    public dynamic var isProductDisconnected: Bool = false
    /// Product is connected, but gps location is unavailable.
    public dynamic var isLocationUnavailable: Bool = false
    /// The aircraft location.
    public dynamic var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
}
