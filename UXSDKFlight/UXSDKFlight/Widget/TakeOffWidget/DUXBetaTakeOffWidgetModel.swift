//
//  DUXBetaTakeOffWidgetModel.swift
//  UXSDKFlight
//
//  MIT License
//  
//  Copyright © 2018-2020 DJI
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

let kTakeOffHeight: Double = 1.2
let kPrecisionTakeOffHeight: Double = 6.0
let kLandHeight: Double = 0.3

/**
 * Enum defining the state of the aircraft.
 */
@objc public enum DUXBetaTakeOffLandingState: Int {
    public typealias RawValue = Int
    
    /**
     * The aircraft is ready to take off.
     */
    case ReadyToTakeOff
    
    /**
     * The aircraft is currently flying and is ready to land.
     */
    case ReadyToLand
    
    /**
     * The aircraft has started auto landing.
     */
    case AutoLanding
    
    /**
     * The aircraft has started auto landing and it cannot be canceled.
     */
    case ForcedAutoLanding
    
    /**
     * The aircraft has paused auto landing and is waiting for confirmation before continuing.
     */
    case WaitingForLandingConfirmation
    
    /**
     * The aircraft has determined it is unsafe to land while auto landing is in progress
     */
    case UnsafeToLand
    
    /**
     * The aircraft is returning to its home location.
     */
    case ReturningHome
    
    /**
     * The aircraft cannot take off.
     */
    case TakeOffDisabled
    
    /**
     * The aircraft cannot land.
     */
    case LandDisabled
    
    /**
     * The aircraft is disconnected.
     */
    case Disconnected
}

/**
 * Data model for the DUXBetaTakeOffWidget used to define
 * the underlying logic and communication.
*/
@objcMembers public class DUXBetaTakeOffWidgetModel: DUXBetaBaseWidgetModel {
    /// The state of the model.
    dynamic public var state: DUXBetaTakeOffLandingState = .Disconnected
    /// The boolean value indicating if aircraft is flying.
    dynamic public var isFlying = false
    /// The boolean value indicating if aircraft is landing.
    dynamic public var isLanding = false
    /// The boolean value indicating if aircraft is going home.
    dynamic public var isGoingHome = false
    /// The boolean value indicating if aircraft has motors on.
    dynamic public var areMotorsOn = false
    /// The boolean value indicating if flight mode is ATTI.
    dynamic public var isInAttiMode = false
    /// The boolean value indicating if aircraft requires landing confirmation.
    dynamic public var isLandingConfirmationNeeded = false
    /// The boolean value indicating if aircraft supports precision take off.
    dynamic public var isPrecisionTakeoffSupported = false
    /// The boolean value indicating if auto landing is disabled.
    dynamic public var isCancelAutoLandingDisabled = false
    /// The boolean value indicating if the aircraft is an Inspire2 or any of Matrice200 series.
    dynamic public var isInspire2OrMatrice200Series = false
    /// The confirmation height limit when auto landing.
    dynamic public var forcedLandingHeight: Int = Int.min
    /// The model name of the aircraft.
    dynamic public var modelName: String = ""
    /// The flight mode of the aircraft.
    dynamic public var flightMode: DJIFlightMode = .unknown
    /// The remote control mode of the aircraft.
    dynamic public var remoteControlMode: DJIRCMode = .unknown
    /// The landing protection state of the aircraft.
    dynamic public var landingProtectionState: DJIVisionLandingProtectionState = .none
    /// The module handling the unit type related logic
    dynamic public var unitModule = DUXBetaUnitTypeModule()
    
