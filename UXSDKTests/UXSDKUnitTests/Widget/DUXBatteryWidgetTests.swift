//
//  DUXBetaBatteryWidgetTests.swift
//  UXSDKUnitTests
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

import XCTest

class DUXBetaBatteryWidgetTests: XCTestCase {
    
    var mockKeyManager: DUXBetaMockKeyManager?
    
    var cleanWarningRecord : DUXBetaMockBatteryWarningRecord?
    
    //MSDK Keys
    var overallBatteryStatusKey : DJIFlightControllerKey?
    var percentageNeededToGoHomeKey : DJIFlightControllerKey?
    var battery1PercentageKey : DJIBatteryKey?
    var battery2PercentageKey : DJIBatteryKey?
    var battery1VoltageKey : DJIBatteryKey?
    var battery2VoltageKey : DJIBatteryKey?
    var batteryAggregationStateKey : DJIBatteryKey?
    var isConnectedKey : DJIFlightControllerKey?
    var battery1WarningKey : DJIBatteryKey?
    var battery2WarningKey : DJIBatteryKey?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
        
        self.cleanWarningRecord = DUXBetaMockBatteryWarningRecord()
        self.cleanWarningRecord!.damagedCellIndex = -1;
        self.cleanWarningRecord!.isOverHeated = false;
        
        self.overallBatteryStatusKey = DJIFlightControllerKey(param: DJIFlightControllerParamBatteryThresholdBehavior)
        self.percentageNeededToGoHomeKey = DJIFlightControllerKey(param: DJIFlightControllerParamBatteryPercentageNeededToGoHome)
        self.battery1PercentageKey = DJIBatteryKey(index:0, andParam: DJIBatteryParamChargeRemainingInPercent)
        self.battery2PercentageKey = DJIBatteryKey(index:1, andParam: DJIBatteryParamChargeRemainingInPercent)
        self.battery1VoltageKey = DJIBatteryKey(index:0, andParam: DJIBatteryParamCellVoltages)
        self.battery2VoltageKey = DJIBatteryKey(index:1, andParam: DJIBatteryParamCellVoltages)
        self.batteryAggregationStateKey = DJIBatteryKey(aggregationParam: DJIBatteryParamAggregationState)
        self.isConnectedKey = DJIFlightControllerKey(param:DJIParamConnection)
        
