//
//  DUXBetaSmartListInternalModel.swift
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
 * DUXBetaSmartListInternalModel - This class is used internally by the default SmartList and subclasses. It listens for isProductConnected
 * and aircraftModel for making decidions in a smartlist.
 *
 * If additional keys need to be added, inSetup to add your own bindings and properties.
 * Then in your SmartListWidget class override DUXBetaSmartListModel.createSmartListInternalsModel() to create your specific model
 */
@objcMembers open class DUXBetaSmartListInternalModel : DUXBetaBaseWidgetModel {
    public var aircraftModel: String = ""
    
    /**
     * Override inSetup in a custom internal model to listen to additional keys.
     */
    open override func inSetup() {
        if let key = DJIProductKey(param: DJIProductParamModelName) {
            bindSDKKey(key, (\DUXBetaSmartListInternalModel.aircraftModel).toString)
            // For testing purposes, create a subclass and then override the DUXBetaSmartListModel.createSmartListInternalsModel()
        }
    }
    
    open override func inCleanup() {
        unbindSDK(self)
    }
}
