//
//  DUXBetaRTKSatelliteStatusWidgetTests.swift
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
import CoreFoundation


class DUXBetaRTKSatelliteStatusWidgetTests: XCTestCase {

    var mockKeyManager: DUXBetaMockKeyManager?

    var flightControllerConnectedKey: DJIFlightControllerKey?
    var isRTKBeingUsedKey: DJIFlightControllerKey?
    var isRTKEnabledKey: DJIFlightControllerKey?
    
    var aircraftLocationKey: DJIFlightControllerKey?
    var baseStationLocationKey: DJIFlightControllerKey?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }

    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager

        self.flightControllerConnectedKey = DJIFlightControllerKey(param: DJIParamConnection);
        
        self.isRTKBeingUsedKey = DJIFlightControllerKey(index: 0,
                                                 subComponent: DJIFlightControllerRTKSubComponent,
                                            subComponentIndex: 0,
                                                     andParam: DJIRTKParamIsRTKBeingUsed)
        
        self.isRTKEnabledKey = DJIFlightControllerKey(index: 0,
                                               subComponent: DJIFlightControllerRTKSubComponent,
                                          subComponentIndex: 0,
                                                   andParam: DJIRTKParamEnabled)
        
        self.aircraftLocationKey = DJIFlightControllerKey(index: 0,
                                                   subComponent: DJIFlightControllerRTKSubComponent,
                                              subComponentIndex: 0,
                                                       andParam: DJIRTKParamMobileStationFusionLocation)
        
        self.baseStationLocationKey = DJIFlightControllerKey(index: 0,
                                                      subComponent: DJIFlightControllerRTKSubComponent,
                                                 subComponentIndex: 0,
                                                          andParam: DJIRTKParamBaseStationLocation)
        
    }

    func testRTKConnectionStatusInUse() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.flightControllerConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isRTKBeingUsedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isRTKEnabledKey!) : DUXBetaMockKeyedValue(value: true)
        ]

        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let widgetModel = DUXBetaRTKSatelliteStatusWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.rtkConnectionStatus, DUXBetaRTKConnectionStatus.inUse)
        widgetModel.cleanup()
    }
    
    func testRTKConnectionStatusNotInUse() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.flightControllerConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isRTKBeingUsedKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: self.isRTKEnabledKey!) : DUXBetaMockKeyedValue(value: true)
        ]

        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let widgetModel = DUXBetaRTKSatelliteStatusWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.rtkConnectionStatus, DUXBetaRTKConnectionStatus.notInUse)
        widgetModel.cleanup()
    }
    
    func testRTKConnectionStatusDisconnectedFlightController() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.flightControllerConnectedKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: self.isRTKBeingUsedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isRTKEnabledKey!) : DUXBetaMockKeyedValue(value: true)
        ]

        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let widgetModel = DUXBetaRTKSatelliteStatusWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.rtkConnectionStatus, DUXBetaRTKConnectionStatus.disconnected)
        widgetModel.cleanup()
    }
    
    func testRTKConnectionStatusDisconnectedRTKDisabled() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.flightControllerConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isRTKBeingUsedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isRTKEnabledKey!) : DUXBetaMockKeyedValue(value: false)
        ]

        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let widgetModel = DUXBetaRTKSatelliteStatusWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.rtkConnectionStatus, DUXBetaRTKConnectionStatus.disconnected)
        widgetModel.cleanup()
    }
}
