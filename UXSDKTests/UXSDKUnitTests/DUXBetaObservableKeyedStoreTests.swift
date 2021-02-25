//
//  DUXBetaObservableKeyedStoreTests.swift
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

//class DUXBetaObservableKeyedStoreTests: XCTestCase {
//    var observableInMemoryKeyedStore:ObservableInMemoryKeyedStore = ObservableInMemoryKeyedStore()
//
//    override func setUp() {
//
//    }
//
//    override func tearDown() {
//
//    }
//
//    func testAvailableValue() {
//        let modelValue = ModelValue(integer:2)
//        let key = ExternalKey(index: 0, param: .PeakingThreshold)
//
//        self.observableInMemoryKeyedStore.set(modelValue: modelValue, for: key)
//        Thread.sleep(forTimeInterval: 2)
//
//        let availableModelValue = self.observableInMemoryKeyedStore.availableValueFor(key: key)
//        XCTAssertNotNil(availableModelValue)
//        XCTAssertEqual(modelValue, availableModelValue)
//    }
//
//    func testObserverBroadcasting() {
//        let observer = NSObject()
//        let key = ExternalKey(index: 0, param: .PeakingThreshold)
//
//        let observingExpectation = XCTestExpectation(description: "Observed Change")
//
//        let modelValue = ModelValue(integer:2)
//
//        self.observableInMemoryKeyedStore.add(observer: observer,
//                                      for: key,
//                                      broadcastAvailableValue: false) { (updatedValue:ModelValue?, priorValue:ModelValue?, key:ExternalKey) in
//
//            observingExpectation.fulfill()
//            XCTAssertEqual(updatedValue, modelValue)
//        }
//
//        self.observableInMemoryKeyedStore.set(modelValue: modelValue, for: key)
//        self.wait(for: [observingExpectation], timeout: 5)
//    }
//
//    func testSingleObserverRemoval() {
//        let observer = NSObject()
//        let key = ExternalKey(index: 0, param: .PeakingThreshold)
//
//        let observingExpectation = XCTestExpectation(description: "Observed Change")
//        observingExpectation.expectedFulfillmentCount = 1
//
//        let modelValue = ModelValue(integer:2)
//
//        self.observableInMemoryKeyedStore.add(observer: observer,
//                                      for: key,
//                                      broadcastAvailableValue: false) { (updatedValue:ModelValue?, priorValue:ModelValue?, key:ExternalKey) in
//
//                                        observingExpectation.fulfill()
//        }
//        Thread.sleep(forTimeInterval: 2)
//        self.observableInMemoryKeyedStore.set(modelValue: modelValue, for: key)
//        self.wait(for: [observingExpectation], timeout: 5)
//        Thread.sleep(forTimeInterval: 2)
//        self.observableInMemoryKeyedStore.remove(observer: observer, for: key)
//        Thread.sleep(forTimeInterval: 2)
//        let secondModelValue = ModelValue(integer:3)
//        self.observableInMemoryKeyedStore.set(modelValue: secondModelValue, for: key)
//        Thread.sleep(forTimeInterval: 3)
//    }
//
//    func testAllObserverRemoval() {
//        let observer = NSObject()
//        let key = ExternalKey(index: 0, param: .PeakingThreshold)
//
//        let observingExpectation = XCTestExpectation(description: "Observed Change")
//        observingExpectation.expectedFulfillmentCount = 1
//
//        let modelValue = ModelValue(integer:2)
//
//        self.observableInMemoryKeyedStore.add(observer: observer,
//                                      for: key,
//                                      broadcastAvailableValue: false) { (updatedValue:ModelValue?, priorValue:ModelValue?, key:ExternalKey) in
//
//                                        observingExpectation.fulfill()
//        }
//        Thread.sleep(forTimeInterval: 2)
//        self.observableInMemoryKeyedStore.set(modelValue: modelValue, for: key)
//        self.wait(for: [observingExpectation], timeout: 5)
//        Thread.sleep(forTimeInterval: 2)
//        self.observableInMemoryKeyedStore.removeAllObservers()
//        Thread.sleep(forTimeInterval: 2)
//        let secondModelValue = ModelValue(integer:3)
//        self.observableInMemoryKeyedStore.set(modelValue: secondModelValue, for: key)
//        Thread.sleep(forTimeInterval: 3)
//    }
//}
