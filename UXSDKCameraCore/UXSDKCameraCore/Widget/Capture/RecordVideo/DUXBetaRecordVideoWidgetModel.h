//
//  DUXBetaRecordVideoWidgetModel.h
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

#import "DUXBetaCaptureBaseWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

@class DUXBetaCameraStorageState;

// This prefixed DUXBeta on purpose

/**
 *  Domain of possible record video widget error states
 */
FOUNDATION_EXPORT NSString *const DUXBetaRecordVideoWidgetDomain;

/**
 *  Enumeration of possible record video widget error states
 */
typedef NS_ENUM (NSInteger, DUXBetaRecordVideoWidgetError) {
    /**
     *  Camera is not in correct state to start or stop record video
     */
    DUXBetaRecordVideoWidgetErrorCameraNotOperational = -1L,
    /**
     *  Unknown error state
     */
    DUXBetaRecordVideoWidgetErrorUnknown = -999L
};

/**
 *  The record video widget model abstracts away the non-UI DJI product-related logic of the record video widget
 */
@interface DUXBetaRecordVideoWidgetModel : DUXBetaCaptureBaseWidgetModel

/**
 *  Indicates if the camera is recording
 */
@property (nonatomic, assign, readonly) BOOL isRecording;

/**
 *  Indicates if the camera can start recording
 */
@property (nonatomic, assign, readonly) BOOL canStartRecording;

/**
 *  Indicates if the camera can stop recording
 */
@property (nonatomic, assign, readonly) BOOL canStopRecording;

/**
 *  Starts recording video, returns an error if camera is not in a correct state
 */
- (void)startRecordVideoWithCompletion:(DJICompletionBlock)completion;

/**
 *  Starts recording video, returns an error if camera is not in a correct state
 */
- (void)stopRecordVideoWithCompletion:(DJICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
