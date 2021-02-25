//
//  DUXBetaFocusTargetWidget.m
//  DJIUXSDK
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

#import "DUXBetaFocusTargetWidget.h"

#import <UXSDKCore/UIImage+DUXBetaAssets.h>

static const CGSize kDesignSize = {50.0,50.0};

@interface DUXBetaFocusTargetWidget()

@property (strong, nonatomic) UIImageView *focusImageView;
@property (strong, nonatomic) NSLayoutConstraint *focusImageWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *focusImageHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *focusImageViewTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *focusImageViewBottomConstraint;

@end

@implementation DUXBetaFocusTargetWidget

@synthesize manualFocusImage = _manualFocusImage;
@synthesize autoFocusImage = _autoFocusImage;

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaFocusTargetWidgetModel alloc] init];
    [self.widgetModel setup];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BindRKVOModel(self.widgetModel, @selector(updateUI), focusMode, isAssistantWorking, focusStatus);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    //setup imageview, we use one image and will just swap the asset depending on the state.
    self.focusImageView = [[UIImageView alloc] initWithImage:self.manualFocusImage];
    self.focusImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.focusImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.focusImageView];
    [self.focusImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    self.focusImageViewTopConstraint = [self.focusImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor];
    self.focusImageViewTopConstraint.active = YES;
    self.focusImageHeightConstraint = [self.focusImageView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor];
    self.focusImageHeightConstraint.active = YES;
    self.focusImageWidthConstraint = [self.focusImageView.widthAnchor constraintEqualToAnchor:self.focusImageView.heightAnchor];
    self.focusImageWidthConstraint.active = YES;
    self.focusImageViewBottomConstraint = [self.focusImageView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    self.focusImageViewBottomConstraint.active = YES;
}

- (void)updateUI {
    //only perform animations if focus mode is auto.
    if (self.widgetModel.focusMode == DJICameraFocusModeAuto || self.widgetModel.focusMode == DJICameraFocusModeAFC) {
        if(self.widgetModel.focusStatus == DJICameraFocusStatusIdle) {
            //do nothing for right now
        } else if (self.widgetModel.focusStatus == DJICameraFocusStatusFocusing) {
            NSLog(@"start animations");
            [self startAutoFocusAnimation];
        } else if (self.widgetModel.focusStatus == DJICameraFocusStatusSuccessful) {
            //stop animation and play sound
            [self stopAutoFocusAnimationWithSuccess:YES];
            NSLog(@"stop animations");
        } else if (self.widgetModel.focusStatus == DJICameraFocusStatusFailed) {
            //stop animation don't play sound
            [self stopAutoFocusAnimationWithSuccess:NO];
        } else {
            //don't do anything state is unknown
        }
    }

    if(self.widgetModel.focusMode == DJICameraFocusModeManual) {
        [self.focusImageView setImage:self.manualFocusImage];
    } else if (self.widgetModel.focusMode == DJICameraFocusModeAFC || self.widgetModel.focusMode == DJICameraFocusModeAuto) {
        [self.focusImageView setImage:self.autoFocusImage];
    } else {
        //State is unknown
    }
}

- (void)startAutoFocusAnimation {
    [UIView animateKeyframesWithDuration:0.8 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            self.focusImageHeightConstraint.constant -= 10;
            self.focusImageWidthConstraint.constant -= 10;
            self.focusImageViewTopConstraint.constant += 10;
            [self.view layoutIfNeeded];
        }];

        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.3 animations:^{
            self.focusImageHeightConstraint.constant += 10;
            self.focusImageWidthConstraint.constant += 10;
            self.focusImageViewTopConstraint.constant -=10;
            [self.view layoutIfNeeded];
        }];
    } completion:nil];
}

- (void)stopAutoFocusAnimationWithSuccess:(BOOL)success {
    if (success) {
        //can't find the sounds file but we would need to play it here.
    }
    [self.focusImageView.layer removeAllAnimations];
}

- (UIImage *)manualFocusImage {
    if (_manualFocusImage) {
        return _manualFocusImage;
    }
    return [UIImage duxbeta_imageWithAssetNamed:@"ManualFocus" forClass:[self class]];
}

- (UIImage *)autoFocusImage {
    if (_autoFocusImage) {
        return _autoFocusImage;
    }
    return [UIImage duxbeta_imageWithAssetNamed:@"AutoFocus" forClass:[self class]];
}

- (void)setManualFocusImage:(UIImage *)manualFocusImage {
    _manualFocusImage = manualFocusImage;
    [self updateUI];
}

- (void)setAutoFocusImage:(UIImage *)autoFocusImage {
    _autoFocusImage = autoFocusImage;
    [self updateUI];
}

- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

@end
