//
//  DUXBetaSystemStatusWidgetModel.m
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

#import "DUXBetaSystemStatusWidgetModel.h"
#import "DUXBetaVoiceNotification.h"
#import <AVFoundation/AVFoundation.h>
#import "NSData+DUXBetaAssets.h"

#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaSystemStatusWidgetModel ()

@property (nonatomic, assign) NSInteger maxFlightHeightMeters;

@end

@implementation DUXBetaSystemStatusWidgetModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _isCriticalWarning = NO;
        _suggestedWarningMessage = @"Disconnected";
        _systemStatusWarningLevel = DJIWarningStatusLevelOffline;
    }
    return self;
}

- (void)inSetup {
    BindSDKKey([DJIProductKey keyWithParam:DJIProductParamSystemStatus], warningStatusItem);
    BindSDKKey([DJIFlightControllerKey keyWithParam:DJIFlightControllerParamMaxFlightHeight], maxFlightHeightMeters);
    
    BindRKVOModel(self, @selector(updateStates), warningStatusItem, maxFlightHeightMeters);
}

- (void)updateStates {
    NSString *heightInfo = @"";
    BOOL isLimitedAltitude = [self.warningStatusItem.message containsString:@"Height Limited Zone"];
    BOOL isSpecialUnlock = [self.warningStatusItem.message containsString:@"Special Unlock"];
    if (isLimitedAltitude || isSpecialUnlock) {
        heightInfo = [NSString stringWithFormat:@" - %0.1f %@", [self.unitModule metersToMeasurementSystem:self.maxFlightHeightMeters], self.unitModule.unitSuffix];
    }

    if (self.warningStatusItem != nil) {
        NSString *fullMessage = [self.warningStatusItem.message stringByAppendingString:heightInfo];
        self.suggestedWarningMessage = fullMessage;
        self.isCriticalWarning = self.warningStatusItem.isUrgent;
        self.systemStatusWarningLevel = self.warningStatusItem.warningLevel;
    }

    if ([self.warningStatusItem.message containsString:@"Compass Error"]) {
        DUXBetaVoiceNotificationKey *voiceNotificationKey = [[DUXBetaVoiceNotificationKey alloc] initWithIndex:0
                                                                                             parameter:DUXBetaVoiceNotificationParameterAttitude];
        DUXBetaVoiceNotification *voiceNotification = [[DUXBetaVoiceNotification alloc] init];
        
        voiceNotification.audioPlayer = [self createAttiAudioPlayer];
        
        ModelValue *modelWithNotification = [[ModelValue alloc] initWithValue:[voiceNotification copy]];
        
        [[DUXBetaSingleton sharedObservableInMemoryKeyedStore] setModelValue:modelWithNotification
                                                                  forKey:voiceNotificationKey];
    }
}

- (AVAudioPlayer *)createAttiAudioPlayer {
    NSError *findAudioFileError = nil;
    
    NSString *attiModeAudioFileName = @"VoiceNotificationAttitude";
    NSString *attiModeFileType = AVFileTypeMPEGLayer3;
    NSData *attiModeAssetData = [NSData duxbeta_dataWithAssetNamed:attiModeAudioFileName];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:attiModeAssetData
                                                      fileTypeHint:attiModeFileType
                                                             error:&findAudioFileError];
    if (!findAudioFileError) {
        return player;
    } else {
        NSLog(@"Couldn't find audio file: VoiceNotificationAttitude");
        return nil;
    }
}

@end
