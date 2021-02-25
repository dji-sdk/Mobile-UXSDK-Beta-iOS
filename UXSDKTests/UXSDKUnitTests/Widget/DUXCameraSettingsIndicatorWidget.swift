//
//  DUXCameraSettingsIndicatorWidget.swift
//  UXSDKUnitTests
//
//  MIT License
//  
//  Copyright © 2021 DJI
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

class DUXCameraSettingsIndicatorWidget: XCTestCase {

    var isConnectedKey : DJIFlightControllerKey?
    var isCameraConnectedKey : DJICameraKey?
    var mockKeyManager : DUXBetaMockKeyManager?
    var exposureModeKey : DJICameraKey?
    
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
        
        self.isConnectedKey = DJIFlightControllerKey(param: DJIParamConnection)
        self.isCameraConnectedKey = DJICameraKey(param: DJIParamConnection)
        self.exposureModeKey = DJICameraKey(param: DJICameraParamExposureMode)
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }
    
    func test_Disconnected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaCameraSettingsIndicatorWidgetModel()
        widgetModel.setup()
        XCTAssertFalse(widgetModel.isProductConnected)
    }
    
    func test_Connected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaCameraSettingsIndicatorWidgetModel()
        widgetModel.setup()
        XCTAssertTrue(widgetModel.isProductConnected)
    }
    
    func test_ProductDisconnected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaCameraSettingsIndicatorWidgetModel()
        widgetModel.setup()
        XCTAssertTrue(widgetModel.state.isProductDisconnected)
        XCTAssertEqual(widgetModel.state.cameraSettingsExposureMode, DJICameraExposureMode.unknown)
    }
    
    func test_CameraDisconnected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaCameraSettingsIndicatorWidgetModel()
        widgetModel.setup()
        XCTAssertTrue(widgetModel.state.isCameraDisconnected)
        XCTAssertEqual(widgetModel.state.cameraSettingsExposureMode, DJICameraExposureMode.unknown)
    }
    
    func test_ExposureMode_program() {
        let exposureMode = DJICameraExposureMode.program
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.exposureModeKey!) : DUXBetaMockKeyedValue(value: exposureMode.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaCameraSettingsIndicatorWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state.cameraSettingsExposureMode, exposureMode)
        XCTAssertFalse(widgetModel.state.isProductDisconnected)
        XCTAssertFalse(widgetModel.state.isCameraDisconnected)
    }
    
    func test_ExposureMode_shutterPriority() {
        let exposureMode = DJICameraExposureMode.shutterPriority
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.exposureModeKey!) : DUXBetaMockKeyedValue(value: exposureMode.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaCameraSettingsIndicatorWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state.cameraSettingsExposureMode, exposureMode)
        XCTAssertFalse(widgetModel.state.isProductDisconnected)
        XCTAssertFalse(widgetModel.state.isCameraDisconnected)
    }
    
    func test_ExposureMode_aperturePriority() {
        let exposureMode = DJICameraExposureMode.aperturePriority
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.exposureModeKey!) : DUXBetaMockKeyedValue(value: exposureMode.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaCameraSettingsIndicatorWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state.cameraSettingsExposureMode, exposureMode)
        XCTAssertFalse(widgetModel.state.isProductDisconnected)
        XCTAssertFalse(widgetModel.state.isCameraDisconnected)
    }
    
    func test_ExposureMode_manual() {
        let exposureMode = DJICameraExposureMode.manual
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.exposureModeKey!) : DUXBetaMockKeyedValue(value: exposureMode.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaCameraSettingsIndicatorWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state.cameraSettingsExposureMode, exposureMode)
        XCTAssertFalse(widgetModel.state.isProductDisconnected)
        XCTAssertFalse(widgetModel.state.isCameraDisconnected)
    }
    
    func test_ExposureMode_unknown() {
        let exposureMode = DJICameraExposureMode.unknown
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.exposureModeKey!) : DUXBetaMockKeyedValue(value: exposureMode.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaCameraSettingsIndicatorWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state.cameraSettingsExposureMode, exposureMode)
        XCTAssertFalse(widgetModel.state.isProductDisconnected)
        XCTAssertFalse(widgetModel.state.isCameraDisconnected)
    }
}
