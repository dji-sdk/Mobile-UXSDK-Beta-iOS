//
//  DUXBetaTravelModeListItemWidgetModel.swift
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
import DJISDK

@objcMembers open class DUXBetaTravelModeListItemWidgetModel : DUXBetaBaseWidgetModel {
    /// Property to indicate if this aircraft has movable landing gear. (i.e. an Inspire series)
    dynamic var isLandingGearMovable = false
    /// Property indicating the current landing gear mode for this aircraft.
    dynamic var landingGearMode: DJILandingGearMode = .unknown

    /**
     * Set up the bindingsfor this model
     */
    open override func inSetup() {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamIsLandingGearMovable) {
            bindSDKKey(key, (\DUXBetaTravelModeListItemWidgetModel.isLandingGearMovable ).toString)
        }
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamLandingGearMode) {
            bindSDKKey(key, (\DUXBetaTravelModeListItemWidgetModel.landingGearMode).toString)
        }

    }
        
    /**
     * And unbind for cleanup
     */
    open override func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
    
    
    open func enterTravelMode(_ completion: @escaping (NSError?) -> Void) {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamLandingGearEnterTransportMode) {
            DJISDKManager.keyManager()?.performAction(for: key, withArguments: nil, andCompletion: { finished, response, error in
                print("SDL enterTravelMode completion finished \(finished), resp \(String(describing: response)), error \(String(describing: error))")
                let e: NSError? = error as NSError?
                completion(e)
            })
        }
    }
    
    open func exitTravelMode(_ completion: @escaping (NSError?) -> Void) {
        if let key = DJIFlightControllerKey(param: DJIFlightControllerParamLandingGearExitTransportMode) {
            DJISDKManager.keyManager()?.performAction(for: key, withArguments: nil, andCompletion: { finished, response, error in
                print("SDL exitTravelMode completion finished \(finished)")
                let e: NSError? = error as NSError?
                completion(e)
            })
        }
    }

}
