//
//  AMSLAltitudeWidgetTests.swift
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

class AMSLAltitudeWidgetTests: XCTestCase {
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
        
        let widgetModel = DUXBetaAltitudeWidgetModel()
        widgetModel.setup()
        XCTAssertTrue(widgetModel.altitudeState.isProductDisconnected)
    }
    
    func test_AMSLAltitude() {
        let altitudeKey = DJIFlightControllerKey(param: DJIFlightControllerParamAltitudeInMeters)
        let takeOffAltitudeKey = DJIFlightControllerKey(param: DJIFlightControllerParamTakeoffLocationAltitude)
        
        //Altitude value
        let altitudeAGL: Double = 1000.0
        let takeOffAltitude: Double = 500.0
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: altitudeKey!) : DUXBetaMockKeyedValue(value: altitudeAGL),
                                                             DUXBetaMockKey(key: takeOffAltitudeKey!) : DUXBetaMockKeyedValue(value: takeOffAltitude)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaAltitudeWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.altitudeState.altitudeAMSL == NSMeasurement(doubleValue: altitudeAGL + takeOffAltitude, unit: UnitLength.meters) as Measurement<Unit>)
    }
}
