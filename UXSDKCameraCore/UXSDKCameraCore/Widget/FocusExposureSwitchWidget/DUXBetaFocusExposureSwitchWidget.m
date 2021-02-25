//
//  DUXBetaFocusExposureSwitchWidget.m
//  UXSDKCameraCore
//
//  MIT License
//  
//  Copyright © 2018-2020 DJI
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

#import "DUXBetaFocusExposureSwitchWidget.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>
#import <UXSDKCore/UIFont+DUXBetaFonts.h>


static const CGSize kDesignSize = {35.0, 35.0};
static const CGSize kDesignExposureSize = {23.0, 23.0};
static const CGFloat kDesignBorderThickness = 0.5;

@interface DUXBetaFocusExposureSwitchWidget ()

@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation DUXBetaFocusExposureSwitchWidget

- (void)viewDidLoad {
    [super viewDidLoad];
    self.widgetModel = [[DUXBetaFocusExposureSwitchWidgetModel alloc] init];
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    self.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    self.view.layer.borderColor = self.borderColor.CGColor;
    self.view.layer.borderWidth = kDesignBorderThickness * self.view.frame.size.height / kDesignSize.height;

    UIImage *exposureImage = [UIImage duxbeta_imageWithAssetNamed:@"ExposureTool" forClass:[self class]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:exposureImage];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView = imageView;
    [self.view addSubview:imageView];
    
    CGFloat imageToSelfRatio = kDesignExposureSize.height / kDesignSize.height;
    CGSize exposureImageSize = exposureImage.size;
    CGFloat exposureAspectRatio = exposureImageSize.width / exposureImageSize.height;
    
    [imageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:imageToSelfRatio].active = YES;
    [imageView.widthAnchor constraintEqualToAnchor:imageView.heightAnchor multiplier:exposureAspectRatio].active = YES;
    [imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [imageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    [self.widgetModel setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), isAdjustableFocalPointSupported, focusMode, switchMode);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)updateUI {
    self.view.hidden = !self.widgetModel.isAdjustableFocalPointSupported;
    if (self.widgetModel.switchMode == DUXBetaExposureMode) {
        self.imageView.image = [UIImage duxbeta_imageWithAssetNamed:@"ExposureTool" forClass:[self class]];
    } else if (self.widgetModel.switchMode == DUXBetaFocusMode) {
        if (self.widgetModel.focusMode == DJICameraFocusModeAuto || self.widgetModel.focusMode == DJICameraFocusModeAFC) {
            self.imageView.image = [UIImage duxbeta_imageWithAssetNamed:@"FocusTool" forClass:[self class]];
        } else {
            self.imageView.image = [UIImage duxbeta_imageWithAssetNamed:@"ManualFocus" forClass:[self class]];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    __weak typeof(self) weakSelf = self;
    [super touchesEnded:touches withEvent:event];
    weakSelf.widgetModel.switchMode = weakSelf.widgetModel.switchMode == DUXBetaExposureMode ? DUXBetaFocusMode : DUXBetaExposureMode;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateUI];
    });
}

- (void)setPreferredCameraIndex:(NSUInteger)preferredCameraIndex {
    _preferredCameraIndex = preferredCameraIndex;
    self.widgetModel.preferredCameraIndex = preferredCameraIndex;
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
