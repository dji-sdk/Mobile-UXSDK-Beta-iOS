//
//  DUXBetaCaptureBaseWidget.m
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

#import <UXSDKCore/DUXBetaStateChangeBroadcaster.h>
#import <UXSDKCore/UIImage+DUXBetaAssets.h>
#import <UXSDKCameraCore/UXSDKCameraCore-Swift.h>

#import "DUXBetaCaptureBaseWidget.h"

@interface DUXBetaCaptureBaseWidget ()

@property (nonatomic) CGSize minWidgetSize;
@property (nonatomic, strong) NSLayoutConstraint *widgetAspectRatioConstraint;
@property (nonatomic) NSMutableDictionary<NSString *, UIImage *> *storageImageMap;

@end


@implementation DUXBetaCaptureBaseWidget

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = false;
    
    [self setupStorageImages];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Add RKVO Bindings
    BindRKVOModel(self.widgetModel, @selector(updateIsConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(updateStorageOverlayImage), isProductConnected, storageModule.cameraStorageState);
    
    [self updateUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setCameraIndex:(NSUInteger)preferredCameraIndex {
    _cameraIndex = preferredCameraIndex;
    self.widgetModel.cameraIndex = preferredCameraIndex;
}

#pragma mark - Helper Methods

- (void)setupUI {
    self.borderImageView = [[UIImageView alloc] init];
    self.borderImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.borderImageView.image = self.borderDisabledImage;
    
    self.centerImageView = [[UIImageView alloc] init];
    self.centerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.centerImageView.image = self.centerDisabledImage;
    
    self.storageImageView = [[UIImageView alloc] init];
    self.storageImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.outerRingImageView = [[UIImageView alloc] init];
    self.outerRingImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.outerRingImageView.image = self.outerRingImage;
    self.outerRingImageView.hidden = YES;
    
    [self.view addSubview:self.outerRingImageView];
    [self.view addSubview:self.borderImageView];
    [self.view addSubview:self.centerImageView];
    [self.view addSubview:self.storageImageView];
    
    [self.outerRingImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.outerRingImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.outerRingImageView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.outerRingImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    
    [self.borderImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.borderImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.borderImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.borderImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;

    [self.centerImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.centerImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.centerImageView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.centerImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    
    [self.storageImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.storageImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.storageImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.3].active = YES;
    [self.storageImageView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.3].active = YES;
    
    self.minWidgetSize = self.borderDisabledImage.size;
    self.widgetAspectRatioConstraint = [self.view.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:self.widgetSizeHint.preferredAspectRatio];
    self.widgetAspectRatioConstraint.active = YES;
}

- (void)setupStorageImages {
    self.storageImageMap = [NSMutableDictionary new];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"SSDFull" forClass:[self class]] forStorageType:DUXBetaCaptureStorageTypeSSD andStorageState:DUXBetaCaptureStorageStateFull];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"SSDNone" forClass:[self class]] forStorageType:DUXBetaCaptureStorageTypeSSD andStorageState:DUXBetaCaptureStorageStateNotInserted];
    
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"SDCardSlow" forClass:[self class]] forStorageType:DUXBetaCaptureStorageTypeSDCard andStorageState:DUXBetaCaptureStorageStateSlow];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"SDCardFull" forClass:[self class]] forStorageType:DUXBetaCaptureStorageTypeSDCard andStorageState:DUXBetaCaptureStorageStateFull];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"SDCardNone" forClass:[self class]] forStorageType:DUXBetaCaptureStorageTypeSDCard andStorageState:DUXBetaCaptureStorageStateNotInserted];
    
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"InternalStorageSlow" forClass:[self class]] forStorageType:DUXBetaCaptureStorageTypeInternalStorage andStorageState:DUXBetaCaptureStorageStateSlow];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"InternalStorageFull" forClass:[self class]] forStorageType:DUXBetaCaptureStorageTypeInternalStorage andStorageState:DUXBetaCaptureStorageStateFull];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"InternalStorageNone" forClass:[self class]] forStorageType:DUXBetaCaptureStorageTypeInternalStorage andStorageState:DUXBetaCaptureStorageStateNotInserted];
}

