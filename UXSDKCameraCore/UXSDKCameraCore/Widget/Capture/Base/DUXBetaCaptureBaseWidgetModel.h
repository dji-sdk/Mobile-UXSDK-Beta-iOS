//
//  DUXBetaCaptureBaseWidgetModel.h
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

#import "DUXBetaStorageModule.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Data model for the DUXBetaCaptureBaseWidget used to define
 * the underlying logic and communication.
*/
@interface DUXBetaCaptureBaseWidgetModel : DUXBetaBaseWidgetModel

@property (nonatomic, strong, readonly) DUXBetaStorageModule *storageModule;

@property (nonatomic, assign, readonly) BOOL isCameraConnected;

/**
 *  Available recording time from the camera
 */
@property (nonatomic, assign, readwrite) NSUInteger cameraIndex;

/**
 *  Camera display name
 */
@property (nonatomic, strong, readonly) NSString *cameraDisplayName;

/**
 *  Initializes shoot photo widget model with the preferred index of the camera it will
 *  control
 */
- (instancetype)initWithPreferredCameraIndex:(NSUInteger)preferredCameraIndex NS_DESIGNATED_INITIALIZER;


@end

NS_ASSUME_NONNULL_END