        self.battery1WarningKey = DJIBatteryKey(index: 0, andParam: DJIBatteryParamLatestWarningRecord)
        self.battery2WarningKey = DJIBatteryKey(index: 1, andParam: DJIBatteryParamLatestWarningRecord)
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }
    
    func testSingleBattery() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.overallBatteryStatusKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIBatteryThresholdBehavior.flyNormally.rawValue)),
            DUXBetaMockKey(key: self.battery1PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 100.0)),
            DUXBetaMockKey(key: self.battery1VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery1WarningKey!) : DUXBetaMockKeyedValue(value: self.cleanWarningRecord!),
            DUXBetaMockKey(key: self.battery2WarningKey!) : DUXBetaMockKeyedValue(value: self.cleanWarningRecord!),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()
        
        XCTAssertNotNil(widgetModel.batteryState)
        
        XCTAssertEqual(widgetModel.batteryState.batteryPercentage, 100.0)
        XCTAssertEqual(widgetModel.batteryState.voltage.value, 3.5)
        XCTAssertEqual(widgetModel.batteryState.warningStatus.rawValue, DUXBetaBatteryStatus.normal.rawValue)

        widgetModel.cleanup()
    }
    
    func testDualBatteryBothNormal() {
        let batteryAggregationState = DUXBetaMockBatteryAggregationState()
        batteryAggregationState.numberOfConnectedBatteries = 2
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.batteryAggregationStateKey!) : DUXBetaMockKeyedValue(value:batteryAggregationState),
            DUXBetaMockKey(key: self.overallBatteryStatusKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIBatteryThresholdBehavior.flyNormally.rawValue)),
            DUXBetaMockKey(key: self.battery1PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 100.0)),
            DUXBetaMockKey(key: self.battery2PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 100.0)),
            DUXBetaMockKey(key: self.battery1VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery2VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery1WarningKey!) : DUXBetaMockKeyedValue(value: self.cleanWarningRecord!),
            DUXBetaMockKey(key: self.battery2WarningKey!) : DUXBetaMockKeyedValue(value: self.cleanWarningRecord!),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()
        
        XCTAssertTrue(widgetModel.batteryState is DUXBetaDualBatteryState)

        XCTAssertEqual(widgetModel.batteryState.warningStatus.rawValue, DUXBetaBatteryStatus.normal.rawValue)
        XCTAssertEqual(widgetModel.batteryState.voltage.value, 3.5)
        XCTAssertEqual(widgetModel.batteryState.batteryPercentage, 100.0)
        
        widgetModel.cleanup()
    }
    
    func testDualBatteryOneOverheating() {
        let overheatingBatteryWarning = DUXBetaMockBatteryWarningRecord()
        overheatingBatteryWarning.isOverHeated = true
        let normalBatteryWarning = DJIBatteryWarningRecord()
        
        let batteryAggregationState = DUXBetaMockBatteryAggregationState()
        batteryAggregationState.numberOfConnectedBatteries = 2
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.batteryAggregationStateKey!) : DUXBetaMockKeyedValue(value:batteryAggregationState),
            DUXBetaMockKey(key: self.overallBatteryStatusKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIBatteryThresholdBehavior.flyNormally.rawValue)),
            DUXBetaMockKey(key: self.battery1PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 100.0)),
            DUXBetaMockKey(key: self.battery2PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 100.0)),
            DUXBetaMockKey(key: self.battery1VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery2VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery1WarningKey!) : DUXBetaMockKeyedValue(value: overheatingBatteryWarning),
            DUXBetaMockKey(key: self.battery2WarningKey!) : DUXBetaMockKeyedValue(value: normalBatteryWarning),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()
        
        XCTAssertNotNil(widgetModel.batteryState)
        
        XCTAssertTrue(widgetModel.batteryState is DUXBetaDualBatteryState)
        
        if let dualBatteryState = widgetModel.batteryState as? DUXBetaDualBatteryState {
            XCTAssertEqual(dualBatteryState.warningStatus.rawValue, DUXBetaBatteryStatus.overheating.rawValue)
            
            XCTAssertEqual(dualBatteryState.voltage.value, 3.5)
            XCTAssertEqual(dualBatteryState.batteryPercentage, 100.0)
            
            XCTAssertEqual(dualBatteryState.battery2Voltage.value, 3.5)
            XCTAssertEqual(dualBatteryState.battery2Percentage, 100.0)
        }
        widgetModel.cleanup()
    }
    
    func testDualBatteryWarningLevel2() {
        let batteryAggregationState = DUXBetaMockBatteryAggregationState()
        batteryAggregationState.numberOfConnectedBatteries = 2
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.batteryAggregationStateKey!) : DUXBetaMockKeyedValue(value:batteryAggregationState),
            DUXBetaMockKey(key: self.overallBatteryStatusKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIBatteryThresholdBehavior.landImmediately.rawValue)),
            DUXBetaMockKey(key: self.battery1PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 100.0)),
            DUXBetaMockKey(key: self.battery2PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 100.0)),
            DUXBetaMockKey(key: self.battery1VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery2VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery1WarningKey!) : DUXBetaMockKeyedValue(value: self.cleanWarningRecord!),
            DUXBetaMockKey(key: self.battery2WarningKey!) : DUXBetaMockKeyedValue(value: self.cleanWarningRecord!),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()
        
        XCTAssertNotNil(widgetModel.batteryState)
        
        XCTAssertTrue(widgetModel.batteryState is DUXBetaDualBatteryState)

        if let dualBatteryState = widgetModel.batteryState as? DUXBetaDualBatteryState {
            XCTAssertEqual(dualBatteryState.warningStatus.rawValue, DUXBetaBatteryStatus.warningLevel2.rawValue)
            
            XCTAssertEqual(dualBatteryState.voltage.value, 3.5)
            XCTAssertEqual(dualBatteryState.batteryPercentage, 100.0)
            
            XCTAssertEqual(dualBatteryState.battery2Voltage.value, 3.5)
            XCTAssertEqual(dualBatteryState.battery2Percentage, 100.0)
        }
        widgetModel.cleanup()
    }
    
    func testDualBatteryWarningLevel1() {
        let batteryAggregationState = DUXBetaMockBatteryAggregationState()
        batteryAggregationState.numberOfConnectedBatteries = 2
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.batteryAggregationStateKey!) : DUXBetaMockKeyedValue(value:batteryAggregationState),
            DUXBetaMockKey(key: self.overallBatteryStatusKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIBatteryThresholdBehavior.goHome.rawValue)),
            DUXBetaMockKey(key: self.battery1PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 100.0)),
            DUXBetaMockKey(key: self.battery2PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 100.0)),
            DUXBetaMockKey(key: self.battery1VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery2VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery1WarningKey!) : DUXBetaMockKeyedValue(value: self.cleanWarningRecord!),
            DUXBetaMockKey(key: self.battery2WarningKey!) : DUXBetaMockKeyedValue(value: self.cleanWarningRecord!),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()
        
        XCTAssertNotNil(widgetModel.batteryState)
        
        XCTAssertTrue(widgetModel.batteryState is DUXBetaDualBatteryState)

        if let dualBatteryState = widgetModel.batteryState as? DUXBetaDualBatteryState {
            XCTAssertEqual(dualBatteryState.warningStatus.rawValue, DUXBetaBatteryStatus.warningLevel1.rawValue)
            
            XCTAssertEqual(dualBatteryState.voltage.value, 3.5)
            XCTAssertEqual(dualBatteryState.batteryPercentage, 100.0)
            
            XCTAssertEqual(dualBatteryState.battery2Voltage.value, 3.5)
            XCTAssertEqual(dualBatteryState.battery2Percentage, 100.0)
        }
        widgetModel.cleanup()
    }
    
    func testDualBatteryWarningLevel1_GoHomeThreshold() {
        let batteryAggregationState = DUXBetaMockBatteryAggregationState()
        batteryAggregationState.numberOfConnectedBatteries = 2
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.batteryAggregationStateKey!) : DUXBetaMockKeyedValue(value:batteryAggregationState),
            DUXBetaMockKey(key: self.percentageNeededToGoHomeKey!) : DUXBetaMockKeyedValue(value:30),
            DUXBetaMockKey(key: self.overallBatteryStatusKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIBatteryThresholdBehavior.flyNormally.rawValue)),
            DUXBetaMockKey(key: self.battery1PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 29.0)),
            DUXBetaMockKey(key: self.battery2PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 31.0)),
            DUXBetaMockKey(key: self.battery1VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery2VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery1WarningKey!) : DUXBetaMockKeyedValue(value: self.cleanWarningRecord!),
            DUXBetaMockKey(key: self.battery2WarningKey!) : DUXBetaMockKeyedValue(value: self.cleanWarningRecord!),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()
        
        XCTAssertNotNil(widgetModel.batteryState)
        
        XCTAssertTrue(widgetModel.batteryState is DUXBetaDualBatteryState)

        if let dualBatteryState = widgetModel.batteryState as? DUXBetaDualBatteryState {
            XCTAssertEqual(dualBatteryState.warningStatus.rawValue, DUXBetaBatteryStatus.warningLevel1.rawValue)
            
            XCTAssertEqual(dualBatteryState.voltage.value, 3.5)
            XCTAssertEqual(dualBatteryState.batteryPercentage, 29.0)
            
            XCTAssertEqual(dualBatteryState.battery2Voltage.value, 3.5)
            XCTAssertEqual(dualBatteryState.battery2Percentage, 31.0)
        }
        widgetModel.cleanup()
    }

    func testAggregateBatteryNormal() {
        let batteryAggregationState = DUXBetaMockBatteryAggregationState()
        batteryAggregationState.numberOfConnectedBatteries = 6
        batteryAggregationState.chargeRemainingInPercent = 100
        batteryAggregationState.voltage = 3500

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.batteryAggregationStateKey!) : DUXBetaMockKeyedValue(value:batteryAggregationState),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()

        XCTAssertNotNil(widgetModel.batteryState)
        XCTAssertEqual(widgetModel.batteryState.voltage.value, 3.5)
        XCTAssertEqual(widgetModel.batteryState.batteryPercentage, 100.0)
        XCTAssertEqual(widgetModel.batteryState.warningStatus.rawValue, DUXBetaBatteryStatus.normal.rawValue)
        
        widgetModel.cleanup()
    }
    
    func testAggregateBatteryError() {
        let batteryAggregationState = DUXBetaMockBatteryAggregationState()
        batteryAggregationState.numberOfConnectedBatteries = 6
        batteryAggregationState.chargeRemainingInPercent = 100
        batteryAggregationState.voltage = 3500
        batteryAggregationState.isCellDamaged = true

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.batteryAggregationStateKey!) : DUXBetaMockKeyedValue(value:batteryAggregationState),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()

        XCTAssertNotNil(widgetModel.batteryState)
        XCTAssertEqual(widgetModel.batteryState.voltage.value, 3.5)
        XCTAssertEqual(widgetModel.batteryState.batteryPercentage, 100.0)
        XCTAssertEqual(widgetModel.batteryState.warningStatus.rawValue, DUXBetaBatteryStatus.error.rawValue)
        
        widgetModel.cleanup()
    }
    
    func testAggregateBatteryOverheating() {
        let batteryAggregationState = DUXBetaMockBatteryAggregationState()
        batteryAggregationState.numberOfConnectedBatteries = 6
        batteryAggregationState.chargeRemainingInPercent = 100
        batteryAggregationState.voltage = 3500

        let overheatingWarningRecord = DUXBetaMockBatteryWarningRecord()
        overheatingWarningRecord.isOverHeated = true
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.battery1WarningKey!) : DUXBetaMockKeyedValue(value: overheatingWarningRecord),
            DUXBetaMockKey(key: self.batteryAggregationStateKey!) : DUXBetaMockKeyedValue(value:batteryAggregationState),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()

        XCTAssertNotNil(widgetModel.batteryState)
        XCTAssertEqual(widgetModel.batteryState.voltage.value, 3.5)
        XCTAssertEqual(widgetModel.batteryState.batteryPercentage, 100.0)
        XCTAssertEqual(widgetModel.batteryState.warningStatus.rawValue, DUXBetaBatteryStatus.overheating.rawValue)
        
        widgetModel.cleanup()
    }
    
    func testAggregateBatteryWarningLevel2() {
        let batteryAggregationState = DUXBetaMockBatteryAggregationState()
        batteryAggregationState.numberOfConnectedBatteries = 6
        batteryAggregationState.chargeRemainingInPercent = 100
        batteryAggregationState.voltage = 3500
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.overallBatteryStatusKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIBatteryThresholdBehavior.landImmediately.rawValue)),
            DUXBetaMockKey(key: self.batteryAggregationStateKey!) : DUXBetaMockKeyedValue(value:batteryAggregationState),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()

        XCTAssertNotNil(widgetModel.batteryState)
        XCTAssertEqual(widgetModel.batteryState.voltage.value, 3.5)
        XCTAssertEqual(widgetModel.batteryState.batteryPercentage, 100.0)
        XCTAssertEqual(widgetModel.batteryState.warningStatus.rawValue, DUXBetaBatteryStatus.warningLevel2.rawValue)
        
        widgetModel.cleanup()
    }
    
    func testAggregateBatteryWarningLevel1() {
        let batteryAggregationState = DUXBetaMockBatteryAggregationState()
        batteryAggregationState.numberOfConnectedBatteries = 6
        batteryAggregationState.chargeRemainingInPercent = 100
        batteryAggregationState.voltage = 3500
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.overallBatteryStatusKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIBatteryThresholdBehavior.goHome.rawValue)),
            DUXBetaMockKey(key: self.batteryAggregationStateKey!) : DUXBetaMockKeyedValue(value:batteryAggregationState),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()
        
        XCTAssertNotNil(widgetModel.batteryState)
        XCTAssertEqual(widgetModel.batteryState.voltage.value, 3.5)
        XCTAssertEqual(widgetModel.batteryState.batteryPercentage, 100.0)
        XCTAssertEqual(widgetModel.batteryState.warningStatus.rawValue, DUXBetaBatteryStatus.warningLevel1.rawValue)
        
        widgetModel.cleanup()
    }
    
    func testAggregateBatteryWarningLevel1_GoHomeThreshold() {
        let batteryAggregationState = DUXBetaMockBatteryAggregationState()
        batteryAggregationState.numberOfConnectedBatteries = 6
        batteryAggregationState.chargeRemainingInPercent = 29
        batteryAggregationState.voltage = 3500
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.overallBatteryStatusKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIBatteryThresholdBehavior.goHome.rawValue)),
            DUXBetaMockKey(key: self.percentageNeededToGoHomeKey!) : DUXBetaMockKeyedValue(value:30),
            DUXBetaMockKey(key: self.batteryAggregationStateKey!) : DUXBetaMockKeyedValue(value:batteryAggregationState),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()
        
        XCTAssertNotNil(widgetModel.batteryState)
        XCTAssertEqual(widgetModel.batteryState.voltage.value, 3.5)
        XCTAssertEqual(widgetModel.batteryState.batteryPercentage, 29.0)
        XCTAssertEqual(widgetModel.batteryState.warningStatus.rawValue, DUXBetaBatteryStatus.warningLevel1.rawValue)
        
        widgetModel.cleanup()
    }
    
    func testProductDisconnected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.overallBatteryStatusKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIBatteryThresholdBehavior.flyNormally.rawValue)),
            DUXBetaMockKey(key: self.battery1PercentageKey!) : DUXBetaMockKeyedValue(value: NSNumber(floatLiteral: 100.0)),
            DUXBetaMockKey(key: self.battery1VoltageKey!) : DUXBetaMockKeyedValue(value: [3500.0, 3500.0, 3500.0]),
            DUXBetaMockKey(key: self.battery1WarningKey!) : DUXBetaMockKeyedValue(value: DJIBatteryWarningRecord()),
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaBatteryWidgetModel()
        widgetModel.setup()
        
        XCTAssertNotNil(widgetModel.batteryState)
        
        XCTAssertTrue(widgetModel.batteryState.isMember(of: DUXBetaBatteryState.self))
        
        XCTAssertEqual(widgetModel.batteryState.batteryPercentage, 0.0)
        XCTAssertEqual(widgetModel.batteryState.voltage.value, 0.0)
        XCTAssertEqual(widgetModel.batteryState.warningStatus.rawValue, DUXBetaBatteryStatus.unknown.rawValue)
        
        widgetModel.cleanup()
    }
}
