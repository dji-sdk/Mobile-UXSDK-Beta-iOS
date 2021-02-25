//
//  DUXBetaGPSSignalWidgetTests.swift
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

class DUXBetaGPSSignalWidgetTests: XCTestCase {

    var mockKeyManager : DUXBetaMockKeyManager?
    var gpsSatelliteCountKey : DJIFlightControllerKey?
    var isRTKEnabledKey : DJIFlightControllerKey?
    var gpsSignalStatusKey : DJIFlightControllerKey?
    var rtkPositioningSolutionKey : DJIFlightControllerKey?
    var rtkBeidouSatelliteCountKey : DJIFlightControllerKey?
    var rtkGPSSatelliteCountKey : DJIFlightControllerKey?
    var rtkGalileoSatelliteCountKey : DJIFlightControllerKey?
    var rtkGlonassSatelliteCountKey : DJIFlightControllerKey?

    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
        
        self.gpsSatelliteCountKey = DJIFlightControllerKey(param: DJIFlightControllerParamSatelliteCount)
        
        self.rtkGPSSatelliteCountKey = DJIFlightControllerKey(index: 0,
                                                       subComponent: DJIFlightControllerRTKSubComponent,
                                                  subComponentIndex: 0,
                                                           andParam: DJIRTKParamMainGPSCount)

        self.rtkBeidouSatelliteCountKey = DJIFlightControllerKey(index: 0,
                                                          subComponent: DJIFlightControllerRTKSubComponent,
                                                     subComponentIndex: 0,
                                                              andParam: DJIRTKParamMainBeidouCount)
        
        self.rtkGalileoSatelliteCountKey = DJIFlightControllerKey(index: 0,
                                                           subComponent: DJIFlightControllerRTKSubComponent,
                                                      subComponentIndex: 0,
                                                               andParam: DJIRTKParamMainGalileoCount)
        
        self.rtkGlonassSatelliteCountKey = DJIFlightControllerKey(index: 0,
                                                           subComponent: DJIFlightControllerRTKSubComponent,
                                                      subComponentIndex: 0,
                                                               andParam: DJIRTKParamMainGlonassCount)
        
        self.isRTKEnabledKey = DJIFlightControllerKey(index: 0,
                                               subComponent: DJIFlightControllerRTKSubComponent,
                                          subComponentIndex: 0,
                                                   andParam: DJIRTKParamEnabled)

        self.rtkPositioningSolutionKey = DJIFlightControllerKey(index: 0,
                                                         subComponent: DJIFlightControllerRTKSubComponent,
                                                    subComponentIndex: 0,
                                                             andParam:DJIRTKParamPositioningSolution)
        
        self.gpsSignalStatusKey = DJIFlightControllerKey(param: DJIFlightControllerParamGPSSignalStatus)
        
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }

    func testSatelliteCountGPS() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.gpsSatelliteCountKey!) : DUXBetaMockKeyedValue(value: 5),
            DUXBetaMockKey(key: self.isRTKEnabledKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaGPSSignalWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.satelliteCount, 5)
        XCTAssertFalse(widgetModel.isRTKEnabled)
        widgetModel.cleanup()
    }
    
    func testSatelliteCountRTK() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.rtkGPSSatelliteCountKey!) : DUXBetaMockKeyedValue(value: 1),
            DUXBetaMockKey(key: self.rtkGalileoSatelliteCountKey!) : DUXBetaMockKeyedValue(value: 2),
            DUXBetaMockKey(key: self.rtkGlonassSatelliteCountKey!) : DUXBetaMockKeyedValue(value: 4),
            DUXBetaMockKey(key: self.rtkBeidouSatelliteCountKey!) : DUXBetaMockKeyedValue(value: 8),
            DUXBetaMockKey(key: self.isRTKEnabledKey!) : DUXBetaMockKeyedValue(value: true)
        ]
            
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaGPSSignalWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.satelliteCount, 15)
        XCTAssertTrue(widgetModel.isRTKEnabled)
        widgetModel.cleanup()
    }
    
    func testGPSSignalStatus() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.gpsSignalStatusKey!) : DUXBetaMockKeyedValue(value:DUXBetaGPSSatelliteStrength.level5.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaGPSSignalWidgetModel()
        
        widgetModel.setup()
        XCTAssert(widgetModel.satelliteSignal == DUXBetaGPSSatelliteStrength.level5)
        widgetModel.cleanup()
    }
    
    func testIsRTKPositioningAccurate() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.rtkPositioningSolutionKey!) : DUXBetaMockKeyedValue(value:DJIRTKPositioningSolution.fixedPoint.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaGPSSignalWidgetModel()
        
        widgetModel.setup()
        XCTAssertTrue(widgetModel.isRTKAccurate)
        widgetModel.cleanup()
    }
    
    func testIsRTKPositioningInaccurate() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.rtkPositioningSolutionKey!) : DUXBetaMockKeyedValue(value:DJIRTKPositioningSolution.float.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaGPSSignalWidgetModel()
        
        widgetModel.setup()
        XCTAssertFalse(widgetModel.isRTKAccurate)
        widgetModel.cleanup()
    }
}

