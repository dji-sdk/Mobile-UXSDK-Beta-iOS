//
//  DUXBetaCameraModeSwitchWidgetModel.m
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

#import "DUXBetaCameraModeSwitchWidgetModel.h"

@interface DUXBetaCameraModeSwitchWidgetModel ()

@property (nonatomic, assign) DUXBetaCameraModeSwitchPosition switchPosition;
@property (nonatomic, assign) DJICameraMode cameraMode;

@end

@implementation DUXBetaCameraModeSwitchWidgetModel

- (instancetype)init {
    return [self initWithPreferredCameraIndex:0];
}

- (instancetype)initWithPreferredCameraIndex:(NSUInteger)preferredCameraIndex {
    self = [super init];
    
    if (self) {
        _preferredCameraIndex = preferredCameraIndex;
    }
    
    return self;
}

- (void)inSetup {
    BindSDKKey([DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamMode], self.cameraMode);
    BindRKVOModel(self, @selector(update), self.cameraMode);
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)update {
    if (self.cameraMode == DJICameraModeShootPhoto) {
        self.switchPosition = DUXBetaCameraModeSwitchPositionShootPhoto;
    } else if (self.cameraMode == DJICameraModeRecordVideo) {
        self.switchPosition = DUXBetaCameraModeSwitchPositionRecordVideo;
    } else {
        self.switchPosition = DUXBetaCameraModeSwitchPositionUnknown;
    }
}

- (DJICameraMode)cameraModeFromSwitchPosition:(DUXBetaCameraModeSwitchPosition)switchPosition {
    if (switchPosition == DUXBetaCameraModeSwitchPositionShootPhoto) {
        return DJICameraModeShootPhoto;
    } else if (switchPosition == DUXBetaCameraModeSwitchPositionRecordVideo) {
        return DJICameraModeRecordVideo;
    } else {
        return DJICameraModeUnknown;
    }
}

- (void)transitionModeTo:(DUXBetaCameraModeSwitchPosition)position {
    
    DJICameraMode mode = [self cameraModeFromSwitchPosition:position];
    if (mode != DJICameraModeUnknown) {
        [[DJISDKManager keyManager] setValue:@(mode)
                                      forKey:[DJICameraKey keyWithIndex:self.preferredCameraIndex andParam:DJICameraParamMode]
                              withCompletion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error: %@", error);
            }
        }];
    }
}

#pragma mark - Setter

- (void)setPreferredCameraIndex:(NSUInteger)preferredCameraIndex {
    [self inCleanup];
    _preferredCameraIndex = preferredCameraIndex;
    [self inSetup];
}

@end
