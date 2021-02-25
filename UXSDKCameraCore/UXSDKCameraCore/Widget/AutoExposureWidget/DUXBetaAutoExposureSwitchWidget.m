//
//  DUXBetaAutoExposureSwitchWidget.m
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

#import "DUXBetaAutoExposureSwitchWidget.h"
#import "DUXBetaAutoExposureSwitchWidgetModel.h"
#import <UXSDKCore/UIImage+DUXBetaAssets.h>
#import <UXSDKCore/UIFont+DUXBetaFonts.h>
#import <UXSDKCore/UIColor+DUXBetaColors.h>

static const CGSize kDesignSize = {35.0, 35.0};
static const CGFloat kDesignBorderThickness = 0.5;
static const CGRect kDesignLockImageRect = {4.0, 11.5, 7.0, 10.0};
static const CGFloat kDesignAELabelFontSize = 12.0;
static const CGFloat kDesignLeading = 5.0;
static const CGFloat kDesignMargin = 3.0;

@interface DUXBetaAutoExposureSwitchWidget ()

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UILabel *aeLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSLayoutConstraint *imageLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *imageLabelSpaceConstraint;

@end

@implementation DUXBetaAutoExposureSwitchWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _lockColor = [UIColor uxsdk_whiteColor];
        _unlockColor = [UIColor uxsdk_disabledGrayWhite58];
        self.lockImage = [UIImage duxbeta_imageWithAssetNamed:@"AELock" forClass:[self class]];
        self.unlockImage = [UIImage duxbeta_imageWithAssetNamed:@"AEUnlock" forClass:[self class]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaAutoExposureSwitchWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), isLocked);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    self.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    
    self.view.layer.borderColor = self.borderColor.CGColor;
    self.view.layer.borderWidth = kDesignBorderThickness * self.view.frame.size.height / kDesignSize.height;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.lockImage];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView = imageView;
    [self.view addSubview:imageView];
    
    CGFloat imageToSelfRatio = kDesignLockImageRect.size.height / kDesignSize.height;
    CGFloat imageAspectRatio = self.lockImage.size.width / self.lockImage.size.height;
    
    [imageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:imageToSelfRatio].active = YES;
    [imageView.widthAnchor constraintEqualToAnchor:imageView.heightAnchor multiplier:imageAspectRatio].active = YES;
    
    [imageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    UILabel *aeLabel = [UILabel new];
    aeLabel.text = @"AE";
    aeLabel.textColor = self.lockColor;
    aeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.aeLabel = aeLabel;
    [self.view addSubview:aeLabel];
    
    [aeLabel.centerYAnchor constraintEqualToAnchor:imageView.centerYAnchor].active = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)updateUI {
    self.view.layer.borderWidth = kDesignBorderThickness * self.view.frame.size.height / kDesignSize.height;
    
    CGFloat adjustedFont = kDesignAELabelFontSize / kDesignSize.width * self.view.frame.size.width;
    self.aeLabel.font = [UIFont systemFontOfSize:adjustedFont];
    
    CGFloat adjustedLeading = kDesignLeading / kDesignSize.width * self.view.frame.size.width;
    if (self.imageLeadingConstraint) {
        self.imageLeadingConstraint.active = NO;
    }
    self.imageLeadingConstraint = [self.imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:adjustedLeading];
    self.imageLeadingConstraint.active = YES;
    
    CGFloat adjustedMargin = kDesignMargin / kDesignSize.width * self.view.frame.size.width;
    if (self.imageLabelSpaceConstraint) {
        self.imageLabelSpaceConstraint.active = NO;
    }
    self.imageLabelSpaceConstraint = [self.aeLabel.leadingAnchor constraintEqualToAnchor:self.imageView.trailingAnchor constant:adjustedMargin];
    self.imageLabelSpaceConstraint.active = YES;
    
    if (self.widgetModel.isLocked == YES) {
        self.aeLabel.textColor = self.lockColor;
        self.imageView.image = self.lockImage;
    } else {
        self.aeLabel.textColor = self.unlockColor;
        self.imageView.image = self.unlockImage;
    }
}

- (void)setPreferredCameraIndex:(NSUInteger)preferredCameraIndex {
    _preferredCameraIndex = preferredCameraIndex;
    self.widgetModel.preferredCameraIndex = preferredCameraIndex;
}

- (void)onTapGesture {
    [self.widgetModel toggleLockedState];
}

- (void)setLockColor:(UIColor *)lockColor {
    _lockColor = lockColor;
    [self updateUI];
}

- (void)setLockImage:(UIImage *)lockImage {
    _lockImage = lockImage;
    [self updateUI];
}

- (void)setUnlockColor:(UIColor *)unlockColor {
    _unlockColor = unlockColor;
    [self updateUI];
}

- (void)setUnlockImage:(UIImage *)unlockImage {
    _unlockImage = unlockImage;
    [self updateUI];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
