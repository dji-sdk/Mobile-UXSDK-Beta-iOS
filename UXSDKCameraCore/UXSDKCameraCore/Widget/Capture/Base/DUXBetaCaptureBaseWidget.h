//
//  DUXBetaCaptureBaseWidget.h
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

#import <UXSDKCore/DUXBetaBaseWidget.h>
#import <UXSDKCore/DUXBetaStateChangeBaseData.h>

#import "DUXBetaCaptureBaseWidgetModel.h"
#import "DUXBetaCameraStorageState.h"

/**
 *  Block that will run when the shoot photo widget is tapped
 */
typedef void (^DUXBetacaptureWidgetActionBlock)(void);

/**
 *  Enumeration of possible actionable states of the widget.
 */
typedef NS_ENUM (NSInteger, DUXBetaCaptureActionState) {
    /**
     * When the user interaction is disabled
     */
    DUXBetaCaptureActionStateDisabled,
    /**
     * When the user interaction is enabled
     */
    DUXBetaCaptureActionStateEnabled,
    /**
     * When a tap is performed
     */
    DUXBetaCaptureActionStatePressed
};


/**
 *  Widget for controlling the photo capture of the camera
 */
@interface DUXBetaCaptureBaseWidget : DUXBetaBaseWidget

@property (nonatomic, assign) DUXBetaCaptureActionState state;

@property (nonatomic, strong) UIImage *outerRingImage;

@property (nonatomic, strong) UIImage *borderEnabledImage;
@property (nonatomic, strong) UIImage *borderDisabledImage;
@property (nonatomic, strong) UIImage *borderPressedImage;

@property (nonatomic, strong) UIImage *centerEnabledImage;
@property (nonatomic, strong) UIImage *centerDisabledImage;
@property (nonatomic, strong) UIImage *centerPressedImage;
 
/**
 *  Border image, by default a gray scale circular border
 */
@property (nonatomic, strong) UIImageView *borderImageView;

/**
 *  Center image, by default a gray circle
 */
@property (nonatomic, strong) UIImageView *centerImageView;

/**
 *  Storage status overlay icon
 */
@property (nonatomic, strong) UIImageView *storageImageView;

/**
 *  View displayed by widget when camera is taking photo
 */
@property (nonatomic, strong) UIImageView *outerRingImageView;

/**
 *  Index of the camera the widget controls
 */
@property (nonatomic, assign) NSUInteger cameraIndex;

/**
 *  The widget model that contains the underlying logic and communication.
*/
@property (nonatomic, strong) DUXBetaCaptureBaseWidgetModel *widgetModel;

/**
 *  Widget action block, executed when the widget is tapped
 */
@property (nonatomic, copy) DUXBetacaptureWidgetActionBlock action;

- (void)setupUI;
- (void)updateUI;
- (UIImage *)borderImageForState:(DUXBetaCaptureActionState)state;
- (UIImage *)centerImageForState:(DUXBetaCaptureActionState)state;

- (void)setImage:(UIImage *)image forStorageType:(DUXBetaCaptureStorageType)type andStorageState:(DUXBetaCaptureStorageState)state;
- (UIImage *)getImageForSorageType:(DUXBetaCaptureStorageType)type andStorageState:(DUXBetaCaptureStorageState)state;

- (void)updateStorageOverlayImage;

@end

/**
 * CaptureBaseModelState contains the hooks for model changes in the DUXBetaCaptureBaseWidget.
 * It implements the hooks:
 *
 * Key: productConnected    Type: NSNumber - Sends a boolean value as an NSNumber indicating the connected state of
 *                                           the device when it changes.
*/
@interface CaptureBaseModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;

@end

/**
 * CaptureBaseUIState contains the hooks for UI changes in the widget class DUXBetaCaptureBaseWidget.
 * It implements the hooks:
 *
 * Key: widgetTapped         Type: NSNumber - Sends a boolean YES as an NSNumber when the widget is tapped.
*/
@interface CaptureBaseUIState : DUXBetaStateChangeBaseData

+ (instancetype)widgetTapped;

@end
