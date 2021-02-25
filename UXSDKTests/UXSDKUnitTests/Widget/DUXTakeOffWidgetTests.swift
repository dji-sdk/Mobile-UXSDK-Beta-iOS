//
//  DUXBetaTakeOffWidgetTests.swift
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

class DUXBetaTakeOffWidgetTests: XCTestCase {
    
    var mockKeyManager: DUXBetaMockKeyManager?
    
    var isConnectedKey: DJIFlightControllerKey?
    var isFlyingKey: DJIFlightControllerKey?
    var isLandingKey: DJIFlightControllerKey?
    var isGoingHomeKey: DJIFlightControllerKey?
    var isFlightModeKey: DJIFlightControllerKey?
    var landHeightKey: DJIFlightControllerKey?
    var isLandingConfirmationNeededKey: DJIFlightControllerKey?
    var areMotorsOnKey: DJIFlightControllerKey?
    var remoteControlModeKey: DJIRemoteControllerKey?
    var modelNameKey: DJIProductKey?
    var isPrecisionTakeOffSupportedKey: DJIFlightControllerKey?
    var isCancelAutoLandingDisabledKey: DJIFlightControllerKey?
    var landingProtectionStateKey: DJIFlightControllerKey?

    override func setUpWithError() throws {
        mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
        
        isConnectedKey = DJIFlightControllerKey(param: DJIParamConnection)
        isFlyingKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsFlying)
        isLandingKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsLanding)
        isGoingHomeKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsGoingHome)
        isFlightModeKey = DJIFlightControllerKey(param: DJIFlightControllerParamFlightMode)
        landHeightKey = DJIFlightControllerKey(param: DJIFlightControllerParamForceLandingHeight)
        isLandingConfirmationNeededKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsLandingConfirmationNeeded)
        areMotorsOnKey = DJIFlightControllerKey(param: DJIFlightControllerParamAreMotorsOn)
        remoteControlModeKey = DJIRemoteControllerKey(param: DJIRemoteControllerParamMode)
        modelNameKey = DJIProductKey(param: DJIProductParamModelName)
        isPrecisionTakeOffSupportedKey = DJIFlightControllerKey(param: DJIFlightAssistantParamPrecisionLandingEnabled)
        isCancelAutoLandingDisabledKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsCancelAutoLandingDisabled)
        landingProtectionStateKey = DJIFlightControllerKey(index: 0,
                                                           subComponent: DJIFlightControllerFlightAssistantSubComponent,
                                                           subComponentIndex: 0,
                                                           andParam: DJIFlightControllerParamLandingProtectionState)
    }

    override func tearDownWithError() throws {
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }

    func test_Connected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertTrue(widgetModel.isProductConnected)
        widgetModel.cleanup()
    }
    
    func test_Disconnected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertFalse(widgetModel.isProductConnected)
        widgetModel.cleanup()
    }
    
    func test_Disconnected_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .Disconnected)
        widgetModel.cleanup()
    }

    func test_ReadyToTakeOff_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isGoingHomeKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: areMotorsOnKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: remoteControlModeKey!) : DUXBetaMockKeyedValue(value: DJIRCMode.normal.rawValue)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .ReadyToTakeOff)
        widgetModel.cleanup()
    }
    
    func test_TakeOffDisabled_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isGoingHomeKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: areMotorsOnKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: remoteControlModeKey!) : DUXBetaMockKeyedValue(value: DJIRCMode.slave.rawValue)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .TakeOffDisabled)
        widgetModel.cleanup()
    }
    
    func test_ReadyToLand_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isGoingHomeKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: areMotorsOnKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: remoteControlModeKey!) : DUXBetaMockKeyedValue(value: DJIRCMode.normal.rawValue)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .ReadyToLand)
        widgetModel.cleanup()
    }
    
    func test_LandDisabled_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isGoingHomeKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: areMotorsOnKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: remoteControlModeKey!) : DUXBetaMockKeyedValue(value: DJIRCMode.slave.rawValue)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .LandDisabled)
        widgetModel.cleanup()
    }
    
    func test_ReturningHome_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isGoingHomeKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .ReturningHome)
        widgetModel.cleanup()
    }
    
    func test_ForcedAutoLanding_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isCancelAutoLandingDisabledKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .ForcedAutoLanding)
        widgetModel.cleanup()
    }
    
    func test_WaitingForLandingConfirmation_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isCancelAutoLandingDisabledKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isLandingConfirmationNeededKey!) : DUXBetaMockKeyedValue(value: true),
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .WaitingForLandingConfirmation)
        widgetModel.cleanup()
    }
    
    func test_AutoLanding_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isCancelAutoLandingDisabledKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: isLandingConfirmationNeededKey!) : DUXBetaMockKeyedValue(value: false),
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .AutoLanding)
        widgetModel.cleanup()
    }
    
    func test_UnsafeToLand_State() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isLandingKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: isCancelAutoLandingDisabledKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: landingProtectionStateKey!) : DUXBetaMockKeyedValue(value: DJIVisionLandingProtectionState.notSafeToLand.rawValue),
        ]
        
        mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, .UnsafeToLand)
        widgetModel.cleanup()
    }
    
    func test_LandHeight_Set() {
         let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
             DUXBetaMockKey(key: landHeightKey!) : DUXBetaMockKeyedValue(value: 20),
         ]
         
         mockKeyManager?.mockKeyValueDictionary = mockValues
         let widgetModel = DUXBetaTakeOffWidgetModel()
         
         widgetModel.setup()
         XCTAssertEqual(widgetModel.landHeight, 20)
         widgetModel.cleanup()
     }
    
    func test_LandHeight_NotSet() {
        let widgetModel = DUXBetaTakeOffWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.landHeight, 0.3)
        widgetModel.cleanup()
    }
}
