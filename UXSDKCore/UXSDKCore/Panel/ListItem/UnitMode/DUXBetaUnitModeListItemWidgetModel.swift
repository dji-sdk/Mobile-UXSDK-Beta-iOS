//
//  DUXBetaUnitModeListItemWidgetModel.swift
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
 *  Model for the SystemStatusList widget to show and edit the measurement units in the app. This model
 *  uses the global preferences as the aircraft is always metric and can not be changed.
*/
@objcMembers open class DUXBetaUnitModeListItemWidgetModel : DUXBetaBaseWidgetModel {
    /// The module handling the unit type related logic
    dynamic public var unitModule = DUXBetaUnitTypeModule()
    
    public dynamic var measurementUnit = MeasureUnitType.Metric {
        didSet {
            let unitTypeKey = UnitTypeKey(index: 0, parameter: UnitTypeParameter.Imperial)
            DUXBetaSingleton.sharedObservableInMemoryKeyedStore().set(modelValue: ModelValue(unsignedInteger: UInt(measurementUnit.rawValue)), for: unitTypeKey)
        }
        
    }
    
    public override init() {
        super.init()
        add(unitModule)
    }
    
    open override func inSetup() {
        bindRKVOModel(self, #selector(updateUnit), (\DUXBetaUnitModeListItemWidgetModel.unitModule.unitType).toString)
    }
    
    open override func inCleanup() {
        unbindRKVOModel(self)
    }
    
    func updateUnit() {
        if measurementUnit != unitModule.unitType {
            measurementUnit = unitModule.unitType
        }
    }
}
