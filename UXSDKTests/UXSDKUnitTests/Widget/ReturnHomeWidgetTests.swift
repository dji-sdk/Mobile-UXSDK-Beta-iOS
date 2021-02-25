//
//  ReturnHomeWidgetTests.swift
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

class ReturnHomeWidgetTests: XCTestCase {
    
    var mockKeyManager: DUXBetaMockKeyManager?
    
    var isConnectedKey: DJIFlightControllerKey?
    var isFlyingKey: DJIFlightControllerKey?
    var isLandingKey: DJIFlightControllerKey?
    var isGoingHomeKey: DJIFlightControllerKey?
    var areMotorsOnKey: DJIFlightControllerKey?
    var isCancelReturnToHomeDisabledKey: DJIFlightControllerKey?
    var isRTHAtCurrentAltitudeEnabled: DJIFlightControllerKey?
    var remoteControlModeKey: DJIRemoteControllerKey?

    override func setUpWithError() throws {
        mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
        
        isConnectedKey = DJIFlightControllerKey(param: DJIParamConnection)
        isFlyingKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsFlying)
        isLandingKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsLanding)
        isGoingHomeKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsGoingHome)
        areMotorsOnKey = DJIFlightControllerKey(param: DJIFlightControllerParamAreMotorsOn)
        isCancelReturnToHomeDisabledKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsCancelReturnToHomeDisabled)
        isRTHAtCurrentAltitudeEnabled = DJIFlightControllerKey(param: DJIFlightControllerParamConfigRTHInCurrentAltitude)
        remoteControlModeKey = DJIRemoteControllerKey(param: DJIRemoteControllerParamMode)
    }

    override func tearDownWithError() throws {
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }

    func test_Connected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnHomeWidgetModel()
        
        widgetModel.setup()
        XCTAssertTrue(widgetModel.isProductConnected)
        widgetModel.cleanup()
    }
    
    func test_Disconnected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnHomeWidgetModel()
        
        widgetModel.setup()
        XCTAssertFalse(widgetModel.isProductConnected)
        widgetModel.cleanup()
    }
    
    func test_Disconnected_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnHomeWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .Disconnected)
        widgetModel.cleanup()
    }

    func test_ReadyToReturnHome_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isFlyingKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isGoingHomeKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: areMotorsOnKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnHomeWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .ReadyToReturnHome)
        widgetModel.cleanup()
    }
    
    func test_ReturnHomeDisabled_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isFlyingKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnHomeWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .ReturnHomeDisabled)
        widgetModel.cleanup()
    }
    
    func test_NoMotors_ReturnHomeDisabled_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: areMotorsOnKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnHomeWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .ReturnHomeDisabled)
        widgetModel.cleanup()
    }
    
    func test_ReturningHome_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isFlyingKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: areMotorsOnKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isGoingHomeKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isCancelReturnToHomeDisabledKey!) : DUXBetaMockKeyedValue(value: false),
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnHomeWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .ReturningHome)
        widgetModel.cleanup()
    }
    
    func test_ForcedReturningToHome_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isFlyingKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: areMotorsOnKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isGoingHomeKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isCancelReturnToHomeDisabledKey!) : DUXBetaMockKeyedValue(value: true),
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnHomeWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .ForcedReturningToHome)
        widgetModel.cleanup()
    }
    
    func test_ReturningHome_Slave_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isFlyingKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: areMotorsOnKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isGoingHomeKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isCancelReturnToHomeDisabledKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: remoteControlModeKey!) : DUXBetaMockKeyedValue(value: DJIRCMode.master.rawValue)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnHomeWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .ReturningHome)
        widgetModel.cleanup()
    }
    
    func test_ForcedReturningToHome_Slave_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isFlyingKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: areMotorsOnKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isGoingHomeKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isCancelReturnToHomeDisabledKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: remoteControlModeKey!) : DUXBetaMockKeyedValue(value: DJIRCMode.slave.rawValue)
        ]

        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnHomeWidgetModel()

        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .ForcedReturningToHome)
        widgetModel.cleanup()
    }
    
    func test_AutoLanding_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isFlyingKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: areMotorsOnKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaReturnHomeWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .AutoLanding)
        widgetModel.cleanup()
    }
}
