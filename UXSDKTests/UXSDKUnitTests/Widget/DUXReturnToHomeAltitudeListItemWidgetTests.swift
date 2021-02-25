//
//  DUXBetaReturnToHomeAltitudeListItemWidgetTests.swift
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

class DUXBetaReturnToHomeAltitudeListItemWidgetTests: XCTestCase {

    var mockKeyManager : DUXBetaMockKeyManager?
    
    var noviceModeKey : DJIFlightControllerKey?
    var maxAltitudeKey : DJIFlightControllerKey?
    var returnHomeHeightKey : DJIFlightControllerKey?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
        
        self.noviceModeKey = DJIFlightControllerKey(index: 0, andParam:DJIFlightControllerParamNoviceModeEnabled)
        self.maxAltitudeKey = DJIFlightControllerKey(index: 0, andParam:DJIFlightControllerParamMaxFlightHeight)
        self.returnHomeHeightKey = DJIFlightControllerKey(index: 0, andParam:DJIFlightControllerParamGoHomeHeightInMeters)
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }

    func testSetRTHHeightNoviceMode() {
        let testValue = true;
        let startRTHAltitude: Int = 100
        let finalAltitude: Int = 50
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.noviceModeKey!) : DUXBetaMockKeyedValue(value: testValue),
            DUXBetaMockKey(key: self.returnHomeHeightKey!) : DUXBetaMockKeyedValue(value: startRTHAltitude)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnToHomeAltitudeListItemWidgetModel()
        
        widgetModel.setup()
        widgetModel.updateReturnHomeHeight(finalAltitude) { result in
            XCTAssertEqual(widgetModel.returnToHomeAltitude, Double(startRTHAltitude))
            widgetModel.cleanup()
        }
    }

    func testSetRTHHeightNoNoviceMode() {
        let testValue = false;
        let startRTHAltitude: Int = 100
        let finalAltitude: Int = 50
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.noviceModeKey!) : DUXBetaMockKeyedValue(value: testValue),
            DUXBetaMockKey(key: self.returnHomeHeightKey!) : DUXBetaMockKeyedValue(value: startRTHAltitude)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnToHomeAltitudeListItemWidgetModel()
        
        widgetModel.setup()
        widgetModel.updateReturnHomeHeight(finalAltitude) { result in
            XCTAssertEqual(widgetModel.returnToHomeAltitude, Double(finalAltitude))
            widgetModel.cleanup()
        }
    }

    func testSetOverRTHHeightNoviceMode() {
        let testValue = true;
        let startRTHAltitude: Int = 100
        let finalAltitude: Int = 510
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.noviceModeKey!) : DUXBetaMockKeyedValue(value: testValue),
            DUXBetaMockKey(key: self.returnHomeHeightKey!) : DUXBetaMockKeyedValue(value: startRTHAltitude)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnToHomeAltitudeListItemWidgetModel()
        
        widgetModel.setup()
        widgetModel.updateReturnHomeHeight(finalAltitude) { result in
            XCTAssertEqual(widgetModel.returnToHomeAltitude, Double(startRTHAltitude))
            widgetModel.cleanup()
        }
    }
    
    func testSetOverRTHHeightNoNoviceMode() {
        let testValue = true;
        let startRTHAltitude: Int = 100
        let finalAltitude: Int = 510
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.noviceModeKey!) : DUXBetaMockKeyedValue(value: testValue),
            DUXBetaMockKey(key: self.returnHomeHeightKey!) : DUXBetaMockKeyedValue(value: startRTHAltitude)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnToHomeAltitudeListItemWidgetModel()
        
        widgetModel.setup()
        widgetModel.updateReturnHomeHeight(finalAltitude) { result in
            XCTAssertEqual(widgetModel.returnToHomeAltitude, Double(startRTHAltitude))
            widgetModel.cleanup()
        }
    }


    func testSetRTHOverMaxAltitudeHeightNoNoviceMode() {
        let testValue = false;
        let startRTHAltitude: Int = 80
        let finalAltitude: Int = 120
        let maxAltitude = 100
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.noviceModeKey!) : DUXBetaMockKeyedValue(value: testValue),
            DUXBetaMockKey(key: self.returnHomeHeightKey!) : DUXBetaMockKeyedValue(value: startRTHAltitude),
            DUXBetaMockKey(key: self.maxAltitudeKey!) : DUXBetaMockKeyedValue(value: maxAltitude)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnToHomeAltitudeListItemWidgetModel()
        
        widgetModel.setup()
        widgetModel.updateReturnHomeHeight(finalAltitude) { result in
            XCTAssertEqual(widgetModel.returnToHomeAltitude, Double(startRTHAltitude))
            widgetModel.cleanup()
        }
    }

}
