//
//  DUXBetaVisionWidgetTests.swift
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

class DUXBetaVisionWidgetTests: XCTestCase {

    var mockKeyManager : DUXBetaMockKeyManager?
    var modelNameKey : DJIProductKey?
    var flightModeKey : DJIFlightControllerKey?
    var isSensorBeingUsedKey: DJIFlightControllerKey?
    var collisionAvoidanceEnabledKey : DJIFlightControllerKey?
    var isLeftRightSensorEnabledKey : DJIFlightControllerKey?
    var isNoseTailSensorEnabledKey : DJIFlightControllerKey?
    var avoidanceStateM300Key : DJIFlightControllerKey?
    var upwardsAvoidanceEnabledKey : DJIFlightControllerKey?
//    var downwardsAvoidanceEnabledKey : DJIFlightControllerKey?
    
    override class func setUp() {
        super.setUp()
        let mockKeyManager = DUXBetaMockKeyManager()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(mockKeyManager)
    }
    
    override func setUp() {
        super.setUp()

        self.mockKeyManager = DUXBetaKeyInterfaceAdapter.sharedInstance().getHandler() as? DUXBetaMockKeyManager
        
        self.modelNameKey = DJIProductKey(param: DJIProductParamModelName)
        
        self.flightModeKey = DJIFlightControllerKey(param: DJIFlightControllerParamFlightMode)
        
        self.isSensorBeingUsedKey = DJIFlightControllerKey(index: 0,
                                                    subComponent: DJIFlightControllerFlightAssistantSubComponent,
                                               subComponentIndex: 0,
                                                        andParam: DJIFlightAssistantParamIsSensorBeingUsed)
        
        self.isLeftRightSensorEnabledKey = DJIFlightControllerKey(index: 0,
                                                           subComponent: DJIFlightControllerFlightAssistantSubComponent,
                                                      subComponentIndex: 0,
                                                               andParam: DJIFlightAssistantParamVisionLeftRightSensorEnabled)
        
        self.collisionAvoidanceEnabledKey = DJIFlightControllerKey(index: 0,
                                                            subComponent: DJIFlightControllerFlightAssistantSubComponent,
                                                       subComponentIndex: 0,
                                                                andParam: DJIFlightAssistantParamCollisionAvoidanceEnabled)
        
        self.isNoseTailSensorEnabledKey = DJIFlightControllerKey(index: 0,
                                                          subComponent: DJIFlightControllerFlightAssistantSubComponent,
                                                     subComponentIndex: 0,
                                                              andParam: DJIFlightAssistantParamVisionNoseTailSensorEnabled)

        self.avoidanceStateM300Key = DJIFlightControllerKey(index: 0,
                                                     subComponent: DJIFlightControllerFlightAssistantSubComponent,
                                                subComponentIndex: 0,
                                                         andParam: DJIFlightAssistantParamAvoidanceState)
        
        self.upwardsAvoidanceEnabledKey = DJIFlightControllerKey(index: 0,
                                                          subComponent: DJIFlightControllerFlightAssistantSubComponent,
                                                     subComponentIndex: 0,
                                                              andParam: DJIFlightAssistantParamUpwardsAvoidanceEnabled)
        
//        self.downwardsAvoidanceEnabledKey = DJIFlightControllerKey(index: 0,
//                                                            subComponent: DJIFlightControllerFlightAssistantSubComponent,
//                                                       subComponentIndex: 0,
//                                                                andParam: DJIFlightControllerParamLandingConfirmEnable)
    }
    
