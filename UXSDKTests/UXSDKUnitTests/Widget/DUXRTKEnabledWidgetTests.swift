//
//  DUXBetaRTKEnabledWidgetTests.swift
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
import DJISDK

class DUXBetaRTKEnabledWidgetTests: XCTestCase {

    var mockKeyManager: DUXBetaMockKeyManager?

    var areMotorsOnKey: DJIFlightControllerKey?
    
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager

        self.areMotorsOnKey = DJIFlightControllerKey(param: DJIFlightControllerParamAreMotorsOn)
    }
    
    func testCannotEnableRTKSourceType() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.areMotorsOnKey!) : DUXBetaMockKeyedValue(value: true)
        ]

        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let widgetModel = DUXBetaRTKEnabledWidgetModel()
        widgetModel.setup()
        let djiRTK = DUXBetaMockAircraft.shared().flightController!.rtk!
        let djiRTKState = DUXBetaMockRTKState()
        djiRTKState.mockIsTakeoffAltitudeRecorded = true
        djiRTKState.mockHomePointDataSource = DJIRTKDataSource.GPS
        djiRTK.delegate?.rtk?(djiRTK, didUpdate: djiRTKState)
        XCTAssertFalse(widgetModel.canEnableRTK)
        widgetModel.cleanup()
    }
    
    func testCannotEnableRTKHomeAltitude() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.areMotorsOnKey!) : DUXBetaMockKeyedValue(value: true)
        ]

        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let widgetModel = DUXBetaRTKEnabledWidgetModel()
        widgetModel.setup()
        let djiRTK = DUXBetaMockAircraft.shared().flightController!.rtk!
        let djiRTKState = DUXBetaMockRTKState()
        djiRTKState.mockIsTakeoffAltitudeRecorded = false
        djiRTKState.mockHomePointDataSource = DJIRTKDataSource.RTK
        djiRTK.delegate?.rtk?(djiRTK, didUpdate: djiRTKState)
        XCTAssertFalse(widgetModel.canEnableRTK)
        widgetModel.cleanup()
    }
    
    func testCanEnableMotorsOff() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.areMotorsOnKey!) : DUXBetaMockKeyedValue(value: false)
        ]

        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let widgetModel = DUXBetaRTKEnabledWidgetModel()
        widgetModel.setup()
        let djiRTK = DUXBetaMockAircraft.shared().flightController!.rtk!
        let djiRTKState = DUXBetaMockRTKState()
        djiRTKState.mockIsTakeoffAltitudeRecorded = false
        djiRTKState.mockHomePointDataSource = DJIRTKDataSource.GPS
        djiRTK.delegate?.rtk?(djiRTK, didUpdate: djiRTKState)
        XCTAssertTrue(widgetModel.canEnableRTK)
        widgetModel.cleanup()
    }

    func testCanEnableHomePointSet() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.areMotorsOnKey!) : DUXBetaMockKeyedValue(value: true)
        ]

        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let widgetModel = DUXBetaRTKEnabledWidgetModel()
        widgetModel.setup()
        let djiRTK = DUXBetaMockAircraft.shared().flightController!.rtk!
        let djiRTKState = DUXBetaMockRTKState()
        djiRTKState.mockIsTakeoffAltitudeRecorded = true
        djiRTKState.mockHomePointDataSource = DJIRTKDataSource.RTK
        djiRTK.delegate?.rtk?(djiRTK, didUpdate: djiRTKState)
        XCTAssertTrue(widgetModel.canEnableRTK)
        widgetModel.cleanup()
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }
}
