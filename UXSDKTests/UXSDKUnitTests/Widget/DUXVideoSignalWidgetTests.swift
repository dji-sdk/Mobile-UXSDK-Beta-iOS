//
//  DUXBetaVideoSignalWidgetTests.swift
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

enum AirLinkType {
    case wifi
    case lightbridge
    case ocuSync
}

class DUXBetaVideoSignalWidgetTests: XCTestCase {
    
    var mockKeyManager : DUXBetaMockKeyManager?
    
    var downlinkSignalQualityKey : DJIAirLinkKey?
    var wifiFrequencyBandKey : DJIAirLinkKey?
    var lightbridgeFrequencyBandKey : DJIAirLinkKey?
    var ocuSyncFrequencyBandKey : DJIAirLinkKey?
    var ocuSyncLinkChannelNumberKey : DJIAirLinkKey?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()
        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
        
        self.downlinkSignalQualityKey = DJIAirLinkKey(index:0, andParam:DJIAirLinkParamDownlinkSignalQuality)
        
        self.wifiFrequencyBandKey = DJIAirLinkKey(index: 0,
                                           subComponent: DJIAirLinkWiFiLinkSubComponent,
                                      subComponentIndex: 0,
                                               andParam: DJIWiFiLinkParamFrequencyBand)
        
        self.lightbridgeFrequencyBandKey = DJIAirLinkKey(index: 0,
                                                  subComponent: DJIAirLinkLightbridgeLinkSubComponent,
                                             subComponentIndex: 0,
                                                      andParam: DJILightbridgeLinkParamFrequencyBand)
        
        self.ocuSyncFrequencyBandKey = DJIAirLinkKey(index: 0,
                                              subComponent: DJIAirLinkOcuSyncLinkSubComponent,
                                         subComponentIndex: 0,
                                                  andParam: DJIOcuSyncLinkParamFrequencyBand)
        
        self.ocuSyncLinkChannelNumberKey = DJIAirLinkKey(index:0,
                                               subComponent:DJIAirLinkOcuSyncLinkSubComponent,
                                          subComponentIndex:0,
                                                   andParam:DJIOcuSyncLinkParamChannelNumber)
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }

    func testReflectSignalStrength() {
        let testInputToResultDictionary = [
            0 : DUXBetaVideoSignalStrength.level0,
            10 : DUXBetaVideoSignalStrength.level1,
            30 : DUXBetaVideoSignalStrength.level2,
            50 : DUXBetaVideoSignalStrength.level3,
            70 : DUXBetaVideoSignalStrength.level4,
            90 : DUXBetaVideoSignalStrength.level5
        ]
        
        for testInput in testInputToResultDictionary.keys {
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
                DUXBetaMockKey(key: self.downlinkSignalQualityKey!) : DUXBetaMockKeyedValue(value: testInput)
            ]
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            let widgetModel = DUXBetaVideoSignalWidgetModel()
            
            widgetModel.setup()
            XCTAssertEqual(widgetModel.barsLevel, testInputToResultDictionary[testInput])
            widgetModel.cleanup()
        }
    }
    
    func testWifiBand() {
        let testValue = DJIWiFiFrequencyBand.band2Dot4GHz

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.wifiFrequencyBandKey!) : DUXBetaMockKeyedValue(value: testValue.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaVideoSignalWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.wifiFrequencyBand, testValue)
        widgetModel.cleanup()
    }
    
    func testLightbridgeBand() {
        let testValue = DJILightbridgeFrequencyBand.band2Dot4GHz

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.lightbridgeFrequencyBandKey!) : DUXBetaMockKeyedValue(value: testValue.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaVideoSignalWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.lightBridgeFrequencyBand, testValue)
        widgetModel.cleanup()
    }
    
    func testOcusyncBand() {
        let testValue = DJIOcuSyncFrequencyBand.band2Dot4GHz

        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
            DUXBetaMockKey(key: self.lightbridgeFrequencyBandKey!) : DUXBetaMockKeyedValue(value: testValue.rawValue)
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        let widgetModel = DUXBetaVideoSignalWidgetModel()
        
        widgetModel.setup()
        XCTAssertEqual(widgetModel.ocuSyncFrequencyBand, testValue)
        widgetModel.cleanup()
    }
    
    func testOcusyncBandDual() {
        let testInputToResultDictionary = [
            5600 : DJIOcuSyncFrequencyBand.band5Dot8GHz,
            5000 : DJIOcuSyncFrequencyBand.band2Dot4GHz,
            2000 : DJIOcuSyncFrequencyBand.bandUnknown
        ]
        
        for testInput in testInputToResultDictionary.keys {
            let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue] = [
                DUXBetaMockKey(key: self.ocuSyncFrequencyBandKey!) : DUXBetaMockKeyedValue(value: DJIOcuSyncFrequencyBand.bandDual.rawValue),
                DUXBetaMockKey(key: self.ocuSyncLinkChannelNumberKey!) : DUXBetaMockKeyedValue(value: testInput)
            ]
            
            self.mockKeyManager?.mockKeyValueDictionary = mockValues
            let widgetModel = DUXBetaVideoSignalWidgetModel()
            
            widgetModel.setup()
            XCTAssertEqual(widgetModel.ocuSyncFrequencyBand, testInputToResultDictionary[testInput])
            widgetModel.cleanup()
        }
    }
}
