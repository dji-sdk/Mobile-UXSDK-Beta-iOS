//
//  DUXBetaUnitTypeTests.swift
//  UXSDKUnitTests
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

import XCTest
import UXSDKCore

class DUXBetaUnitTypeTests: XCTestCase {

    func test_unitSuffix_Metric() {
        // Given
        let unitModule = DUXBetaUnitTypeModule()
        unitModule.unitType = .Metric
        
        // When
        let suffix = unitModule.unitSuffix
        
        // Then
        XCTAssertEqual("m", suffix)
    }
    
    func test_unitSuffix_Imperial() {
        // Given
        let unitModule = DUXBetaUnitTypeModule()
        unitModule.unitType = .Imperial
        
        // When
        let suffix = unitModule.unitSuffix
        
        // Then
        XCTAssertEqual("ft", suffix)
    }
    
    func test_metersToMeasurement_Metric() {
        // Given
        let unitModule = DUXBetaUnitTypeModule()
        unitModule.unitType = .Metric
        
        // When
        let meters = 100.0
        let convertedValue = unitModule.metersToMeasurementSystem(meters)
        
        // Then
        XCTAssertEqual(meters, convertedValue)
    }
    
    func test_metersToMeasurement_Imperial() {
        // Given
        let unitModule = DUXBetaUnitTypeModule()
        unitModule.unitType = .Imperial
        
        // When
        let meters = 100.0
        let convertedValue = unitModule.metersToMeasurementSystem(meters)
        
        // Then
        XCTAssertEqual(meters * 3.28084, convertedValue)
    }
    
    func test_roundedMetersToMeasurement_Metric() {
        // Given
        let unitModule = DUXBetaUnitTypeModule()
        unitModule.unitType = .Metric
        
        // When
        let meters = 100.0
        let convertedValue = unitModule.measurementRoundeUpToMeters(meters)
        
        // Then
        XCTAssertEqual(meters + 0.15, convertedValue)
    }
    
    func test_roundedMetersToMeasurement_Imperial() {
        // Given
        let unitModule = DUXBetaUnitTypeModule()
        unitModule.unitType = .Imperial
        
        // When
        let meters = 100.0
        let convertedValue = unitModule.measurementRoundeUpToMeters(meters)
        
        // Then
        XCTAssertEqual(meters * 0.3048000097536 + 0.15, convertedValue)
    }
    
    func test_unitString_Metric() {
        // Given
        let unitModule = DUXBetaUnitTypeModule()
        unitModule.unitType = .Metric
        
        // When
        let meters = 100.0
        let string = unitModule.meters(toUnitString: meters)
        
        // Then
        XCTAssertEqual("\(meters)m", string)
    }
    
    func test_unitString_Imperial() {
        // Given
        let unitModule = DUXBetaUnitTypeModule()
        unitModule.unitType = .Imperial
        
        // When
        let meters = 100.0
        let string = unitModule.meters(toUnitString: meters)
        
        // Then
        XCTAssertEqual("\(meters * 3.28084)ft", string)
    }
}
