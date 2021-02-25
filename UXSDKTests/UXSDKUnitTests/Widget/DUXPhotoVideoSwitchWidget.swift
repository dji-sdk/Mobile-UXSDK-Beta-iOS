//
//  DUXPhotoVideoSwitchWidget.swift
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

class DUXPhotoVideoSwitchWidget: XCTestCase {

    var isConnectedKey : DJIFlightControllerKey?
    var isCameraConnectedKey : DJICameraKey?
    var mockKeyManager : DUXBetaMockKeyManager?
    var isRecordingKey : DJICameraKey?
    var isShootingSinglePhotoKey : DJICameraKey?
    var isShootingIntervalPhotoKey : DJICameraKey?
    var isShootingBurstPhotoKey : DJICameraKey?
    var isShootingRAWBurstPhotoKey : DJICameraKey?
    var isShootingPanoramaPhotoKey : DJICameraKey?
    var flatModeKey: DJICameraKey?
    var cameraModeKey: DJICameraKey?
    var isFlatModeSupportedKey: DJICameraKey?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
        
        self.cameraModeKey = DJICameraKey(param: DJICameraParamMode)
        self.flatModeKey = DJICameraKey(param: DJICameraParamFlatMode)
        self.isFlatModeSupportedKey = DJICameraKey(param: DJICameraParamIsFlatModeSupported)
        self.isConnectedKey = DJIFlightControllerKey(param: DJIParamConnection)
        self.isCameraConnectedKey = DJICameraKey(param: DJIParamConnection)
        self.isRecordingKey = DJICameraKey(param: DJICameraParamIsRecording)
        self.isShootingSinglePhotoKey = DJICameraKey(param: DJICameraParamIsShootingSinglePhoto)
        self.isShootingIntervalPhotoKey = DJICameraKey(param: DJICameraParamIsShootingIntervalPhoto)
        self.isShootingBurstPhotoKey = DJICameraKey(param: DJICameraParamIsShootingBurstPhoto)
        self.isShootingRAWBurstPhotoKey = DJICameraKey(param: DJICameraParamIsShootingRAWBurstPhoto)
        self.isShootingPanoramaPhotoKey = DJICameraKey(param: DJICameraParamIsShootingPanoramaPhoto)
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
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertFalse(widgetModel.isProductConnected)
    }
    
    func test_Connected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertTrue(widgetModel.isProductConnected)
    }
    
    func test_ProductDisconnected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, DUXBetaPhotoVideoSwitchState.ProductDisconnected)
    }
    
    func test_CameraDisconnected() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, DUXBetaPhotoVideoSwitchState.CameraDisconnected)
    }
    
    func test_PhotoMode_withoutFlatMode() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isFlatModeSupportedKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: self.cameraModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJICameraMode.shootPhoto.rawValue))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, DUXBetaPhotoVideoSwitchState.PhotoMode)
    }
    
    func test_PhotoMode_withFlatMode() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isFlatModeSupportedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.cameraModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJICameraMode.shootPhoto.rawValue))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, DUXBetaPhotoVideoSwitchState.PhotoMode)
    }
    
    func test_VideoMode_withoutFlatMode() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isFlatModeSupportedKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: self.cameraModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJICameraMode.recordVideo.rawValue))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, DUXBetaPhotoVideoSwitchState.VideoMode)
    }
    
    func test_VideoMode_withFlatMode() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isFlatModeSupportedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.cameraModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJICameraMode.recordVideo.rawValue))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, DUXBetaPhotoVideoSwitchState.VideoMode)
    }
    
    func test_VideoMode_whenNoShooting() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isFlatModeSupportedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.cameraModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJICameraMode.recordVideo.rawValue)),
            DUXBetaMockKey(key: self.isShootingSinglePhotoKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: self.isShootingIntervalPhotoKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: self.isShootingBurstPhotoKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: self.isShootingPanoramaPhotoKey!) : DUXBetaMockKeyedValue(value: false),
            DUXBetaMockKey(key: self.isShootingRAWBurstPhotoKey!) : DUXBetaMockKeyedValue(value: false)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state, DUXBetaPhotoVideoSwitchState.VideoMode)
    }
    
    func test_Disabled_whenRecording() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.cameraModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJICameraMode.recordVideo.rawValue)),
            DUXBetaMockKey(key: self.isRecordingKey!) : DUXBetaMockKeyedValue(value: true),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state.rawValue, DUXBetaPhotoVideoSwitchState.Disabled.rawValue)
    }
    
    func test_Disabled_whenShootingSinglePhotoKey() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.cameraModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJICameraMode.recordVideo.rawValue)),
            DUXBetaMockKey(key: self.isShootingSinglePhotoKey!) : DUXBetaMockKeyedValue(value: true),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state.rawValue, DUXBetaPhotoVideoSwitchState.Disabled.rawValue)
    }
    
    func test_Disabled_whenShootingIntervalPhotoKey() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.cameraModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJICameraMode.recordVideo.rawValue)),
            DUXBetaMockKey(key: self.isShootingIntervalPhotoKey!) : DUXBetaMockKeyedValue(value: true),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state.rawValue, DUXBetaPhotoVideoSwitchState.Disabled.rawValue)
    }
    
    func test_Disabled_whenShootingBurstPhotoKey() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.cameraModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJICameraMode.recordVideo.rawValue)),
            DUXBetaMockKey(key: self.isShootingBurstPhotoKey!) : DUXBetaMockKeyedValue(value: true),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state.rawValue, DUXBetaPhotoVideoSwitchState.Disabled.rawValue)
    }
    
    func test_Disabled_whenShootingPanoramaPhotoKey() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.cameraModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJICameraMode.recordVideo.rawValue)),
            DUXBetaMockKey(key: self.isShootingPanoramaPhotoKey!) : DUXBetaMockKeyedValue(value: true),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state.rawValue, DUXBetaPhotoVideoSwitchState.Disabled.rawValue)
    }
    
    func test_Disabled_whenShootingRAWBurstPhotoKey() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.isConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.isCameraConnectedKey!) : DUXBetaMockKeyedValue(value: true),
            DUXBetaMockKey(key: self.cameraModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJICameraMode.recordVideo.rawValue)),
            DUXBetaMockKey(key: self.isShootingRAWBurstPhotoKey!) : DUXBetaMockKeyedValue(value: true),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaPhotoVideoSwitchWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.state.rawValue, DUXBetaPhotoVideoSwitchState.Disabled.rawValue)
    }
}
