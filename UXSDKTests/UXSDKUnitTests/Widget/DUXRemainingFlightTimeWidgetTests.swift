//
//  DUXBetaRemainingFlightTimeWidgetTests.swift
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

class DUXBetaRemainingFlightTimeWidgetTests: XCTestCase {

    var mockKeyManager: DUXBetaMockKeyManager?
    
    var isConnectedKey : DJIFlightControllerKey?
    var batteryRemainingPercentKey : DJIBatteryKey?
    var batteryPercentToLandKey : DJIFlightControllerKey?
    var batteryPercentToGoHomeKey : DJIFlightControllerKey?
    var seriousLowBatteryThresholdKey : DJIFlightControllerKey?
    var lowBatteryThresholdKey : DJIFlightControllerKey?
    var remainingFlightTimeKey : DJIFlightControllerKey?
    var isFlyingKey : DJIFlightControllerKey?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
        
        self.isConnectedKey = DJIFlightControllerKey(param: DJIParamConnection)
        self.batteryRemainingPercentKey = DJIBatteryKey(param: DJIBatteryParamChargeRemainingInPercent)
        self.batteryPercentToLandKey = DJIFlightControllerKey(param: DJIFlightControllerParamBatteryPercentageNeededToLandFromCurrentHeight)
        self.batteryPercentToGoHomeKey = DJIFlightControllerKey(param:DJIFlightControllerParamBatteryPercentageNeededToGoHome)
        self.seriousLowBatteryThresholdKey = DJIFlightControllerKey(param:DJIFlightControllerParamSeriousLowBatteryWarningThreshold)
        self.lowBatteryThresholdKey = DJIFlightControllerKey(param:DJIFlightControllerParamLowBatteryWarningThreshold)
        self.remainingFlightTimeKey = DJIFlightControllerKey(param:DJIFlightControllerParamRemainingFlightTime)
        self.isFlyingKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsFlying)
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }
    
    func testConnected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.batteryRemainingPercentKey!) : DUXBetaMockKeyedValue(value: 99),
            DUXBetaMockKey(key: self.batteryPercentToLandKey!) : DUXBetaMockKeyedValue(value: 25),
            DUXBetaMockKey(key: self.batteryPercentToGoHomeKey!) : DUXBetaMockKeyedValue(value: 30),
            DUXBetaMockKey(key: self.seriousLowBatteryThresholdKey!) : DUXBetaMockKeyedValue(value: 15),
            DUXBetaMockKey(key: self.lowBatteryThresholdKey!) : DUXBetaMockKeyedValue(value: 20),
            DUXBetaMockKey(key: self.remainingFlightTimeKey!) : DUXBetaMockKeyedValue(value: 4500),
            DUXBetaMockKey(key: self.isFlyingKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaRemainingFlightTimeWidgetModel()
        
        widgetModel.setup()
        XCTAssertTrue(widgetModel.isProductConnected)
        XCTAssertEqual(widgetModel.flightTimeData.remainingCharge, 99)
        XCTAssertEqual(widgetModel.flightTimeData.batteryNeededToLand, 25)
        XCTAssertEqual(widgetModel.flightTimeData.batteryNeededToGoHome, 30)
        XCTAssertEqual(widgetModel.flightTimeData.seriousLowBatteryThreshold, 15)
        XCTAssertEqual(widgetModel.flightTimeData.lowBatteryThreshold, 20)
        XCTAssertEqual(widgetModel.flightTimeData.flightTime, 4500)
        widgetModel.cleanup()
    }
    
    func testDisconnected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: self.batteryRemainingPercentKey!) : DUXBetaMockKeyedValue(value: 99),
            DUXBetaMockKey(key: self.batteryPercentToLandKey!) : DUXBetaMockKeyedValue(value: 25),
            DUXBetaMockKey(key: self.batteryPercentToGoHomeKey!) : DUXBetaMockKeyedValue(value: 30),
            DUXBetaMockKey(key: self.seriousLowBatteryThresholdKey!) : DUXBetaMockKeyedValue(value: 15),
            DUXBetaMockKey(key: self.lowBatteryThresholdKey!) : DUXBetaMockKeyedValue(value: 20),
            DUXBetaMockKey(key: self.remainingFlightTimeKey!) : DUXBetaMockKeyedValue(value: 4500),
            DUXBetaMockKey(key: self.isFlyingKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaRemainingFlightTimeWidgetModel()
        
        widgetModel.setup()
        XCTAssertFalse(widgetModel.isProductConnected)
        XCTAssertEqual(widgetModel.flightTimeData.remainingCharge, 0)
        XCTAssertEqual(widgetModel.flightTimeData.batteryNeededToLand, 0)
        XCTAssertEqual(widgetModel.flightTimeData.batteryNeededToGoHome, 0)
        XCTAssertEqual(widgetModel.flightTimeData.seriousLowBatteryThreshold, 0)
        XCTAssertEqual(widgetModel.flightTimeData.lowBatteryThreshold, 0)
        XCTAssertEqual(widgetModel.flightTimeData.flightTime, 0)
        widgetModel.cleanup()
    }
}

