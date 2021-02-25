//
//  DUXBetaGimbalPitchWidgetModel.m
//  UXSDKCameraCore
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

#import "DUXBetaGimbalPitchWidgetModel.h"


@interface DUXBetaGimbalPitchWidgetModel ()

@property (strong, nonatomic) NSDictionary <NSString *, DJIParamCapability *> *currentCapabilities;
@property (strong, nonatomic) id gimbalInfo;
@property (strong, nonatomic) NSNumber *pitchValue;
@property (strong, nonatomic) NSTimer *fadeTimer;
@property (assign, nonatomic) BOOL widgetShouldFadeOut;
@property (strong, nonatomic) DUXBetaGimbalPitchWidgetState *state;

@end

@implementation DUXBetaGimbalPitchWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.preferredGimbalIndex = 0;
        self.widgetShouldFadeOut = NO;
        self.pitchValue = @(0);
        self.stableRangeUpperBound = 5;
        self.stableRangeLowerBound = -5;
        self.upperWarningBound = 20;
        self.lowerWarningBound = -80;
        self.state = [[DUXBetaGimbalPitchWidgetState alloc] initWithMaxPitch:0 minPitch:-90 currentPitchValue:0];
    }
    return self;
}

- (void)inSetup {
    [self setupTimer];
    BindSDKKey([DJIGimbalKey keyWithIndex:self.preferredGimbalIndex andParam:DJIGimbalParamCapabilities], currentCapabilities);
    BindSDKKey([DJIGimbalKey keyWithIndex:self.preferredGimbalIndex andParam:DJIGimbalParamAttitudeInDegrees], gimbalInfo);
    BindRKVOModel(self, @selector(updateStates),currentCapabilities,gimbalInfo);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)setupTimer {
    __weak DUXBetaGimbalPitchWidgetModel *weakSelf = self;
    self.fadeTimer = [NSTimer scheduledTimerWithTimeInterval:self.widgetFadeTimeInterval repeats:NO block:^(NSTimer * _Nonnull timer) {
        [timer invalidate];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.widgetShouldFadeOut = YES;
        });
    }];
}

- (void)updateStates {
    if (self.currentCapabilities && self.gimbalInfo) {
        [self.fadeTimer invalidate];
        [self setupTimer];
        if (self.widgetShouldFadeOut) {
            self.widgetShouldFadeOut = NO;
        }
        
        DJIGimbalAttitude gimbalAttitude = {0};
        [self.gimbalInfo getValue:&gimbalAttitude];
        self.pitchValue = @(gimbalAttitude.pitch);
        DJIParamCapabilityMinMax *minMax = (DJIParamCapabilityMinMax *)[self.currentCapabilities objectForKey:DJIGimbalParamAdjustPitch];
        self.state = [[DUXBetaGimbalPitchWidgetState alloc] initWithMaxPitch:minMax.max.integerValue minPitch:minMax.min.integerValue currentPitchValue:self.pitchValue.integerValue];
        
        self.upperWarningBound = minMax.max.integerValue - 10;
        self.lowerWarningBound = minMax.min.integerValue + 10;
    }
}

- (void)setWidgetFadeTimeInterval:(NSTimeInterval)widgetFadeTimeInterval {
    _widgetFadeTimeInterval = widgetFadeTimeInterval;
    if (widgetFadeTimeInterval >= 0) {
        [self setupTimer];
    } else {
        [self.fadeTimer invalidate];
    }
}

- (void)changeIndex:(NSInteger)preferredGimbalIndex {
    _preferredGimbalIndex = preferredGimbalIndex;
    if (self.vmState == DUXBetaVMStateSetUp) {
        [self inCleanup];
        [self inSetup];
    }
}

@end
