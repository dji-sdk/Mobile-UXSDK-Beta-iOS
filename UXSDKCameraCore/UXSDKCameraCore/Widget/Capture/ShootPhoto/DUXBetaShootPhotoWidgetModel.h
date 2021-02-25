//
//  DUXBetaShootPhotoWidgetModel.h
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

@class DUXBetaCameraPhotoState;

NS_ASSUME_NONNULL_BEGIN

// This prefixed DUXBeta on purpose

/**
 *  Domain of possible shoot photo widget error states
 */
FOUNDATION_EXPORT NSString *const DUXBetaShootPhotoWidgetDomain;

/**
 *  Enumeration of possible shoot photo widget error states
 */
typedef NS_ENUM (NSInteger, DUXBetaShootPhotoWidgetError) {
    /**
     *  Camera is not in correct state to start or stop shooting photos
     */
    DUXBetaShootPhotoWidgetErrorCameraNotOperational = -1L,
    /**
     *  Unknown error state
     */
    DUXBetaShootPhotoWidgetErrorUnknown = -999L
};

/**
 *  The shoot photo widget model abstracts away the non-UI DJI product-related logic of the shoot photo widget
 */
@interface DUXBetaShootPhotoWidgetModel : DUXBetaCaptureBaseWidgetModel

/**
 *  State of shoot photo mode and specific related modes on the camera
 */
@property (nonatomic, strong, readonly) DUXBetaCameraPhotoState *cameraPhotoState;

/**
 *  Indicates if the camera is busy shooting a photo
 */
@property (nonatomic, assign, readonly) BOOL isShootingPhoto;

/**
 *  Indicates if the camera is busy storing a photo
 */
@property (nonatomic, assign, readonly) BOOL isStoringPhoto;

/**
 *  Indicates if the camera can start shooting a photo
 */
@property (nonatomic, assign, readonly) BOOL canStartShootingPhoto;

/**
 *  Indicates if the camera can stop a photo
 */
@property (nonatomic, assign, readonly) BOOL canStopShootingPhoto;

/**
 *  Starts shooting video in current shoot photo mode, returns an error if camera is not in a correct state
 */
- (void)startShootPhotoWithCompletion:(DJICompletionBlock)completion;

/**
 *  Stops shooting photo, returns an error if camera is not in a correct state
 */
- (void)stopShootPhotoWithCompletion:(DJICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
