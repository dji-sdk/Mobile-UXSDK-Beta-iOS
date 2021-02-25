//
//  DUXBetaSystemStatusWidgetTests.swift
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

class DUXBetaSystemStatusWidgetTests: XCTestCase {

    var mockKeyManager : DUXBetaMockKeyManager?
    var warningStatusKey : DJIProductKey?
    var maxHeightKey : DJIFlightControllerKey?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
        
        self.warningStatusKey = DJIProductKey(param: DJIProductParamSystemStatus)
        self.maxHeightKey = DJIFlightControllerKey(param: DJIFlightControllerParamMaxFlightHeight)
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }

    func testNormalMessage() {
        let testStatus = DUXBetaMockWarningStatusItem()
        testStatus.overridenWarningLevelProperty = DJIWarningStatusLevel.none
        testStatus.overridenMessageProperty = "hello world"
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.warningStatusKey!) : DUXBetaMockKeyedValue(value: testStatus),
            DUXBetaMockKey(key: self.maxHeightKey!) : DUXBetaMockKeyedValue(value: 400.0)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaSystemStatusWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.suggestedWarningMessage, "hello world")
        widgetModel.cleanup()
    }
    
    func testHeightLimitedMessageMetric() {
        let testStatus = DUXBetaMockWarningStatusItem()
        testStatus.overridenWarningLevelProperty = DJIWarningStatusLevel.none
        testStatus.overridenMessageProperty = "Height Limited Zone"
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.warningStatusKey!) : DUXBetaMockKeyedValue(value: testStatus),
            DUXBetaMockKey(key: self.maxHeightKey!) : DUXBetaMockKeyedValue(value: 100.0)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaSystemStatusWidgetModel()
        widgetModel.unitModule.unitType = .Metric
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.suggestedWarningMessage, "Height Limited Zone - 100.0 m")
        widgetModel.cleanup()
    }
    
    func testHeightLimitedMessageImperial() {
        let testStatus = DUXBetaMockWarningStatusItem()
        testStatus.overridenWarningLevelProperty = DJIWarningStatusLevel.none
        testStatus.overridenMessageProperty = "Height Limited Zone"
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.warningStatusKey!) : DUXBetaMockKeyedValue(value: testStatus),
            DUXBetaMockKey(key: self.maxHeightKey!) : DUXBetaMockKeyedValue(value: 121.92)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaSystemStatusWidgetModel()
        widgetModel.unitModule.unitType = .Imperial
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.suggestedWarningMessage, "Height Limited Zone - 397.0 ft")
        widgetModel.cleanup()
    }
    
    func testCompassErrorVoiceSent() {
        let testStatus = DUXBetaMockWarningStatusItem()
        testStatus.overridenWarningLevelProperty = DJIWarningStatusLevel.none
        testStatus.overridenMessageProperty = "Compass Error"

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.warningStatusKey!) : DUXBetaMockKeyedValue(value: testStatus),
            DUXBetaMockKey(key: self.maxHeightKey!) : DUXBetaMockKeyedValue(value: 121.92)
        ]

        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let voiceNotificationKey = VoiceNotificationKey.init(index: 0, parameter: VoiceNotificationParameter.Attitude)
        XCTAssertNil(DUXBetaSingleton.sharedObservableInMemoryKeyedStore().availableValueFor(key: voiceNotificationKey))

        let widgetModel = DUXBetaSystemStatusWidgetModel()
        widgetModel.unitModule.unitType = .Imperial

        widgetModel.setup()
        XCTAssertEqual(widgetModel.suggestedWarningMessage, "Compass Error")

        XCTAssertNotNil(DUXBetaSingleton.sharedObservableInMemoryKeyedStore().availableValueFor(key: voiceNotificationKey))
        widgetModel.cleanup()
    }
}
