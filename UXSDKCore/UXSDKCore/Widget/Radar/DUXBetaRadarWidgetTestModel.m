//
//  DUXBetaRadarWidgetTestModel.m
//  UXSDKCore
//
//  Copyright © 2020 DJI
//  
// Private class. DO NOT RELEASE

#import "DUXBetaRadarWidgetTestModel.h"

@interface DJIObstacleDetectionSector ()

//Doc key: DJIVisionDetectionState_DJIVisionDetectionSector_obstacleDistanceInMeters
/**
 *  The detected obstacle distance to the aircraft in meters.
 */
@property(nonatomic, readwrite) double obstacleDistanceInMeters;

//Doc key: DJIVisionDetectionState_DJIVisionDetectionSector_warningLevel
/**
 *  The warning level based on distance.
 */
@property(nonatomic, readwrite) DJIObstacleDetectionSectorWarning warningLevel;

@end

@interface DJIVisionDetectionState ()

@property(nonatomic, readwrite) DJIVisionSensorPosition position;
@property(nonatomic, readwrite) BOOL isSensorBeingUsed;
@property(nonatomic, readwrite) DJIVisionSystemWarning systemWarning;

//Doc key: DJIVisionDetectionState_obstacleDistanceInMeters
/**
 *  The distance to the closest detected obstacle, in meters. It is only used when
 *  the sensor is an infrared TOF  sensor. The valid range is [0.3, 5.0]. Phantom 4
 *  Pro has two infrared sensors on its left and right. Both sensors have a
 *  70-degree horizontal field of view (FOV) and 20-degree vertical FOV. The value
 *  is always 0.0 if the sensor is a dual-camera sensor or the sensor is not working
 *  properly.
 */
@property(nonatomic, readwrite) double obstacleDistanceInMeters;

//Doc key: DJIVisionDetectionState_detectionSectors
/**
 *  The vision system can see in front of the aircraft with a 70 degree horizontal
 *  field of view (FOV) and 55-degree  vertical FOV for the Phantom 4. The
 *  horizontal FOV is split into four equal sectors and this array contains the
 *  distance and warning information for each sector. For Phantom 4, the horizontal
 *  FOV is separated into 4 sectors.
 */
@property(nullable, nonatomic, readwrite) NSArray<DJIObstacleDetectionSector *> *detectionSectors;

@end

@interface DJIVisionControlState ()

//@property (nonatomic, readonly) BOOL isBraking;
/**
 *  YES if the aircraft will not ascend further because of an obstacle detected
 *  within 1m above it.
 */
@property (nonatomic, readwrite) BOOL isAscentLimitedByObstacle;
/**
 *  `YES` if the aircraft is avoiding collision from an obstacle moving towards the
 *  aircraft.
 */
//@property (nonatomic, readonly) BOOL isAvoidingActiveObstacleCollision;
//@property (nonatomic, readonly) BOOL isPerformingPrecisionLanding;
//@property (nonatomic, readonly) DJIVisionLandingProtectionState landingProtectionState;
//@property (nonatomic, readonly) BOOL isAdvancedPilotAssistanceSystemActive;

@end

@implementation DJIObstacleDetectionSector
-(void) setObstacleDistanceInMeters:(double)distance {
    _obstacleDistanceInMeters = distance;
}
@end

@implementation DJIVisionDetectionState
-(void) setObstacleDistanceInMeters:(double)distance {
    _obstacleDistanceInMeters = distance;
}
@end

@implementation DJIVisionControlState
-(void) setIsAscentLimitedByObstacle:(BOOL)isLimited {
    _isAscentLimitedByObstacle = isLimited;
}
@end

typedef NS_ENUM(NSInteger, DUXBetaRadarTestStates) {
    RadarFullDistance = 0,
    Radar1,
    Radar2,
    Radar3,
    Radar4,
    Radar5,
    Radar6,
    Radar7,
    Radar8,
    Radar9,
    Radar10,
    Radar11,
    Radar12,
    Radar13,
    Radar14
};

@interface DUXBetaRadarWidgetTestModel ()
@property (nonatomic, strong, readwrite) DJIVisionDetectionState *noseState;
@property (nonatomic, strong, readwrite) DJIVisionDetectionState *tailState;
@property (nonatomic, strong, readwrite) DJIVisionDetectionState *rightState;
@property (nonatomic, strong, readwrite) DJIVisionDetectionState *leftState;
@property (nonatomic, strong, readwrite) DJIVisionControlState *controlState;
@property (nonatomic, strong, readwrite) DJIFlightAssistantObstacleAvoidanceSensorState *avoidanceStateM300;

