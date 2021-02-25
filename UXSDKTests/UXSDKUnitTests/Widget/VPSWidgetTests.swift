//
//  VPSWidgetTests.swift
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

class VPSWidgetTests: XCTestCase {
    var mockKeyManager: DUXBetaMockKeyManager?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }
    
    func test_Disconnected() {
        let isConnectedKey = DJIFlightControllerKey(param: DJIParamConnection)
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVPSWidgetModel()
        widgetModel.setup()
        XCTAssertTrue(widgetModel.vpsState.isProductDisconnected)
    }
    
    func test_isDisabled_False() {
        let isConnectedKey = DJIFlightControllerKey(param: DJIParamConnection)
        let isEnabledKey = DJIFlightControllerKey(param: DJIFlightControllerParamVisionAssistedPositioningEnabled)
        let isBeingUsedKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsUltrasonicBeingUsed)
        
        guard let isEnabledKeyUnwrapped = isEnabledKey,
              let isBeingUsedKeyUnwrapped = isBeingUsedKey,
              let isConnectedKeyUnwrapped = isConnectedKey
        else {
                XCTFail("Found Nil Key(s)")
                return
        }
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKeyUnwrapped) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isEnabledKeyUnwrapped) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isBeingUsedKeyUnwrapped) : DUXBetaMockKeyedValue(value: true)]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVPSWidgetModel()
        widgetModel.setup()
        XCTAssertFalse(widgetModel.vpsState.isDisabled)
    }
    
    func test_isDisabled_True() {
        let isConnectedKey = DJIFlightControllerKey(param: DJIParamConnection)
        let isEnabledKey = DJIFlightControllerKey(param: DJIFlightControllerParamVisionAssistedPositioningEnabled)
        let isBeingUsedKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsUltrasonicBeingUsed)
        
        guard let isEnabledKeyUnwrapped = isEnabledKey,
              let isBeingUsedKeyUnwrapped = isBeingUsedKey,
              let isConnectedKeyUnwrapped = isConnectedKey
        else {
                XCTFail("Found Nil Key(s)")
                return
        }
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKeyUnwrapped) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isEnabledKeyUnwrapped) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isBeingUsedKeyUnwrapped) : DUXBetaMockKeyedValue(value: false)]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVPSWidgetModel()
        widgetModel.setup()
        XCTAssertTrue(widgetModel.vpsState.isDisabled)
    }
    
    func test_EnabledVPS() {
        let isConnectedKey = DJIFlightControllerKey(param: DJIParamConnection)
        let isEnabledKey = DJIFlightControllerKey(param: DJIFlightControllerParamVisionAssistedPositioningEnabled)
        let isBeingUsedKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsUltrasonicBeingUsed)
        let heightInMetersKey = DJIFlightControllerKey(param: DJIFlightControllerParamUltrasonicHeightInMeters)
        
        guard let isEnabledKeyUnwrapped = isEnabledKey,
              let isBeingUsedKeyUnwrapped = isBeingUsedKey,
              let isConnectedKeyUnwrapped = isConnectedKey,
              let heightInMetersKeyUnwrapped = heightInMetersKey
        else {
                XCTFail("Found Nil Key(s)")
                return
        }
        
        let height = 10.0
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKeyUnwrapped) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isEnabledKeyUnwrapped) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isBeingUsedKeyUnwrapped) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: heightInMetersKeyUnwrapped) : DUXBetaMockKeyedValue(value: height)]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVPSWidgetModel()
        widgetModel.setup()
        XCTAssertFalse(widgetModel.vpsState.isDisabled)

        XCTAssert(widgetModel.vpsState.currentVPS == NSMeasurement(doubleValue: height, unit: UnitLength.meters) as Measurement<Unit>)
    }
}
