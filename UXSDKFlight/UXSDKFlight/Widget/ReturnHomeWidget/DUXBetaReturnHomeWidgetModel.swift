//
//  DUXBetaReturnHomeWidgetModel.swift
//  UXSDKFlight
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
import UXSDKCore

/**
 * Enum defining the state of the aircraft.
 */
@objc public enum DUXBetaReturnHomeState: Int {
    public typealias RawValue = Int
    
    /**
     * The aircraft is ready to return to home.
     */
    case ReadyToReturnHome
    
    /**
     * The aircraft cannot return to home.
     */
    case ReturnHomeDisabled
    
    /**
     * The aircraft has started returning to home.
     */
    case ReturningHome
    
    /**
     * The aircraft has started returning to home and it cannot be canceled.
     */
    case ForcedReturningToHome
    
    /**
     * The aircraft has started auto landing.
     */
    case AutoLanding
    
    /**
     * The aircraft is disconnected.
     */
    case Disconnected
}

/**
 * Data model for the ReturnHomeWidget used to define
 * the underlying logic and communication.
*/
@objcMembers public class DUXBetaReturnHomeWidgetModel: DUXBetaBaseWidgetModel {
    /// The state of the model.
    dynamic public var state: DUXBetaReturnHomeState = .Disconnected
    /// The boolean value indicating if aircraft is flying.
    dynamic public var isFlying = false
    /// The boolean value indicating if aircraft is landing.
    dynamic public var isLanding = false
    /// The boolean value indicating if aircraft is going home.
    dynamic public var isGoingHome = false
    /// The boolean value indicating if aircraft has motors on.
    dynamic public var areMotorsOn = false
    /// The boolean value indicating if return to home cancel is disabled.
    dynamic public var isCancelReturnToHomeDisabled = false
    /// The boolean value indicating if auto landing is disabled.
    dynamic public var isRTHAtCurrentAltitudeEnabled = false
    /// The enum value describing whether the return to home route
    /// is clear of, near, or passes through a fly zone.
    dynamic public var rthFlyzoneState: DJIFlyZoneReturnToHomeState = .unknown
    /// The remote control mode of the aircraft.
    dynamic public var remoteControlMode: DJIRCMode = .unknown
    /// The distance to home in meters.
    dynamic public var distanceToHome: Double = 0.0
    /// The go home height in meters.
    dynamic public var currentGoHomeHeightInMeters: Double = 0.0
    /// The aircraft altitude in meters.
    dynamic public var currentAircraftAltitudeInMeters: Double = 0.0
    /// The aircraft location.
    dynamic public var homeLocation = CLLocation.init()
    /// The aircraft location.
    dynamic public var aircraftLocation = CLLocation.init()
    /// The module handling the unit type related logic
    dynamic public var unitModule = DUXBetaUnitTypeModule()

    public override init() {
        super.init()
        add(unitModule)
    }
    
