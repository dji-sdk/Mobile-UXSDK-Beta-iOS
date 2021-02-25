//
//  DUXBetaAirSenseWidgetTests.swift
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

class DUXBetaAirSenseWidgetTests: XCTestCase {

    var mockKeyManager: DUXBetaMockKeyManager?

    var isAirSenseConnectedKey: DJIFlightControllerKey?
    var warningLevelKey: DJIFlightControllerKey?
    var airplaneStatesKey: DJIFlightControllerKey?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager

        self.isAirSenseConnectedKey = DJIFlightControllerKey(param: DJIFlightControllerParamAirSenseSystemConnected)
        self.warningLevelKey = DJIFlightControllerKey(param: DJIFlightControllerParamAirSenseSystemWarningLevel)
        self.airplaneStatesKey = DJIFlightControllerKey(param:DJIFlightControllerParamAirSenseAirplaneStates)
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }

    func testAirSenseWarningLevels() {
        for i in 0...4 {
            let mockValues = [
                DUXBetaMockKey(key: self.isAirSenseConnectedKey!) : DUXBetaMockKeyedValue(value: true),
                DUXBetaMockKey(key: self.warningLevelKey!) : DUXBetaMockKeyedValue(value: i)
            ]
            
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            let widgetModel = DUXBetaAirSenseWidgetModel()
            
            widgetModel.setup()
            XCTAssertEqual(widgetModel.airSenseWarningLevel, UInt(i))
            XCTAssertTrue(widgetModel.isAirSenseConnected)
            widgetModel.cleanup()
        }
    }
    
    func testAirSenseIsConnected() {
        let mockValues = [
            DUXBetaMockKey(key: self.isAirSenseConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.warningLevelKey!) : DUXBetaMockKeyedValue(value: 0),
            DUXBetaMockKey(key: self.airplaneStatesKey!) : DUXBetaMockKeyedValue(value: NSArray())
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaAirSenseWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.airSenseWarningLevel, 0)
        XCTAssertTrue(widgetModel.isAirSenseConnected)
        widgetModel.cleanup()
    }
    
    func testAirSenseIsDisonnected() {
        let mockValues = [
            DUXBetaMockKey(key: self.isAirSenseConnectedKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: self.warningLevelKey!) : DUXBetaMockKeyedValue(value: 0),
            DUXBetaMockKey(key: self.airplaneStatesKey!) : DUXBetaMockKeyedValue(value: NSArray())
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaAirSenseWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.airSenseWarningLevel, UInt(0))
        XCTAssertFalse(widgetModel.isAirSenseConnected)
        XCTAssertEqual(widgetModel.airSenseWarningState, DUXBetaAirSenseState_Disconnected)
        widgetModel.cleanup()
    }
    
    func testAirplaneNearby() {
        let testAirplaneState = DJIAirSenseAirplaneState()
        let nearbyAirplanes = [testAirplaneState]
        
        let mockValues = [
            DUXBetaMockKey(key: self.isAirSenseConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.warningLevelKey!) : DUXBetaMockKeyedValue(value: 0),
            DUXBetaMockKey(key: self.airplaneStatesKey!) : DUXBetaMockKeyedValue(value: nearbyAirplanes)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaAirSenseWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.airSenseWarningLevel, UInt(0))
        XCTAssertTrue(widgetModel.isAirSenseConnected)
        widgetModel.cleanup()
    }
}

