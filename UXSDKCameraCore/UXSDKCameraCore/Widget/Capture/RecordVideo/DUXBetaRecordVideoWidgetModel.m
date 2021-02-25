//
//  DUXBetaRecordVideoWidgetModel.m
//  UXSDKCameraCore
//
//  MIT License
//  
//  Copyright © 2018-2021 DJI
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

#import "DUXBetaRecordVideoWidgetModel.h"
#import "DUXBetaCameraStorageState.h"
#import "DUXBetaCameraPhotoState.h"

@interface DUXBetaRecordVideoWidgetModel ()

@property (nonatomic, assign) DJICameraMode cameraMode;

@property (nonatomic, assign, readwrite) BOOL isRecording;
@property (nonatomic, assign, readwrite) BOOL canStartRecording;
@property (nonatomic, assign, readwrite) BOOL canStopRecording;

@end

NSString *const DUXBetaRecordVideoWidgetDomain = @"DUXBetaRecordVideoWidgetDomain";

@implementation DUXBetaRecordVideoWidgetModel

#pragma mark - Lifecycle

- (void)inSetup {
    [super inSetup];
    
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamMode], cameraMode);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamIsRecording], isRecording);
    
    BindRKVOModel(self, @selector(updateVideoState), isRecording);
}

- (void)updateVideoState {
    self.canStartRecording = !self.isRecording;
    self.canStopRecording = self.isRecording;
}

#pragma mark - Action Methods

- (void)startRecordVideoWithCompletion:(DJICompletionBlock)completion {
    weakSelf(target);
    if (self.cameraMode == DJICameraModeRecordVideo) {
        [self attemptStartRecordingWithCompletion:completion];
    } else {
        // TODO: This needs a better mechanism, to be added when overall capture widget is implemented
        [[DJISDKManager keyManager] setValue:@(DJICameraModeRecordVideo)
                                      forKey:[DJICameraKey keyWithIndex:self.cameraIndex
                                                               andParam:DJICameraParamMode]
                              withCompletion:^(NSError * _Nullable error) {
                                  if (error) {
                                      if (completion) {
                                          completion(error);
                                      }
                                  } else {
                                      [target attemptStartRecordingWithCompletion:completion];
                                  }
        }];
    }
}

- (void)attemptStartRecordingWithCompletion:(DJICompletionBlock)completion {
    if (self.canStartRecording) {
        [[DJISDKManager keyManager] performActionForKey:[DJICameraKey keyWithIndex:self.cameraIndex
                                                                          andParam:DJICameraParamStartRecordVideo]
                                          withArguments:nil
                                          andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
                                              if (completion) {
                                                  completion(error);
                                              }
                                          }];
    } else {
        NSError *startRecordVideoError = [NSError errorWithDomain:DUXBetaRecordVideoWidgetDomain
                                                             code:DUXBetaRecordVideoWidgetErrorCameraNotOperational
                                                         userInfo:@{
                                                                   NSLocalizedDescriptionKey : [self localizedDescriptionForErrorCode:DUXBetaRecordVideoWidgetErrorCameraNotOperational]
                                                                   }];
        if (completion) {
            completion(startRecordVideoError);
        }
    }
}

- (void)stopRecordVideoWithCompletion:(DJICompletionBlock)completion {
    if (self.canStopRecording) {
        [[DJISDKManager keyManager] performActionForKey:[DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamStopRecordVideo]
                                          withArguments:nil
                                          andCompletion:^(BOOL finished, DJIKeyedValue * _Nullable response, NSError * _Nullable error) {
                                              if (completion) {
                                                  completion(error);
                                              }
                                          }];
    } else {
        NSError *stopRecordVideoError = [NSError errorWithDomain:DUXBetaRecordVideoWidgetDomain
                                                            code:DUXBetaRecordVideoWidgetErrorCameraNotOperational
                                                        userInfo:@{
                                                                    NSLocalizedDescriptionKey : [self localizedDescriptionForErrorCode:DUXBetaRecordVideoWidgetErrorCameraNotOperational]
                                                                    }];
        if (completion) {
            completion(stopRecordVideoError);
        }
    }
}

- (nonnull NSString *)localizedDescriptionForErrorCode:(DUXBetaRecordVideoWidgetError)errorCode {
    switch (errorCode) {
        case DUXBetaRecordVideoWidgetErrorCameraNotOperational:
            return NSLocalizedString(@"The camera is not in the correct mode for this operation.", @"Record Video Widget Localized Error Description");
            break;
        default:
            return NSLocalizedString(@"Unknown error.", @"Record Video Widget Localized Error Description");
            break;
    }
}

@end