    override class func tearDown() {
        super.tearDown()
        DUXBetaKeyInterfaceAdapter.sharedInstance().setHandler(DJISDKManager.keyManager() as? DUXBetaKeyInterfaces)
    }
    
    
    func testVisionStatusDisabledActiveTrack() {
        DUXBetaMockMissionControl.shared().mockActiveTrackMode = 1 as NSInteger //1 = profile -> vision unsupported
        DUXBetaMockMissionControl.shared().mockTapFlyMode = 0 as NSInteger //0 = forward -> vision supported
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNamePhantom4),
            DUXBetaMockKey(key: self.flightModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIFlightMode.activeTrack.rawValue)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isLeftRightSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isNoseTailSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.disabled)
        widgetModel.cleanup()
    }
    
    func testVisionStatusDisabledTapFly() {
        DUXBetaMockMissionControl.shared().mockActiveTrackMode = 0 as NSInteger //0 = trace -> vision supported
        DUXBetaMockMissionControl.shared().mockTapFlyMode = 2 as NSInteger //2 = free -> vision unsupported
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNamePhantom4),
            DUXBetaMockKey(key: self.flightModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIFlightMode.tapFly.rawValue)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isLeftRightSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isNoseTailSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.disabled)
        widgetModel.cleanup()
    }
    
    
    func testCurrentAircraftSupportVisionForUnsupportedModel() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice600),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(!widgetModel.currentAircraftSupportVision)
        widgetModel.cleanup()
    }
    
    func testVisionStatusClosed() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNamePhantom4),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.closed)
        widgetModel.cleanup()
    }

    func testVisionStatusDisabledFlightMode() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNamePhantom4),
            DUXBetaMockKey(key: self.flightModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIFlightMode.atti.rawValue)),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.disabled)
        widgetModel.cleanup()
    }
    
    func testVisionStatusEnabledActiveTrack() {
        DUXBetaMockMissionControl.shared().mockActiveTrackMode = 0 as NSInteger //0 = trace -> vision supported
        DUXBetaMockMissionControl.shared().mockTapFlyMode = 0 as NSInteger //0 = forward -> vision supported
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNamePhantom4),
            DUXBetaMockKey(key: self.flightModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIFlightMode.activeTrack.rawValue)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isLeftRightSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isNoseTailSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues

        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.normal)
        widgetModel.cleanup()
    }

    func testVisionStatusAllSensorsEnabledMavic2() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMavic2),
            DUXBetaMockKey(key: self.flightModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIFlightMode.goHome.rawValue)),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isLeftRightSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isNoseTailSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniAll)
        widgetModel.cleanup()
    }
    
    func testVisionStatusLeftRightDisabledMavic2() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMavic2),
            DUXBetaMockKey(key: self.flightModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIFlightMode.goHome.rawValue)),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isLeftRightSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false)),
            DUXBetaMockKey(key: self.isNoseTailSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniFrontBack)
        widgetModel.cleanup()
    }

    func testVisionStatusAllDisabledMavic2() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMavic2),
            DUXBetaMockKey(key: self.flightModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIFlightMode.goHome.rawValue)),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isLeftRightSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false)),
            DUXBetaMockKey(key: self.isNoseTailSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniDisabled)
        widgetModel.cleanup()
    }
    
    func testVisionStatusClosedMavic2() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMavic2),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniClosed)
        widgetModel.cleanup()
    }
    
    func testVisionStatusAllSensorsEnabledMavic2Enterprise() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMavic2Enterprise),
            DUXBetaMockKey(key: self.flightModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIFlightMode.goHome.rawValue)),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isLeftRightSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isNoseTailSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniAll)
        widgetModel.cleanup()
    }
    
    func testVisionStatusLeftRightDisabledMavic2Enterprise() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMavic2Enterprise),
            DUXBetaMockKey(key: self.flightModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIFlightMode.goHome.rawValue)),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isLeftRightSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false)),
            DUXBetaMockKey(key: self.isNoseTailSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniFrontBack)
        widgetModel.cleanup()
    }
    
    func testVisionStatusAllDisabledMavic2Enterprise() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMavic2Enterprise),
            DUXBetaMockKey(key: self.flightModeKey!) : DUXBetaMockKeyedValue(value: NSNumber(value: DJIFlightMode.atti.rawValue)),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isLeftRightSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false)),
            DUXBetaMockKey(key: self.isNoseTailSensorEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniDisabled)
        widgetModel.cleanup()
    }

    func testVisionStatusClosedMavic2Enterprise() {
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMavic2Enterprise),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniClosed)
        widgetModel.cleanup()
    }
    
    func testM300All() {
        let mockM300AvoidanceState = DUXBetaMockFlightAssistantObstacleAvoidanceSensorState()
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInVerticalDirectionEnabled = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInVerticalDirectionWorking = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInHorizontalDirectionEnabled = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInHorizontalDirectionWorking = true
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.avoidanceStateM300Key!) : DUXBetaMockKeyedValue(value:mockM300AvoidanceState),
            DUXBetaMockKey(key: self.upwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:true),
//            DUXBetaMockKey(key: self.downwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:true),
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniAll)
        widgetModel.cleanup()
    }
    
    func testM300HorizontalUserDisable() {
        let mockM300AvoidanceState = DUXBetaMockFlightAssistantObstacleAvoidanceSensorState()
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInVerticalDirectionEnabled = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInVerticalDirectionWorking = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInHorizontalDirectionEnabled = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInHorizontalDirectionWorking = true
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.avoidanceStateM300Key!) : DUXBetaMockKeyedValue(value:mockM300AvoidanceState),
            DUXBetaMockKey(key: self.upwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:false),
