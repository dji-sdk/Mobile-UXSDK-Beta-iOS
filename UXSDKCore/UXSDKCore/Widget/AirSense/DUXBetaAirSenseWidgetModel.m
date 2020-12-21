//
//  DUXBetaAirSenseWidgetModel.m
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

#import "DUXBetaAirSenseWidgetModel.h"

#import <UXSDKCore/UXSDKCore-Swift.h>

static NSString * const DUXBetaAirSenseWidgetWarningMessageReasonForLevel2 = @"Another aircraft is nearby. Fly with caution.";
static NSString * const DUXBetaAirSenseWidgetWarningMessageReasonForLevels3to5 = @"Another aircraft is nearby. Fly with caution.";

static NSString * const DUXBetaAirSenseWidgetWarningMessageSolutionForLevel2 = @"Another aircraft is too close, please descend to a safer altitude.";
static NSString * const DUXBetaAirSenseWidgetWarningMessageSolutionForLevel3to5 = @"Another aircraft is dangerously close, please descend to a safer altitude.";

@interface DUXBetaAirSenseWidgetModel()

//Internal properties
@property (strong, nonatomic) NSArray *airplaneStates;

//Exposed properties
@property (assign, nonatomic, readwrite) BOOL isAirSenseConnected;
@property (assign, nonatomic, readwrite) NSUInteger airSenseWarningLevel;
@property (assign, nonatomic, readwrite) DUXBetaAirSenseState airSenseWarningState;

@end

@implementation DUXBetaAirSenseWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _airSenseWarningLevel = 0;
        _isAirSenseConnected = NO;
        _airSenseWarningState = DUXBetaAirSenseState_Unknown;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAirSenseSystemWarningLevel], airSenseWarningLevel);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAirSenseSystemConnected], isAirSenseConnected);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamAirSenseAirplaneStates], airplaneStates);

    BindRKVOModel(self, @selector(presentWarningMessageIfAppropriate), airSenseWarningLevel);
    BindRKVOModel(self, @selector(updateAirSenseState), isProductConnected, isAirSenseConnected, airplaneStates, airSenseWarningLevel);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)updateAirSenseState {
    [self presentWarningMessageIfAppropriate];
    
    if (!self.isProductConnected) {
        self.airSenseWarningState = DUXBetaAirSenseState_Disconnected;
    } else if (self.airplaneStates.count == 0) {
        self.airSenseWarningState = DUXBetaAirSenseState_NoAirplanesNearby;
    } else {
        switch (self.airSenseWarningLevel) {
            case 0:
                self.airSenseWarningState = DUXBetaAirSenseState_Level0;
                break;
            case 1:
                self.airSenseWarningState = DUXBetaAirSenseState_Level1;
                break;
            case 2:
                self.airSenseWarningState = DUXBetaAirSenseState_Level2;
                break;
            case 3:
                self.airSenseWarningState = DUXBetaAirSenseState_Level3;
                break;
            case 4:
                self.airSenseWarningState = DUXBetaAirSenseState_Level4;
                break;
        }
    }
}

- (void)presentWarningMessageIfAppropriate {
    if (self.airSenseWarningLevel == 2) {
        [self sendWarningMessageWithReason:DUXBetaAirSenseWidgetWarningMessageReasonForLevel2
                               andSolution:DUXBetaAirSenseWidgetWarningMessageSolutionForLevel2];
    }
    if (self.airSenseWarningLevel > 2) {
        [self sendWarningMessageWithReason:DUXBetaAirSenseWidgetWarningMessageReasonForLevels3to5
                               andSolution:DUXBetaAirSenseWidgetWarningMessageSolutionForLevel3to5];
    }
}

- (void)sendWarningMessageWithReason:(NSString *)reason andSolution:(NSString *)solution {
    DUXBetaWarningMessageKey *warningMessageKey = [[DUXBetaWarningMessageKey alloc] initWithIndex:0
                                                                                parameter:DUXBetaWarningMessageParameterSendWarningMessage];
    
    DUXBetaWarningMessage *warningMessage = [[DUXBetaWarningMessage alloc] init];
    warningMessage.reason = reason;
    warningMessage.solution = solution;
    warningMessage.level = DUXBetaWarningMessageLevelWarning;
    warningMessage.type = DUXBetaWarningMessageTypePinned;
    
    ModelValue *modelWithWarningMessage = [[ModelValue alloc] initWithValue:[warningMessage copy]];
    
    [[DUXBetaSingleton sharedObservableInMemoryKeyedStore] setModelValue:modelWithWarningMessage
                                                              forKey:warningMessageKey];
}

@end
