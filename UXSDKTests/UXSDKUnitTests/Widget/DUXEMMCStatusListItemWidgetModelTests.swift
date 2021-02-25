//
//  DUXBetaEMMCStatusListItemWidgetModelTests.swift
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
//import DJISDK

class DUXBetaEMMCStatusListItemWidgetModelTests: XCTestCase {
    
    var mockKeyManager : DUXBetaMockKeyManager?
    
    var internalStorageSupported : DJICameraKey?
    var freeStorageInMB : DJICameraKey?
    var operatingState : DJICameraKey?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
        
        self.internalStorageSupported = DJICameraKey(index: 0, andParam:DJICameraParamIsInternalStorageSupported)
        self.freeStorageInMB = DJICameraKey(index: 0, andParam:DJICameraParamInternalStorageRemainingSpaceInMB)
        self.operatingState = DJICameraKey(index: 0, andParam:DJICameraParamInternalStorageOperationState)
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }
    
    func testInternalStorageSupported() {
        let testValue = true;
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.internalStorageSupported!) : DUXBetaMockKeyedValue(value: testValue),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaEMMCStatusListItemWidgetModel()
        
        widgetModel.setup()
        XCTAssert(widgetModel.isInternalStorageSupported == true)
        widgetModel.cleanup()
    }
    
    func testFreeStorage() {
        let testValue = 7100;
        let finalValue = 0
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.freeStorageInMB!) : DUXBetaMockKeyedValue(value: testValue),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaEMMCStatusListItemWidgetModel()
        
        widgetModel.setup()
        XCTAssert(widgetModel.freeStorageInMB == testValue)
        
        self.mockKeyManager?.mockKeyValueDictionary[DUXBetaMockKey(key: self.freeStorageInMB!)] = DUXBetaMockKeyedValue(value: finalValue)
        XCTAssert(widgetModel.freeStorageInMB == finalValue)
        widgetModel.cleanup()
    }
    
    func testOperatingState() {
        let testValue: DJICameraSDCardOperationState = .stateNotInserted
        let finalValue: DJICameraSDCardOperationState = .stateNormal
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.operatingState!) : DUXBetaMockKeyedValue(value: testValue),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaEMMCStatusListItemWidgetModel()
        
        widgetModel.setup()
        XCTAssert(widgetModel.internalStorageOperationState == testValue)
        
        self.mockKeyManager?.mockKeyValueDictionary[DUXBetaMockKey(key: self.operatingState!)] = DUXBetaMockKeyedValue(value: finalValue)
        XCTAssert(widgetModel.internalStorageOperationState == finalValue)
        widgetModel.cleanup()
    }
}
