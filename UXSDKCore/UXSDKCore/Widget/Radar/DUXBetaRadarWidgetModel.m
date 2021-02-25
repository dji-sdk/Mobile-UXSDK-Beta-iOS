//
//  DUXBetaRadarWidgetModel.m
//  UXSDKCore
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

#import "DUXBetaRadarWidgetModel.h"

@interface DUXBetaRadarWidgetModel()

@property (nonatomic, strong, readwrite) DJIVisionDetectionState *noseState;
@property (nonatomic, strong, readwrite) DJIVisionDetectionState *tailState;
@property (nonatomic, strong, readwrite) DJIVisionDetectionState *rightState;
@property (nonatomic, strong, readwrite) DJIVisionDetectionState *leftState;
@property (nonatomic, strong, readwrite) DJIVisionControlState *controlState;
@property (nonatomic, strong, readwrite) DJIFlightAssistantObstacleAvoidanceSensorState *avoidanceStateM300;

// These value is consolidated into Undefined, Level1, Level2, Level3. Anything > Leve3 maps to level 3
@property (nonatomic, readwrite) DJIObstacleDetectionSectorWarning  radarWarningLevel;
@end

@implementation DUXBetaRadarWidgetModel

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamVisionDetectionNoseState], noseState);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamVisionDetectionTailState], tailState);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamVisionDetectionRightState], rightState);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamVisionDetectionLeftState], leftState);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamVisionControlState], controlState);
    BindSDKKey([DJIFlightControllerKey keyWithIndex:0 subComponent:DJIFlightControllerFlightAssistantSubComponent subComponentIndex:0 andParam:DJIFlightAssistantParamAvoidanceState], avoidanceStateM300);
    BindRKVOModel(self, @selector(update), noseState, tailState, rightState, leftState, controlState, avoidanceStateM300);
    
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)update {
    if (self.avoidanceStateM300) {
        // TODO: Currently non-functional and always returns nil for M300. Once supported in MSDK, update.
    } else {
        DJIObstacleDetectionSectorWarning testLevel;
        DJIObstacleDetectionSectorWarning sectorLevel = DJIObstacleDetectionSectorWarningInvalid;
        if (self.noseState.detectionSectors != nil) {
            testLevel = [self warningLevelForRadarSectors: self.noseState.detectionSectors];
            // This test works because the testLevel can't be < DJIObstacleDetectionSectorWarningInvalid
            if ((testLevel > DJIObstacleDetectionSectorWarningInvalid) || (testLevel < sectorLevel)) {
                sectorLevel = testLevel;
            }
        }

        if (self.tailState.detectionSectors != nil) {
            testLevel = [self warningLevelForRadarSectors: self.tailState.detectionSectors];
            // This test works because the testLevel can't be < DJIObstacleDetectionSectorWarningInvalid
            if ((testLevel > DJIObstacleDetectionSectorWarningInvalid) || (testLevel < sectorLevel)) {
                sectorLevel = testLevel;
            }
        }

        if (self.leftState.detectionSectors != nil) {
            testLevel = [self warningLevelForRadarSectors: self.leftState.detectionSectors];
            // This test works because the testLevel can't be < DJIObstacleDetectionSectorWarningInvalid
            if ((testLevel > DJIObstacleDetectionSectorWarningInvalid) || (testLevel < sectorLevel)) {
                sectorLevel = testLevel;
            }
        }

        if (self.rightState.detectionSectors != nil) {
            testLevel = [self warningLevelForRadarSectors: self.rightState.detectionSectors];
            // This test works because the testLevel can't be < DJIObstacleDetectionSectorWarningInvalid
            if ((testLevel > DJIObstacleDetectionSectorWarningInvalid) || (testLevel < sectorLevel)) {
                sectorLevel = testLevel;
            }
        }
        self.radarWarningLevel = sectorLevel;
    }
}
    
- (DJIObstacleDetectionSectorWarning)warningLevelForRadarSectors:(NSArray<DJIObstacleDetectionSector *> *)sectorsArray {
    DJIObstacleDetectionSectorWarning outLevel = DJIObstacleDetectionSectorWarningInvalid;
    
    for (DJIObstacleDetectionSector *sector in sectorsArray) {
        DJIObstacleDetectionSectorWarning level = sector.warningLevel;
        switch (level) {
        case DJIObstacleDetectionSectorWarningUnknown:
        case DJIObstacleDetectionSectorWarningInvalid:
            // These will not affect the level since we already have set to invalid.
            break;
            
        case DJIObstacleDetectionSectorWarningLevel1:
        case DJIObstacleDetectionSectorWarningLevel2:
        case DJIObstacleDetectionSectorWarningLevel3:
            outLevel = MIN(level, (outLevel == DJIObstacleDetectionSectorWarningInvalid) ? DJIObstacleDetectionSectorWarningLevel3 : outLevel);
            break;
            
        case DJIObstacleDetectionSectorWarningLevel4:
        case DJIObstacleDetectionSectorWarningLevel5:
        case DJIObstacleDetectionSectorWarningLevel6:
            level = DJIObstacleDetectionSectorWarningLevel3;
            outLevel = MIN(level, (outLevel == DJIObstacleDetectionSectorWarningInvalid) ? DJIObstacleDetectionSectorWarningLevel3 : outLevel);
            break;
            
        default:
            // Don't change the level for other cases. There should be no other cases
            break;
        }
    }
    return outLevel;
}
@end
