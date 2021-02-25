//
//  DUXBetaCameraStorageState.h
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
 *  The possible storage types of the camera, dependent on model, storage settings, and current video or photo resolution
 */
typedef NS_ENUM(NSInteger, DUXBetaCaptureStorageType) {
    
    /**
     *  The camera is currently storing photo or video data on the SD card
     */
    DUXBetaCaptureStorageTypeSDCard,
    
    /**
     *  The camera is currently storing photo or video data on the embedded internal storage of the aircraft
     */
    DUXBetaCaptureStorageTypeInternalStorage,
    
    /**
     *  The camera is currently storing photo or video data on the SSD
     */
    DUXBetaCaptureStorageTypeSSD,
    
    /**
     *  The camera is currently storing photo or video data on an unknown storage device or no storage device is available
     */
    DUXBetaCaptureStorageTypeUnknown
};


/**
 *  The possible storage states
 */
typedef NS_ENUM(NSInteger, DUXBetaCaptureStorageState) {
    
    /**
     *  The storage state is slow
     */
    DUXBetaCaptureStorageStateSlow,
    
    /**
     *  The storage state is full
     */
    DUXBetaCaptureStorageStateFull,
    
    /**
     *  The storage state is not inserted
     */
    DUXBetaCaptureStorageStateNotInserted,
    
    /**
     *  The storage state is unknown
     */
    DUXBetaCaptureStorageStateUnknown
};


/**
 *  The camera storage state
 */
@interface DUXBetaCameraStorageState : NSObject

/**
 * The type of the storage
 */
@property (nonatomic, assign, readonly) DUXBetaCaptureStorageType type;

/**
 * The state of the storage
 */
@property (nonatomic, assign, readonly) DUXBetaCaptureStorageState state;

/**
 *  The storage location set on the camera
 */
@property (nonatomic, assign, readonly) DJICameraStorageLocation storageLocation;

/**
 *  The available count of the storage location
 */
@property (nonatomic, assign, readonly) NSUInteger availableCount;

/**
 *  Initialize the state with a storage location and available count value
 */
- (nonnull instancetype)initWithStorageLocation:(DJICameraStorageLocation)storageLocation
                                 availableCount:(NSUInteger)availableCount NS_DESIGNATED_INITIALIZER;

/**
 *  Checks if the storage location is out of storage space
 */
- (BOOL)isStorageLocationOutOfStorageSpace;

/**
 *  Checks if the storage location is not available
 */
- (BOOL)isStorageLocationNotAvailable;

/**
 *  Checks if the storage location is slow
 */
- (BOOL)isStorageLocationSlow;

@end


/**
 *  The camera SD card storage state
 */
@interface DUXBetaCameraSDStorageState : DUXBetaCameraStorageState

/**
 *  The camera SD card operation state
 */
@property (nonatomic, assign, readonly) DJICameraSDCardOperationState sdCardOperationState;

/**
 *  Initialize the state with a storage location, available count, and SD card operation state values
 */
- (nonnull instancetype)initWithStorageLocation:(DJICameraStorageLocation)storageLocation
                                 availableCount:(NSUInteger)availableCount
                           sdCardOperationState:(DJICameraSDCardOperationState)sdCardOperationState NS_DESIGNATED_INITIALIZER;

@end

/**
 *  The camera SSD storage state
 */
@interface DUXBetaCameraSSDStorageState : DUXBetaCameraStorageState

/**
 *  The camera SSD operation state
 */
@property (nonatomic, assign, readonly) DJICameraSSDOperationState ssdOperationState;

/**
 *  Initialize the state with storage location, available count, and SSD operation state
 */
- (nonnull instancetype)initWithStorageLocation:(DJICameraStorageLocation)storageLocation
                                 availableCount:(NSUInteger)availableCaptureCount
                              ssdOperationState:(DJICameraSSDOperationState)ssdOperationState NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
