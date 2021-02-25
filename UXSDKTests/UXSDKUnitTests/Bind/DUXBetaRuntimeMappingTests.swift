//
//  DUXBetaRuntimeMappingTests.swift
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

@objcMembers class DUXBetaOtherMockObject:NSObject {
    
}

@objcMembers class DUXBetaMockObject: NSObject {
    var testInt8:Int8 = 0
    var testUInt8:UInt8 = 0
    var testInt16:Int16 = 0
    var testUInt16:UInt16 = 0
    var testInt32:Int32 = 0
    var testUInt32:UInt32 = 0
    var testInt64:Int64 = 0
    var testUInt64:UInt64 = 0
    var testFloat:Float = 0.0
    var testDouble:Double = 0.0
    
    var cfStringTest:CFString = "CFString" as CFString
    var cfArrayTest:CFArray = [1] as CFArray
    
    var nsStringTest:NSString = "NSString"
    var nsMutableStringTest:NSMutableString = "NSMutableString"
    var nsDecimalNumberTest:NSDecimalNumber = NSDecimalNumber(string: "0.1")
    var nsNumberTest:NSNumber = NSNumber(value: 0)
    var nsValueTest:NSValue = NSValue.init(cgRect: CGRect.zero)
    var nsMutableDataTest:NSMutableData = NSMutableData.init()
    var nsDataTest:NSData = NSData.init()
    var nsDateTest:NSDate = NSDate.init(timeIntervalSinceNow: 0)
    var nsURLTest:NSURL = NSURL.init(string: "www.google.com")!
    var nsMutableArrayTest:NSMutableArray = NSMutableArray.init(array: [1])
    var nsArrayTest:NSArray = NSArray.init(array: [1])
    var nsMutableDictTest:NSMutableDictionary = NSMutableDictionary.init(objects: [1], forKeys: ["one" as NSCopying])
    var nsDictTest:NSDictionary = NSDictionary.init(objects: [1], forKeys: ["one" as NSCopying])
    var mockOtherObject: DUXBetaOtherMockObject = DUXBetaOtherMockObject()
}

class DUXBetaRuntimeMappingTests: XCTestCase {
    
