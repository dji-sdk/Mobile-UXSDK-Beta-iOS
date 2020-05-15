//
//  DUXBetaVisionWidgetModel.h
//  DJIUXSDK
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidgetModel.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *  Enum listing all the different states of the vision status
 */
typedef NS_ENUM(NSUInteger, DUXBetaVisionStatus) {
    //Collision avoidance is enabled
    DUXBetaVisionStatusNormal = 0,
    //Collision avoidance is enabled, but flight mode does not support vision system
    DUXBetaVisionStatusDisabled,
    //Collision avoidance is disabled by user
    DUXBetaVisionStatusClosed,
    //Left, right, nose, and tail sensors are all enabled for Mavic 2, M300
    DUXBetaVisionStatusOmniAll,
    //Left and right sensors are disabled for Mavic 2
    DUXBetaVisionStatusOmniFrontBack,
    //Collision avoidance is only active upwards and downwards for M300
    DUXBetaVisionStatusOmniVertical,
    //Collision avoidance is only active forwards, backwards, left and right for M300
    DUXBetaVisionStatusOmniHorizontal,
    //All sensors are disabled for Mavic 2, M300
    DUXBetaVisionStatusOmniDisabled,
    //Collision avoidance is disabled by user for Mavic 2, M300
    DUXBetaVisionStatusOmniClosed,
    //Vision Status is unknown
    DUXBetaVisionStatusUnknown
};

@interface DUXBetaVisionWidgetModel : DUXBetaBaseWidgetModel

/**
 *  The current vision status of the aircraft
 */
@property (nonatomic, readonly) DUXBetaVisionStatus visionSystemStatus;
@property (nonatomic, readonly) BOOL currentAircraftSupportVision;
@property (nonatomic, readonly) BOOL isCollisionAvoidanceEnabled;

- (void)sendWarningMessageWithReason:(NSString *)reason andSolution:(NSString *)solution;

@end

NS_ASSUME_NONNULL_END