@property (nonatomic, assign) DUXBetaRadarTestStates step;
@property (nonatomic, assign) NSInteger caseCount;
@end

@implementation DUXBetaRadarWidgetTestModel

- (void)inSetup {
//BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamVisionDetectionNoseState], noseState);
//BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamVisionDetectionTailState], tailState);
//BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamVisionDetectionRightState], rightState);
//BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamVisionDetectionLeftState], leftState);
//BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamVisionControlState], controlState);
//BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamAvoidanceState], avoidanceStateM300);
BindRKVOModel(self, @selector(update), noseState, tailState, rightState, leftState, controlState, avoidanceStateM300);

    
    self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(4.0), @(12.0), @(6.0), @(2.0)]];
    self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(2.0), @(1.0), @(4.0), @(12.0)]];
    self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(1.9)]];
    self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(5.0)]];
    DJIVisionControlState *controlState = [DJIVisionControlState new];
    controlState.isAscentLimitedByObstacle = NO;
    self.controlState = controlState;

    self.caseCount = 14;
    self.step = RadarFullDistance - 1;
    
    
    __weak DUXBetaRadarWidgetTestModel *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^() {
        [weakSelf radarStateMachineStep];
    });

}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)update {
}

- (void)radarStateMachineStep {
    self.step = (self.step + 1) % self.caseCount;
    
    switch (self.step) {
        case RadarFullDistance:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(10.0), @(10.0), @(10.0), @(10.0)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(10.0), @(10.0), @(10.0), @(10.0)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(10.0)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(10.0)]];
            {
                DJIVisionControlState *controlState = [DJIVisionControlState new];
                controlState.isAscentLimitedByObstacle = NO;
                self.controlState = controlState;
            }
            break;

        case Radar1:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(8), @(8), @(8), @(8)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(8), @(8), @(8), @(8)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(6)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(10.0)]];
            break;

        case Radar2:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(6), @(6), @(6), @(6)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(6), @(6), @(6), @(6)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(3)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(5.0)]];
            break;

        case Radar3:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(4), @(4), @(4), @(4)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(4), @(4), @(4), @(4)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(1)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(2.9)]];
            break;

        case Radar4:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(2), @(2), @(2), @(2)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(2), @(2), @(2), @(2)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(10)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(6)]];
            break;

        case Radar5:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(2), @(2), @(2), @(2)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(2), @(2), @(2), @(2)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(3)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(5)]];
            break;

        case Radar6:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(0), @(0), @(0), @(0)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(0), @(0), @(0), @(0)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(2)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(3)]];
            break;

        case Radar7:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(10.0), @(8), @(6), @(5)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(10.0), @(8), @(6), @(5)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(10.0)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(10.0)]];
            {
                DJIVisionControlState *controlState = [DJIVisionControlState new];
                controlState.isAscentLimitedByObstacle = YES;
                self.controlState = controlState;
            }
            break;

        case Radar8:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(4), @(6), @(8), @(10)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(5), @(6), @(8), @(10.0)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(10.0)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(6)]];
            break;

        case Radar9:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(1), @(1), @(1), @(1)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(1), @(1), @(1), @(1)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(10.0)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(2)]];
            break;

        case Radar10:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(10), @(8), @(6), @(2)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(10), @(8), @(6), @(2)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(0)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(0)]];
            break;
            
        case Radar11:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(2), @(10), @(8), @(6)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(2), @(10), @(8), @(6)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(0)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(0)]];
            break;
            
        case Radar12:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(6), @(2), @(10), @(8)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(6), @(2), @(10), @(8)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(0)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(0)]];
            break;
        
        case Radar13:
            self.noseState = [self buildVisionDetectionState:DJIVisionSensorPositionNose sensorsDistances:@[ @(8), @(6), @(2), @(10)]];
            self.tailState = [self buildVisionDetectionState:DJIVisionSensorPositionTail sensorsDistances:@[ @(8), @(6), @(2), @(10)]];
            self.rightState = [self buildVisionDetectionState:DJIVisionSensorPositionLeft sensorsDistances:@[ @(0)]];
            self.leftState = [self buildVisionDetectionState:DJIVisionSensorPositionRight sensorsDistances:@[ @(0)]];
            break;
    }
    
    __weak DUXBetaRadarWidgetTestModel *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^() {
        [weakSelf radarStateMachineStep];
    });
    
}

