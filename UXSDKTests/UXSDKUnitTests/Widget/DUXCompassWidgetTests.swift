//
//  DUXBetaCompassWidgetTests.swift
//  UXSDKUnitTests
//
//  MIT License
//  
//  Copyright © 2018-2021 DJI
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

class DUXBetaCompassWidgetTests: XCTestCase {
    var mockKeyManager: DUXBetaMockKeyManager?
    
    let aircraftAttitudeKey = DJIFlightControllerKey(param: DJIFlightControllerParamAttitude)
    let gimbalYawRelativeToAircraftKey = DJIGimbalKey(param: DJIGimbalParamAttitudeYawRelativeToAircraft)
    let homeLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamHomeLocation)
    let aircraftLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)
    let rcGPSDataKey = DJIRemoteControllerKey(param: DJIRemoteControllerParamGPSData)
    
    var rcGPSDataValue: NSValue?
    
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
    
    func test_aircraftAttitude() {
        guard let aircraftAttitudeKeyUnwrapped = aircraftAttitudeKey else {
            XCTFail("Found Nil Key")
            return
        }

        let aircraftAttitude = DJISDKVector3D()
        aircraftAttitude.x = 100.0
        aircraftAttitude.y = 50.0
        aircraftAttitude.z = 150.0

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: aircraftAttitudeKeyUnwrapped) : DUXBetaMockKeyedValue(value: aircraftAttitude)]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaCompassWidgetModel()
        widgetModel.locationManager = nil;
        widgetModel.setup()
        
        XCTAssert(widgetModel.compassState.aircraftAttitude.pitch == aircraftAttitude.y)
        XCTAssert(widgetModel.compassState.aircraftAttitude.yaw == aircraftAttitude.z)
        XCTAssert(widgetModel.compassState.aircraftAttitude.roll == aircraftAttitude.x)
    }
    
    func test_gimbalYawRelativeToAircraft() {
        guard let gimbalYawRelativeToAircraftKeyUnwrapped = gimbalYawRelativeToAircraftKey else {
            XCTFail("Found Nil Key(s)")
            return
        }
        
        let gimbalYawRelativeToAircraft = CLLocationDirection(exactly: 100.0)
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [DUXBetaMockKey(key: gimbalYawRelativeToAircraftKeyUnwrapped) : DUXBetaMockKeyedValue(value: gimbalYawRelativeToAircraft!)]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaCompassWidgetModel()
        widgetModel.locationManager = nil;
        widgetModel.setup()
        
        XCTAssert(widgetModel.compassState.gimbalHeading == gimbalYawRelativeToAircraft)
    }
    
    func test_centerHomeGPS() {
        guard let homeLocationKeyUnwrapped = homeLocationKey,
              let aircraftLocationKeyUnwrapped = aircraftLocationKey else {
                XCTFail("Found Nil Key(s)")
                return
        }

        let homeLocation = CLLocation(latitude: CLLocationDegrees(exactly: 37.421830)!, longitude: CLLocationDegrees(exactly: -122.137390)!)
        //PA office location
        let aircraftLocation = CLLocation(latitude: CLLocationDegrees(exactly: 37.421842)!, longitude: CLLocationDegrees(exactly: -122.137382)!)
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [ DUXBetaMockKey(key: homeLocationKeyUnwrapped) : DUXBetaMockKeyedValue(value: homeLocation),
                                                                 DUXBetaMockKey(key: aircraftLocationKeyUnwrapped) : DUXBetaMockKeyedValue(value: aircraftLocation)]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaCompassWidgetModel()
        widgetModel.locationManager = nil;
        widgetModel.setup()
        
        let droneDistance = aircraftLocation.distance(from: homeLocation)
        let homeAngle = DUXBetaLocationUtil.angleBetween(homeLocation, andLocation: homeLocation)
        let droneAngle = DUXBetaLocationUtil.angleBetween(homeLocation, andLocation: aircraftLocation)
        
        XCTAssertEqual(widgetModel.compassState.centerType, .homeGPS)
        XCTAssertEqual(widgetModel.compassState.rcLocationState, nil)
        XCTAssertEqual(widgetModel.compassState.aircraftState.angle, droneAngle)
        XCTAssertEqual(widgetModel.compassState.homeLocationState?.angle, homeAngle)
        XCTAssertEqual(widgetModel.compassState.homeLocationState?.distance, 0.0)
        XCTAssertEqual(widgetModel.compassState.aircraftState.distance, droneDistance)
    }
    
    func test_centerRCMobileGPS() {
        guard let homeLocationKeyUnwrapped = homeLocationKey,
              let aircraftLocationKeyUnwrapped = aircraftLocationKey,
              let rcGPSDataKeyUnwrapped = rcGPSDataKey
        else {
                XCTFail("Found Nil Key(s)")
                return
        }

        let homeLocation = CLLocation(latitude: CLLocationDegrees(exactly: 37.421830)!, longitude: CLLocationDegrees(exactly: -122.137390)!)
        //PA office location
        let aircraftLocation = CLLocation(latitude: CLLocationDegrees(exactly: 37.421842)!, longitude: CLLocationDegrees(exactly: -122.137382)!)
        let rcLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: 37.421831)!, longitude: CLLocationDegrees(exactly: -122.137391)!)
        let rcGPSTime = DJIRCGPSTime(hour: UInt8(exactly: 2.0)!, minute: UInt8(exactly: 2.0)!, second: UInt8(exactly: 2.0)!, year: UInt16(exactly: 2019)!, month: UInt8(exactly: 2.0)!, day: UInt8(exactly: 2.0)!)
        let rcGPSData = DJIRCGPSData(time: rcGPSTime, location: rcLocation, eastSpeed: 10.0, northSpeed: 10.0, satelliteCount: 2, accuracy: 10.0, isValid: true)
        self.rcGPSDataValue = NSValue.duxbeta_rcGPSDataValue(rcGPSData)
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [DUXBetaMockKey(key: homeLocationKeyUnwrapped) : DUXBetaMockKeyedValue(value: homeLocation),
                                                                 DUXBetaMockKey(key: aircraftLocationKeyUnwrapped) : DUXBetaMockKeyedValue(value: aircraftLocation),
                                                                 DUXBetaMockKey(key: rcGPSDataKeyUnwrapped) : DUXBetaMockKeyedValue(value: self.rcGPSDataValue!)]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaCompassWidgetModel()
        widgetModel.locationManager = nil;
        widgetModel.setup()
        
        let rcLocationTest = CLLocation(latitude: rcLocation.latitude, longitude: rcLocation.longitude)
        let droneDistance = rcLocationTest.distance(from: aircraftLocation)
        let homeDistance = rcLocationTest.distance(from: homeLocation)
        let droneAngle = DUXBetaLocationUtil.angleBetween(rcLocationTest, andLocation: aircraftLocation)
        let homeAngle = DUXBetaLocationUtil.angleBetween(rcLocationTest, andLocation: homeLocation)
        
        XCTAssertEqual(widgetModel.compassState.centerType, .rcMobileGPS)
        XCTAssertEqual(widgetModel.compassState.rcLocationState?.distance, 0.0)
        XCTAssertEqual(widgetModel.compassState.aircraftState.angle, droneAngle)
        XCTAssertEqual(widgetModel.compassState.homeLocationState?.angle, homeAngle)
        XCTAssertEqual(widgetModel.compassState.aircraftState.distance, droneDistance)
        XCTAssertEqual(widgetModel.compassState.homeLocationState?.distance, homeDistance)
    }
}