    /**
     * Override of parent inSetup method that binds properties to keys
     * and attaches method callbacks on properties updates.
     */
    override public func inSetup() {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamIsFlying) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.isFlying).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamIsLanding) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.isLanding).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamIsGoingHome) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.isGoingHome).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamAreMotorsOn) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.areMotorsOn).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamIsCancelReturnToHomeDisabled) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.isCancelReturnToHomeDisabled).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamConfigRTHInCurrentAltitude) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.isRTHAtCurrentAltitudeEnabled).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamReturnToHomeState) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.rthFlyzoneState).toString)
        }
        if let key = DJIRemoteControllerKey(param: DJIRemoteControllerParamMode) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.remoteControlMode).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamGoHomeHeightInMeters) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.currentGoHomeHeightInMeters).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamAltitudeInMeters) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.currentAircraftAltitudeInMeters).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamHomeLocation) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.homeLocation).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) {
            bindSDKKey(key, (\DUXBetaReturnHomeWidgetModel.aircraftLocation).toString)
        }
        
        bindRKVOModel(self, #selector(updateState),
                      (\DUXBetaReturnHomeWidgetModel.isFlying).toString,
                      (\DUXBetaReturnHomeWidgetModel.isLanding).toString,
                      (\DUXBetaReturnHomeWidgetModel.isGoingHome).toString,
                      (\DUXBetaReturnHomeWidgetModel.isCancelReturnToHomeDisabled).toString,
                      (\DUXBetaReturnHomeWidgetModel.isRTHAtCurrentAltitudeEnabled).toString,
                      (\DUXBetaReturnHomeWidgetModel.areMotorsOn).toString,
                      (\DUXBetaReturnHomeWidgetModel.remoteControlMode).toString,
                      (\DUXBetaReturnHomeWidgetModel.rthFlyzoneState).toString,
                      (\DUXBetaReturnHomeWidgetModel.currentGoHomeHeightInMeters).toString,
                      (\DUXBetaReturnHomeWidgetModel.currentAircraftAltitudeInMeters).toString,
                      (\DUXBetaReturnHomeWidgetModel.isProductConnected).toString)
        
        bindRKVOModel(self, #selector(updateDistanceToHome),
                      (\DUXBetaReturnHomeWidgetModel.homeLocation).toString,
                      (\DUXBetaReturnHomeWidgetModel.aircraftLocation).toString)
    }
    
    /**
     * Override of parent inCleanup method that unbinds properties from keys
     * and detaches methods callbacks.
    */
    override public func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
    
    /**
     * Performs return home action.
     */
    @objc public func performReturnHomeAction(_ completion: @escaping DUXBetaWidgetModelActionCompletionBlock) {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamGoHome) {
            DJISDKManager.keyManager()?.performAction(for: key, withArguments: nil, andCompletion: { (finished, response, error) in
                completion(error)
            })
        } else {
            completion(nil)
        }
    }
    
    /**
     * Performs cancel return home action.
     */
    @objc public func performCancelReturnHomeAction(_ completion: @escaping DUXBetaWidgetModelActionCompletionBlock) {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamCancelGoHome) {
            DJISDKManager.keyManager()?.performAction(for: key, withArguments: nil, andCompletion: { (finished, response, error) in
                completion(error)
            })
        } else {
            completion(nil)
        }
    }
    
    /**
     * Updates the state property based on several flight status properties.
     * It gets called anytime a change is detected in the underlying variables.
     */
    @objc public func updateState() {
        var nextState: DUXBetaReturnHomeState = .Disconnected
        
        if isProductConnected {
            if !isFlying || !areMotorsOn {
                nextState = .ReturnHomeDisabled
            } else if isLanding {
                nextState = .AutoLanding
            } else if isGoingHome {
                if isCancelReturnHomeDisabled {
                    nextState = .ForcedReturningToHome
                } else {
                    nextState = .ReturningHome
                }
            } else {
                nextState = .ReadyToReturnHome
            }
        }
        if nextState != state {
            state = nextState
        }
    }
    
    @objc public func updateDistanceToHome() {
        guard CLLocationCoordinate2DIsValid(homeLocation.coordinate) && CLLocationCoordinate2DIsValid(aircraftLocation.coordinate) else {
            distanceToHome = 0.0
            return
        }
        
        guard homeLocation.coordinate.latitude == 0.0 && homeLocation.coordinate.latitude == 0.0 else {
            distanceToHome = 0.0
            return
        }
        
        guard aircraftLocation.coordinate.latitude == 0.0 && aircraftLocation.coordinate.latitude == 0.0 else {
            distanceToHome = 0.0
            return
        }
        
        distanceToHome = aircraftLocation.distance(from: homeLocation)
    }
    
    fileprivate var isCancelReturnHomeDisabled: Bool {
        return isCancelReturnToHomeDisabled || remoteControlMode == .slave
    }
}
