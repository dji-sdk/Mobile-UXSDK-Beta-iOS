//
//  DUXBetaUnitTypeModule.swift
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
 * Abstraction that encapsulates unit type related logic and helper methods.
 */
@objc public class DUXBetaUnitTypeModule: DUXBetaBaseModule {
    /// The type of the current unit.
    @objc dynamic public var unitType: MeasureUnitType = .Metric {
        didSet {
            updateSuffix()
        }
    }
    /// The suffix string specific to the unit type.
    @objc dynamic public var unitSuffix: String = ""
    
    fileprivate let kModelMetersToFeet = 3.28084
    fileprivate let kModelFeetToMeters = 0.3048000097536
    
    fileprivate let unitTypeKey = UnitTypeKey(index: 0, parameter: UnitTypeParameter.Imperial)
    
    /**
     * Set up the module by initializing all the required resources
     */
    public override func setup() {
        // Read from user defaults
        unitType = DUXBetaSingleton.sharedGlobalPreferences().measurementUnitType
        if unitType == .None {
            unitType = .Metric
        }
        
        // Observe the UnitTypeParameter key
        DUXBetaSingleton.sharedObservableInMemoryKeyedStore().add(observer: self,
                                                              for: unitTypeKey,
                                                              broadcastAvailableValue: true) { [weak self] (oldValue, newValue, key) in

            guard let self = self else { return }
            guard let unitTypeValue = newValue?.value as? UInt else { return }
            guard let unitTypeParameter = UnitTypeParameter(rawValue: unitTypeValue) else { return }

            let newUnitType =  MeasureUnitType(unitTypeParameter)
            if self.unitType != newUnitType {
                self.unitType = newUnitType
                DUXBetaSingleton.sharedGlobalPreferences().measurementUnitType = self.unitType
            }
        }
    }
    
    /**
     * Clean up the module by destroying all the resources used
     */
    public override func cleanup() {
        DUXBetaSingleton.sharedObservableInMemoryKeyedStore().remove(observer: self, for: unitTypeKey)
    }
    
    /**
     * The method stringFormat(for:) returns the strign format specific to the given unit type.
     * - Parameters:
     *      - unitType: The given unit type parameter.
     *
     * - Returns: The computed string format.
     */
    public static func stringFormat(for unitType: MeasureUnitType) -> String {
        switch unitType {
        case .Imperial:
            return "%.0f"
        default:
            return "%.1f"
        }
    }
    
    /**
     * The method metersToMeasurementSystem converts the given value to the current unit type.
     * - Parameters:
     *      - measureIn: The value to be converted.
     *
     * - Returns: The result of the conversion.
     */
    @objc public func metersToMeasurementSystem(_ measureIn: Double) -> Double {
        if unitType == .Metric {
            return measureIn
        } else {
            return measureIn * kModelMetersToFeet
        }
    }
    
    /**
     * The method measurementRoundeUpToMeters converts the given value to the current unit type.
     * - Parameters:
     *      - measureIn: The value to be converted.
     *
     * - Returns: The approximate conversion.
     */
    @objc public func measurementRoundeUpToMeters(_ measureIn: Double) -> Double {
        if unitType == .Metric {
            return measureIn + 0.15
        } else {
            return measureIn * kModelFeetToMeters + 0.15
        }
    }
    
    /**
     * The method meters(toUnitString:) converts the given value to the string containing the current unit type and suffix.
     * - Parameters:
     *      - measureIn: The value to be converted.
     *
     * - Returns: The string containing the current unit type and suffix.
     */
    @objc public func meters(toUnitString metersIn: Double) -> String {
        return String(format: Self.stringFormat(for: unitType), metersToMeasurementSystem(metersIn)) + "\(unitSuffix)"
    }
    
    /**
     * The method meters(toIntegerString:) converts the given value to the integer string containing the current unit type and suffix.
     * - Parameters:
     *      - measureIn: The value to be converted.
     *
     * - Returns: The string containing the current unit type and suffix.
     */
    @objc public func meters(toIntegerString metersIn: Double) -> String {
        return String(format: "%.0f", metersToMeasurementSystem(metersIn)) + "\(unitSuffix)"
    }
    
    // MARK - Helper Methods
    
    fileprivate func updateSuffix() {
        unitSuffix = unitType == MeasureUnitType.Imperial ? "ft" : "m"
    }
}
