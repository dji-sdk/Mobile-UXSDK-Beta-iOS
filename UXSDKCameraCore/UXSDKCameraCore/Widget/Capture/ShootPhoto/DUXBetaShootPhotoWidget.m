//
//  DUXBetaShootPhotoWidget.m
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

#import "DUXBetaShootPhotoWidget.h"
#import "DUXBetaCameraStorageState.h"
#import "DUXBetaCameraPhotoState.h"
#import "DUXBetaShootPhotoWidgetModel.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>
#import <UXSDKCore/UIColor+DUXBetaColors.h>
#import <AVFoundation/AVFoundation.h>


@interface DUXBetaShootPhotoWidget ()

/**
 *  Widget model used by the shoot photo widget
 */
@property (nonatomic, strong) DUXBetaShootPhotoWidgetModel *widgetModel;

@property (nonatomic) NSMutableDictionary<NSString *, UIImage *> *shootModeImageMap;

@end

@implementation DUXBetaShootPhotoWidget

@dynamic widgetModel;

/*********************************************************************************/
#pragma mark - View Lifecycle
/*********************************************************************************/

- (instancetype)init {
    self = [super init];
    if (self) {
        [self instantiateProperties];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self instantiateProperties];
    }
    return self;
}

- (void)instantiateProperties {
    _photoModeTintColor = [UIColor uxsdk_darkGrayWhite25];
    _shootModeImageMap = [NSMutableDictionary new];
}

- (void)viewDidLoad {
    [self setupCaptureImages];
    [self setupShootModeImages];
    
    self.widgetModel = [[DUXBetaShootPhotoWidgetModel alloc] initWithPreferredCameraIndex:self.cameraIndex];
    [self.widgetModel setup];
    
    [super viewDidLoad];
    
    [self setupAudio];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateIsShooting), isShootingPhoto, isStoringPhoto);
    BindRKVOModel(self.widgetModel, @selector(updatePhotoState), cameraPhotoState);
    BindRKVOModel(self.widgetModel, @selector(updateCanStopShooting), canStopShootingPhoto);
    BindRKVOModel(self.widgetModel, @selector(updatePhotoVisibility), isProductConnected, storageModule.cameraStorageState);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

/*********************************************************************************/
#pragma mark - Layout Subviews
/*********************************************************************************/

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updatePhotoState];
}

/*********************************************************************************/
#pragma mark - UI Setup
/*********************************************************************************/

- (void)setupUI {
    [super setupUI];
    
    self.photoModeView = [[UIImageView alloc] init];
    self.photoModeView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoModeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoModeView.image = [self photoModeImage];
    self.photoModeView.tintColor = self.photoModeTintColor;
    
    [self.view addSubview:self.photoModeView];
    [self.view bringSubviewToFront:self.storageImageView];
    
    [self.photoModeView.centerXAnchor constraintEqualToAnchor:self.centerImageView.centerXAnchor].active = YES;
    [self.photoModeView.centerYAnchor constraintEqualToAnchor:self.centerImageView.centerYAnchor].active = YES;
    [self.photoModeView.widthAnchor constraintEqualToAnchor:self.centerImageView.widthAnchor multiplier:0.45].active = YES;
    [self.photoModeView.heightAnchor constraintEqualToAnchor:self.centerImageView.heightAnchor multiplier:0.45].active = YES;
    
    __weak typeof(self) weakSelf = self;
    
    self.action = ^() {
        if (weakSelf.widgetModel.isShootingPhoto) {
            [weakSelf.widgetModel stopShootPhotoWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                }
            }];
        } else {
            [weakSelf.widgetModel startShootPhotoWithCompletion:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                }
            }];
        }
    };
}

- (void)setupAudio {
    // Audio Setup
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                     withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                           error:&error];
    if (error) {
        NSLog(@"Error configuring the Audio Session %@", error);
    }
    
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"Error Activating the Audio Session %@", error);
    }
}

