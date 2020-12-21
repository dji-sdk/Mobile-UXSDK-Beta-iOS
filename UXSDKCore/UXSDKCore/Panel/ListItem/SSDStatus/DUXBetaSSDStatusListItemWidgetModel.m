//
//  DUXBetaSSDStatusListItemWidgetModel.m
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2020 DJI
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

#import "DUXBetaSSDStatusListItemWidgetModel.h"

@interface DUXBetaSSDStatusListItemWidgetModel ()
@property (nonatomic, readwrite) BOOL isSSDConnected;
@property (nonatomic, readwrite) BOOL noRawCapture;
@property (nonatomic, readwrite) NSUInteger freeStorageInMB;
@property (nonatomic, readwrite) NSUInteger ssdTotalSpace;
@property (nonatomic, readwrite) NSUInteger availableRecordingTimeInSeconds;
@property (nonatomic, readwrite) DJICameraSSDOperationState ssdOperationState;

/**
 * The camera index this model is currently observing. Defaults to camera 0. Currently, only the Inspire 2 supports SSD and
 * only supports 1 camera, so this isn't publically exposed.
 */
@property (nonatomic, readwrite) NSUInteger preferredCameraIndex;
@property (nonatomic, readwrite) NSError    *formatError;

@end

@implementation DUXBetaSSDStatusListItemWidgetModel

- (void)inSetup {
    _preferredCameraIndex = 0;
    
    [self bindKeys];
}

- (void)bindKeys {
    BindSDKKey([DJICameraKey keyWithIndex:0 andParam:DJICameraParamSSDIsConnected], isSSDConnected);
    BindSDKKey([DJICameraKey keyWithIndex:0 andParam:DJICameraParamSSDRemainingSpaceInMB], freeStorageInMB);
    BindSDKKey([DJICameraKey keyWithIndex:0 andParam:DJICameraParamSSDOperationState], ssdOperationState);
    // Not currently used but potentially useful to include
    BindSDKKey([DJICameraKey keyWithParam:DJICameraParamSSDAvailableRecordingTimeInSeconds], availableRecordingTimeInSeconds);
}

- (void)inCleanup {
    UnBindSDK;
}

- (NSString *)formatErrorDescription {
    if (self.formatError != nil) {
        return [NSString stringWithFormat:@"\n%@", self.formatError.localizedDescription];
    }
    
    return @"";
}

- (void)formatSSD {
    __weak DUXBetaSSDStatusListItemWidgetModel *weakSelf = self;
    DJICameraKey *cameraKey = [DJICameraKey keyWithIndex:_preferredCameraIndex andParam:DJICameraParamFormatSSD];
    
    [[DJISDKManager keyManager] performActionForKey:cameraKey
                                      withArguments:nil
                                      andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
        // This completion is only for the performAction method, not for the results of the format action. It will
        // not report when formating is completed, only if there are parameter errors with this call.
        __strong DUXBetaSSDStatusListItemWidgetModel *strongSelf = weakSelf;
        
        strongSelf.formatError = error;
        if (error != nil) {
            strongSelf.ssdFormatError = YES;
        } else {
            strongSelf.ssdFormatError = NO;
        }
    }];

}

@end
