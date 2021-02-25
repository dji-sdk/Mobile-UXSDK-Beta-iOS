//
//  DUXBetaRadarWidgetTestModel.h
//  UXSDKCore
//
//  Copyright © 2020 DJI
//
// Private class. DO NOT RELEASE


#import <UXSDKCore/DUXBetaBaseWidgetModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaRadarWidgetTestModel : DUXBetaBaseWidgetModel

@property (nonatomic, readonly) DJIVisionDetectionState *noseState;
@property (nonatomic, readonly) DJIVisionDetectionState *tailState;
@property (nonatomic, readonly) DJIVisionDetectionState *rightState;
@property (nonatomic, readonly) DJIVisionDetectionState *leftState;
@property (nonatomic, readonly) DJIVisionControlState *controlState;
@property (nonatomic, readonly) DJIFlightAssistantObstacleAvoidanceSensorState *avoidanceStateM300;

@end

NS_ASSUME_NONNULL_END
