//
//  DUXBetaBindTests.swift
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
import UXSDKCore

@objcMembers class DUXBetaTestBindObject: NSObject {
    dynamic var testInt: NSInteger = 0
}


class DUXBetaBindTests: XCTestCase {
    let testIntBindDescription = "TestIntBindDescription"
    var testExpectation: XCTestExpectation?
    var calledWhenUnbound = false
    
    override func tearDown() {
        calledWhenUnbound = false
    }

    func testRKVOBind() {
        let testObject = DUXBetaTestBindObject()
        testObject.duxbeta_bindRKVO(withTarget: self, selector: #selector(bindTestCallBackSelector(transform:)), propertiesList: getVaList([#keyPath(DUXBetaTestBindObject.testInt)]))
        testExpectation = XCTestExpectation.init(description: testIntBindDescription)
        testObject.testInt = 1
        self.wait(for: [self.testExpectation!], timeout: 10)
        
        testObject.duxbeta_removeCustomObserver(self)
        testObject.testInt = 2
        if calledWhenUnbound {
            XCTFail("UnbindRKVO Failed")
        }
    }
    
    @objc public func bindTestCallBackSelector(transform: DUXBetaRKVOTransform) {
        if self.testExpectation?.expectationDescription == self.testIntBindDescription {
            if let unwrappedNewInt = transform.updatedValue as? Int, let unwrappedOldInt = transform.oldValue as? Int {
                if (unwrappedOldInt == 0 && unwrappedNewInt == 1) {
                     self.testExpectation?.fulfill()
                }
                if (unwrappedNewInt == 2) {
                    self.calledWhenUnbound = true
                }
            }
        }
    }
}
