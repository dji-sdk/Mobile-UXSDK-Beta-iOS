//
//  DUXBetaCameraPhotoState.h
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

#import <UXSDKCore/DUXBetaBaseWidgetModel.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The camera state when in shoot photo mode, used by DUXBetaShootPhotoWidget and DUXBetaShootPhotoWidgetModel
 */
@interface DUXBetaCameraPhotoState : NSObject

/**
 *  The shoot photo mode of the camera
 */
@property (nonatomic, assign, readonly) DJICameraShootPhotoMode shootPhotoMode;

/**
 *  The count property specific to each photo shoot mode of the camera
 */
@property (nonatomic, assign, readonly) NSUInteger count;

/**
 *  Initialize the state with a given shoot photo mode
 */
- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode NS_DESIGNATED_INITIALIZER;

@end

/**
 *  The camera state when the shoot photo mode is panorama mode, used by DUXBetaShootPhotoWidget and DUXBetaShootPhotoWidgetModel
 */
@interface DUXBetaCameraPanoramaPhotoState : DUXBetaCameraPhotoState

/**
 *  Panorama mode set on the camera
 */
@property (nonatomic, assign, readonly) DJICameraPhotoPanoramaMode photoPanoramaMode;

/**
 *  Initialize the state with a given shoot photo mode and a given panorama mode
 */
- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode
                             photoPanoramaMode:(DJICameraPhotoPanoramaMode)photoPanoramaMode NS_DESIGNATED_INITIALIZER;

@end

/**
 *  The camera state when the shoot photo mode is burst mode, used by DUXBetaShootPhotoWidget and DUXBetaShootPhotoWidgetModel
 */
@interface DUXBetaCameraBurstPhotoState : DUXBetaCameraPhotoState

/**
 *  Photo burst count set on the camera
 */
@property (nonatomic, assign, readonly) DJICameraPhotoBurstCount photoBurstCount;

/**
 *  Initialize the state with a given shoot photo mode and a given photo burst count
 */
- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode
                               photoBurstCount:(DJICameraPhotoBurstCount)photoBurstCount NS_DESIGNATED_INITIALIZER;

@end

/**
 *  The camera state when the shoot photo mode is AEB mode, used by DUXBetaShootPhotoWidget and DUXBetaShootPhotoWidgetModel
 */
@interface DUXBetaCameraAEBPhotoState : DUXBetaCameraPhotoState

/**
 *  AEB (Automatic exposure bracketing) count set on the camera
 */
@property (nonatomic, assign, readonly) DJICameraPhotoAEBCount photoAEBCount;

/**
 *  Initialize the state with a given shoot photo mode and a given AEB count
 */
- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode
                                 photoAEBCount:(DJICameraPhotoAEBCount)photoAEBCount NS_DESIGNATED_INITIALIZER;

@end

/**
 *  The camera state when the shoot photo mode is interval mode, used by DUXBetaShootPhotoWidget and DUXBetaShootPhotoWidgetModel
 */
@interface DUXBetaCameraIntervalPhotoState : DUXBetaCameraPhotoState

/**
 *  The interval capture count set on the camera
 */
@property (nonatomic, assign, readonly) uint8_t captureCount;

/**
 *  The time interval in seconds between successive photos set on the camera
 */
@property (nonatomic, assign, readonly) uint8_t timeIntervalInSeconds;

/**
 *  Initialize the state with a given shoot photo mode, capture count, and time interval in seconds
 */
- (nonnull instancetype)initWithShootPhotoMode:(DJICameraShootPhotoMode)shootPhotoMode
                                  captureCount:(uint8_t)captureCount
                         timeIntervalInSeconds:(uint8_t)timeIntervalInSeconds NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
