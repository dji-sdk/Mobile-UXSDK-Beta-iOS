//
//  DUXBetaHorizontalVelocityWidgetTests.swift
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

class DUXBetaHorizontalVelocityWidgetTests: XCTestCase {
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
        
        let widgetModel = DUXBetaHorizontalVelocityWidgetModel()
        widgetModel.setup()
        XCTAssertTrue(widgetModel.horizontalVelocityState.isProductDisconnected)
    }
    
    func testHorizontalVelocity() {
        let horizontalVelocityKey = DJIFlightControllerKey(param: DJIFlightControllerParamVelocity)

        guard let horizontalVelocityKeyUnwrapped = horizontalVelocityKey
            else {
                XCTFail("Found Nil Key")
                return
        }
        
        let velocityVector = DJISDKVector3D()
        velocityVector.x = 100.0
        velocityVector.y = 50.0
        velocityVector.z = 150.0
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: horizontalVelocityKeyUnwrapped) : DUXBetaMockKeyedValue(value: velocityVector)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaHorizontalVelocityWidgetModel()
        widgetModel.setup()
        
        let horizontalVelocityValue = sqrt(velocityVector.x * velocityVector.x + velocityVector.y * velocityVector.y)
        let horizontalVelocity = NSMeasurement(doubleValue: horizontalVelocityValue, unit: UnitLength.meters)
        XCTAssertEqual(widgetModel.horizontalVelocityState.currentVelocity, horizontalVelocity as Measurement<Unit>)
    }
}