//            DUXBetaMockKey(key: self.downwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:false),
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniHorizontal)
        widgetModel.cleanup()
    }
    
    func testM300HorizontalSensorDisable() {
        let mockM300AvoidanceState = DUXBetaMockFlightAssistantObstacleAvoidanceSensorState()
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInVerticalDirectionEnabled = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInVerticalDirectionWorking = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInHorizontalDirectionEnabled = false
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInHorizontalDirectionWorking = false
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.avoidanceStateM300Key!) : DUXBetaMockKeyedValue(value:mockM300AvoidanceState),
            DUXBetaMockKey(key: self.upwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:true),
//            DUXBetaMockKey(key: self.downwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:true),
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.visionSystemStatus, DUXBetaVisionStatus.omniVertical)
        widgetModel.cleanup()
    }
    
    func testM300VerticalUserDisable() {
        let mockM300AvoidanceState = DUXBetaMockFlightAssistantObstacleAvoidanceSensorState()
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInVerticalDirectionEnabled = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInVerticalDirectionWorking = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInHorizontalDirectionEnabled = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInHorizontalDirectionWorking = true
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.avoidanceStateM300Key!) : DUXBetaMockKeyedValue(value:mockM300AvoidanceState),
            DUXBetaMockKey(key: self.upwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:true),
//            DUXBetaMockKey(key: self.downwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:true),
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniVertical)
        widgetModel.cleanup()
    }
    
    func testM300VerticalSensorDisable() {
        let mockM300AvoidanceState = DUXBetaMockFlightAssistantObstacleAvoidanceSensorState()
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInVerticalDirectionEnabled = false
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInVerticalDirectionWorking = false
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInHorizontalDirectionEnabled = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInHorizontalDirectionWorking = true
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.avoidanceStateM300Key!) : DUXBetaMockKeyedValue(value:mockM300AvoidanceState),
            DUXBetaMockKey(key: self.upwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:true),
//            DUXBetaMockKey(key: self.downwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:true),
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssertEqual(widgetModel.visionSystemStatus, DUXBetaVisionStatus.omniHorizontal)
        widgetModel.cleanup()
    }
    
    func testM300ClosedUserDisable() {
        let mockM300AvoidanceState = DUXBetaMockFlightAssistantObstacleAvoidanceSensorState()
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInVerticalDirectionEnabled = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInVerticalDirectionWorking = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInHorizontalDirectionEnabled = true
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInHorizontalDirectionWorking = true
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.avoidanceStateM300Key!) : DUXBetaMockKeyedValue(value:mockM300AvoidanceState),
            DUXBetaMockKey(key: self.upwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:false),
//            DUXBetaMockKey(key: self.downwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:false),
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: false)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniClosed)
        widgetModel.cleanup()
    }
    
    func testM300ClosedSensorDisable() {
        let mockM300AvoidanceState = DUXBetaMockFlightAssistantObstacleAvoidanceSensorState()
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInVerticalDirectionEnabled = false
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInVerticalDirectionWorking = false
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorsInHorizontalDirectionEnabled = false
        mockM300AvoidanceState.isVisualObstacleAvoidanceSensorInHorizontalDirectionWorking = false
        
        let mockValues: [DUXBetaMockKey : DUXBetaMockKeyedValue]  = [
            DUXBetaMockKey(key: self.avoidanceStateM300Key!) : DUXBetaMockKeyedValue(value:mockM300AvoidanceState),
            DUXBetaMockKey(key: self.upwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:true),
//            DUXBetaMockKey(key: self.downwardsAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value:true),
            DUXBetaMockKey(key: self.modelNameKey!) : DUXBetaMockKeyedValue(value: DJIAircraftModelNameMatrice300RTK),
            DUXBetaMockKey(key: self.collisionAvoidanceEnabledKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true)),
            DUXBetaMockKey(key: self.isSensorBeingUsedKey!) : DUXBetaMockKeyedValue(value: NSNumber(booleanLiteral: true))
        ]
        
        self.mockKeyManager?.mockKeyValueDictionary = mockValues
        
        let widgetModel = DUXBetaVisionWidgetModel()
        widgetModel.setup()
        XCTAssert(widgetModel.visionSystemStatus == DUXBetaVisionStatus.omniClosed)
        widgetModel.cleanup()
    }
}
