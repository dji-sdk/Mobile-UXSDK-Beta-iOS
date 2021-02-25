//
//  DUXBetaMapWidgetTests.swift
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
import DJISDK

class DUXBetaMapWidgetTests: XCTestCase, DUXBetaFlyZoneDataProviderDelegate ,DJISDKManagerDelegate {
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        NSLog("todo: do something here? just added to conform to protocol...")
    }
    

    var mockFlyZoneManager:DJIFlyZoneManager?
    var isRegistered: Bool = false
    var registrationSemaphore: DispatchSemaphore?
    
    let lockedFlyZoneDataExpecationDescription = "LockedFlyZoneDataExpecationDescription"
    let unlockedFlyZoneDataExpecationDescription = "UnlockedFlyZoneDataExpecationDescription"
    let customUnlockedFlyZoneDataExpecationDescription = "CustomUnlockedFlyZoneDataExpecationDescription"
    
    var mockKeyManager: DUXBetaMockKeyManager?
    
    var testExpectation: XCTestExpectation?
    
    public func flyZoneDataProvider(_ flyZoneDataProvider: DUXBetaFlyZoneDataProvider, didUpdateFlyZones flyZones: [String : DJIFlyZoneInformation]) {
        if self.testExpectation?.expectationDescription == self.lockedFlyZoneDataExpecationDescription {
            self.testExpectation?.fulfill()
        }
    }

    public func flyZoneDataProvider(_ flyZoneDataProvider: DUXBetaFlyZoneDataProvider, didUpdateUnlockedFlyZones flyZones: [String : DJIFlyZoneInformation]) {
        if self.testExpectation?.expectationDescription == self.unlockedFlyZoneDataExpecationDescription {
            self.testExpectation?.fulfill()
        }
    }

    public func flyZoneDataProvider(_ flyZoneDataProvider: DUXBetaFlyZoneDataProvider, requestsPresentationOfAlertWithTitle alertTitle: String, alertMessage: String, loginAccountStateCompletion completion: DJISDK.DJIAccountStateCompletionBlock? = nil) {
        
    }

    public func flyZoneDataProvider(_ flyZoneDataProvider: DUXBetaFlyZoneDataProvider, successfullyUnlockedFlyZonesWithIDs flyZoneIDs: [NSNumber]) {

    }

    public func flyZoneDataProvider(_ flyZoneDataProvider: DUXBetaFlyZoneDataProvider, unsuccessfullyUnlockedFlyZonesWithIDs flyZoneIDs: [NSNumber], withError error: Error) {

    }

    public func flyZoneDataProvider(_ flyZoneDataProvider: DUXBetaFlyZoneDataProvider, abortedUnlockingProcessWithCurrentUserAccountState userAccountState: DJIUserAccountState) {
        
    }

    public func flyZoneDataProvider(_ flyZoneDataProvider: DUXBetaFlyZoneDataProvider, didUpdateCustomUnlockZones customUnlockZones: [String : DJICustomUnlockZone]) {
        if self.testExpectation?.expectationDescription == self.customUnlockedFlyZoneDataExpecationDescription {
            self.testExpectation?.fulfill()
        }
    }

    public func flyZoneDataProvider(_ flyZoneDataProvider: DUXBetaFlyZoneDataProvider, didUpdateEnabledCustomUnlockZone customUnlockZone: DJICustomUnlockZone?) {

    }
    
    func appRegisteredWithError(_ error: Error?) {
        if let unwrappedError = error {
            print(unwrappedError)
        }
        self.registrationSemaphore?.signal()
    }
    
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
    
    override func tearDown() {
        super.tearDown()
        DJISDKManager.stopListening(onRegistrationUpdatesOfListener: self)
    }
    /*
    func testFlyZones() {
        let provider = DUXBetaFlyZoneDataProvider()
        DJISDKManager.registerApp(with: self)
        provider.flyZoneManager = DJISDKManager.flyZoneManager()!
        provider.delegate = self
        self.testExpectation = self.expectation(description: self.lockedFlyZoneDataExpecationDescription)
        provider.refreshNearbyVisibleFlyZones(ofCategory: [.restricted, .authorization, .enhancedWarning, .warning])
        self.wait(for: [self.testExpectation!], timeout: 30)
    }

    func testUnlockedFlyZones() {
        let provider = DUXBetaFlyZoneDataProvider()
        DJISDKManager.registerApp(with: self)
        provider.flyZoneManager = DJISDKManager.flyZoneManager()!
        provider.delegate = self
        self.testExpectation = self.expectation(description: self.unlockedFlyZoneDataExpecationDescription)
        provider.refreshNearbyVisibleFlyZones(ofCategory: [.restricted, .authorization, .enhancedWarning, .warning])
        self.wait(for: [self.testExpectation!], timeout: 30)
    }

    func testCustomUnlockZones() {
        DJISDKManager.registerApp(with: self)
        let serialNumberKey = DJIFlightControllerKey(param: DJIParamSerialNumber)
        
        guard let serialNumberKeyUnwrapped = serialNumberKey else {
            XCTFail("Found Nil Key")
            return
        }
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: serialNumberKeyUnwrapped) : DUXBetaMockKeyedValue(value: "JPB7768")
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let provider = DUXBetaFlyZoneDataProvider()
        provider.userAccountManager = DUXBetaMockUserAccountManager()
        provider.needsCustomUnlockZones = true
        provider.flyZoneManager = DJISDKManager.flyZoneManager()!
        provider.delegate = self
        self.testExpectation = self.expectation(description: self.customUnlockedFlyZoneDataExpecationDescription)
        provider.getCustomUnlockedZones()
        self.wait(for: [self.testExpectation!], timeout: 30)
    }

    func testCustomUnlockOverlays() {
        DJISDKManager.registerApp(with: self)
        let serialNumberKey = DJIFlightControllerKey(param: DJIParamSerialNumber)
        
        guard let serialNumberKeyUnwrapped = serialNumberKey else {
            XCTFail("Found Nil Key")
            return
        }
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: serialNumberKeyUnwrapped) : DUXBetaMockKeyedValue(value: "JPB7768")
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let mapWidget = DUXBetaMapWidget()
        mapWidget.showCustomUnlockZones = true
        mapWidget.flyZoneDataProvider.getCustomUnlockedZones()

        sleep(5)

        XCTAssert(mapWidget.overlayProvider.addedOverlays.count == 2)

        mapWidget.showCustomUnlockZones = false

        sleep(5)

        XCTAssert(mapWidget.overlayProvider.addedOverlays.count == 0)
        XCTAssert(mapWidget.overlayProvider.removedOverlays.count == 2)
    }

    func testCustomUnlockAnnotations() {
        DJISDKManager.registerApp(with: self)
        let serialNumberKey = DJIFlightControllerKey(param: DJIParamSerialNumber)
        
        guard let serialNumberKeyUnwrapped = serialNumberKey else {
            XCTFail("Found Nil Key")
            return
        }
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: serialNumberKeyUnwrapped) : DUXBetaMockKeyedValue(value: "JPB7768")
        ]
        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let mapWidget = DUXBetaMapWidget()
        mapWidget.flyZoneDataProvider.userAccountManager = DUXBetaMockUserAccountManager()
        mapWidget.showCustomUnlockZones = true
        mapWidget.tapToUnlockEnabled = true
        mapWidget.flyZoneDataProvider.getCustomUnlockedZones()

        sleep(5)

        XCTAssert(mapWidget.annotationProvider.addedAnnotations.count == 2)

        mapWidget.showCustomUnlockZones = false

        sleep(5)

        XCTAssert(mapWidget.annotationProvider.addedAnnotations.count == 0)
        XCTAssert(mapWidget.annotationProvider.removedAnnotations.count == 2)
    }*/
}
