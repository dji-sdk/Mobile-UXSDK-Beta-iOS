//
//  DUXBetaFPVWidgetModelTests.swift
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

class DUXBetaFPVWidgetModelTests: XCTestCase {
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
    
    func testCameraName_Default() {
        //Given
        let cameraName = "Camera Name"
        
        //When
        let widgetModel = DUXBetaFPVWidgetModel()
        widgetModel.videoFeed = DJIVideoFeed.init()
        widgetModel.computeDisplayedValues(index0Name: cameraName, index1Name: "", index4Name: "", cameraSource: DJIVideoFeedPhysicalSource.mainCamera)
        
        //Then
        XCTAssertEqual(widgetModel.displayedCameraName, cameraName)
        XCTAssertEqual(widgetModel.displayedCameraSide, "")
    }
    
    func testCameraName_Inspire2_Main() {
        //Given
        let cameraName = "Camera Name"
        let aircraftModelKey = DJIProductKey(param: DJIProductParamModelName)
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: aircraftModelKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameInspire2)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        //When
        let widgetModel = DUXBetaFPVWidgetModel()
        widgetModel.videoFeed = DJIVideoFeed.init()
        widgetModel.setup()
        widgetModel.computeDisplayedValues(index0Name: cameraName, index1Name: "", index4Name: "", cameraSource: DJIVideoFeedPhysicalSource.mainCamera)
        
        //Then
        XCTAssertEqual(widgetModel.displayedCameraName, cameraName)
        XCTAssertEqual(widgetModel.displayedCameraSide, "")
    }
    
    func testCameraName_Inspire2_FPV() {
        //Given
        let cameraName = "Camera Name"
        let aircraftModelKey = DJIProductKey(param: DJIProductParamModelName)
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: aircraftModelKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameInspire2)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        //When
        let widgetModel = DUXBetaFPVWidgetModel()
        widgetModel.videoFeed = DJIVideoFeed.init()
        widgetModel.setup()
        widgetModel.computeDisplayedValues(index0Name: cameraName, index1Name: "", index4Name: "", cameraSource: DJIVideoFeedPhysicalSource.fpvCamera)
        
        //Then
        XCTAssertEqual(widgetModel.displayedCameraName, "FPV Camera")
        XCTAssertEqual(widgetModel.displayedCameraSide, "")
    }
    
    func testCameraName_M300RTK_LeftCamera() {
        //Given
        let cameraName0 = "Camera Name 0"
        let cameraName1 = "Camera Name 1"
        let cameraName4 = "Camera Name 4"
        let aircraftModelKey = DJIProductKey(param: DJIProductParamModelName)
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: aircraftModelKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        //When
        let widgetModel = DUXBetaFPVWidgetModel()
        widgetModel.videoFeed = DJIVideoFeed.init()
        widgetModel.setup()
        widgetModel.computeDisplayedValues(index0Name: cameraName0, index1Name: cameraName1, index4Name: cameraName4, cameraSource: DJIVideoFeedPhysicalSource.leftCamera)
        
        //Then
        XCTAssertEqual(widgetModel.displayedCameraName, cameraName0)
        XCTAssertEqual(widgetModel.displayedCameraSide, "Port-side")
    }
    
    func testCameraName_M300RTK_Right() {
        //Given
        let cameraName0 = "Camera Name 0"
        let cameraName1 = "Camera Name 1"
        let cameraName4 = "Camera Name 4"
        let aircraftModelKey = DJIProductKey(param: DJIProductParamModelName)
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: aircraftModelKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        //When
        let widgetModel = DUXBetaFPVWidgetModel()
        widgetModel.videoFeed = DJIVideoFeed.init()
        widgetModel.setup()
        widgetModel.computeDisplayedValues(index0Name: cameraName0, index1Name: cameraName1, index4Name: cameraName4, cameraSource: DJIVideoFeedPhysicalSource.rightCamera)
        
        //Then
        XCTAssertEqual(widgetModel.displayedCameraName, cameraName1)
        XCTAssertEqual(widgetModel.displayedCameraSide, "Starboard-side")
    }
    
    func testCameraName_M300RTK_Top() {
        //Given
        let cameraName0 = "Camera Name 0"
        let cameraName1 = "Camera Name 1"
        let cameraName4 = "Camera Name 4"
        let aircraftModelKey = DJIProductKey(param: DJIProductParamModelName)
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: aircraftModelKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        //When
        let widgetModel = DUXBetaFPVWidgetModel()
        widgetModel.videoFeed = DJIVideoFeed.init()
        widgetModel.setup()
        widgetModel.computeDisplayedValues(index0Name: cameraName0, index1Name: cameraName1, index4Name: cameraName4, cameraSource: DJIVideoFeedPhysicalSource.topCamera)
        
        //Then
        XCTAssertEqual(widgetModel.displayedCameraName, cameraName4)
        XCTAssertEqual(widgetModel.displayedCameraSide, "Top-side")
    }
    
    func testCameraName_M300RTK_FPV() {
        //Given
        let cameraName0 = "Camera Name 0"
        let cameraName1 = "Camera Name 1"
        let cameraName4 = "Camera Name 4"
        let aircraftModelKey = DJIProductKey(param: DJIProductParamModelName)
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: aircraftModelKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        //When
        let widgetModel = DUXBetaFPVWidgetModel()
        widgetModel.videoFeed = DJIVideoFeed.init()
        widgetModel.setup()
        widgetModel.computeDisplayedValues(index0Name: cameraName0, index1Name: cameraName1, index4Name: cameraName4, cameraSource: DJIVideoFeedPhysicalSource.fpvCamera)
        
        //Then
        XCTAssertEqual(widgetModel.displayedCameraName, "FPV Camera")
        XCTAssertEqual(widgetModel.displayedCameraSide, "")
    }
    
    func testCameraName_M300RTK_Main() {
        //Given
        let cameraName0 = "Camera Name 0"
        let cameraName1 = "Camera Name 1"
        let cameraName4 = "Camera Name 4"
        let aircraftModelKey = DJIProductKey(param: DJIProductParamModelName)
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: aircraftModelKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        //When
        let widgetModel = DUXBetaFPVWidgetModel()
        widgetModel.videoFeed = DJIVideoFeed.init()
        widgetModel.setup()
        widgetModel.computeDisplayedValues(index0Name: cameraName0, index1Name: cameraName1, index4Name: cameraName4, cameraSource: DJIVideoFeedPhysicalSource.mainCamera)
        
        //Then
        XCTAssertEqual(widgetModel.displayedCameraName, cameraName0)
        XCTAssertEqual(widgetModel.displayedCameraSide, "")
    }
    
    func testCameraName_ExtPort_Main() {
        //Given
        let cameraName = "Camera Name"
        let aircraftModelKey = DJIProductKey(param: DJIProductParamModelName)
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: aircraftModelKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice600)]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        //When
        let widgetModel = DUXBetaFPVWidgetModel()
        widgetModel.videoFeed = DJIVideoFeed.init()
        widgetModel.setup()
        widgetModel.computeDisplayedValues(index0Name: cameraName, index1Name: "", index4Name: "", cameraSource: DJIVideoFeedPhysicalSource.mainCamera)
        
        //Then
        XCTAssertEqual(widgetModel.displayedCameraName, cameraName)
        XCTAssertEqual(widgetModel.displayedCameraSide, "")
    }
}