- (void)setupCaptureImages {
    self.outerRingImage = [UIImage duxbeta_imageWithAssetNamed:@"CaptureRingAnimation" forClass:[self class]];
    self.borderEnabledImage = [UIImage duxbeta_imageWithAssetNamed:@"CaptureBorderEnabled" forClass:[self class]];
    self.borderDisabledImage = [UIImage duxbeta_imageWithAssetNamed:@"CaptureBorderDisabled" forClass:[self class]];
    self.borderPressedImage = [UIImage duxbeta_imageWithAssetNamed:@"CaptureBorderPressed" forClass:[self class]];
    self.centerEnabledImage = [UIImage duxbeta_imageWithAssetNamed:@"CaptureCenterEnabled" forClass:[self class]];
    self.centerDisabledImage = [UIImage duxbeta_imageWithAssetNamed:@"CaptureCenterDisabled" forClass:[self class]];
    self.centerPressedImage = [UIImage duxbeta_imageWithAssetNamed:@"CaptureCenterPressed" forClass:[self class]];
    
    self.stopIntervalEnabledImage = [UIImage duxbeta_imageWithAssetNamed:@"StopIntervalEnabled" forClass:[self class]];
    self.stopIntervalPressedImage = [UIImage duxbeta_imageWithAssetNamed:@"StopIntervalPressed" forClass:[self class]];
    self.stopIntervalDisabledImage = [UIImage duxbeta_imageWithAssetNamed:@"StopIntervalDisabled" forClass:[self class]];
}

- (void)setupShootModeImages {
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"HyperLight" forClass:[self class]] forShootMode:DJICameraShootPhotoModeHyperLight andCount:0];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"ShallowFocus" forClass:[self class]] forShootMode:DJICameraShootPhotoModeShallowFocus andCount:0];
    
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"HDRPhoto" forClass:[self class]] forShootMode:DJICameraShootPhotoModeHDR andCount:0];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"HDRPhoto" forClass:[self class]] forShootMode:DJICameraShootPhotoModeEHDR andCount:0];
    
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"BurstPhoto3" forClass:[self class]] forShootMode:DJICameraShootPhotoModeBurst andCount:DJICameraPhotoBurstCount3];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"BurstPhoto5" forClass:[self class]] forShootMode:DJICameraShootPhotoModeBurst andCount:DJICameraPhotoBurstCount5];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"BurstPhoto7" forClass:[self class]] forShootMode:DJICameraShootPhotoModeBurst andCount:DJICameraPhotoBurstCount7];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"BurstPhoto10" forClass:[self class]] forShootMode:DJICameraShootPhotoModeBurst andCount:DJICameraPhotoBurstCount10];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"BurstPhoto14" forClass:[self class]] forShootMode:DJICameraShootPhotoModeBurst andCount:DJICameraPhotoBurstCount14];
    
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"RawBurstPhoto3" forClass:[self class]] forShootMode:DJICameraShootPhotoModeRAWBurst andCount:DJICameraPhotoBurstCount3];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"RawBurstPhoto5" forClass:[self class]] forShootMode:DJICameraShootPhotoModeRAWBurst andCount:DJICameraPhotoBurstCount5];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"RawBurstPhoto7" forClass:[self class]] forShootMode:DJICameraShootPhotoModeRAWBurst andCount:DJICameraPhotoBurstCount7];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"RawBurstPhoto10" forClass:[self class]] forShootMode:DJICameraShootPhotoModeRAWBurst andCount:DJICameraPhotoBurstCount10];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"RawBurstPhoto14" forClass:[self class]] forShootMode:DJICameraShootPhotoModeRAWBurst andCount:DJICameraPhotoBurstCount14];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"RawBurstPhotoInfinity" forClass:[self class]] forShootMode:DJICameraShootPhotoModeRAWBurst andCount:DJICameraPhotoBurstCountContinuous];
    
    
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"AEBPhoto3" forClass:[self class]] forShootMode:DJICameraShootPhotoModeAEB andCount:DJICameraPhotoAEBCount3];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"AEBPhoto5" forClass:[self class]] forShootMode:DJICameraShootPhotoModeAEB andCount:DJICameraPhotoAEBCount5];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"AEBPhoto7" forClass:[self class]] forShootMode:DJICameraShootPhotoModeAEB andCount:DJICameraPhotoAEBCount7];
    
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"PanoramaPhoto1x3" forClass:[self class]] forShootMode:DJICameraShootPhotoModePanorama andCount:DJICameraPhotoPanoramaMode180];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"PanoramaPhoto3x1" forClass:[self class]] forShootMode:DJICameraShootPhotoModePanorama andCount:DJICameraPhotoPanoramaMode3x1];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"PanoramaPhoto3x3" forClass:[self class]] forShootMode:DJICameraShootPhotoModePanorama andCount:DJICameraPhotoPanoramaMode3x3];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"PanoramaPhotoGlobe" forClass:[self class]] forShootMode:DJICameraShootPhotoModePanorama andCount:DJICameraPhotoPanoramaModeSphere];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"PanoramaPhotoSuperResolution" forClass:[self class]] forShootMode:DJICameraShootPhotoModePanorama andCount:DJICameraPhotoPanoramaModeSuperResolution];
    
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhotoAuto" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:0];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhoto1s" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:1];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhoto2s" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:2];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhoto3s" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:3];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhoto4s" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:4];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhoto5s" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:5];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhoto7s" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:7];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhoto10s" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:10];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhoto15s" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:15];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhoto20s" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:20];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhoto30s" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:30];
    [self setImage:[UIImage duxbeta_imageWithAssetNamed:@"IntervalPhoto60s" forClass:[self class]] forShootMode:DJICameraShootPhotoModeInterval andCount:60];
}