- (void)updateUI {
    self.borderImageView.image = [self borderImageForState:self.state];
    [self.centerImageView setImage:[self centerImageForState:self.state] animated:YES];
}

- (void)setState:(DUXBetaCaptureActionState)state {
    _state = state;
    
    self.view.userInteractionEnabled = (state == DUXBetaCaptureActionStateEnabled);
    
    [self updateUI];
}

- (UIImage *)borderImageForState:(DUXBetaCaptureActionState)state {
    switch (state) {
        case DUXBetaCaptureActionStateEnabled:
            return self.borderEnabledImage;
        case DUXBetaCaptureActionStatePressed:
            return self.borderPressedImage;
        default:
            return self.borderDisabledImage;
    }
}

- (UIImage *)centerImageForState:(DUXBetaCaptureActionState)state {
    switch (state) {
        case DUXBetaCaptureActionStateEnabled:
            return self.centerEnabledImage;
        case DUXBetaCaptureActionStatePressed:
            return self.centerPressedImage;
        default:
            return self.centerDisabledImage;
    }
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {self.minWidgetSize.width / self.minWidgetSize.height, self.minWidgetSize.width, self.minWidgetSize.height};
    return hint;
}

#pragma mark - Image Customization Methods

- (NSString *)storageKey:(DUXBetaCaptureStorageType)type andState:(DUXBetaCaptureStorageState)state {
    return [NSString stringWithFormat:@"%ld %ld", (long)type, (long)state];
}

- (void)setImage:(UIImage *)image forStorageType:(DUXBetaCaptureStorageType)type andStorageState:(DUXBetaCaptureStorageState)state {
    NSString *key = [self storageKey:type andState:state];
    self.storageImageMap[key] = image;
}

- (UIImage *)getImageForSorageType:(DUXBetaCaptureStorageType)type andStorageState:(DUXBetaCaptureStorageState)state {
    NSString *key = [self storageKey:type andState:state];
    return self.storageImageMap[key];
}

#pragma mark - Widget Model Update Methods

- (void)updateIsConnected {
    //Forward the model change
    [DUXBetaStateChangeBroadcaster send:[CaptureBaseModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)updateStorageOverlayImage {
    if (!self.widgetModel.isProductConnected || !self.widgetModel.isCameraConnected) {
        self.storageImageView.hidden = YES;
        self.state = DUXBetaCaptureActionStateDisabled;
    } else {
        
        DUXBetaCameraStorageState *cameraStorageState = self.widgetModel.storageModule.cameraStorageState;
        UIImage *image = [self getImageForSorageType:cameraStorageState.type andStorageState:cameraStorageState.state];

        if (image) {
            self.storageImageView.image = image;
            self.storageImageView.hidden = NO;
            self.state = DUXBetaCaptureActionStateDisabled;
        } else {
            self.storageImageView.hidden = YES;
            self.state = DUXBetaCaptureActionStateEnabled;
        }
    }
}

/*********************************************************************************/
#pragma mark - Event Handling
/*********************************************************************************/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    self.state = DUXBetaCaptureActionStatePressed;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    self.state = DUXBetaCaptureActionStateEnabled;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    self.state = DUXBetaCaptureActionStateEnabled;
    
    //Forward widget tap
    [DUXBetaStateChangeBroadcaster send:[CaptureBaseUIState widgetTapped]];
    
    if (self.action) {
        self.action();
    }
}

@end

#pragma mark - Hooks

@implementation CaptureBaseModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[CaptureBaseModelState alloc] initWithKey:@"productConnected" number:@(isConnected)];
}

@end


@implementation CaptureBaseUIState

+ (instancetype)widgetTapped {
    return [[CaptureBaseUIState alloc] initWithKey:@"widgetTapped" number:@(0)];
}

@end
