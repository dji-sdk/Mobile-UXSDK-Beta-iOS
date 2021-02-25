//
//  DUXBetaShootPhotoWidget.h
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

#import "DUXBetaCaptureBaseWidget.h"


NS_ASSUME_NONNULL_BEGIN

/**
 *  Widget for controlling the photo capture of the camera
 */
@interface DUXBetaShootPhotoWidget : DUXBetaCaptureBaseWidget

@property (nonatomic, strong) UIImage *stopIntervalEnabledImage;
@property (nonatomic, strong) UIImage *stopIntervalPressedImage;
@property (nonatomic, strong) UIImage *stopIntervalDisabledImage;

@property (nonatomic, strong) UIColor *photoModeTintColor;

/**
 *  Overlay icon representing the current photo mode of the camera
 */
@property (nonatomic, strong) UIImageView *photoModeView;


- (void)setImage:(UIImage *)image forShootMode:(DJICameraShootPhotoMode)shootMode andCount:(NSUInteger)count;
- (UIImage *)getImageForShootMode:(DJICameraShootPhotoMode)shootMode andCount:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