- (UIImage *)centerImageForState:(DUXBetaCaptureActionState)state {
    switch (state) {
        case DUXBetaCaptureActionStateEnabled:
            return self.widgetModel.canStopShootingPhoto ? self.stopIntervalEnabledImage : self.centerEnabledImage;
        case DUXBetaCaptureActionStatePressed:
            return self.widgetModel.canStopShootingPhoto ? self.stopIntervalPressedImage : self.centerPressedImage;
        default:
            return self.widgetModel.canStopShootingPhoto ? self.stopIntervalDisabledImage : self.centerDisabledImage;
    }
}

#pragma mark - Widget Model Update Methods

- (void)updateIsShooting {
    if (self.widgetModel.isShootingPhoto || self.widgetModel.isStoringPhoto) {
        [self startProgressAnimation];
    } else {
        [self stopProgressAnimation];
    }
}

- (void)updatePhotoState {
    self.photoModeView.image = [[self photoModeImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)updateCanStopShooting {
    self.photoModeView.hidden = self.widgetModel.canStopShootingPhoto;
    
    [self updateUI];
}

- (void)updatePhotoVisibility {
    self.photoModeView.hidden = !self.storageImageView.hidden || self.widgetModel.canStopShootingPhoto;
}

#pragma mark - Image Customization Methods

- (NSString *)modeKey:(DJICameraShootPhotoMode)shootMode andCount:(NSUInteger)count {
    return [NSString stringWithFormat:@"%ld %ld", (long)shootMode, (long)count];
}

- (void)setImage:(UIImage *)image forShootMode:(DJICameraShootPhotoMode)shootMode andCount:(NSUInteger)count {
    NSString *key = [self modeKey:shootMode andCount:count];
    self.shootModeImageMap[key] = image;
    
    [self updatePhotoState];
}

- (UIImage *)getImageForShootMode:(DJICameraShootPhotoMode)shootMode andCount:(NSUInteger)count {
    NSString *key = [self modeKey:shootMode andCount:count];
    return self.shootModeImageMap[key];
}

- (nullable UIImage *)photoModeImage {
    return [self getImageForShootMode:self.widgetModel.cameraPhotoState.shootPhotoMode andCount:self.widgetModel.cameraPhotoState.count];
}

#pragma mark - Animation Methods

- (void)startProgressAnimation {
    //Start animation only if there's an animation active
    CABasicAnimation *rotationAnimation = [self.outerRingImageView.layer animationForKey:@"rotation"];
    if (rotationAnimation != nil) {
        return;
    }
    
    self.state = DUXBetaCaptureActionStatePressed;
    self.outerRingImageView.hidden = NO;
    self.borderImageView.hidden = YES;
    
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.fromValue = @(0.0);
    rotationAnimation.toValue = @(-M_PI * 2.0);
    [self.outerRingImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

- (void)stopProgressAnimation {
    //Stop animation only if there's an animation active
    CABasicAnimation *rotationAnimation = [self.outerRingImageView.layer animationForKey:@"rotation"];
    if (rotationAnimation == nil) {
        return;
    }
    
    self.state = DUXBetaCaptureActionStateEnabled;
    
    self.borderImageView.hidden = NO;
    self.outerRingImageView.hidden = YES;
    [self.outerRingImageView.layer removeAnimationForKey:@"rotation"];
}

@end