/*
DJIVisionSensorPositionNose,
DJIVisionSensorPositionTail,
DJIVisionSensorPositionRight,
DJIVisionSensorPositionLeft,
DJIVisionSensorPositionUnknown
*/
/*
 DJIObstacleDetectionSectorWarningInvalid,
// Warning level 1. Phantom 4 and Mavic Pro: > 10 meters. Spark: > 4 meters. Others: > 20 meters.
DJIObstacleDetectionSectorWarningLevel1,

// Warning level 2. Phantom 4 and Mavic Pro:  8 - 10 meters. Spark:  2 - 4 meters. Others:  15 - 20 meters.
DJIObstacleDetectionSectorWarningLevel2,

//  Warning level 3.  Phantom 4 and Mavic Pro:  6 - 8 meters. Spark: < 2 meters. Others: the 10 - 15 meters.
DJIObstacleDetectionSectorWarningLevel3,

 *  Warning level 4. Phantom 4 and Mavic Pro: 4 - 6 meters. Others: 6 - 10 meters. Spark does not support this warning level.
DJIObstacleDetectionSectorWarningLevel4,

 *  Warning level 5. Phantom 4 and Mavic Pro: 2 - 4 meters.  Others:  3 - 6 meters. Spark does not support this warning level.
DJIObstacleDetectionSectorWarningLevel5,

 *  Warning level 6. Phantom 4 and Mavic Pro: < 2 meters.  Others: < 3 meters. Spark does not support this warning level.
DJIObstacleDetectionSectorWarningLevel6,

 *  The distance warning is unknown. This warning is returned when an exception occurs.
DJIObstacleDetectionSectorWarningUnknown = 0xFF
*/
/* DJIVisionSystemWarning){
    
    DJIVisionSystemWarningInvalid,
    DJIVisionSystemWarningSafe,     > 2m
    DJIVisionSystemWarningDangerous,    < 2m
    DJIVisionSystemWarningUnknown = 0xFF
} */
- (DJIObstacleDetectionSector*)buildDetectionSector:(DJIVisionSensorPosition)position distance:(double)distance {
    
    DJIObstacleDetectionSectorWarning warningLevel = DJIObstacleDetectionSectorWarningLevel1;
    
    if ((position == DJIVisionSensorPositionNose) || (position == DJIVisionSensorPositionTail)) {
        if ((distance < 10) && (distance >= 8.0)) {
            warningLevel = DJIObstacleDetectionSectorWarningLevel2;
        } else if ((distance < 8.0) && (distance >= 6.0)) {
            warningLevel = DJIObstacleDetectionSectorWarningLevel3;
        } else if ((distance < 6.0) && (distance >= 4.0)) {
            warningLevel = DJIObstacleDetectionSectorWarningLevel4;
        } else if ((distance < 4.0) && (distance >= 2.0)) {
            warningLevel = DJIObstacleDetectionSectorWarningLevel5;
        } else if (distance < 2.0) {
            warningLevel = DJIObstacleDetectionSectorWarningLevel6;
        }
    } else {
        // These values used are 3 and 6 meters, but don't have an actual warning level
        warningLevel = DJIObstacleDetectionSectorWarningInvalid;
        if (distance > 6.0) {
            warningLevel = DJIObstacleDetectionSectorWarningUnknown;
        } else if (distance < 3.0) {
            warningLevel = DJIObstacleDetectionSectorWarningLevel2;
        } else {
            warningLevel = DJIObstacleDetectionSectorWarningLevel1;
        }
    }

    DJIObstacleDetectionSector *sensor = [DJIObstacleDetectionSector new];
    sensor.obstacleDistanceInMeters = distance;
    sensor.warningLevel = warningLevel;
    
    return sensor;
}

- (DJIVisionDetectionState*)buildVisionDetectionState:(DJIVisionSensorPosition) position
                                     sensorsDistances:(NSArray<NSNumber*>*)sensorsDistances {

    NSMutableArray<DJIObstacleDetectionSector*> *distanceArray = [NSMutableArray<DJIObstacleDetectionSector*> new];
    double minDistance = 1000.0;

    for (NSNumber *distance in sensorsDistances) {
        DJIObstacleDetectionSector *sectorObject = [self buildDetectionSector:position distance:[distance doubleValue]];
        if (sectorObject.obstacleDistanceInMeters < minDistance) {
            minDistance = sectorObject.obstacleDistanceInMeters;
        }
        [distanceArray addObject:sectorObject];
    }
    DJIVisionDetectionState *detectionState = [DJIVisionDetectionState new];
    detectionState.isSensorBeingUsed = YES;
    detectionState.position = position;
    detectionState.detectionSectors = distanceArray;
    detectionState.obstacleDistanceInMeters = minDistance;
    
    if (minDistance <= 2.0) {
        detectionState.systemWarning = DJIVisionSystemWarningDangerous;
    } else {
        detectionState.systemWarning = DJIVisionSystemWarningSafe;
    }

    return detectionState;
}
@end
