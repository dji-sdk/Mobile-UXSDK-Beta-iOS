//
//  DUXBetaSDCardRemainingCapacityListItemWidgetTests.swift
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

import Foundation
import XCTest


class DUXBetaSDCardRemainingCapacityListItemWidgetTests: XCTestCase {
    
    var mockKeyManager : DUXBetaMockKeyManager?
    
    var freeStorageInMBKey : DJICameraKey?
    var sdCardInserteKey : DJICameraKey?
    var sdCardOperationStateKey : DJICameraKey?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
        
        self.freeStorageInMBKey = DJICameraKey(index:0, andParam:DJICameraParamSDCardRemainingSpaceInMB);
        self.sdCardInserteKey = DJICameraKey(index:0, andParam:DJICameraParamSDCardIsInserted);
        self.sdCardOperationStateKey = DJICameraKey(index:0, andParam:DJICameraParamSDCardOperationState);

    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }

    
    func testCardInserted() {
        let testValue = true;

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.sdCardInserteKey!) : DUXBetaMockKeyedValue(value: testValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaSDCardStatusListItemWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.isSDCardInserted, testValue)
        widgetModel.cleanup()
    }
    
    func testCardMissing() {
        let testValue = false;

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.sdCardInserteKey!) : DUXBetaMockKeyedValue(value: testValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaSDCardStatusListItemWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.isSDCardInserted, testValue)
        widgetModel.cleanup()
    }

    
    func testFreeMemoryInMB() {
        let testValue = 32768

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.freeStorageInMBKey!) : DUXBetaMockKeyedValue(value: testValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaSDCardStatusListItemWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.freeStorageInMB, testValue)
        widgetModel.cleanup()
    }
    
    func testSDCardNormal() {
        let testValue : DJICameraSDCardOperationState = .stateNormal

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.sdCardOperationStateKey!) : DUXBetaMockKeyedValue(value: testValue.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaSDCardStatusListItemWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.sdOperationState, testValue)
        widgetModel.cleanup()
    }
    
    func testSDCardFull() {
        let testValue : DJICameraSDCardOperationState = .stateFull

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.sdCardOperationStateKey!) : DUXBetaMockKeyedValue(value: testValue.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaSDCardStatusListItemWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.sdOperationState, testValue)
        widgetModel.cleanup()
    }

}
