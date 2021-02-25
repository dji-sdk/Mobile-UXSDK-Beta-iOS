//
//  DUXBetaSimulatorControlWidgetModel.m
//  UXSDKTraining
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

#import "DUXBetaSimulatorControlWidgetModel.h"


@interface DUXBetaSimulatorControlWidgetModel()

@property (nonatomic, assign) BOOL isSimulatorActive;
@property (nonatomic, assign) NSUInteger satelliteCount;

@end

@implementation DUXBetaSimulatorControlWidgetModel

- (void)inSetup {
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamSatelliteCount], satelliteCount);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamIsSimulatorActive], isSimulatorActive);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamSimulatorWindSpeed], windSpeed);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamSimulatorState], simulatorState);
}

- (void)inCleanup {
    UnBindSDK;
}

- (void)activateSimulator {
    if (self.isSimulatorActive) {
        [[DJISDKManager keyManager] performActionForKey:[DJIFlightControllerKey keyWithParam:DJIFlightControllerParamStopSimulator]
                                          withArguments:nil
                                          andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {}];
    } else {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.latitude, self.longitude);
        NSArray *arguments = @[[NSValue valueWithBytes:&location objCType:@encode(CLLocationCoordinate2D)], @(self.frequency), @(self.number)];
        [[DJISDKManager keyManager] performActionForKey:[DJIFlightControllerKey keyWithParam:DJIFlightControllerParamStartSimulator]
                                          withArguments:arguments
                                          andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {}];
    }
}

- (void)updateWindSpeed {
    [[DJISDKManager keyManager] setValue:self.windSpeed
                                  forKey:[DJIFlightControllerKey keyWithParam:DJIFlightControllerParamSimulatorWindSpeed]
                          withCompletion:^(NSError * _Nullable error) {}];
}

@end