    /// Get the height the aircraft will reach after takeoff.
    public var takeOffHeight: Double {
        return kTakeOffHeight
    }
    /// Get the height the aircraft will reach after a precision takeoff
    public var precisionTakeOffHeight: Double {
        return kPrecisionTakeOffHeight
    }
    /// Get the current height of the aircraft while waiting for landing confirmation.
    public var landHeight: Double {
        if forcedLandingHeight != Int.min {
            return Double(forcedLandingHeight) * 0.1
        }
        return kLandHeight
    }
    
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
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.isFlying).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamIsLanding) {
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.isLanding).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamIsGoingHome) {
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.isGoingHome).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamFlightMode) {
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.flightMode).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamForceLandingHeight) {
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.forcedLandingHeight).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamIsLandingConfirmationNeeded) {
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.isLandingConfirmationNeeded).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamAreMotorsOn) {
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.areMotorsOn).toString)
        }
        if let key = DJIRemoteControllerKey(param: DJIRemoteControllerParamMode) {
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.remoteControlMode).toString)
        }
        if let key = DJIProductKey(param: DJIProductParamModelName) {
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.modelName).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightAssistantParamPrecisionLandingEnabled) {
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.isPrecisionTakeoffSupported).toString)
        }
        if let key = DJIFlightControllerKey(index: 0,
                                            subComponent: DJIFlightControllerFlightAssistantSubComponent,
                                            subComponentIndex: 0,
                                            andParam: DJIFlightControllerParamLandingProtectionState) {
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.landingProtectionState).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamIsCancelAutoLandingDisabled) {
            bindSDKKey(key, (\DUXBetaTakeOffWidgetModel.isCancelAutoLandingDisabled).toString)
        }
        
        bindRKVOModel(self, #selector(updateIsInAttiMode), (\DUXBetaTakeOffWidgetModel.flightMode).toString)
        bindRKVOModel(self, #selector(updateIsInspire2OrMatrice200Series), (\DUXBetaTakeOffWidgetModel.modelName).toString)
        bindRKVOModel(self, #selector(updateState),
                      (\DUXBetaTakeOffWidgetModel.isFlying).toString,
                      (\DUXBetaTakeOffWidgetModel.isLanding).toString,
                      (\DUXBetaTakeOffWidgetModel.isGoingHome).toString,
                      (\DUXBetaTakeOffWidgetModel.isInAttiMode).toString,
                      (\DUXBetaTakeOffWidgetModel.forcedLandingHeight).toString,
                      (\DUXBetaTakeOffWidgetModel.isLandingConfirmationNeeded).toString,
                      (\DUXBetaTakeOffWidgetModel.areMotorsOn).toString,
                      (\DUXBetaTakeOffWidgetModel.remoteControlMode).toString,
                      (\DUXBetaTakeOffWidgetModel.isInspire2OrMatrice200Series).toString,
                      (\DUXBetaTakeOffWidgetModel.isPrecisionTakeoffSupported).toString,
                      (\DUXBetaTakeOffWidgetModel.landingProtectionState).toString,
                      (\DUXBetaTakeOffWidgetModel.isCancelAutoLandingDisabled).toString,
                      (\DUXBetaTakeOffWidgetModel.isProductConnected).toString)
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
     * Performs take off action.
     */
    public func performTakeOffAction(_ completion: @escaping DUXBetaWidgetModelActionCompletionBlock) {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamStartTakeoff) {
            DJISDKManager.keyManager()?.performAction(for: key, withArguments: nil, andCompletion: { (finished, response, error) in
                completion(error)
            })
        } else {
            completion(nil)
        }
    }
    
    /**
     * Performs precision take off action.
     */
    public func performPrecisionTakeOffAction(_ completion: @escaping DUXBetaWidgetModelActionCompletionBlock) {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamStartPrecisionTakeoff) {
            DJISDKManager.keyManager()?.performAction(for: key, withArguments: nil, andCompletion: { (finished, response, error) in
                completion(error)
            })
        } else {
            completion(nil)
        }
    }
    
    /**
     * Performs landing action.
     */
    public func performLandingAction(_ completion: @escaping DUXBetaWidgetModelActionCompletionBlock) {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamAutoLanding) {
            DJISDKManager.keyManager()?.performAction(for: key, withArguments: nil, andCompletion: { (finished, response, error) in
                completion(error)
            })
        } else {
            completion(nil)
        }
    }
    
    /**
     * Performs the landing confirmation action. This allows aircraft to land when
     * landing confirmation is received.
     */
    public func performLandingConfirmationAction(_ completion: @escaping DUXBetaWidgetModelActionCompletionBlock) {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamConfirmLanding) {
            DJISDKManager.keyManager()?.performAction(for: key, withArguments: nil, andCompletion: { (finished, response, error) in
                completion(error)
            })
        } else {
            completion(nil)
        }
    }
    
    /**
     * Performs cancel landing action.
     */
    public func performCancelLandingAction(_ completion: @escaping DUXBetaWidgetModelActionCompletionBlock) {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamCancelAutoLanding) {
            DJISDKManager.keyManager()?.performAction(for: key, withArguments: nil, andCompletion: { (finished, response, error) in
                completion(error)
            })
        } else {
            completion(nil)
        }
    }
    
    /**
     * Updates the isInAttiMode property based of the flightMode value.
     */
    public func updateIsInAttiMode() {
        isInAttiMode = flightMode == .atti || flightMode == .attiCourseLock || flightMode == .gpsAtti || flightMode == .gpsAttiWristband
    }
    
    /**
     * Updates the isInspire2OrMatrice200Series property based of the aircraft model name.
     */
    public func updateIsInspire2OrMatrice200Series() {
        isInspire2OrMatrice200Series = modelName == DJIAircraftModelNameInspire2 || ProductUtil.isMatrice200Series()
    }
    
    /**
     * Updates the state property based on several flight status properties.
     * It gets called anytime a change is detected in the underlying variables.
     */
    public func updateState() {
        var nextState: DUXBetaTakeOffLandingState = .Disconnected
        
        if isProductConnected {
            if isLanding {
                if cancelAutoLandingDisabled {
                    nextState = .ForcedAutoLanding
                } else if landingProtectionState == .notSafeToLand {
                    nextState = .UnsafeToLand
                } else if isLandingConfirmationNeeded {
                    nextState = .WaitingForLandingConfirmation
                } else {
                    nextState = .AutoLanding
                }
            } else if isGoingHome {
                nextState = .ReturningHome
            } else if !areMotorsOn {
                if remoteControlMode == .slave {
                    nextState = .TakeOffDisabled
                } else {
                    nextState = .ReadyToTakeOff
                }
            } else {
                if remoteControlMode == .slave {
                    nextState = .LandDisabled
                } else {
                    nextState = .ReadyToLand
                }
            }
        }
        if nextState != state {
            state = nextState
        }
    }
    
    fileprivate var cancelAutoLandingDisabled: Bool {
        return isCancelAutoLandingDisabled || remoteControlMode == .slave
    }
}
