//
//  DUXBetaFPVDecodeModelTests.swift
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

class DUXBetaFPVDecodeModelTests: XCTestCase {
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
    
    func testDecodingType_CameraX3() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX3)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._DM368_inspire)
        }
    }
    
    func testDecodingType_CameraZ3() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameZ3)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._A9_OSMO_NO_368)
        }
    }
    
    func testDecodingType_CameraX5() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX5)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._DM368_inspire)
        }
    }
    
    func testDecodingType_CameraX5R() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX5R)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._DM368_inspire)
        }
    }
    
    func testDecodingType_CameraP3P() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePhantom3ProfessionalCamera)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._DM365_phamtom3x)
        }
    }
    
    func testDecodingType_CameraP3PAdvanced() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePhantom3AdvancedCamera)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._A9_phantom3s)
        }
    }
    
    func testDecodingType_CameraP3PStandard() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePhantom3StandardCamera)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._A9_phantom3c)
        }
    }
    
    func testDecodingType_CameraP4() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePhantom4Camera)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._1860_phantom4x)
        }
    }
    
    func testDecodingType_CameraMavicPro() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameMavicProCamera)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._unknown)
        }
    }
    
    func testDecodingType_CameraSpark() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameSparkCamera)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._1860_phantom4x)
        }
    }
    
    func testDecodingType_CameraZ30() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameZ30)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._GD600)
        }
    }
    
    func testDecodingType_CameraP4P() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePhantom4ProCamera)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._H1_Inspire2)
        }
    }
    
    func testDecodingType_CameraP4Advanced() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePhantom4AdvancedCamera)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._H1_Inspire2)
        }
    }
    
    func testDecodingType_CameraX5S() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX5S)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._H1_Inspire2)
        }
    }
    
    func testDecodingType_CameraX4S() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX4S)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._H1_Inspire2)
        }
    }
    
    func testDecodingType_CameraX7() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX7)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._H1_Inspire2)
        }
    }
    
    func testDecodingType_Payload() {
        if let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) {
            //Given
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePayload)]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            //When
            let model = DUXBetaFPVDecodeModel()
            model.setup()
            //Then
            XCTAssertEqual(model.encodeType, H264EncoderType._H1_Inspire2)
        }
    }
    
    func testContentRect_BroadcastMode() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePayload),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.broadcast.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        XCTAssertEqual(model.contentClipRect, CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    func testContentRect_RecordVideoMode() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePayload),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.recordVideo.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        XCTAssertEqual(model.contentClipRect, CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    func testContentRect_PlaybackMode() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePayload),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.playback.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        XCTAssertEqual(model.contentClipRect, CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    func testContentRect_MediaDownloadMode() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePayload),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.mediaDownload.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        XCTAssertEqual(model.contentClipRect, CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    func testContentRect_unknwonMode() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePayload),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.unknown.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        XCTAssertEqual(model.contentClipRect, CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    func testContentRect_PhotoMode_CameraX3_ratioUnknown() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePayload),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratioUnknown.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        XCTAssertEqual(model.contentClipRect, CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    func testContentRect_PhotoMode_Ratio3_2_X3() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX3),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio3_2.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 3, height: 2))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio4_3_X3() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX3),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio4_3.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 4, height: 3))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio16_9_X3() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX3),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio16_9.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 16, height: 9))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_RatioUnknown_9_X3() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX3),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratioUnknown.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 16, height: 9))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio3_2_X5() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX5),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio3_2.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 3, height: 2))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio4_3_X5() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX5),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio4_3.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 4, height: 3))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio16_9_X5() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX5),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio16_9.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 16, height: 9))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_RatioUnknown_9_X5() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX5),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratioUnknown.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 16, height: 9))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio3_2_X5R() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX5R),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio3_2.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 3, height: 2))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio4_3_X5R() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX5R),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio4_3.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 4, height: 3))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio16_9_X5R() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX5R),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio16_9.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 16, height: 9))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_RatioUnknown_9_X5R() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameX5R),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratioUnknown.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 16, height: 9))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio3_2_P3P() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePhantom3ProfessionalCamera),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio3_2.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 3, height: 2))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio4_3_P3P() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePhantom3ProfessionalCamera),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio4_3.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 4, height: 3))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio16_9_P3P() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePhantom3ProfessionalCamera),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio16_9.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 16, height: 9))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_RatioUnknown_9_P3P() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNamePhantom3ProfessionalCamera),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratioUnknown.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 16, height: 9))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio3_2_MavicPro() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameMavicProCamera),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio3_2.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 3, height: 2))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio4_3_MavicPro() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameMavicProCamera),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio4_3.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 4, height: 3))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_Ratio16_9_MavicPro() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameMavicProCamera),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratio16_9.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 16, height: 9))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
    
    func testContentRect_PhotoMode_RatioUnknown_9_MavicPro() {
        guard let cameraNameKey = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else {
            XCTFail("Found a nil key")
            return
        }
        guard let cameraModeKey = DJICameraKey(index: 0, andParam: DJICameraParamMode) else {
            XCTFail("Found a nil key")
            return
        }
        guard let ratioKey = DJICameraKey(index: 0, andParam: DJICameraParamPhotoAspectRatio) else {
            XCTFail("Found a nil key")
            return
        }
        
        //Given
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: cameraNameKey) : DUXBetaMockKeyedValue(value:DJICameraDisplayNameMavicProCamera),
            DUXBetaMockKey(key: ratioKey) : DUXBetaMockKeyedValue(value:DJICameraPhotoAspectRatio.ratioUnknown.rawValue),
            DUXBetaMockKey(key: cameraModeKey) : DUXBetaMockKeyedValue(value:DJICameraMode.shootPhoto.rawValue)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        //When
        let model = DUXBetaFPVDecodeModel()
        model.setup()
        //Then
        let streamRect = CGRect(x: 0, y: 0, width: 16, height: 9)
        let destRect = DJIVideoPresentViewAdjustHelper.aspectFit(withFrame: streamRect, size: CGSize(width: 16, height: 9))
        let rect = DJIVideoPresentViewAdjustHelper.normalizeFrame(destRect, withIdentityRect: streamRect)
        XCTAssertEqual(model.contentClipRect, rect)
    }
}
