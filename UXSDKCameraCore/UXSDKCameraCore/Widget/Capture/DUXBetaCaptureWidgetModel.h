//
//  DUXBetaCaptureWidgetModel.h
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
#import <UXSDKCore/UXSDKCore-Swift.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The capture widget model abstracts away the non-UI DJI product-related logic of the capture widget
 */
@interface DUXBetaCaptureWidgetModel : DUXBetaBaseWidgetModel

/**
 *  The index of the camera the capture widget is talking to
 *  Set to 0 by default
 */
@property (nonatomic, assign, readwrite) NSUInteger cameraIndex;

/**
 *  The current mode of the camera
 */
@property (nonatomic, assign, readonly) DJICameraMode cameraMode;

/**
 *  Initialize the widget model and it's children widget models with the provided preferred camera index
 *  Calling init instead will initialize the instance with a preferredCameraIndex value of 0
 */
- (instancetype)initWithPreferredCameraIndex:(NSUInteger)preferredCameraIndex NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