    func testCreatedIntegerTypes() {
        let testObject = DUXBetaMockObject()
        testObject.duxbeta_setCustomMappingValue(1, forKey:#keyPath(DUXBetaMockObject.testInt8))
        XCTAssert(testObject.testInt8 == 1)
        
        testObject.duxbeta_setCustomMappingValue(2, forKey:#keyPath(DUXBetaMockObject.testUInt8))
        XCTAssert(testObject.testUInt8 == 2)
        
        testObject.duxbeta_setCustomMappingValue(3, forKey:#keyPath(DUXBetaMockObject.testInt16))
        XCTAssert(testObject.testInt16 == 3)
        
        testObject.duxbeta_setCustomMappingValue(4, forKey:#keyPath(DUXBetaMockObject.testUInt16))
        XCTAssert(testObject.testUInt16 == 4)
        
        testObject.duxbeta_setCustomMappingValue(5, forKey:#keyPath(DUXBetaMockObject.testInt32))
        XCTAssert(testObject.testInt32 == 5)
        
        testObject.duxbeta_setCustomMappingValue(6, forKey:#keyPath(DUXBetaMockObject.testUInt32))
        XCTAssert(testObject.testUInt32 == 6)
        
        testObject.duxbeta_setCustomMappingValue(7, forKey:#keyPath(DUXBetaMockObject.testInt64))
        XCTAssert(testObject.testInt64 == 7)
        
        testObject.duxbeta_setCustomMappingValue(8, forKey:#keyPath(DUXBetaMockObject.testUInt64))
        XCTAssert(testObject.testUInt64 == 8)
        
        testObject.duxbeta_setCustomMappingValue(1.1, forKey:#keyPath(DUXBetaMockObject.testFloat))
        XCTAssert(testObject.testFloat == 1.1)
        
        testObject.duxbeta_setCustomMappingValue(1.2, forKey: #keyPath(DUXBetaMockObject.testDouble))
        XCTAssert(testObject.testDouble == 1.2)
    }
    
    
#warning("CoreFoundation types seem to be broken.  I have filed a follow up ticket to investigate this")
    func testCoreFoundationTypes() {
//        let testObject = DUXBetaMockObject()
//
//        let newString = "CFString Changed" as CFString
//
//        testObject.duxbeta_setCustomMappingValue(newString, forKey: #keyPath(DUXBetaMockObject.cfStringTest))
//        XCTAssert(testObject.cfStringTest == ("CFString Changed" as CFString))
//
//        testObject.duxbeta_setCustomMappingValue([2] as CFArray, forKey: #keyPath(DUXBetaMockObject.cfArrayTest))
//        XCTAssert(testObject.cfArrayTest == [2] as CFArray)
    }
    
    func testFoundationTypes() {
        let testObject = DUXBetaMockObject()

        testObject.duxbeta_setCustomMappingValue(("NSString Changed" as NSString), forKey: #keyPath(DUXBetaMockObject.nsStringTest))
        XCTAssert(testObject.nsStringTest == ("NSString Changed" as NSString))
        
        testObject.duxbeta_setCustomMappingValue(testObject.nsMutableStringTest.appending("!"), forKey: #keyPath(DUXBetaMockObject.nsMutableStringTest))
        XCTAssert(testObject.nsMutableStringTest == ("NSMutableString!" as NSMutableString))
        
        testObject.duxbeta_setCustomMappingValue(NSDecimalNumber.init(string: "1.0"), forKey: #keyPath(DUXBetaMockObject.nsDecimalNumberTest))
        XCTAssert(testObject.nsDecimalNumberTest == 1.0)
        
        testObject.duxbeta_setCustomMappingValue(NSNumber.init(value: 1), forKey: #keyPath(DUXBetaMockObject.nsNumberTest))
        XCTAssert(testObject.nsNumberTest == 1)
        
        testObject.duxbeta_setCustomMappingValue(NSValue.init(cgRect: CGRect.init(x: 0, y: 0, width: 1.0, height: 1.0)), forKey: #keyPath(DUXBetaMockObject.nsValueTest))
        XCTAssert(testObject.nsValueTest == NSValue.init(cgRect: CGRect.init(x: 0, y: 0, width: 1.0, height: 1.0)))
        
        if let testMutableData = NSMutableData.init(capacity: 10) {
            testObject.duxbeta_setCustomMappingValue(testMutableData, forKey: #keyPath(DUXBetaMockObject.nsMutableDataTest))
            XCTAssert(testObject.nsMutableDataTest == testMutableData)
        }
        
        let currentDate = NSDate.init(timeIntervalSinceNow: 0)
        testObject.duxbeta_setCustomMappingValue(currentDate, forKey: #keyPath(DUXBetaMockObject.nsDateTest))
        XCTAssert(testObject.nsDateTest == currentDate)
        
        if let url = NSURL.init(string: "www.dji.com") {
            testObject.duxbeta_setCustomMappingValue(url, forKey: #keyPath(DUXBetaMockObject.nsURLTest))
            XCTAssert(testObject.nsURLTest == url)
        }
        
        testObject.duxbeta_setCustomMappingValue(NSMutableArray.init(array: [1,2]), forKey: #keyPath(DUXBetaMockObject.nsMutableArrayTest))
        XCTAssert(testObject.nsMutableArrayTest == [1,2])
        
        testObject.duxbeta_setCustomMappingValue([2], forKey: #keyPath(DUXBetaMockObject.nsArrayTest))
        XCTAssert(testObject.nsArrayTest == [2])
        
        let testMutableDict = NSMutableDictionary.init(objects: [1,2], forKeys: ["one" as NSCopying, "two" as NSCopying])
        
        testObject.duxbeta_setCustomMappingValue(testMutableDict, forKey: #keyPath(DUXBetaMockObject.nsMutableDictTest))
        XCTAssert(testObject.nsMutableDictTest == testMutableDict)
        
        let testDict = NSDictionary.init(objects: [1,2], forKeys: ["one" as NSCopying, "two" as NSCopying])
        
        testObject.duxbeta_setCustomMappingValue(testDict, forKey: #keyPath(DUXBetaMockObject.nsDictTest))
        XCTAssert(testObject.nsDictTest == testDict)
        
        let newTestObject = DUXBetaOtherMockObject()
        testObject.duxbeta_setCustomMappingValue(newTestObject, forKey: #keyPath(DUXBetaMockObject.mockOtherObject))
        XCTAssert(testObject.mockOtherObject == newTestObject)
    }
}
